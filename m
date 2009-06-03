Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 0FF715F0019
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 13:01:43 -0400 (EDT)
Received: by pxi37 with SMTP id 37so147451pxi.12
        for <linux-mm@kvack.org>; Wed, 03 Jun 2009 10:01:42 -0700 (PDT)
Message-ID: <4A26AC73.6040804@gmail.com>
Date: Wed, 03 Jun 2009 10:01:39 -0700
From: Joel Krauska <jkrauska@gmail.com>
MIME-Version: 1.0
Subject: swapoff throttling and speedup?
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On occasion we need to unswap a system that's gotten unruly.

Scenario: Some leaky app eats up way more RAM than it should, and pushes
a few gigs of the running system in to swap.  The leaky app is killed, 
but there's still lots of good stuff sitting in swap that we need to tidy
up to get the system back to normal performance levels.


The normal recourse is to run
 swapoff -a ; swapon -a


I have two related questions about the swap tools and how they work.


1. Has anyone tried making a nicer swapoff?
Right now swapoff can be pretty aggressive if the system is otherwise
heavily loaded.  On systems that I need to leave running other jobs,
swapoff compounds the slowness of the system overall by burning up
a single CPU and lots of IO

I wrote a perl wrapper that briefly runs swapoff 
and then kills it, but it would seem more reasonable to have a knob
to make swapoff less aggressive. (max kb/s, etc)  

It looked to me like the swapoff code was immediately hitting kernel 
internals instead of doing more lifting itself (and making it 
obvious where I could insert some sleeps)

Has anyone found better options here?



2. A faster(multithreaded?) swapoff?
>From what I can tell, swapoff is single threaded, which seems to make 
unswapping a CPU bound activity.  

In the opposite use case of my first question, on systems that I /can/
halt all the running code (assuming if they've gone off the deep end and have
several gigs in SWAP) it can take quite a long time for unswap to 
tidy up the mess.  

Has anyone considered improvements to swapoff to speed it up?
(multiple threads?)


I'm hoping others have been down this road before.

As a rule, we try to avoid swapping when possible, but using:
vm.swappiness = 1

But it does still happen on occasion and that lead to this mail.

Cheers,

Joel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
