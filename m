Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 9B8AF6B002B
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 01:15:17 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id B1F453EE0BD
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 14:15:15 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8A9A445DE5C
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 14:15:15 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5E06345DE58
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 14:15:15 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 46C23E18004
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 14:15:15 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 777A71DB8043
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 14:15:14 +0900 (JST)
Message-ID: <507E3EA6.5080809@jp.fujitsu.com>
Date: Wed, 17 Oct 2012 14:14:14 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v1 1/3] mm: teach mm by current context info to not
 do I/O during memory allocation
References: <1350403183-12650-1-git-send-email-ming.lei@canonical.com> <1350403183-12650-2-git-send-email-ming.lei@canonical.com>
In-Reply-To: <1350403183-12650-2-git-send-email-ming.lei@canonical.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@canonical.com>
Cc: linux-kernel@vger.kernel.org, Alan Stern <stern@rowland.harvard.edu>, Oliver Neukum <oneukum@suse.de>, Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-usb@vger.kernel.org, linux-pm@vger.kernel.org, Jiri Kosina <jiri.kosina@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Michal Hocko <mhocko@suse.cz>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-mm <linux-mm@kvack.org>

(2012/10/17 0:59), Ming Lei wrote:
> This patch introduces PF_MEMALLOC_NOIO on process flag('flags' field of
> 'struct task_struct'), so that the flag can be set by one task
> to avoid doing I/O inside memory allocation in the task's context.
> 
> The patch trys to solve one deadlock problem caused by block device,
> and the problem may happen at least in the below situations:
> 
> - during block device runtime resume, if memory allocation with
> GFP_KERNEL is called inside runtime resume callback of any one
> of its ancestors(or the block device itself), the deadlock may be
> triggered inside the memory allocation since it might not complete
> until the block device becomes active and the involed page I/O finishes.
> The situation is pointed out first by Alan Stern. It is not a good
> approach to convert all GFP_KERNEL in the path into GFP_NOIO because
> several subsystems may be involved(for example, PCI, USB and SCSI may
> be involved for usb mass stoarage device)
> 
> - during error handling of usb mass storage deivce, USB bus reset
> will be put on the device, so there shouldn't have any
> memory allocation with GFP_KERNEL during USB bus reset, otherwise
> the deadlock similar with above may be triggered. Unfortunately, any
> usb device may include one mass storage interface in theory, so it
> requires all usb interface drivers to handle the situation. In fact,
> most usb drivers don't know how to handle bus reset on the device
> and don't provide .pre_set() and .post_reset() callback at all, so
> USB core has to unbind and bind driver for these devices. So it
> is still not practical to resort to GFP_NOIO for solving the problem.
> 
> Also the introduced solution can be used by block subsystem or block
> drivers too, for example, set the PF_MEMALLOC_NOIO flag before doing
> actual I/O transfer.
> 
> Cc: Alan Stern <stern@rowland.harvard.edu>
> Cc: Oliver Neukum <oneukum@suse.de>
> Cc: Jiri Kosina <jiri.kosina@suse.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: "Rafael J. Wysocki" <rjw@sisk.pl>
> Cc: linux-mm <linux-mm@kvack.org>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> Signed-off-by: Ming Lei <ming.lei@canonical.com>
> ---
>   include/linux/sched.h |   11 +++++++++++
>   mm/page_alloc.c       |   10 +++++++++-
>   mm/vmscan.c           |   13 +++++++++++++
>   3 files changed, 33 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index f6961c9..c149ae7 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1811,6 +1811,7 @@ extern void thread_group_times(struct task_struct *p, cputime_t *ut, cputime_t *
>   #define PF_FROZEN	0x00010000	/* frozen for system suspend */
>   #define PF_FSTRANS	0x00020000	/* inside a filesystem transaction */
>   #define PF_KSWAPD	0x00040000	/* I am kswapd */
> +#define PF_MEMALLOC_NOIO 0x00080000	/* Allocating memory without IO involved */
>   #define PF_LESS_THROTTLE 0x00100000	/* Throttle me less: I clean memory */
>   #define PF_KTHREAD	0x00200000	/* I am a kernel thread */
>   #define PF_RANDOMIZE	0x00400000	/* randomize virtual address space */
> @@ -1848,6 +1849,16 @@ extern void thread_group_times(struct task_struct *p, cputime_t *ut, cputime_t *
>   #define tsk_used_math(p) ((p)->flags & PF_USED_MATH)
>   #define used_math() tsk_used_math(current)
>   
> +#define memalloc_noio() (current->flags & PF_MEMALLOC_NOIO)
> +#define memalloc_noio_save(noio_flag) do { \
> +	(noio_flag) = current->flags & PF_MEMALLOC_NOIO; \
> +	current->flags |= PF_MEMALLOC_NOIO; \
> +} while (0)
> +#define memalloc_noio_restore(noio_flag) do { \
> +	if (!(noio_flag)) \
> +		current->flags &= ~PF_MEMALLOC_NOIO; \
> +} while (0)
> +
>   /*
>    * task->jobctl flags
>    */
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 8e1be1c..e3746dd 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2630,10 +2630,18 @@ retry_cpuset:
>   	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask, order,
>   			zonelist, high_zoneidx, alloc_flags,
>   			preferred_zone, migratetype);
> -	if (unlikely(!page))
> +	if (unlikely(!page)) {
> +		/*
> +		 * Resume, block IO and its error handling path
> +		 * can deadlock because I/O on the device might not
> +		 * complete.
> +		 */
> +		if (unlikely(memalloc_noio()))
> +			gfp_mask &= ~GFP_IOFS;
>   		page = __alloc_pages_slowpath(gfp_mask, order,
>   				zonelist, high_zoneidx, nodemask,
>   				preferred_zone, migratetype);
> +	}
>   
>   	trace_mm_page_alloc(page, order, gfp_mask, migratetype);
>   
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 1e9aa66..6647805 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -3298,6 +3298,19 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
>   	};
>   	unsigned long nr_slab_pages0, nr_slab_pages1;
>   
> +	if (unlikely(memalloc_noio())) {
> +		sc.gfp_mask &= ~GFP_IOFS;
> +		shrink.gfp_mask = sc.gfp_mask;
> +		/*
> +		 * We allow to reclaim only clean pages.
> +		 * It can affect RECLAIM_SWAP and RECLAIM_WRITE mode
> +		 * but this is really rare event and allocator can
> +		 * fallback to other zones.
> +		 */
> +		sc.may_writepage = 0;
> +		sc.may_swap = 0;

I think the idea is reasonable. I have a request.

In current implemententation of vmscan.c, it seems sc.may_writepage, sc.may_swap
are handled independent from gfp_mask. 

So, could you drop changes from this patch and handle these flags in another patch
if these flags should be unset if ~GFP_IOFS ?

I think try_to_free_page() path's sc.may_xxxx should be handled in the same way.

Thanks,
-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
