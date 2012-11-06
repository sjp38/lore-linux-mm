Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id A6D116B0044
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 18:23:56 -0500 (EST)
Date: Tue, 6 Nov 2012 15:23:54 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 1/6] mm: teach mm by current context info to not do
 I/O during memory allocation
Message-Id: <20121106152354.90150a3b.akpm@linux-foundation.org>
In-Reply-To: <1351931714-11689-2-git-send-email-ming.lei@canonical.com>
References: <1351931714-11689-1-git-send-email-ming.lei@canonical.com>
	<1351931714-11689-2-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@canonical.com>
Cc: linux-kernel@vger.kernel.org, Alan Stern <stern@rowland.harvard.edu>, Oliver Neukum <oneukum@suse.de>, Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Jens Axboe <axboe@kernel.dk>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, linux-usb@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org, Jiri Kosina <jiri.kosina@suse.com>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>

On Sat,  3 Nov 2012 16:35:09 +0800
Ming Lei <ming.lei@canonical.com> wrote:

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
> approach to convert all GFP_KERNEL[1] in the path into GFP_NOIO because
> several subsystems may be involved(for example, PCI, USB and SCSI may
> be involved for usb mass stoarage device, network devices involved too
> in the iSCSI case)
> 
> - during block device runtime suspend, because runtime resume need
> to wait for completion of concurrent runtime suspend.
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
> It is not a good idea to convert all these GFP_KERNEL in the
> affected path into GFP_NOIO because these functions doing that may be
> implemented as library and will be called in many other contexts.
> 
> In fact, memalloc_noio() can convert some of current static GFP_NOIO
> allocation into GFP_KERNEL back in other non-affected contexts, at least
> almost all GFP_NOIO in USB subsystem can be converted into GFP_KERNEL
> after applying the approach and make allocation with GFP_IO
> only happen in runtime resume/bus reset/block I/O transfer contexts
> generally.

It's unclear from the description why we're also clearing __GFP_FS in
this situation.

If we can avoid doing this then there will be a very small gain: there
are some situations in which a filesystem can clean pagecache without
performing I/O.


It doesn't appear that the patch will add overhead to the alloc/free
hotpaths, which is good.

> 
> ...
>
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1805,6 +1805,7 @@ extern void thread_group_times(struct task_struct *p, cputime_t *ut, cputime_t *
>  #define PF_FROZEN	0x00010000	/* frozen for system suspend */
>  #define PF_FSTRANS	0x00020000	/* inside a filesystem transaction */
>  #define PF_KSWAPD	0x00040000	/* I am kswapd */
> +#define PF_MEMALLOC_NOIO 0x00080000	/* Allocating memory without IO involved */
>  #define PF_LESS_THROTTLE 0x00100000	/* Throttle me less: I clean memory */
>  #define PF_KTHREAD	0x00200000	/* I am a kernel thread */
>  #define PF_RANDOMIZE	0x00400000	/* randomize virtual address space */
> @@ -1842,6 +1843,15 @@ extern void thread_group_times(struct task_struct *p, cputime_t *ut, cputime_t *
>  #define tsk_used_math(p) ((p)->flags & PF_USED_MATH)
>  #define used_math() tsk_used_math(current)
>  
> +#define memalloc_noio() (current->flags & PF_MEMALLOC_NOIO)
> +#define memalloc_noio_save(flag) do { \
> +	(flag) = current->flags & PF_MEMALLOC_NOIO; \
> +	current->flags |= PF_MEMALLOC_NOIO; \
> +} while (0)
> +#define memalloc_noio_restore(flag) do { \
> +	current->flags = (current->flags & ~PF_MEMALLOC_NOIO) | flag; \
> +} while (0)
> +

Again with the ghastly macros.  Please, do this properly in regular old
C, as previously discussed.  It really doesn't matter what daft things
local_irq_save() did 20 years ago.  Just do it right!

Also, you can probably put the unlikely() inside memalloc_noio() and
avoid repeating it at all the callsites.

And it might be neater to do:

/*
 * Nice comment goes here
 */
static inline gfp_t memalloc_noio_flags(gfp_t flags)
{
	if (unlikely(current->flags & PF_MEMALLOC_NOIO))
		flags &= ~GFP_IOFS;
	return flags;
}

>   * task->jobctl flags
>   */
>
> ...
>
> @@ -2304,6 +2304,12 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
>  		.gfp_mask = sc.gfp_mask,
>  	};
>  
> +	if (unlikely(memalloc_noio())) {
> +		gfp_mask &= ~GFP_IOFS;
> +		sc.gfp_mask = gfp_mask;
> +		shrink.gfp_mask = sc.gfp_mask;
> +	}

We can avoid writing to shrink.gfp_mask twice.  And maybe sc.gfp_mask
as well.  Unclear, I didn't think about it too hard ;)

>  	throttle_direct_reclaim(gfp_mask, zonelist, nodemask);
>  
>  	/*
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
