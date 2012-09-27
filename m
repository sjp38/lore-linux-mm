Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id AD0B96B0044
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 21:40:07 -0400 (EDT)
Received: by pbbrq2 with SMTP id rq2so3098748pbb.14
        for <linux-mm@kvack.org>; Wed, 26 Sep 2012 18:40:07 -0700 (PDT)
Date: Wed, 26 Sep 2012 18:40:04 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch for-3.6] mm, thp: fix mapped pages avoiding unevictable
 list on mlock
In-Reply-To: <alpine.LSU.2.00.1209192021270.28543@eggly.anvils>
Message-ID: <alpine.DEB.2.00.1209261821380.7745@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1209191818490.7879@chino.kir.corp.google.com> <alpine.LSU.2.00.1209192021270.28543@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org

On Wed, 19 Sep 2012, Hugh Dickins wrote:

> Good catch, and the patch looks right to me, as far as it goes:
> but does it go far enough?
> 
> I hesitate because it looks as if the NR_MLOCK zone page state is
> maintained (with incs and decs) in ignorance of THP; so although
> you will be correcting the Unevictable kB with your mlock_vma_page(),
> the Mlocked kB just above it in /proc/meminfo would still be wrong?
> 

Indeed, NR_MLOCK is a separate problem with regard to thp and it's 
currently incremented once for every hugepage rather than HPAGE_PMD_NR.  
mlock_vma_page() needs to increment by hpage_nr_pages(page) like 
add_page_to_lru_list() does.

> I suppose I'm not sure whether this is material for late-3.6:
> surely it's not a fix for a recent regression?
> 

Ok, sounds good.  If there's no objection, I'd like to ask Andrew to apply 
this to -mm and remove the cc to stable@vger.kernel.org since the 
mlock_vma_page() problem above is separate and doesn't conflict with this 
code, so I'll send a followup patch to address that.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
