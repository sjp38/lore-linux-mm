Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 5F6E56B0002
	for <linux-mm@kvack.org>; Fri, 22 Mar 2013 02:01:16 -0400 (EDT)
Date: Fri, 22 Mar 2013 15:01:13 +0900
From: Minchan Kim <minchan.kim@lge.com>
Subject: Re: [RFC v7 00/11] Support vrange for anonymous page
Message-ID: <20130322060113.GA4802@blaptop>
References: <1363073915-25000-1-git-send-email-minchan@kernel.org>
 <514A6282.8020406@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <514A6282.8020406@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, Arun Sharma <asharma@fb.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Jason Evans <je@fb.com>, sanjay@google.com, Paul Turner <pjt@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Mar 20, 2013 at 06:29:38PM -0700, John Stultz wrote:
> On 03/12/2013 12:38 AM, Minchan Kim wrote:
> >First of all, let's define the term.
> > From now on, I'd like to call it as vrange(a.k.a volatile range)
> >for anonymous page. If you have a better name in mind, please suggest.
> >
> >This version is still *RFC* because it's just quick prototype so
> >it doesn't support THP/HugeTLB/KSM and even couldn't build on !x86.
> >Before further sorting out issues, I'd like to post current direction
> >and discuss it. Of course, I'd like to extend this discussion in
> >comming LSF/MM.
> >
> >In this version, I changed lots of thing, expecially removed vma-based
> >approach because it needs write-side lock for mmap_sem, which will drop
> >performance in mutli-threaded big SMP system, KOSAKI pointed out.
> >And vma-based approach is hard to meet requirement of new system call by
> >John Stultz's suggested semantic for consistent purged handling.
> >(http://linux-kernel.2935.n7.nabble.com/RFC-v5-0-8-Support-volatile-for-anonymous-range-tt575773.html#none)
> >
> >I tested this patchset with modified jemalloc allocator which was
> >leaded by Jason Evans(jemalloc author) who was interest in this feature
> >and was happy to port his allocator to use new system call.
> >Super Thanks Jason!
> >
> >The benchmark for test is ebizzy. It have been used for testing the
> >allocator performance so it's good for me. Again, thanks for recommending
> >the benchmark, Jason.
> >(http://people.freebsd.org/~kris/scaling/ebizzy.html)
> >
> >The result is good on my machine (12 CPU, 1.2GHz, DRAM 2G)
> >
> >	ebizzy -S 20
> >
> >jemalloc-vanilla: 52389 records/sec
> >jemalloc-vrange: 203414 records/sec
> >
> >	ebizzy -S 20 with background memory pressure
> >
> >jemalloc-vanilla: 40746 records/sec
> >jemalloc-vrange: 174910 records/sec
> >
> >And it's much improved on KVM virtual machine.
> >
> >This patchset is based on v3.9-rc2
> >
> >- What's the sys_vrange(addr, length, mode, behavior)?
> >
> >   It's a hint that user deliver to kernel so kernel can *discard*
> >   pages in a range anytime. mode is one of VRANGE_VOLATILE and
> >   VRANGE_NOVOLATILE. VRANGE_NOVOLATILE is memory pin operation so
> >   kernel coudn't discard any pages any more while VRANGE_VOLATILE
> >   is memory unpin opeartion so kernel can discard pages in vrange
> >   anytime. At a moment, behavior is one of VRANGE_FULL and VRANGE
> >   PARTIAL. VRANGE_FULL tell kernel that once kernel decide to
> >   discard page in a vrange, please, discard all of pages in a
> >   vrange selected by victim vrange. VRANGE_PARTIAL tell kernel
> >   that please discard of some pages in a vrange. But now I didn't
> >   implemented VRANGE_PARTIAL handling yet.
> 
> 
> So I'm very excited to see this new revision! Moving away from the
> VMA based approach I think is really necessary, since managing the
> volatile ranges on a per-mm basis really isn't going to work when we
> want shared volatile ranges between processes (such as the
> shmem/tmpfs case Android uses).
> 
> Just a few questions and observations from my initial playing around
> with the patch:
> 
> 1) So, I'm not sure I understand the benefit of VRANGE_PARTIAL. Why
> would VRANGE_PARTIAL be useful?

For exmaple, some process makes 64M vranges and now kernel needs 8M
pages to flee from memory pressure state. In this case, we don't need
to discard 64M all at once because if we discard only 8M page, the cost
of allocator is (8M/4K) * page(falut + allocation + zero-clearing)
while (64M/4K) * page(falut + allocation + zero-clearing), otherwise.

If it were temporal image extracted on some compressed format, it's not
easy to regenerate punched hole data from original source so it would
be better to discard all pages in the vrange, which will be very far
from memory reclaimer.

> 
> 2) I've got a trivial test program that I've used previously with
> ashmem & my earlier file based efforts that allocates 26megs of page
> aligned memory, and marks every other meg as volatile. Then it forks
> and the child generates a ton of memory pressure, causing pages to
> be purged (and the child killed by the OOM killer). Initially I
> didn't see my test purging any pages with your patches. The problem
> of course was the child's COW pages were not also marked volatile,
> so they could not be purged. Once I over-wrote the data in the
> child, breaking the COW links, the data in the parent was purged
> under pressure.  This is good, because it makes sure we don't purge
> cow pages if the volatility state isn't consistent, but it also
> brings up a few questions:
> 
>     - Should volatility be inherited on fork? If volatility is not
> inherited on fork(), that could cause some strange behavior if the
> data was purged prior to the fork, and also its not clear what the
> behavior of the child should be with regards to data that was
> volatile at fork time.  However, we also don't want strange behavior
> on exec if overwritten volatile pages were unexpectedly purged.

I don't know why we should inherit volatility to child at least, for
anon vrange. Because it's not proper way to share the data.
For data sharing for anonymous page, we should use shmem so the work
could be done when we work tmpfs work, I guess.

Currently, I implemented it to protect only COW pages.
If the data was purged prio to fork, the page should be never mapped
logically so child should see newly zero-cleared page if he try to access
the address. But you pointed out the bug, I should have handled it in
copy_one_pte. I guess the bug might cause OOM kill for parent by wrong
rss count. I will fix it.

I'm not sure it could be a good answer for your question because
I couldn't understand your question fully.
If my answer isn't enough, could you elaborate it more?

> 
>     - At this moment, maybe not having thought it through enough,
> I'm wondering if it makes sense to have  volatility inherited on
> fork, but cleared on exec? What are your thoughts here?  Its been
> awhile, so I'm not sure if that's consistent with my earlier
> comments on the topic.

I already said my opinion above.

> 
> 
> 3) Oddly, in my test case, once I changed the child to over-write
> the volatile range and break the COW pages, the OOM killer more
> frequently seems to favor killing the parent process, instead of the
> memory hogging child process. I need to spend some more time looking
> at this, and I know the OOM killer may go for the parent process
> sometimes, but it definitely happens more frequently then when the
> COW pages are not broken and no data is purged. Again, I need to dig
> in more here.

It should be a problem wrong RSS count.
Could you send test program? I will fix it if you don't have enough time.

> 
> 
> 4) One of the harder aspects I'm trying to get my head around is how
> your patches seem to use both the page list shrinkers
> (discard_vpage) to purge ranges when particular pages selected, and
> a zone shrinker (discard_vrange_pages) which manages its own lru of
> vranges. I get that this is one way to handle purging anonymous
> pages when we are on a swapless system, but the dual purging systems
> definitely make the code harder to follow. Would something like my

discard_vpage is for avoiding swapping out in direct reclaim path
when kswapd miss the page.

discard_vrange_pages is for handling volatile pages as top prioirty
prio to reclaim non-volatile pages.

I think it's very clear, NOT to understand. :)
And discard_vpage is basic core function to discard volatile page
so it could be used many places.

> earlier attempts at changing vmscan to shrink anonymous pages be
> simpler? Or is that just not going to fly w/ the mm folks?

There were many attempt at old. Could you point out?
> 
> 
> I'll continue working with the patches and try to get tmpfs support
> added here soon.
> 
> Also, attached is a simple cleanup patch that you might want to fold in.

Thanks, John!

> 
> thanks
> -john
> 

> >From 10f50e53ae706d61591b3247bc494b47a79f2b69 Mon Sep 17 00:00:00 2001
> From: John Stultz <john.stultz@linaro.org>
> Date: Wed, 20 Mar 2013 18:24:56 -0700
> Subject: [PATCH] vrange: Make various vrange.c local functions static
> 
> Make a number of local functions in vrange.c static.
> 
> Signed-off-by: John Stultz <john.stultz@linaro.org>
> ---
>  mm/vrange.c |   18 +++++++++---------
>  1 file changed, 9 insertions(+), 9 deletions(-)
> 
> diff --git a/mm/vrange.c b/mm/vrange.c
> index c0c5d50..d07884d 100644
> --- a/mm/vrange.c
> +++ b/mm/vrange.c
> @@ -45,7 +45,7 @@ static inline void __set_vrange(struct vrange *range,
>  	range->node.last = end_idx;
>  }
>  
> -void lru_add_vrange(struct vrange *vrange)
> +static void lru_add_vrange(struct vrange *vrange)
>  {
>  	spin_lock(&lru_lock);
>  	WARN_ON(!list_empty(&vrange->lru));
> @@ -53,7 +53,7 @@ void lru_add_vrange(struct vrange *vrange)
>  	spin_unlock(&lru_lock);
>  }
>  
> -void lru_remove_vrange(struct vrange *vrange)
> +static void lru_remove_vrange(struct vrange *vrange)
>  {
>  	spin_lock(&lru_lock);
>  	if (!list_empty(&vrange->lru))
> @@ -130,7 +130,7 @@ static inline void range_resize(struct rb_root *root,
>  	__add_range(range, root, mm);
>  }
>  
> -int add_vrange(struct mm_struct *mm,
> +static int add_vrange(struct mm_struct *mm,
>  			unsigned long start, unsigned long end)
>  {
>  	struct rb_root *root;
> @@ -172,7 +172,7 @@ out:
>  	return 0;
>  }
>  
> -int remove_vrange(struct mm_struct *mm,
> +static int remove_vrange(struct mm_struct *mm,
>  		unsigned long start, unsigned long end)
>  {
>  	struct rb_root *root;
> @@ -292,7 +292,7 @@ out:
>  	return ret;
>  }
>  
> -bool __vrange_address(struct mm_struct *mm,
> +static bool __vrange_address(struct mm_struct *mm,
>  			unsigned long start, unsigned long end)
>  {
>  	struct rb_root *root = &mm->v_rb;
> @@ -387,7 +387,7 @@ static void __vrange_purge(struct mm_struct *mm,
>  	}
>  }
>  
> -int try_to_discard_one(struct page *page, struct vm_area_struct *vma,
> +static int try_to_discard_one(struct page *page, struct vm_area_struct *vma,
>  		unsigned long address)
>  {
>  	struct mm_struct *mm = vma->vm_mm;
> @@ -602,7 +602,7 @@ static int vrange_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
>  
>  }
>  
> -unsigned int discard_vma_pages(struct zone *zone, struct mm_struct *mm,
> +static unsigned int discard_vma_pages(struct zone *zone, struct mm_struct *mm,
>  		struct vm_area_struct *vma, unsigned long start,
>  		unsigned long end, unsigned int nr_to_discard)
>  {
> @@ -669,7 +669,7 @@ out:
>   * Get next victim vrange from LRU and hold a vrange refcount
>   * and vrange->mm's refcount.
>   */
> -struct vrange *get_victim_vrange(void)
> +static struct vrange *get_victim_vrange(void)
>  {
>  	struct mm_struct *mm;
>  	struct vrange *vrange = NULL;
> @@ -711,7 +711,7 @@ struct vrange *get_victim_vrange(void)
>  	return vrange;
>  }
>  
> -void put_victim_range(struct vrange *vrange)
> +static void put_victim_range(struct vrange *vrange)
>  {
>  	put_vrange(vrange);
>  	mmdrop(vrange->mm);
> -- 
> 1.7.10.4
> 


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
