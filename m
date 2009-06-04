Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A75346B005C
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 22:06:29 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5426RvI027788
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 4 Jun 2009 11:06:27 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 582B945DE55
	for <linux-mm@kvack.org>; Thu,  4 Jun 2009 11:06:27 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3371945DE51
	for <linux-mm@kvack.org>; Thu,  4 Jun 2009 11:06:27 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1D6911DB803B
	for <linux-mm@kvack.org>; Thu,  4 Jun 2009 11:06:27 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C4C941DB803A
	for <linux-mm@kvack.org>; Thu,  4 Jun 2009 11:06:26 +0900 (JST)
Date: Thu, 4 Jun 2009 11:04:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: swapoff throttling and speedup?
Message-Id: <20090604110456.90b0ebcb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4A26AC73.6040804@gmail.com>
References: <4A26AC73.6040804@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Joel Krauska <jkrauska@gmail.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 03 Jun 2009 10:01:39 -0700
Joel Krauska <jkrauska@gmail.com> wrote:

> On occasion we need to unswap a system that's gotten unruly.
> 
> Scenario: Some leaky app eats up way more RAM than it should, and pushes
> a few gigs of the running system in to swap.  The leaky app is killed, 
> but there's still lots of good stuff sitting in swap that we need to tidy
> up to get the system back to normal performance levels.
> 
> 
> The normal recourse is to run
>  swapoff -a ; swapon -a
> 
> 
> I have two related questions about the swap tools and how they work.
> 
> 
> 1. Has anyone tried making a nicer swapoff?
> Right now swapoff can be pretty aggressive if the system is otherwise
> heavily loaded.  On systems that I need to leave running other jobs,
> swapoff compounds the slowness of the system overall by burning up
> a single CPU and lots of IO
> 
> I wrote a perl wrapper that briefly runs swapoff 
> and then kills it, but it would seem more reasonable to have a knob
> to make swapoff less aggressive. (max kb/s, etc)  
> 
> It looked to me like the swapoff code was immediately hitting kernel 
> internals instead of doing more lifting itself (and making it 
> obvious where I could insert some sleeps)
> 
I haven't heard this swapoff issue for years.

Hmm, swapoff -a is proper operation ? (I don't think so..)
I think most of people just want "fast" swapoff.

> Has anyone found better options here?
> 
> 
If you know what are the leaky apps, memory cgroup may be a help for
avoiding unnecessary swap-out.
 
How about throttling swapoff's cpu usage by cpu scheduler cgroup ?
No help ?

> 
> 2. A faster(multithreaded?) swapoff?
> From what I can tell, swapoff is single threaded, which seems to make 
> unswapping a CPU bound activity.  
> 
> In the opposite use case of my first question, on systems that I /can/
> halt all the running code (assuming if they've gone off the deep end and have
> several gigs in SWAP) it can take quite a long time for unswap to 
> tidy up the mess.  
> 
> Has anyone considered improvements to swapoff to speed it up?
> (multiple threads?)
> 
not heared of in this mailing list.

But I think swapoff() is a system-call and making it as multithreaded is
not easy. (And we have to take care of complex racy cases...)

> 
> I'm hoping others have been down this road before.
> 
> As a rule, we try to avoid swapping when possible, but using:
> vm.swappiness = 1
> 
> But it does still happen on occasion and that lead to this mail.
> 


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
