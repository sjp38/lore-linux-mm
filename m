Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6D01490010B
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 12:01:46 -0400 (EDT)
Subject: Re: [BUG] fatal hang untarring 90GB file, possibly writeback
 related.
From: James Bottomley <James.Bottomley@suse.de>
In-Reply-To: <20110428150827.GY4658@suse.de>
References: <1303923000.2583.8.camel@mulgrave.site>
	 <1303923177-sup-2603@think> <1303924902.2583.13.camel@mulgrave.site>
	 <1303925374-sup-7968@think> <1303926637.2583.17.camel@mulgrave.site>
	 <1303934716.2583.22.camel@mulgrave.site> <1303990590.2081.9.camel@lenovo>
	 <20110428135228.GC1696@quack.suse.cz> <20110428140725.GX4658@suse.de>
	 <1304000714.2598.0.camel@mulgrave.site>  <20110428150827.GY4658@suse.de>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 28 Apr 2011 11:01:39 -0500
Message-ID: <1304006499.2598.5.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Jan Kara <jack@suse.cz>, colin.king@canonical.com, Chris Mason <chris.mason@oracle.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>, mgorman@novell.com

On Thu, 2011-04-28 at 16:08 +0100, Mel Gorman wrote:
> On Thu, Apr 28, 2011 at 09:25:14AM -0500, James Bottomley wrote:
> > On Thu, 2011-04-28 at 15:07 +0100, Mel Gorman wrote:
> > > On Thu, Apr 28, 2011 at 03:52:28PM +0200, Jan Kara wrote:
> > > > On Thu 28-04-11 12:36:30, Colin Ian King wrote:
> > > > > One more data point to add, I've been looking at an identical issue when
> > > > > copying large amounts of data.  I bisected this - and the lockups occur
> > > > > with commit 
> > > > > 3e7d344970673c5334cf7b5bb27c8c0942b06126 - before that I don't see the
> > > > > issue. With this commit, my file copy test locks up after ~8-10
> > > > > iterations, before this commit I can copy > 100 times and don't see the
> > > > > lockup.
> > > >   Adding Mel to CC, I guess he'll be interested. Mel, it seems this commit
> > > > of yours causes kswapd on non-preempt kernels spin for a *long* time...
> > > > 
> > > 
> > > I'm still thinking about the traces which do not point the finger
> > > directly at compaction per-se but it's possible that the change means
> > > kswapd is not reclaiming like it should be.
> > > 
> > > To test this theory, does applying
> > > [d527caf2: mm: compaction: prevent kswapd compacting memory to reduce
> > > CPU usage] help?
> > 
> > I can answer definitively no to this.  The upstream kernel I reproduced
> > this on has that patch included.
> > 
> 
> So it is.
> 
> Another consequence of this patch is that when high order allocations
> are in progress (is the test case fork heavy in any way for
> example?

It's a simple huge untar, so it shouldn't fork.

>  alternatively, it might be something in the storage stack
> that requires high-order allocs)

I've tried switching from CFQ to deadline with no apparent changes

>  we are no longer necessarily going
> to sleep because of should_reclaim_continue() check. This could
> explain kswapd-at-99% but would only apply if CONFIG_COMPACTION is
> set (does unsetting CONFIG_COMPACTION help). If the bug only triggers
> for CONFIG_COMPACTION, does the following *untested* patch help any?

Turning off COMPACTION and HUGEPAGES doesn't help ... kswapd still goes
to 99% on the PREEMPT kernel, so it doesn't seem to be related

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
