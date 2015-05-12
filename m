Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id AFD606B0038
	for <linux-mm@kvack.org>; Tue, 12 May 2015 05:31:50 -0400 (EDT)
Received: by pdbnk13 with SMTP id nk13so2463482pdb.0
        for <linux-mm@kvack.org>; Tue, 12 May 2015 02:31:50 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id cg10si21720564pdb.135.2015.05.12.02.31.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 May 2015 02:31:49 -0700 (PDT)
Date: Tue, 12 May 2015 12:31:38 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [RFC] rmap: fix "race" between do_wp_page and shrink_active_list
Message-ID: <20150512093137.GD17628@esperanza>
References: <1431330677-24476-1-git-send-email-vdavydov@parallels.com>
 <20150511142402.GJ6776@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150511142402.GJ6776@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Christoph Lameter <cl@linux.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, May 11, 2015 at 07:24:02AM -0700, Paul E. McKenney wrote:
> On Mon, May 11, 2015 at 10:51:17AM +0300, Vladimir Davydov wrote:
> > Hi,
> > 
> > I've been arguing with Minchan for a while about whether store-tearing
> > is possible while setting page->mapping in __page_set_anon_rmap and
> > friends, see
> > 
> >   http://thread.gmane.org/gmane.linux.kernel.mm/131949/focus=132132
> > 
> > This patch is intended to draw attention to this discussion. It fixes a
> > race that could happen if store-tearing were possible. The race is as
> > follows.
> > 
> > In do_wp_page() we can call page_move_anon_rmap(), which sets
> > page->mapping as follows:
> > 
> >         anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
> >         page->mapping = (struct address_space *) anon_vma;
> > 
> > The page in question may be on an LRU list, because nowhere in
> > do_wp_page() we remove it from the list, neither do we take any LRU
> > related locks. Although the page is locked, shrink_active_list() can
> > still call page_referenced() on it concurrently, because the latter does
> > not require an anonymous page to be locked.
> > 
> > If store tearing described in the thread were possible, we could face
> > the following race resulting in kernel panic:
> > 
> >   CPU0                          CPU1
> >   ----                          ----
> >   do_wp_page                    shrink_active_list
> >    lock_page                     page_referenced
> >                                   PageAnon->yes, so skip trylock_page
> >    page_move_anon_rmap
> >     page->mapping = anon_vma
> >                                   rmap_walk
> >                                    PageAnon->no
> >                                    rmap_walk_file
> >                                     BUG
> >     page->mapping += PAGE_MAPPING_ANON
> > 
> > This patch fixes this race by explicitly forbidding the compiler to
> > split page->mapping store in __page_set_anon_rmap() and friends and load
> > in PageAnon() with the aid of WRITE/READ_ONCE.
> > 
> > Personally, I don't believe that this can ever happen on any sane
> > compiler, because such an "optimization" would only result in two stores
> > vs one (note, anon_vma is not a constant), but since I can be mistaken I
> > would like to hear from synchronization experts what they think about
> > it.
> 
> An example "insane" compiler might notice that the value set cannot be
> safely observed without multiple CPUs accessing that variable at the
> same time.  A paper entitled "No Sane Compiler Would Optimize Atomics"
> has some examples:
> 
> 	http://www.open-std.org/jtc1/sc22/wg21/docs/papers/2015/n4455.html
> 
> If this paper doesn't scare you, then you didn't read it carefully enough.
> And yes, I did give the author a very hard time about the need to suppress
> some of these optimizations in order to correctly compile old code, and
> will continue to do so.  However, a READ_ONCE() would be a most excellent
> and very cheap way to future-proof this code, and is highly recommended.

Really interesting paper (although scary :-). I think I'm now convinced
that a compiler may be really wicked at times. Thank you for sharing the
link.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
