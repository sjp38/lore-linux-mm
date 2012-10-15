Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id CB0026B00A9
	for <linux-mm@kvack.org>; Mon, 15 Oct 2012 10:33:40 -0400 (EDT)
Date: Mon, 15 Oct 2012 10:33:39 -0400 (EDT)
From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [RFC PATCH 1/3] mm: teach mm by current context info to not do
 I/O during memory allocation
In-Reply-To: <1350278059-14904-2-git-send-email-ming.lei@canonical.com>
Message-ID: <Pine.LNX.4.44L0.1210151029350.1702-100000@iolanthe.rowland.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@canonical.com>
Cc: linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-usb@vger.kernel.org, linux-pm@vger.kernel.org, Oliver Neukum <oneukum@suse.de>, Jiri Kosina <jiri.kosina@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-mm <linux-mm@kvack.org>

On Mon, 15 Oct 2012, Ming Lei wrote:

> This patch introduces PF_MEMALLOC_NOIO on process flag('flags' field of
> 'struct task_struct'), so that the flag can be set by one task
> to avoid doing I/O inside memory allocation in the task's context.
> 
> The patch trys to solve one deadlock problem caused by block device,
> and the problem can be occured at least in the below situations:
> 
> - during block device runtime resume situation, if memory allocation
> with GFP_KERNEL is called inside runtime resume callback of any one
> of its ancestors(or the block device itself), the deadlock may be
> triggered inside the memory allocation since it might not complete
> until the block device becomes active and the involed page I/O finishes.
> The situation is pointed out first by Alan Stern. It is not a good
> approach to convert all GFP_KERNEL in the path into GFP_NOIO because
> several subsystems may be involved(for example, PCI, USB and SCSI may
> be involved for usb mass stoarage device)
> 
> - during error handling situation of usb mass storage deivce, USB
> bus reset will be put on the device, so there shouldn't have any
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

> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1811,6 +1811,7 @@ extern void thread_group_times(struct task_struct *p, cputime_t *ut, cputime_t *
>  #define PF_FROZEN	0x00010000	/* frozen for system suspend */
>  #define PF_FSTRANS	0x00020000	/* inside a filesystem transaction */
>  #define PF_KSWAPD	0x00040000	/* I am kswapd */
> +#define PF_MEMALLOC_NOIO 0x00080000	/* Allocating memory without IO involved */
>  #define PF_LESS_THROTTLE 0x00100000	/* Throttle me less: I clean memory */
>  #define PF_KTHREAD	0x00200000	/* I am a kernel thread */
>  #define PF_RANDOMIZE	0x00400000	/* randomize virtual address space */
> @@ -1848,6 +1849,10 @@ extern void thread_group_times(struct task_struct *p, cputime_t *ut, cputime_t *
>  #define tsk_used_math(p) ((p)->flags & PF_USED_MATH)
>  #define used_math() tsk_used_math(current)
>  
> +#define tsk_memalloc_no_io(p) ((p)->flags & PF_MEMALLOC_NOIO)
> +#define tsk_memalloc_allow_io(p) do { (p)->flags &= ~PF_MEMALLOC_NOIO; } while (0)
> +#define tsk_memalloc_forbid_io(p) do { (p)->flags |= PF_MEMALLOC_NOIO; } while (0)

Instead of allow/forbid, the API should be save/restore (like 
local_irq_save and local_irq_restore).  This makes nesting much easier.

Also, do we really the "p" argument?  This is not at all likely to be 
used with any task other than the current one.

Alan Stern

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
