Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 692FF6B00AB
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 22:20:21 -0500 (EST)
Subject: Re: [RFC][PATCH] PM: Force GFP_NOIO during suspend/resume (was:
 Re: [linux-pm] Memory allocations in .suspend became very unreliable)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20100119101101.5F2E.A69D9226@jp.fujitsu.com>
References: <20100118110324.AE30.A69D9226@jp.fujitsu.com>
	 <201001182155.09727.rjw@sisk.pl>
	 <20100119101101.5F2E.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 19 Jan 2010 14:19:54 +1100
Message-ID: <1263871194.724.520.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, Maxim Levitsky <maximlevitsky@gmail.com>, linux-pm@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2010-01-19 at 10:19 +0900, KOSAKI Motohiro wrote:
> I think the race happen itself is bad. memory and I/O subsystem can't solve such race
> elegantly. These doesn't know enough suspend state knowlege. I think the practical 
> solution is that higher level design prevent the race happen.
> 
> 
> > My patch attempts to avoid these two problems as well as the problem with
> > drivers using GFP_KERNEL allocations during suspend which I admit might be
> > solved by reworking the drivers.
> 
> Agreed. In this case, only drivers change can solve the issue. 

As I explained earlier, this is near to impossible since the allocations
are too often burried deep down the call stack or simply because the
driver doesn't know that we started suspending -another- driver...

I don't think trying to solve those problems at the driver level is
realistic to be honest. This is one of those things where we really just
need to make allocators 'just work' from a driver perspective.

It can't be perfect of course, as mentioned earlier, there will be a
problem if too little free memory is really available due to lots of
dirty pages around, but most of this can be somewhat alleviated in
practice, for example by pushing things out a bit at suspend time,
making some more memory free etc... But yeah, nothing replaces proper
error handling in drivers for allocation failures even with
GFP_KERNEL :-)

Cheers,
Ben.






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
