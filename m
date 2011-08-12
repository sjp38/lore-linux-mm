Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id B9866900137
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 01:45:35 -0400 (EDT)
Date: Fri, 12 Aug 2011 13:45:28 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/5] writeback: dirty position control
Message-ID: <20110812054528.GA10524@localhost>
References: <20110806084447.388624428@intel.com>
 <20110806094526.733282037@intel.com>
 <1312811193.10488.33.camel@twins>
 <20110808141128.GA22080@localhost>
 <1312814501.10488.41.camel@twins>
 <20110808230535.GC7176@localhost>
 <1313103367.26866.39.camel@twins>
 <20110812024353.GA11606@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110812024353.GA11606@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

> > Making our final function look like:
> > 
> >                s - x 3
> >  f(x) :=  1 + (-----)
> >                l - s
> 
> Very intuitive reasoning, thanks!
> 
> I substituted real numbers to the function assuming a mem=2GB system.
> 
> with limit=thresh:
> 
>         gnuplot> set xrange [60000:80000]
>         gnuplot> plot 1 +  (70000.0 - x)**3/(80000-70000.0)**3

I'll use the above one, which is more simple and elegant: 

        f(freerun)  = 2.0
        f(setpoint) = 1.0
        f(limit)    = 0

Code is

        unsigned long freerun = (thresh + bg_thresh) / 2;

        setpoint = (limit + freerun) / 2;
        pos_ratio = abs(dirty - setpoint);
        pos_ratio <<= BANDWIDTH_CALC_SHIFT;
        do_div(pos_ratio, limit - setpoint + 1);
        x = pos_ratio;
        pos_ratio = pos_ratio * x >> BANDWIDTH_CALC_SHIFT;
        pos_ratio = pos_ratio * x >> BANDWIDTH_CALC_SHIFT;
        if (dirty > setpoint)
                pos_ratio = -pos_ratio;
        pos_ratio += 1 << BANDWIDTH_CALC_SHIFT;

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
