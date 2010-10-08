Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id ACC656B006A
	for <linux-mm@kvack.org>; Fri,  8 Oct 2010 06:12:48 -0400 (EDT)
Subject: RE: [PATCH] bdi: use deferable timer for sync_supers task
From: Artem Bityutskiy <Artem.Bityutskiy@nokia.com>
Reply-To: Artem.Bityutskiy@nokia.com
In-Reply-To: <A24AE1FFE7AEC5489F83450EE98351BF227AB58D43@shsmsx502.ccr.corp.intel.com>
References: <20101008083514.GA12402@ywang-moblin2.bj.intel.com>
	 <20101008092520.GB5426@lst.de>
	 <A24AE1FFE7AEC5489F83450EE98351BF227AB58D43@shsmsx502.ccr.corp.intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 08 Oct 2010 13:09:46 +0300
Message-ID: <1286532586.2095.55.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: "ext Wu, Xia" <xia.wu@intel.com>
Cc: Christoph Hellwig <hch@lst.de>, Yong Wang <yong.y.wang@linux.intel.com>, Jens Axboe <jaxboe@fusionio.com>, "Wu,
 Fengguang" <fengguang.wu@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2010-10-08 at 12:04 +0200, ext Wu, Xia wrote:
> On Fri, Oct 08, 2010 at 04:35:14PM +0800, Yong Wang wrote:
> > > sync_supers task currently wakes up periodically for superblock
> > > writeback. This hurts power on battery driven devices. This patch
> > > turns this housekeeping timer into a deferable timer so that it
> > > does not fire when system is really idle.
> 
> > How long can the timer be defereed?  We can't simply stop writing
> > out data for a long time.  I think the current timer value should be
> > the upper bound, but allowing to fire earlier to run during the
> > same wakeup cycle as others is fine.
> 
> If the system is in sleep state, this timer can be deferred to the next wake-up interrupt.
> If the system is busy, this timer will fire at the scheduled time.

However, when the next wake-up interrupt happens is not defined. It can
happen 1ms after, or 1 minute after, or 1 hour after. What Christoph
says is that there should be some guarantee that sb writeout starts,
say, within 5 to 10 seconds interval. Deferrable timers do not guarantee
this. But take a look at the range hrtimers - they do exactly this.

-- 
Best Regards,
Artem Bityutskiy (D?N?N?N?D 1/4  D?D,N?N?N?DoD,D1)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
