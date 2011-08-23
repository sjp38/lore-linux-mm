Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 96F036B016C
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 12:45:27 -0400 (EDT)
Received: by gxk23 with SMTP id 23so287461gxk.14
        for <linux-mm@kvack.org>; Tue, 23 Aug 2011 09:45:25 -0700 (PDT)
Date: Wed, 24 Aug 2011 01:45:15 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH] thp: tail page refcounting fix
Message-ID: <20110823164515.GA2653@barrios-desktop>
References: <1313740111-27446-1-git-send-email-walken@google.com>
 <20110822213347.GF2507@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110822213347.GF2507@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>

On Mon, Aug 22, 2011 at 11:33:47PM +0200, Andrea Arcangeli wrote:
> Hi Michal,
> 
> I had proper time today to think about this issue and focusing more on
> what the problem really is I think I found a simpler way to fix it. I
> also found another maybe even smaller race in direct-io which I hope
> this fixes too.
> 
> Fixing this was already in my top priority, but I wanted to obtain
> proof that the knumad driving the scheduler was working as well as
> hard numa bindings before KVMForum.
> 
> So this solution:
> 
> 1) should allow the working set estimation code to keep doing its
> get_page_unless_zero() without any change (you'll still have to modify
> it to check if you got a THP page etc... but you won't risk to get any
> tail page anymore). Maybe it still needs some non trivial thought
> about the changes but not anymore about tail pages refcounting screwups.
> 
> 2) no change to all existing get_page_unless_zero() is required, so
> this should fix the radix tree speculative page lookup too.
> 
> 3) no RCU new feature is needed

Nice goal.

> 
> 4) get_page was actually called by direct-io as my debug
> instrumentation I wrote to test these changes noticed it so I fixed
> that too

Nice catch.

> 
> 3.1.0-rc for me will crash at boot, I think it's broken and it doesn't
> boot unless one has an initrd which I never have so I did all testing
> on 3.0.0 and the patch is against that too.
> 
> I'd like if you could review, it's still a bit too early to be sure it
> works but my torture testing is going on without much problems so far
> (a loop of dd if=/dev/zero of=/dev/null bs=10M iflag=direct plus heavy
> swapping of THP splitting in a loop and KVM).
> 
> ===
> Subject: thp: tail page refcounting fix
> 
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> Michel while working on the working set estimation code, noticed that calling
> get_page_unless_zero() on a random pfn_to_page(random_pfn) wasn't safe, if the
> pfn ended up being a tail page of a transparent hugepage under splitting by
> __split_huge_page_refcount(). He then found the problem could also
> theoretically materialize with page_cache_get_speculative() during the
> speculative radix tree lookups that uses get_page_unless_zero() in SMP if the
> radix tree page is freed and reallocated and get_user_pages is called on it
> before page_cache_get_speculative has a chance to call get_page_unless_zero().
> 
> So the best way to fix the problem is to keep page_tail->_count zero at all
> times. This will guarantee that get_page_unless_zero() can never succeed on any
> tail page. page_tail->_mapcount is guaranteed zero and is unused for all tail
> pages of a compound page, so we can simply account the tail page references
> there and transfer them to tail_page->_count in __split_huge_page_refcount() (in
> addition to the head_page->_mapcount).

Nice idea!

> 
> While debugging this s/_count/_mapcount/ change I also noticed get_page is
> called by direct-io.c on pages returned by get_user_pages. That wasn't entirely
> safe because the two atomic_inc in get_page weren't atomic. As opposed other
> get_user_page users like secondary-MMU page fault to establish the shadow
> pagetables would never call any superflous get_page after get_user_page
> returns. It's safer to make get_page universally safe for tail pages and to use
> get_page_foll() within follow_page (inside get_user_pages()). get_page_foll()
> is safe to do the refcounting for tail pages without taking any locks because
> it is run within PT lock protected critical sections (PT lock for pte and
> page_table_lock for pmd_trans_huge). The standard get_page() as invoked by
> direct-io instead will now take the compound_lock but still only for tail
> pages. The direct-io paths are usually I/O bound and the compound_lock is per
> THP so very finegrined, so there's no risk of scalability issues with it. A
> simple direct-io benchmarks with all lockdep prove locking and spinlock
> debugging infrastructure enabled shows identical performance and no overhead.
> So it's worth it. Ideally direct-io should stop calling get_page() on pages
> returned by get_user_pages(). The spinlock in get_page() is already optimized
> away for no-THP builds but doing get_page() on tail pages returned by GUP is
> generally a rare operation and usually only run in I/O paths.
> 
> This new refcounting on page_tail->_mapcount in addition to avoiding new RCU
> critical sections will also allow the working set estimation code to work
> without any further complexity associated to the tail page refcounting
> with THP.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> Reported-by: Michel Lespinasse <walken@google.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

The code looks good to me.

The nitpick is about naming 'foll'.
What does it mean? 'follow'?
If it is, I hope we use full name.
Regardless of renaming it, I am okay the patch.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
