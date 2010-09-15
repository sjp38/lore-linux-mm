Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 9C4BA6B007D
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 06:58:38 -0400 (EDT)
Message-ID: <4C90A6C7.9050607@redhat.com>
Date: Wed, 15 Sep 2010 12:58:15 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] Cross Memory Attach
References: <20100915104855.41de3ebf@lilo>
In-Reply-To: <20100915104855.41de3ebf@lilo>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christopher Yeoh <cyeoh@au1.ibm.com>
Cc: linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

  On 09/15/2010 03:18 AM, Christopher Yeoh wrote:
> The basic idea behind cross memory attach is to allow MPI programs doing
> intra-node communication to do a single copy of the message rather than
> a double copy of the message via shared memory.

If the host has a dma engine (many modern ones do) you can reduce this 
to zero copies (at least, zero processor copies).

> The following patch attempts to achieve this by allowing a
> destination process, given an address and size from a source process, to
> copy memory directly from the source process into its own address space
> via a system call. There is also a symmetrical ability to copy from
> the current process's address space into a destination process's
> address space.
>
>

Instead of those two syscalls, how about a vmfd(pid_t pid, ulong start, 
ulong len) system call which returns an file descriptor that represents 
a portion of the process address space.  You can then use preadv() and 
pwritev() to copy memory, and io_submit(IO_CMD_PREADV) and 
io_submit(IO_CMD_PWRITEV) for asynchronous variants (especially useful 
with a dma engine, since that adds latency).

With some care (and use of mmu_notifiers) you can even mmap() your vmfd 
and access remote process memory directly.

A nice property of file descriptors is that you can pass them around 
securely via SCM_RIGHTS.  So a process can create a window into its 
address space and pass it to other processes.

(or you could just use a shared memory object and pass it around)

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
