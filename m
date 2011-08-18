Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 9E130900138
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 08:55:34 -0400 (EDT)
Date: Thu, 18 Aug 2011 20:55:27 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] writeback: Per-block device
 bdi->dirty_writeback_interval and bdi->dirty_expire_interval.
Message-ID: <20110818125526.GC1883@localhost>
References: <CAFPAmTSrh4r71eQqW-+_nS2KFK2S2RQvYBEpa3QnNkZBy8ncbw@mail.gmail.com>
 <20110818094824.GA25752@localhost>
 <CAFPAmTQ3jN8RF5-7E92AoGAGMz5H0GrPxkgJ0O6u_MViGC6KnQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFPAmTQ3jN8RF5-7E92AoGAGMz5H0GrPxkgJ0O6u_MViGC6KnQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kautuk Consul <consul.kautuk@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Artem Bityutskiy <dedekind1@gmail.com>

Hi Kautuk,

> >> However, the user/admin might want to set different writeback speeds
> >> for different block devices based on
> >> their page write-back performance.
> >
> > How can the above two sysctl values impact "writeback speeds"?
> > In particular, what's the "speed" you mean?
> >
> 
> By writeback speed, I meant writeback interval, i.e. the maximum
> interval after which the BDI
> thread for a particular block device can wake up and try to sync pages
> with disk.

OK.

> >> For example, the user might want to write-back pages in smaller
> >> intervals to a block device which has a
> >> faster known writeback speed.
> >
> > That's not a complete rational. What does the user ultimately want by
> > setting a smaller interval? What would be the problems to the other
> > slow devices if the user does so by simply setting a small value
> > _globally_?
> >
> 
> I think that the user might want to set a smaller interval for faster block
> devices so that the dirty pages are synced with that block device/disk sooner.
> This will unset the dirty bit of the page-cache pages sooner, which
> will increase the
> possibility of those pages getting reclaimed quickly in high memory
> usage scenarios.
> For a system that writes to disk very frequently and runs a lot of
> memory intensive user-mode
> applications, this might be crucial for their performance as they
> would possibly have to sleep
> comparitively lesser during page allocation.
> For example, an server handling a database needs frequent disk access
> as well as
> anonymous memory. In such a case it would be nice to keep the
> write-back interval for a USB pen
> drive BDI thread as more than that of a SATA/SCSI disk.

Nope. I'm afraid the above reasoning is totally wrong.

Firstly, it's never a guarantee for a smaller interval to stop the
dirty pages from growing large. Think about a dd task that dirties
pages at 1GB/s speed. It's going to accumulate huge number of dirty
pages before any "small" writeback interval elapsed.

Secondly, according to your logic, it's actually the low speed device
that need smaller intervals. Because if a dirtier task creates 100MB
dirty pages in the same interval, it's the slow device that requires
a lot more time to clean those pages, hence need to start the
writeback earlier.

The conclusion is, the dirty_expire_centisecs and
dirty_writeback_centisecs interfaces are solely for data integrity
purpose.

We have dirty_ratio for controlling the maximum number of dirty pages
and dirty_background_ratio for controlling when to start writeback.

There does exist the problem that their default value 10%/20% can be
too large for a system with 1TB memory and 100MB/s disk, or 4GB memory
and a 10MB/s USB memory stick. In particular they will accumulate more
than 30 seconds worth of data which could break the user assumption on
what dirty_expire_centisecs seem to promise.

Now that we have per-bdi write bandwidth estimation, that problem can
be fixed by somehow auto lowering the effective dirty (background) ratio.
I wonder if this is what you really want.  Greg had some concerns on
this issue, too.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
