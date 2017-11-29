Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2D75B6B0033
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 02:43:07 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id l14so1631850pgu.17
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 23:43:07 -0800 (PST)
Received: from EUR03-DB5-obe.outbound.protection.outlook.com (mail-eopbgr40128.outbound.protection.outlook.com. [40.107.4.128])
        by mx.google.com with ESMTPS id k185si864093pge.131.2017.11.28.23.43.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 28 Nov 2017 23:43:04 -0800 (PST)
Date: Tue, 28 Nov 2017 23:42:46 -0800
From: Andrei Vagin <avagin@virtuozzo.com>
Subject: Re: [PATCH v4 2/4] vm: add a syscall to map a process memory into a
 pipe
Message-ID: <20171129074245.GA32319@outlook.office365.com>
References: <1511767181-22793-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1511767181-22793-3-git-send-email-rppt@linux.vnet.ibm.com>
 <20171127154249.39e60ecf72019216f2f1782d@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20171127154249.39e60ecf72019216f2f1782d@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, criu@openvz.org, Arnd Bergmann <arnd@arndb.de>, Pavel Emelyanov <xemul@virtuozzo.com>, Michael Kerrisk <mtk.manpages@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Josh Triplett <josh@joshtriplett.org>, Jann Horn <jannh@google.com>, Greg KH <gregkh@linuxfoundation.org>, Andrei Vagin <avagin@openvz.org>

On Mon, Nov 27, 2017 at 03:42:49PM -0800, Andrew Morton wrote:
> On Mon, 27 Nov 2017 09:19:39 +0200 Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:
> 
> > From: Andrei Vagin <avagin@virtuozzo.com>
> > 
> > It is a hybrid of process_vm_readv() and vmsplice().
> > 
> > vmsplice can map memory from a current address space into a pipe.
> > process_vm_readv can read memory of another process.
> > 
> > A new system call can map memory of another process into a pipe.
> > 
> > ssize_t process_vmsplice(pid_t pid, int fd, const struct iovec *iov,
> >                         unsigned long nr_segs, unsigned int flags)
> > 
> > All arguments are identical with vmsplice except pid which specifies a
> > target process.
> > 
> > Currently if we want to dump a process memory to a file or to a socket,
> > we can use process_vm_readv() + write(), but it works slow, because data
> > are copied into a temporary user-space buffer.
> > 
> > A second way is to use vmsplice() + splice(). It is more effective,
> > because data are not copied into a temporary buffer, but here is another
> > problem. vmsplice works with the currect address space, so it can be
> > used only if we inject our code into a target process.
> > 
> > The second way suffers from a few other issues:
> > * a process has to be stopped to run a parasite code
> > * a number of pipes is limited, so it may be impossible to dump all
> >   memory in one iteration, and we have to stop process and inject our
> >   code a few times.
> > * pages in pipes are unreclaimable, so it isn't good to hold a lot of
> >   memory in pipes.
> > 
> > The introduced syscall allows to use a second way without injecting any
> > code into a target process.
> > 
> > My experiments shows that process_vmsplice() + splice() works two time
> > faster than process_vm_readv() + write().
> >
> > It is particularly useful on a pre-dump stage. On this stage we enable a
> > memory tracker, and then we are dumping  a process memory while a
> > process continues work. On the first iteration we are dumping all
> > memory, and then we are dumpung only modified memory from a previous
> > iteration.  After a few pre-dump operations, a process is stopped and
> > dumped finally. The pre-dump operations allow to significantly decrease
> > a process downtime, when a process is migrated to another host.
> 
> What is the overall improvement in a typical dumping operation?
> 
> Does that improvement justify the addition of a new syscall, and all
> that this entails?  If so, why?

In criu, we have a pre-dump operation, which is used to reduce a process
downtime during live migration of processes. The pre-dump operation
allows to dump memory without stopping processes. On the first
iteration, criu pre-dump dumps the whole memory of processes, on the
second iteration it saves only changed pages after the first pre-dump
and so on.

The primary goal here is to do this operation without a downtime of
processes, or as maximum this downtime has to be as small as possible.

Currently when we are doing pre-dump, we do next steps:

1. stop all processes by ptrace
2. inject a parasite code into each process to call vmsplice
3. read /proc/pid/pagemap and splice all dirty pages into pipes
4. reset the soft-dirty memory tracker
5. resume processes
6. splice memory from pipe to sockets

But this way has a few limitations:

1. We need to inject a parasite code into processes. This operation is
slow, and it requires to stop processes, so we can't do this step many
times. As result, we have to splice the whole memory to pipes at once.

2. A number of pipes are limited, and a size of each pipe is limited

A default limit for a number of file descriptors is 1024. ?The reliable
maximum pipe size is 3354624 bytes.

? ? ? ? pipe->bufs = kcalloc(pipe_bufs, sizeof(struct pipe_buffer),
? ? ? ? ? ? ? ? ? ? ? ? ? ? ?GFP_KERNEL_ACCOUNT);

so the maximum pipe size can be calculated by this formula:
(1 << PAGE_ALLOC_COSTLY_ORDER) * PAGE_SIZE / sizeof(struct
kernel_pipe_buffer)) * PAGE_SIZE)

This means that we can dump only 1.5 GB of memory.

The major issue of this way is that we need to inject a parasite code
and we can't do this many times, so we have to splice the whole memory
in one iteration.

With the introduced syscall, we are able to splice memory without a
parasite code and even without stopping processes, so we can dump memory
in a few iterations.

> 
> Are there any other applications of this syscall?
> 


For example, gdb can use it to generate a core file, it can splice
memory of a process into a pipe and then splice it from the pipe to a file.
This method works much faster than using PTRACE_PEEK* commands.

This syscall can be interesting for users of process_vm_readv(), in case
if they read memory to send it to somewhere else.

process_vmsplice() may be useful for debuggers from another side.
process_vmsplice() attaches a real process page to a pipe, so we can
splice it once and observe how it is being changed many times.

Thanks,
Andrei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
