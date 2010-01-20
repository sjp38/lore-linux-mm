Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id F32BB6B006A
	for <linux-mm@kvack.org>; Tue, 19 Jan 2010 19:33:12 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0K0XAsO029327
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 20 Jan 2010 09:33:10 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6BCFC45DE51
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 09:33:10 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3CB5B45DE55
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 09:33:10 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 16DB0E18001
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 09:33:10 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id BEBB21DB805A
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 09:33:09 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] PM: Force GFP_NOIO during suspend/resume (was: Re: [linux-pm] Memory allocations in .suspend became very unreliable)
In-Reply-To: <201001192147.58185.rjw@sisk.pl>
References: <1263871194.724.520.camel@pasglop> <201001192147.58185.rjw@sisk.pl>
Message-Id: <20100120085053.405A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Wed, 20 Jan 2010 09:33:08 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: kosaki.motohiro@jp.fujitsu.com, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Maxim Levitsky <maximlevitsky@gmail.com>, linux-pm@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> On Tuesday 19 January 2010, Benjamin Herrenschmidt wrote:
> > On Tue, 2010-01-19 at 10:19 +0900, KOSAKI Motohiro wrote:
> > > I think the race happen itself is bad. memory and I/O subsystem can't solve such race
> > > elegantly. These doesn't know enough suspend state knowlege. I think the practical 
> > > solution is that higher level design prevent the race happen.
> > > 
> > > 
> > > > My patch attempts to avoid these two problems as well as the problem with
> > > > drivers using GFP_KERNEL allocations during suspend which I admit might be
> > > > solved by reworking the drivers.
> > > 
> > > Agreed. In this case, only drivers change can solve the issue. 
> > 
> > As I explained earlier, this is near to impossible since the allocations
> > are too often burried deep down the call stack or simply because the
> > driver doesn't know that we started suspending -another- driver...
> > 
> > I don't think trying to solve those problems at the driver level is
> > realistic to be honest. This is one of those things where we really just
> > need to make allocators 'just work' from a driver perspective.
> > 
> > It can't be perfect of course, as mentioned earlier, there will be a
> > problem if too little free memory is really available due to lots of
> > dirty pages around, but most of this can be somewhat alleviated in
> > practice, for example by pushing things out a bit at suspend time,
> > making some more memory free etc... But yeah, nothing replaces proper
> > error handling in drivers for allocation failures even with
> > GFP_KERNEL :-)
> 
> Agreed.
> 
> Moreover, I didn't try to do anything about that before, because memory
> allocation problems during suspend/resume just didn't happen.  We kind of knew
> they were possible, but since they didn't show up, it wasn't immediately
> necessary to address them.
> 
> Now, however, people started to see these problems in testing and I'm quite
> confident that this is a result of recent changes in the mm subsystem.  Namely,
> if you read the Maxim's report carefully, you'll notice that in his test case
> the mm subsystem apparently attempted to use I/O even though there was free
> memory available in the system.  This is the case I want to prevent from
> happening in the first place.

Hi Rafael,

Do you mean this is the unrelated issue of nVidia bug? Probably I haven't
catch your point. I don't find Maxim's original bug report. Can we share
the test-case and your analysis detail?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
