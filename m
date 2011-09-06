Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id C4AFC6B00EE
	for <linux-mm@kvack.org>; Tue,  6 Sep 2011 14:21:07 -0400 (EDT)
Date: Tue, 6 Sep 2011 14:20:34 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH 02/18] writeback: dirty position control
Message-ID: <20110906182034.GA30513@redhat.com>
References: <20110904015305.367445271@intel.com>
 <20110904020914.848566742@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110904020914.848566742@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: linux-fsdevel@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sun, Sep 04, 2011 at 09:53:07AM +0800, Wu Fengguang wrote:

[..]
> - in memory tight systems, (1) becomes strong enough to squeeze dirty
>   pages inside the control scope
> 
> - in large memory systems where the "gravity" of (1) for pulling the
>   dirty pages to setpoint is too weak, (2) can back (1) up and drive
>   dirty pages to bdi_setpoint ~= setpoint reasonably fast.
> 
> Unfortunately in JBOD setups, the fluctuation range of bdi threshold
> is related to memory size due to the interferences between disks.  In
> this case, the bdi slope will be weighted sum of write_bw and bdi_thresh.

Can you please elaborate a little more that what changes in JBOD setup.

> 
> Given equations
> 
>         span = x_intercept - bdi_setpoint
>         k = df/dx = - 1 / span
> 
> and the extremum values
> 
>         span = bdi_thresh
>         dx = bdi_thresh
> 
> we get
> 
>         df = - dx / span = - 1.0
> 
> That means, when bdi_dirty deviates bdi_thresh up, pos_ratio and hence
> task ratelimit will fluctuate by -100%.

I am not sure I understand above calculation. I understood the part that
for single bdi case, you want 12.5% varation of bdi_setpoint over a
range of write_bw [SP-write_bw/2, SP+write_bw/2]. This requirement will
lead to.

k = -1/8*write_bw

OR span = 8*write_bw, hence
k= -1/span

Now I missed the part that what is different in case of JBOD setup and
how do you come up with values for that setup so that slope of bdi
setpoint is sharper.

IIUC, in case of single bdi case you want to use k=-1/(8*write_bw) and in
case of JBOD you want to use k=-1/(bdi_thresh)?

That means for single bdi case you want to trust bdi, write_bw but in
case of JBOD you stop trusting that and just switch to bdi_thresh. Not
sure what does it mean.

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
