Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 9B4166B004A
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 10:42:47 -0400 (EDT)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp01.au.ibm.com (8.14.4/8.13.1) with ESMTP id o8FEdjJK021265
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 00:39:45 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o8FEgg1o897274
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 00:42:42 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o8FEgfsU023182
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 00:42:42 +1000
Date: Thu, 16 Sep 2010 00:12:32 +0930
From: Christopher Yeoh <cyeoh@au1.ibm.com>
Subject: Re: [RFC][PATCH] Cross Memory Attach
Message-ID: <20100916001232.0c496b02@lilo>
In-Reply-To: <4C90A6C7.9050607@redhat.com>
References: <20100915104855.41de3ebf@lilo>
 <4C90A6C7.9050607@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Wed, 15 Sep 2010 12:58:15 +0200
Avi Kivity <avi@redhat.com> wrote:

>   On 09/15/2010 03:18 AM, Christopher Yeoh wrote:
> > The basic idea behind cross memory attach is to allow MPI programs
> > doing intra-node communication to do a single copy of the message
> > rather than a double copy of the message via shared memory.
> 
> If the host has a dma engine (many modern ones do) you can reduce
> this to zero copies (at least, zero processor copies).

Yes, this interface doesn't really support that. I've tried to keep
things really simple here, but I see potential for increasing
level/complexity of support with diminishing returns:

1. single copy (basically what the current implementation does)
2. support for async dma offload (rather arch specific)
3. ability to map part of another process's address space directly into
   the current one. Would have setup/tear down overhead, but this would
   be useful specifically for reduction operations where we don't even
   need to really copy the data once at all, but use it directly in
   arithmetic/logical operations on the receiver.

For reference, there is also knem http://runtime.bordeaux.inria.fr/knem/
which does implement (2) for I/OAT, though it looks to me the interface
and implementation are relatively speaking quite a bit more complex.

> Instead of those two syscalls, how about a vmfd(pid_t pid, ulong
> start, ulong len) system call which returns an file descriptor that
> represents a portion of the process address space.  You can then use
> preadv() and pwritev() to copy memory, and io_submit(IO_CMD_PREADV)
> and io_submit(IO_CMD_PWRITEV) for asynchronous variants (especially
> useful with a dma engine, since that adds latency).
> 
> With some care (and use of mmu_notifiers) you can even mmap() your
> vmfd and access remote process memory directly.

That interface sounds interesting (I'm not sure I understand how
this would be implemented), though this would mean that a file
descriptor would need to be created for every message that
each process sent wouldn't it?

Regards,

Chris
-- 
cyeoh@au.ibm.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
