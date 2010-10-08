Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 372316B0098
	for <linux-mm@kvack.org>; Fri,  8 Oct 2010 10:02:17 -0400 (EDT)
Subject: Re: [PATCH] bdi: use deferable timer for sync_supers task
From: Artem Bityutskiy <Artem.Bityutskiy@nokia.com>
Reply-To: Artem.Bityutskiy@nokia.com
In-Reply-To: <20101008102709.GA12682@ywang-moblin2.bj.intel.com>
References: <20101008083514.GA12402@ywang-moblin2.bj.intel.com>
	 <20101008092520.GB5426@lst.de>
	 <A24AE1FFE7AEC5489F83450EE98351BF227AB58D43@shsmsx502.ccr.corp.intel.com>
	 <1286532586.2095.55.camel@localhost>
	 <A24AE1FFE7AEC5489F83450EE98351BF227AB58D51@shsmsx502.ccr.corp.intel.com>
	 <1286533687.2095.58.camel@localhost>
	 <20101008102709.GA12682@ywang-moblin2.bj.intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 08 Oct 2010 16:59:21 +0300
Message-ID: <1286546361.2095.92.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Yong Wang <yong.y.wang@linux.intel.com>
Cc: "Wu, Xia" <xia.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Jens Axboe <jaxboe@fusionio.com>, "Wu, Fengguang" <fengguang.wu@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2010-10-08 at 18:27 +0800, Yong Wang wrote:
> On Fri, Oct 08, 2010 at 01:28:07PM +0300, Artem Bityutskiy wrote:
> > On Fri, 2010-10-08 at 18:27 +0800, Wu, Xia wrote:
> > > > However, when the next wake-up interrupt happens is not defined. It can
> > > > happen 1ms after, or 1 minute after, or 1 hour after. What Christoph
> > > > says is that there should be some guarantee that sb writeout starts,
> > > > say, within 5 to 10 seconds interval. Deferrable timers do not guarantee
> > > > this. But take a look at the range hrtimers - they do exactly this.
> > > 
> > > If the system is in sleep state, is there any data which should be written?
> > 
> > May be yes, may be no.
> > 
> 
> Thanks for the quick response, Artem. May I know what might need to be
> written out when system is really idle?

I do not understand the question. There is dirty data, and it should be
flushed within some time interval.

Anyway, to make the long story short, I made an attempt to optimize this
and stop arming the timer when we have no dirty data. But my solution
was not accepted and Al asked me to just get rid of this timer and whole
sync_supers(). He said this should be pushed down to individual FSes. I
guess the idea is that

1) some FSes actually abuse sb synching, e.g., JFFS2.
2) other FSes can eventually optimize things for themselves.

But I did not find time to do this so far.

-- 
Best Regards,
Artem Bityutskiy (D?N?N?N?D 1/4  D?D,N?N?N?DoD,D1)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
