Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 164F26B0032
	for <linux-mm@kvack.org>; Fri,  8 May 2015 05:57:07 -0400 (EDT)
Received: by pdbqd1 with SMTP id qd1so74689817pdb.2
        for <linux-mm@kvack.org>; Fri, 08 May 2015 02:57:06 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id la15si6484112pab.99.2015.05.08.02.56.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 May 2015 02:56:20 -0700 (PDT)
Date: Fri, 8 May 2015 12:56:04 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH v3 3/3] proc: add kpageidle file
Message-ID: <20150508095604.GO31732@esperanza>
References: <cover.1430217477.git.vdavydov@parallels.com>
 <4c24a6bf2c9711dd4dbb72a43a16eba6867527b7.1430217477.git.vdavydov@parallels.com>
 <20150429043536.GB11486@blaptop>
 <20150429091248.GD1694@esperanza>
 <20150430082531.GD21771@blaptop>
 <20150430145055.GB17640@esperanza>
 <20150504031722.GA2768@blaptop>
 <20150504094938.GB4197@esperanza>
 <20150504105459.GA19384@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150504105459.GA19384@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Christoph Lameter <cl@linux-foundation.org>, "Paul E.
 McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Mon, May 04, 2015 at 07:54:59PM +0900, Minchan Kim wrote:
> So, I guess once below compiler optimization happens in __page_set_anon_rmap,
> it could be corrupt in page_refernced.
> 
> __page_set_anon_rmap:
>         page->mapping = (struct address_space *) anon_vma;
>         page->mapping = (struct address_space *)((void *)page_mapping + PAGE_MAPPING_ANON);
> 
> Because page_referenced checks it with PageAnon which has no memory barrier.
> So if above compiler optimization happens, page_referenced can pass the anon
> page in rmap_walk_file, not ramp_walk_anon. It's my theory. :)

FWIW

If such splits were possible, we would have bugs all over the kernel
IMO. An example is do_wp_page() vs shrink_active_list(). In do_wp_page()
we can call page_move_anon_rmap(), which sets page->mapping in exactly
the same fashion as above-mentioned __page_set_anon_rmap():

	anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
	page->mapping = (struct address_space *) anon_vma;

The page in question may be on an LRU list, because nowhere in
do_wp_page() we remove it from the list, neither do we take any LRU
related locks. The page is locked, that's true, but shrink_active_list()
calls page_referenced() on an unlocked page, so according to your logic
they can race with the latter receiving a page with page->mapping equal
to anon_vma w/o PAGE_MAPPING_ANON bit set:

CPU0				CPU1
----				----
do_wp_page			shrink_active_list
 lock_page			 page_referenced
				  PageAnon->yes, so skip trylock_page
 page_move_anon_rmap
  page->mapping = anon_vma
				  rmap_walk
				   PageAnon->no
				   rmap_walk_file
				    BUG
  page->mapping = page->mapping+PAGE_MAPPING_ANON

However, this does not happen.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
