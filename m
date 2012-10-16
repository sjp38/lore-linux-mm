Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 36D146B002B
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 16:19:35 -0400 (EDT)
Date: Tue, 16 Oct 2012 13:19:33 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH v1 1/3] mm: teach mm by current context info to not
 do I/O during memory allocation
Message-Id: <20121016131933.c196457a.akpm@linux-foundation.org>
In-Reply-To: <1350403183-12650-2-git-send-email-ming.lei@canonical.com>
References: <1350403183-12650-1-git-send-email-ming.lei@canonical.com>
	<1350403183-12650-2-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@canonical.com>
Cc: linux-kernel@vger.kernel.org, Alan Stern <stern@rowland.harvard.edu>, Oliver Neukum <oneukum@suse.de>, Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-usb@vger.kernel.org, linux-pm@vger.kernel.org, Jiri Kosina <jiri.kosina@suse.com>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-mm <linux-mm@kvack.org>

On Tue, 16 Oct 2012 23:59:41 +0800
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

The patch seems reasonable to me.  I'd like to see some examples of
these resume-time callsite which are performing the GFP_KERNEL
allocations, please.  You have found some kernel bugs, so those should
be fully described.

> @@ -1848,6 +1849,16 @@ extern void thread_group_times(struct task_struct *p, cputime_t *ut, cputime_t *
>  #define tsk_used_math(p) ((p)->flags & PF_USED_MATH)
>  #define used_math() tsk_used_math(current)
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

This is just awful.  Why oh why do we write code in macros when we have
a nice C compiler?

These can all be done as nice, clean, type-safe, documented C
functions.  And if they can be done that way, they *should* be done
that way!

And I suggest that a better name for memalloc_noio_save() is
memalloc_noio_set().  So this:

static inline unsigned memalloc_noio(void)
{
	return current->flags & PF_MEMALLOC_NOIO;
}

static inline unsigned memalloc_noio_set(unsigned flags)
{
	unsigned ret = memalloc_noio();

	current->flags |= PF_MEMALLOC_NOIO;
	return ret;
}

static inline unsigned memalloc_noio_restore(unsigned flags)
{
	current->flags = (current->flags & ~PF_MEMALLOC_NOIO) | flags;
}

(I think that's correct?  It's probably more efficient this way).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
