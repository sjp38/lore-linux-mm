Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp01.au.ibm.com (8.13.1/8.13.1) with ESMTP id l91FkE71010360
	for <linux-mm@kvack.org>; Tue, 2 Oct 2007 01:46:14 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l91Fk4hx4645086
	for <linux-mm@kvack.org>; Tue, 2 Oct 2007 01:46:04 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l91Fjms2025256
	for <linux-mm@kvack.org>; Tue, 2 Oct 2007 01:45:48 +1000
Message-ID: <4701161E.3030204@linux.vnet.ibm.com>
Date: Mon, 01 Oct 2007 21:15:34 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [patch] splice mmap_sem deadlock
References: <20070928160035.GD12538@wotan.suse.de> <20070928173144.GA11717@kernel.dk> <alpine.LFD.0.999.0709281109290.3579@woody.linux-foundation.org> <20070928181513.GB11717@kernel.dk> <alpine.LFD.0.999.0709281120220.3579@woody.linux-foundation.org> <20070928193017.GC11717@kernel.dk> <alpine.LFD.0.999.0709281247490.3579@woody.linux-foundation.org> <alpine.LFD.0.999.0709281303250.3579@woody.linux-foundation.org> <20071001120330.GE5303@kernel.dk> <alpine.LFD.0.999.0710010807360.3579@woody.linux-foundation.org>
In-Reply-To: <alpine.LFD.0.999.0710010807360.3579@woody.linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Jens Axboe <jens.axboe@oracle.com>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> The comment is wrong.
> 
> On Mon, 1 Oct 2007, Jens Axboe wrote:
>>  
>>  /*
>> + * Do a copy-from-user while holding the mmap_semaphore for reading. If we
>> + * have to fault the user page in, we must drop the mmap_sem to avoid a
>> + * deadlock in the page fault handling (it wants to grab mmap_sem too, but for
>> + * writing). This assumes that we will very rarely hit the partial != 0 path,
>> + * or this will not be a win.
>> + */
> 
> Page faulting only grabs it for reading, and having a page fault happen is 
> not problematic in itself. Readers *do* nest.
> 
> What is problematic is:
> 
> 	thread#1			thread#2
> 
> 	get_iovec_page_array
> 	down_read()
> 	.. everything ok so far ..
> 					mmap()
> 					down_write()
> 					.. correctly blocks on the reader ..
> 					.. everything ok so far ..
> 
> 	.. pagefault ..
> 	down_read()
> 	.. fairness code now blocks on the waiting writer! ..
> 	.. oops. We're deadlocked ..
> 
> So the problem is that while readers do nest nicely, they only do so if no 
> potential writers can possibly exist (which of course never happens: an 
> rwlock with no writers is a no-op ;).

Sounds very similar to the problems we had with CPU hotplug earlier.
It's a rwlock locking anti-pattern. I know that recursive locks
have been frowned upon earlier, but I wonder if there is a case here.
Of-course recursive locks would not be *fair*.

The other solution of passing down lock ownership information is a pain.

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
