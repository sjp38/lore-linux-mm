Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id F15186B006A
	for <linux-mm@kvack.org>; Tue, 19 Jan 2010 15:47:15 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [RFC][PATCH] PM: Force GFP_NOIO during suspend/resume (was: Re: [linux-pm] Memory allocations in .suspend became very unreliable)
Date: Tue, 19 Jan 2010 21:47:58 +0100
References: <20100118110324.AE30.A69D9226@jp.fujitsu.com> <20100119101101.5F2E.A69D9226@jp.fujitsu.com> <1263871194.724.520.camel@pasglop>
In-Reply-To: <1263871194.724.520.camel@pasglop>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <201001192147.58185.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Maxim Levitsky <maximlevitsky@gmail.com>, linux-pm@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tuesday 19 January 2010, Benjamin Herrenschmidt wrote:
> On Tue, 2010-01-19 at 10:19 +0900, KOSAKI Motohiro wrote:
> > I think the race happen itself is bad. memory and I/O subsystem can't solve such race
> > elegantly. These doesn't know enough suspend state knowlege. I think the practical 
> > solution is that higher level design prevent the race happen.
> > 
> > 
> > > My patch attempts to avoid these two problems as well as the problem with
> > > drivers using GFP_KERNEL allocations during suspend which I admit might be
> > > solved by reworking the drivers.
> > 
> > Agreed. In this case, only drivers change can solve the issue. 
> 
> As I explained earlier, this is near to impossible since the allocations
> are too often burried deep down the call stack or simply because the
> driver doesn't know that we started suspending -another- driver...
> 
> I don't think trying to solve those problems at the driver level is
> realistic to be honest. This is one of those things where we really just
> need to make allocators 'just work' from a driver perspective.
> 
> It can't be perfect of course, as mentioned earlier, there will be a
> problem if too little free memory is really available due to lots of
> dirty pages around, but most of this can be somewhat alleviated in
> practice, for example by pushing things out a bit at suspend time,
> making some more memory free etc... But yeah, nothing replaces proper
> error handling in drivers for allocation failures even with
> GFP_KERNEL :-)

Agreed.

Moreover, I didn't try to do anything about that before, because memory
allocation problems during suspend/resume just didn't happen.  We kind of knew
they were possible, but since they didn't show up, it wasn't immediately
necessary to address them.

Now, however, people started to see these problems in testing and I'm quite
confident that this is a result of recent changes in the mm subsystem.  Namely,
if you read the Maxim's report carefully, you'll notice that in his test case
the mm subsystem apparently attempted to use I/O even though there was free
memory available in the system.  This is the case I want to prevent from
happening in the first place.

Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
