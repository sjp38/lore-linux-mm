Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id l91IK77P010273
	for <linux-mm@kvack.org>; Tue, 2 Oct 2007 04:20:07 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l91INhfE241214
	for <linux-mm@kvack.org>; Tue, 2 Oct 2007 04:23:43 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l91IHGKE019145
	for <linux-mm@kvack.org>; Tue, 2 Oct 2007 04:17:16 +1000
Message-ID: <47013A38.2090700@linux.vnet.ibm.com>
Date: Mon, 01 Oct 2007 23:49:36 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [patch] splice mmap_sem deadlock
References: <20070928160035.GD12538@wotan.suse.de> <20070928173144.GA11717@kernel.dk> <alpine.LFD.0.999.0709281109290.3579@woody.linux-foundation.org> <20070928181513.GB11717@kernel.dk> <alpine.LFD.0.999.0709281120220.3579@woody.linux-foundation.org> <20070928193017.GC11717@kernel.dk> <alpine.LFD.0.999.0709281247490.3579@woody.linux-foundation.org> <alpine.LFD.0.999.0709281303250.3579@woody.linux-foundation.org> <20071001120330.GE5303@kernel.dk> <alpine.LFD.0.999.0710010807360.3579@woody.linux-foundation.org> <4701161E.3030204@linux.vnet.ibm.com> <alpine.LFD.0.999.0710010905070.3579@woody.linux-foundation.org>
In-Reply-To: <alpine.LFD.0.999.0710010905070.3579@woody.linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Jens Axboe <jens.axboe@oracle.com>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> 
> On Mon, 1 Oct 2007, Balbir Singh wrote:
>> Sounds very similar to the problems we had with CPU hotplug earlier.
>> It's a rwlock locking anti-pattern. I know that recursive locks
>> have been frowned upon earlier, but I wonder if there is a case here.
>> Of-course recursive locks would not be *fair*.
> 
> The problem with recursive locks is that they are inevitably done wrong.
> 
> For example, the "natural" way  to do them is to just save the process ID 
> or something like that. Which is utter crap. Yet, people do it *every* 
> single time (yes, I've done it too, I admit).
> 

Yes, I've done that too, I guess we learn what's bad by doing it.

> The thing is, "recursive" doesn't mean "same CPU" or "same process" or 
> "same thread" or anything like that. It means "same *dependency-chain*". 
> With the very real implication that you literally have to pass the "lock 
> instance" (whether that is a cookie or anything else) around, and thus 
> really generate the proper chain.
> 
> For example, in CPU hotplug, the dependency chain really did end up moving 
> between different execution contexts, iirc (eg from process context into 
> kernel workqueues).
> 

I agree with whatever you've said so far. The original intention of
every lock is to protect data not code. In the example mentioned before
and in the case of CPU hotplug, what we intend to do, is to prevent
the writer from causing a deadlock. We create a deadlock, as a
side-effect of the locking is fair.

I guess what we might need is a variant of unfair locks. Tracking owners
is one way of eliminating deadlocks that occur, specially since the
reader-writer lock does not allow readers to provide fair locking.
I think this is where RCU excels, it allows readers/writers to proceed
almost independently.

> So we could add some kind of recursive interface that maintained a list of 
> ownership or whatever, but the fact remains that after 16 years, we still 
> haven't really needed it, except for code that is so ugly and broken that 
> pretty much everybody really feels it should be rewritten (and generally 
> for *other* reasons) anyway.
> 

Recursive mutexes are meant for a special purpose. Uncontrolled use of
recursive locks would be really bad.

> So I'm not categorically against nesting, but I'm certainly down on it, 
> and I think it's almost always done wrong.
> 

Yes, recursive locking needs to be designed with care and usage reviewed
with a lot of attention.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
