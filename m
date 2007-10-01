Date: Mon, 1 Oct 2007 09:11:24 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch] splice mmap_sem deadlock
In-Reply-To: <4701161E.3030204@linux.vnet.ibm.com>
Message-ID: <alpine.LFD.0.999.0710010905070.3579@woody.linux-foundation.org>
References: <20070928160035.GD12538@wotan.suse.de> <20070928173144.GA11717@kernel.dk>
 <alpine.LFD.0.999.0709281109290.3579@woody.linux-foundation.org>
 <20070928181513.GB11717@kernel.dk> <alpine.LFD.0.999.0709281120220.3579@woody.linux-foundation.org>
 <20070928193017.GC11717@kernel.dk> <alpine.LFD.0.999.0709281247490.3579@woody.linux-foundation.org>
 <alpine.LFD.0.999.0709281303250.3579@woody.linux-foundation.org>
 <20071001120330.GE5303@kernel.dk> <alpine.LFD.0.999.0710010807360.3579@woody.linux-foundation.org>
 <4701161E.3030204@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Jens Axboe <jens.axboe@oracle.com>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


On Mon, 1 Oct 2007, Balbir Singh wrote:
> 
> Sounds very similar to the problems we had with CPU hotplug earlier.
> It's a rwlock locking anti-pattern. I know that recursive locks
> have been frowned upon earlier, but I wonder if there is a case here.
> Of-course recursive locks would not be *fair*.

The problem with recursive locks is that they are inevitably done wrong.

For example, the "natural" way  to do them is to just save the process ID 
or something like that. Which is utter crap. Yet, people do it *every* 
single time (yes, I've done it too, I admit).

The thing is, "recursive" doesn't mean "same CPU" or "same process" or 
"same thread" or anything like that. It means "same *dependency-chain*". 
With the very real implication that you literally have to pass the "lock 
instance" (whether that is a cookie or anything else) around, and thus 
really generate the proper chain.

For example, in CPU hotplug, the dependency chain really did end up moving 
between different execution contexts, iirc (eg from process context into 
kernel workqueues).

So we could add some kind of recursive interface that maintained a list of 
ownership or whatever, but the fact remains that after 16 years, we still 
haven't really needed it, except for code that is so ugly and broken that 
pretty much everybody really feels it should be rewritten (and generally 
for *other* reasons) anyway.

So I'm not categorically against nesting, but I'm certainly down on it, 
and I think it's almost always done wrong.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
