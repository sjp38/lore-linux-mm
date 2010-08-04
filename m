Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id CAEA26B02A4
	for <linux-mm@kvack.org>; Wed,  4 Aug 2010 18:05:13 -0400 (EDT)
Date: Wed, 4 Aug 2010 15:04:22 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/2] Adding four writeback files in /proc/sys/vm
Message-Id: <20100804150422.c52b308e.akpm@linux-foundation.org>
In-Reply-To: <1280873949-20460-1-git-send-email-mrubin@google.com>
References: <1280873949-20460-1-git-send-email-mrubin@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Michael Rubin <mrubin@google.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, jack@suse.cz, david@fromorbit.com, hch@lst.de, axboe@kernel.dk
List-ID: <linux-mm.kvack.org>

On Tue,  3 Aug 2010 15:19:07 -0700
Michael Rubin <mrubin@google.com> wrote:

> Patch #1 sets up some helper functions for accounting.
> 
> Patch #2 adds some writeback files for visibility
> 
> To help developers and applications gain visibility into writeback
> behaviour adding four read-only sysctl files into /proc/sys/vm.
> These files allow user apps to understand writeback behaviour over time
> and learn how it is impacting their performance.
> 
>    # cat /proc/sys/vm/pages_dirtied
>    3747
>    # cat /proc/sys/vm/pages_entered_writeback
>    3618
>    # cat /proc/sys/vm/dirty_threshold_kbytes
>    816673
>    # cat /proc/sys/vm/dirty_background_threshold_kbytes
>    408336
> 
> The files fall into two groups.
> 
> pages_dirtied and pages_entered_writeback:
> 
> These two new files are necessary to give visibility into writeback
> behaviour. We have /proc/diskstats which lets us understand the io in
> the block layer. We have blktrace for more indepth understanding. We have
> e2fsprogs and debugsfs to give insight into the file systems behaviour,
> but we don't offer our users the ability understand what writeback is
> doing. There is no non-debugfs way to know how active it is,

I see what you did there!

So is there a debugfs-based way of getting this info?  If so, that
should be sufficient.

> if it's
> falling behind or to quantify it's efforts on a system. With these values
> exported users can easily see how much data applications are sending
> through writeback and also at what rates writeback is processing this
> data. Comparing the rates of change between the two allow developers
> to see when writeback is not able to keep up with incoming traffic and
> the rate of dirty memory being sent to the IO back end.  This allows
> folks to understand their io workloads and track kernel issues. Non
> kernel engineers at Google often use these counters to solve puzzling
> performance problems.
> 
> dirty_threshold_kbytes and dirty_background_threshold kbytes:
> 
> We already expose these thresholds in /proc/sys/vm with
> dirty_background_ratio and background_ratio. What's frustrating about
> the ratio variables and the need for these are that they are not
> honored by the kernel. Instead the kernel may alter the number
> requested without giving the user any indication that is the case.
> An app developer can set the ratio to 2% but end up with 5% as
> get_dirty_limits makes sure it is never lower than 5% when set from
> the ratio. Arguably that can be fixed too but the limits which decide
> whether writeback is invoked to aggressively clean dirty pages is
> dependent on changing page state retrieved in
> determine_dirtyable_memory. It makes understanding when the kernel
> decides to writeback data a moving target that no app can ever
> determine. With these thresholds visible and collected over time it
> gives apps a chance to know why writeback happened, or why it did not.
> As systems get larger and larger RAM developers use the ratios to
> predict when their workloads will see writeback invoked. Today there
> is no way to accurately indicate what the kernel will use to kick off
> writeback. Hence the need for these two new files.
> 

We should be very reluctant to add files to /proc which are tied to any
particular internal implementation.  Because when we change that
implementation (and boy does writeback need changing!), we have to
somehow make those files still contain meaningful values.

For pages_dirtied and pages_entered_writeback: it's hard to see how any
reimplementation of writeback would have any problem implementing
these, so OK.

But dirty_threshold_kbytes and dirty_background_threshold_kbytes are
closely tied to the implementation-of-the-day and so I don't think they
should be presented in /proc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
