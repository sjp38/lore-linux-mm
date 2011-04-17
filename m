Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A1381900086
	for <linux-mm@kvack.org>; Sat, 16 Apr 2011 22:11:16 -0400 (EDT)
Date: Sun, 17 Apr 2011 10:11:11 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 4/4] writeback: reduce per-bdi dirty threshold ramp up
 time
Message-ID: <20110417021111.GA11352@localhost>
References: <20110413233122.GA6097@localhost>
 <20110413235211.GN31057@dastard>
 <20110414002301.GA9826@localhost>
 <20110414151424.GA367@localhost>
 <20110414181609.GH5054@quack.suse.cz>
 <20110415034300.GA23430@localhost>
 <20110415143711.GA17181@localhost>
 <20110415221314.GE5432@quack.suse.cz>
 <1302942809.2388.254.camel@twins>
 <20110416142114.GA12220@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110416142114.GA12220@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, Richard Kennedy <richard@rsk.demon.co.uk>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>

On Sat, Apr 16, 2011 at 10:21:14PM +0800, Wu Fengguang wrote:
> On Sat, Apr 16, 2011 at 04:33:29PM +0800, Peter Zijlstra wrote:
> > On Sat, 2011-04-16 at 00:13 +0200, Jan Kara wrote:
> > > 
> > > So what is a takeaway from this for me is that scaling the period
> > > with the dirty limit is not the right thing. If you'd have 4-times more
> > > memory, your choice of "dirty limit" as the period would be as bad as
> > > current 4*"dirty limit". What would seem like a better choice of period
> > > to me would be to have the period in an order of a few seconds worth of
> > > writeback. That would allow the bdi limit to scale up reasonably fast when
> > > new bdi starts to be used and still not make it fluctuate that much
> > > (hopefully).
> > 
> > No best would be to scale the period with the writeout bandwidth, but
> > lacking that the dirty limit had to do. Since we're counting pages, and
> > bandwidth is pages/second we'll end up with a time measure, exactly the
> > thing you wanted.
> 
> I owe you the patch :) Here is a tested one for doing the bandwidth
> based scaling. It's based on the attached global writeout bandwidth
> estimation.
> 
> I tried updating the shift both on rosed and fallen bandwidth, however
> that leads to reset of the accumulated proportion values. So here the
> shift will only be increased and never decreased.

I cannot reproduce the issue now.  It may be due to the bandwidth
estimation went wrong and get tiny values at times in an early patch,
thus "resetting" the proportional values.

I'll carry the below version in future tests. In theory we could do
more coarse tracking with

        if (abs(shift - vm_completions.pg[0].shift) <= 1)
                return;

But let's do it more diligent now.

Thanks,
Fengguang
---
@@ -143,6 +136,13 @@ static int calc_period_shift(void)
 static void update_completion_period(void)
 {
 	int shift = calc_period_shift();
+
+	if (shift > PROP_MAX_SHIFT)
+		shift = PROP_MAX_SHIFT;
+
+	if (shift == vm_completions.pg[0].shift)
+		return;
+
 	prop_change_shift(&vm_completions, shift);
 	prop_change_shift(&vm_dirties, shift);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
