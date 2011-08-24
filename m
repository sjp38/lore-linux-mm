Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 12C626B017D
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 20:13:02 -0400 (EDT)
Date: Wed, 24 Aug 2011 08:12:58 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/5] writeback: dirty position control
Message-ID: <20110824001257.GA6349@localhost>
References: <20110808141128.GA22080@localhost>
 <1312814501.10488.41.camel@twins>
 <20110808230535.GC7176@localhost>
 <1313154259.6576.42.camel@twins>
 <20110812142020.GB17781@localhost>
 <1314027488.24275.74.camel@twins>
 <20110823034042.GC7332@localhost>
 <1314093660.8002.24.camel@twins>
 <20110823141504.GA15949@localhost>
 <20110823174757.GC15820@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110823174757.GC15820@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

> You somehow directly jump to  
> 
> 	balanced_rate = task_ratelimit_200ms * write_bw / dirty_rate
> 
> without explaining why following will not work.
> 
> 	balanced_rate_(i+1) = balance_rate(i) * write_bw / dirty_rate

Thanks for asking that, it's probably the root of confusions, so let
me answer it standalone.

It's actually pretty simple to explain this equation:

                                               write_bw
        balanced_rate = task_ratelimit_200ms * ----------       (1)
                                               dirty_rate

If there are N dd tasks, each task is throttled at task_ratelimit_200ms
for the past 200ms, we are going to measure the overall bdi dirty rate

        dirty_rate = N * task_ratelimit_200ms                   (2)

put (2) into (1) we get

        balanced_rate = write_bw / N                            (3)

So equation (1) is the right estimation to get the desired target (3).


As for

                                                  write_bw
        balanced_rate_(i+1) = balanced_rate_(i) * ----------    (4)
                                                  dirty_rate

Let's compare it with the "expanded" form of (1):

                                                              write_bw
        balanced_rate_(i+1) = balanced_rate_(i) * pos_ratio * ----------      (5)
                                                              dirty_rate

So the difference lies in pos_ratio.

Believe it or not, it's exactly the seemingly use of pos_ratio that
makes (5) independent(*) of the position control.

Why? Look at (4), assume the system is in a state

- dirty rate is already balanced, ie. balanced_rate_(i) = write_bw / N
- dirty position is not balanced, for example pos_ratio = 0.5

balance_dirty_pages() will be rate limiting each tasks at half the
balanced dirty rate, yielding a measured

        dirty_rate = write_bw / 2                               (6)

Put (6) into (4), we get

        balanced_rate_(i+1) = balanced_rate_(i) * 2
                            = (write_bw / N) * 2

That means, any position imbalance will lead to balanced_rate
estimation errors if we follow (4). Whereas if (1)/(5) is used, we
always get the right balanced dirty ratelimit value whether or not
(pos_ratio == 1.0), hence make the rate estimation independent(*) of
dirty position control.

(*) independent as in real values, not the seemingly relations in equation

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
