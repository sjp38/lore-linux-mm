Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 700C06B004A
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 09:52:08 -0400 (EDT)
Date: Wed, 15 Sep 2010 15:51:55 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [RFC][PATCH] Cross Memory Attach
Message-ID: <20100915135155.GA25210@elte.hu>
References: <20100915104855.41de3ebf@lilo>
 <4C90A6C7.9050607@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4C90A6C7.9050607@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Christopher Yeoh <cyeoh@au1.ibm.com>, linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>


* Avi Kivity <avi@redhat.com> wrote:

>  On 09/15/2010 03:18 AM, Christopher Yeoh wrote:
>
> > The basic idea behind cross memory attach is to allow MPI programs 
> > doing intra-node communication to do a single copy of the message 
> > rather than a double copy of the message via shared memory.
> 
> If the host has a dma engine (many modern ones do) you can reduce this 
> to zero copies (at least, zero processor copies).
> 
> > The following patch attempts to achieve this by allowing a 
> > destination process, given an address and size from a source 
> > process, to copy memory directly from the source process into its 
> > own address space via a system call. There is also a symmetrical 
> > ability to copy from the current process's address space into a 
> > destination process's address space.
> 
> Instead of those two syscalls, how about a vmfd(pid_t pid, ulong 
> start, ulong len) system call which returns an file descriptor that 
> represents a portion of the process address space.  You can then use 
> preadv() and pwritev() to copy memory, and io_submit(IO_CMD_PREADV) 
> and io_submit(IO_CMD_PWRITEV) for asynchronous variants (especially 
> useful with a dma engine, since that adds latency).
> 
> With some care (and use of mmu_notifiers) you can even mmap() your 
> vmfd and access remote process memory directly.
> 
> A nice property of file descriptors is that you can pass them around 
> securely via SCM_RIGHTS.  So a process can create a window into its 
> address space and pass it to other processes.
> 
> (or you could just use a shared memory object and pass it around)

Interesting, but how will that work in a scalable way with lots of 
non-thread tasks?

Say we have 100 processes. We'd have to have 100 fd's - each has to be 
passed to a new worker process.

In that sense a PID is just as good of a reference as an fd - it can be 
looked up lockless, etc. - but has the added advantage that it can be 
passed along just by number.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
