Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id C696B6B004D
	for <linux-mm@kvack.org>; Tue,  3 Jan 2012 21:56:48 -0500 (EST)
Received: by iacb35 with SMTP id b35so38459809iac.14
        for <linux-mm@kvack.org>; Tue, 03 Jan 2012 18:56:48 -0800 (PST)
Date: Tue, 3 Jan 2012 18:56:41 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 1/2] mm,mlock: drain pagevecs asynchronously
In-Reply-To: <1325403025-22688-1-git-send-email-kosaki.motohiro@gmail.com>
Message-ID: <alpine.LSU.2.00.1201031802170.1254@eggly.anvils>
References: <CAHGf_=qA3Pnb00n_smhJVKDDCDDr0d-a3E03Rrhnb-S4xK8_fQ@mail.gmail.com> <1325403025-22688-1-git-send-email-kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kosaki.motohiro@gmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <jweiner@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>

On Sun, 1 Jan 2012, kosaki.motohiro@gmail.com wrote:
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> Tao Ma reported current mlock is much slower than old 2.6.18 kernel. Because
> lru_add_drain_all() spent much time. The problem are two. 1) lru_add_drain_all()
> broadcast a worker thread to all cpus unconditionally. then, the performance
> penalty is increased in proportion to number of cpus. 2) lru_add_drain_all()
> wait the worker finished unnecessary. It makes bigger penalty.
> 
> This patch makes lru_add_drain_all_async() and changes mlock/mlockall use it.
> 
> Technical side note:
>  - has_pages_lru_pvecs() checks pagevecs locklessly. Of course, it's racy.
>    But it's no matter because asynchronous worker itself is also racy.
>    any lock can't close a race.
>  - Now, we drain pagevec at last of mlock instead of beginning. because
>    a page drain function (____pagevec_lru_add_fn) is PG_mlocked aware now.
>    Then it's safe and it close more race.
> 
> Without the patch:
> % time ./test_mlock -c 100000
> 
>  real   1m13.608s
>  user   0m0.204s
>  sys    0m40.115s
> 
>  i.e. 200usec per mlock
> 
> With the patch:
> % time ./test_mlock -c 100000
>  real    0m3.939s
>  user    0m0.060s
>  sys     0m3.868s
> 
>  i.e. 13usec per mlock

That's very nice; but it is an artificial test of the codepath you
have clearly speeded up, without any results for the codepaths you
have probably slowed down - I see Minchan is worried about that too.

> 
> test_mlock.c
> ==========================================
>  #include <stdio.h>
>  #include <stdlib.h>
>  #include <unistd.h>
>  #include <errno.h>
>  #include <time.h>
>  #include <sys/time.h>
>  #include <sys/mman.h>
> 
>  #define MM_SZ1 24
>  #define MM_SZ2 56
>  #define MM_SZ3 4168
> 
> void mlock_test()
> {
> 	char ptr1[MM_SZ1];
> 	char ptr2[MM_SZ2];
> 	char ptr3[MM_SZ3];
> 
> 	if(0 != mlock(ptr1, MM_SZ1) )
> 		perror("mlock MM_SZ1\n");
> 	if(0 != mlock(ptr2, MM_SZ2) )
> 		perror("mlock MM_SZ2\n");
> 	if(0 != mlock(ptr3, MM_SZ3) )
> 		perror("mlock MM_SZ3\n");
> 
> 	if(0 != munlock(ptr1, MM_SZ1) )
> 		perror("munlock MM_SZ1\n");
> 	if(0 != munlock(ptr2, MM_SZ2) )
> 		perror("munlock MM_SZ2\n");
> 	if(0 != munlock(ptr3, MM_SZ3) )
> 		perror("munlock MM_SZ3\n");
> }
> 
> int main(int argc, char *argv[])
> {
> 	int ret, opt;
> 	int i,cnt;
> 
> 	while((opt = getopt(argc, argv, "c:")) != -1 )
> 	{
> 		switch(opt){
> 		case 'c':
> 			cnt = atoi(optarg);
> 			break;
> 		default:
> 			printf("Usage: %s [-c count] arg...\n", argv[0]);
> 			exit(EXIT_FAILURE);
> 		}
> 	}
> 
> 	for(i = 0; i < cnt; i++)
> 		mlock_test();
> 
> 	return 0;
> }
> ===========================================
> 
> Reported-by: Tao Ma <boyu.mt@taobao.com>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Minchan Kim <minchan.kim@gmail.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: Johannes Weiner <jweiner@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---
>  include/linux/swap.h |    1 +
>  mm/mlock.c           |    7 +----
>  mm/swap.c            |   64 ++++++++++++++++++++++++++++++++++++++++++++++---
>  3 files changed, 63 insertions(+), 9 deletions(-)
> 
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 1e22e12..11ad301 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -223,6 +223,7 @@ extern void activate_page(struct page *);
>  extern void mark_page_accessed(struct page *);
>  extern void lru_add_drain(void);
>  extern int lru_add_drain_all(void);
> +extern void lru_add_drain_all_async(void);
>  extern void rotate_reclaimable_page(struct page *page);
>  extern void deactivate_page(struct page *page);
>  extern void swap_setup(void);
> diff --git a/mm/mlock.c b/mm/mlock.c
> index 4f4f53b..08f5b6b 100644
> --- a/mm/mlock.c
> +++ b/mm/mlock.c
> @@ -487,8 +487,6 @@ SYSCALL_DEFINE2(mlock, unsigned long, start, size_t, len)
>  	if (!can_do_mlock())
>  		return -EPERM;
>  
> -	lru_add_drain_all();	/* flush pagevec */
> -
>  	down_write(&current->mm->mmap_sem);
>  	len = PAGE_ALIGN(len + (start & ~PAGE_MASK));
>  	start &= PAGE_MASK;
> @@ -505,6 +503,7 @@ SYSCALL_DEFINE2(mlock, unsigned long, start, size_t, len)
>  	up_write(&current->mm->mmap_sem);
>  	if (!error)
>  		error = do_mlock_pages(start, len, 0);
> +	lru_add_drain_all_async();
>  	return error;
>  }
>  
> @@ -557,9 +556,6 @@ SYSCALL_DEFINE1(mlockall, int, flags)
>  	if (!can_do_mlock())
>  		goto out;
>  
> -	if (flags & MCL_CURRENT)
> -		lru_add_drain_all();	/* flush pagevec */
> -
>  	down_write(&current->mm->mmap_sem);
>  
>  	lock_limit = rlimit(RLIMIT_MEMLOCK);
> @@ -573,6 +569,7 @@ SYSCALL_DEFINE1(mlockall, int, flags)
>  	if (!ret && (flags & MCL_CURRENT)) {
>  		/* Ignore errors */
>  		do_mlock_pages(0, TASK_SIZE, 1);
> +		lru_add_drain_all_async();
>  	}
>  out:
>  	return ret;
> diff --git a/mm/swap.c b/mm/swap.c
> index a91caf7..2690f04 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -569,6 +569,49 @@ int lru_add_drain_all(void)
>  	return schedule_on_each_cpu(lru_add_drain_per_cpu);
>  }
>  
> +static DEFINE_PER_CPU(struct work_struct, lru_drain_work);
> +
> +static int __init lru_drain_work_init(void)
> +{
> +	struct work_struct *work;
> +	int cpu;
> +
> +	for_each_possible_cpu(cpu) {
> +		work = &per_cpu(lru_drain_work, cpu);
> +		INIT_WORK(work, &lru_add_drain_per_cpu);
> +	}
> +
> +	return 0;
> +}
> +core_initcall(lru_drain_work_init);
> +
> +static bool has_pages_lru_pvecs(int cpu)

I couldn't make sense of that name!  Though, to be fair, I never made
sense of "lru_add_drain" either: I always imagine a plumber adding a
drain.

pages_are_pending_lru_add(cpu)?

> +{
> +	struct pagevec *pvecs = per_cpu(lru_add_pvecs, cpu);
> +	struct pagevec *pvec;
> +	int lru;
> +
> +	for_each_lru(lru) {
> +		pvec = &pvecs[lru - LRU_BASE];

Hmm, yes, I see other such loops say "- LRU_BASE" too.
Good thing LRU_BASE is 0!  

> +		if (pagevec_count(pvec))
> +			return true;
> +	}
> +
> +	return false;
> +}
> +
> +void lru_add_drain_all_async(void)
> +{
> +	int cpu;
> +
> +	for_each_online_cpu(cpu) {
> +		struct work_struct *work = &per_cpu(lru_drain_work, cpu);
> +
> +		if (has_pages_lru_pvecs(cpu))
> +			schedule_work_on(cpu, work);
> +	}
> +}

You'll be peeking at a lot of remote cpus here, rather than sending them
all an IPI.  My guess is that it is more efficient your way, but that's
not as obvious as I'd like.

I haven't added Gilad Ben-Yossef to the Cc list, but be aware that he's
particularly interested in reducing IPIs, and has some patches on lkml.

I have added Michel Lespinasse to the Cc list, he's good to Cc on
mlock matters.  He thought that if the pages_are_pending check is
a win, then you should do it in lru_add_drain_all() too.  But more,
he wondered if we couldn't do a better job without all this, by
doing just lru_add_drain() first, and then doing the extra work
(of prodding other cpus) only if we come across a page which needs it.

> +
>  /*
>   * Batched page_cache_release().  Decrement the reference count on all the
>   * passed pages.  If it fell to zero then remove the page from the LRU and
> @@ -704,10 +747,23 @@ static void ____pagevec_lru_add_fn(struct page *page, void *arg)
>  	VM_BUG_ON(PageLRU(page));
>  
>  	SetPageLRU(page);
> -	if (active)
> -		SetPageActive(page);
> -	update_page_reclaim_stat(zone, page, file, active);
> -	add_page_to_lru_list(zone, page, lru);
> + redo:
> +	if (page_evictable(page, NULL)) {
> +		if (active)
> +			SetPageActive(page);
> +		update_page_reclaim_stat(zone, page, file, active);
> +		add_page_to_lru_list(zone, page, lru);
> +	} else {
> +		SetPageUnevictable(page);
> +		add_page_to_lru_list(zone, page, LRU_UNEVICTABLE);
> +		smp_mb();
> +
> +		if (page_evictable(page, NULL)) {
> +			del_page_from_lru_list(zone, page, LRU_UNEVICTABLE);
> +			ClearPageUnevictable(page);
> +			goto redo;
> +		}
> +	}
>  }

Right, this is where the overhead comes, in everybody's pagevec_lru_add_fn.

Now, I do like that you're resolving the un/evictable issue here, and
if the overhead really doesn't hurt, then this is a nice way to go.

But I think you should go further to reduce your overhead.  For one
thing, certainly take that silly almost-always-NULL vma arg out of
page_unevictable, and test vma directly in the one or two places that
want it; maybe make page_unevictable(page) an mm_inline function.

And update those various places (many or all in vmscan.c) which are
asking if page_unevictable(), to avoid using pagevec for unevictable
page because they know it doesn't work: you are now making it work.

Hah, I see my own putback_lru(or inactive)_pages patch is open to the
same criticism: if I'm now using a page_list there, it could handle the
unevictable pages directly instead of having to avoid them.  I think.

(I've never noticed before, it worries me now that page_unevictable()
is referring to page mapping flags at a point when we generally have
no hold on the mapping at all; but I've never heard of that being a
problem, and I guess if the mapping is stale, the page will very soon
be freed, so no matter if it went on the Unevictable list for a moment.)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
