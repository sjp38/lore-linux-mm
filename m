Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 73E736B0078
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 16:20:56 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [RFC][PATCH] PM: Force GFP_NOIO during suspend/resume (was: Re: [linux-pm] Memory allocations in .suspend became very unreliable)
Date: Wed, 20 Jan 2010 22:21:34 +0100
References: <1263871194.724.520.camel@pasglop> <201001192147.58185.rjw@sisk.pl> <20100120085053.405A.A69D9226@jp.fujitsu.com>
In-Reply-To: <20100120085053.405A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <201001202221.34804.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Maxim Levitsky <maximlevitsky@gmail.com>, linux-pm@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wednesday 20 January 2010, KOSAKI Motohiro wrote:
> > On Tuesday 19 January 2010, Benjamin Herrenschmidt wrote:
> > > On Tue, 2010-01-19 at 10:19 +0900, KOSAKI Motohiro wrote:
> > > > I think the race happen itself is bad. memory and I/O subsystem can't solve such race
> > > > elegantly. These doesn't know enough suspend state knowlege. I think the practical 
> > > > solution is that higher level design prevent the race happen.
> > > > 
> > > > 
> > > > > My patch attempts to avoid these two problems as well as the problem with
> > > > > drivers using GFP_KERNEL allocations during suspend which I admit might be
> > > > > solved by reworking the drivers.
> > > > 
> > > > Agreed. In this case, only drivers change can solve the issue. 
> > > 
> > > As I explained earlier, this is near to impossible since the allocations
> > > are too often burried deep down the call stack or simply because the
> > > driver doesn't know that we started suspending -another- driver...
> > > 
> > > I don't think trying to solve those problems at the driver level is
> > > realistic to be honest. This is one of those things where we really just
> > > need to make allocators 'just work' from a driver perspective.
> > > 
> > > It can't be perfect of course, as mentioned earlier, there will be a
> > > problem if too little free memory is really available due to lots of
> > > dirty pages around, but most of this can be somewhat alleviated in
> > > practice, for example by pushing things out a bit at suspend time,
> > > making some more memory free etc... But yeah, nothing replaces proper
> > > error handling in drivers for allocation failures even with
> > > GFP_KERNEL :-)
> > 
> > Agreed.
> > 
> > Moreover, I didn't try to do anything about that before, because memory
> > allocation problems during suspend/resume just didn't happen.  We kind of knew
> > they were possible, but since they didn't show up, it wasn't immediately
> > necessary to address them.
> > 
> > Now, however, people started to see these problems in testing and I'm quite
> > confident that this is a result of recent changes in the mm subsystem.  Namely,
> > if you read the Maxim's report carefully, you'll notice that in his test case
> > the mm subsystem apparently attempted to use I/O even though there was free
> > memory available in the system.  This is the case I want to prevent from
> > happening in the first place.
> 
> Hi Rafael,
> 
> Do you mean this is the unrelated issue of nVidia bug?

The nvidia driver _is_ buggy, but Maxim said he couldn't reproduce the
problem if all the allocations made by the nvidia driver during suspend
were changed to GFP_ATOMIC.

> Probably I haven't catch your point. I don't find Maxim's original bug
> report. Can we share the test-case and your analysis detail?

The Maxim's original report is here:
https://lists.linux-foundation.org/pipermail/linux-pm/2010-January/023982.html

and the message I'm referring to is at:
https://lists.linux-foundation.org/pipermail/linux-pm/2010-January/023990.html

Thanks,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
