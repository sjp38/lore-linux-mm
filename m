Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A23228D0040
	for <linux-mm@kvack.org>; Sun,  3 Apr 2011 05:32:21 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 429333EE0AE
	for <linux-mm@kvack.org>; Sun,  3 Apr 2011 18:32:18 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2A84645DE93
	for <linux-mm@kvack.org>; Sun,  3 Apr 2011 18:32:18 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 083B245DE91
	for <linux-mm@kvack.org>; Sun,  3 Apr 2011 18:32:18 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id ED332E08003
	for <linux-mm@kvack.org>; Sun,  3 Apr 2011 18:32:17 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B6960E08001
	for <linux-mm@kvack.org>; Sun,  3 Apr 2011 18:32:17 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 0/3] Unmapped page cache control (v5)
In-Reply-To: <20110402011040.GG6957@dastard>
References: <20110401221921.A890.A69D9226@jp.fujitsu.com> <20110402011040.GG6957@dastard>
Message-Id: <20110403183229.AE4C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Sun,  3 Apr 2011 18:32:16 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, akpm@linux-foundation.org, npiggin@kernel.dk, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>

> On Fri, Apr 01, 2011 at 10:17:56PM +0900, KOSAKI Motohiro wrote:
> > > > But, I agree that now we have to concern slightly large VM change parhaps
> > > > (or parhaps not). Ok, it's good opportunity to fill out some thing.
> > > > Historically, Linux MM has "free memory are waste memory" policy, and It
> > > > worked completely fine. But now we have a few exceptions.
> > > >
> > > > 1) RT, embedded and finance systems. They really hope to avoid reclaim
> > > >    latency (ie avoid foreground reclaim completely) and they can accept
> > > >    to make slightly much free pages before memory shortage.
> > > 
> > > In general we need a mechanism to ensure we can avoid reclaim during
> > > critical sections of application. So some way to give some hints to the
> > > machine to free up lots of memory (/proc/sys/vm/dropcaches is far too
> > > drastic) may be useful.
> > 
> > Exactly.
> > I've heard multiple times this request from finance people. And I've also 
> > heared the same request from bullet train control software people recently.
> 
> Well, that's enough to make me avoid Japanese trains in future. 

Feel free do. :)

>If
> your critical control system has problems with memory reclaim
> interfering with it's operation, then you are doing something
> very, very wrong.
> 
> If you have a need to avoid memory allocation latency during
> specific critical sections then the critical section needs to:
> 
> 	a) have all it's memory preallocated and mlock()d in advance
> 
> 	b) avoid doing anything that requires memory to be
> 	   allocated.
> 
> These are basic design rules for time-sensitive applications.

I wonder why do you think our VM folks don't know that.


> Fundamentally, if you just switch off memory reclaim to avoid the
> latencies involved with direct memory reclaim, then all you'll get
> instead is ENOMEM because there's no memory available and none will be
> reclaimed. That's even more fatal for the system than doing reclaim.

You have two level oversight.

Firstly, *ALL* RT application need to cooperate applications, kernel, 
and other various system level daemons. That's no specific issue of 
this topic. OK, *IF* RT application run egoistic, a system may hang 
up easily even routh mere simple busy loop, yes. But, Who want to do so?

Secondly, You misparsed "avoid direct reclaim" paragraph. We don't talk
about "avoid direct reclaim even if system memory is no enough", We talk
about "avoid direct reclaim by preparing before". 


> IMO, you should tell the people requesting stuff like this to
> architect their critical sections according to best practices.
> Hacking the VM to try to work around badly designed applications is
> a sure recipe for disaster...

I hope this mail satisfy you. :)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
