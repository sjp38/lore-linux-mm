Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id D033E6B0095
	for <linux-mm@kvack.org>; Tue, 14 May 2013 06:32:12 -0400 (EDT)
Received: by mail-ve0-f180.google.com with SMTP id pa12so348154veb.39
        for <linux-mm@kvack.org>; Tue, 14 May 2013 03:32:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <kmrak0$ip1$1@ger.gmane.org>
References: <kmrak0$ip1$1@ger.gmane.org>
Date: Tue, 14 May 2013 18:32:11 +0800
Message-ID: <CACVXFVNQVbe6MjWd9sH4wMK9fRCqxdvX2qSrep9GPfPPWOJ54A@mail.gmail.com>
Subject: Re: Yet another page fault deadlock
From: Ming Lei <tom.leiming@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Maluka <D.Maluka@adbglobal.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, May 14, 2013 at 2:13 AM, Dmitry Maluka <D.Maluka@adbglobal.com> wrote:
> Hi,
>
> Sometimes we run into an interesting deadlock on mm->mmap_sem. I see it
> is similar to these deadlocks:
>
> https://lkml.org/lkml/2005/2/22/123
> https://lkml.org/lkml/2001/9/17/105
>
> in the sense that it is too triggered by page faults and is explained by
> "fair" rwsem semantics (pending write lock blocks further read locks).
>
> First, let me describe the prerequisites. It is an embedded MIPS
> platform. We have 2 custom kernel drivers (call them A and B):
>
> - Driver A implements hardware encryption/decryption. It acts both as a
> char device driver and as an in-kernel library with an API allowing
> other kernel modules to encrypt/decrypt data. Important point: driver A
> uses a single mutex (call it A_mutex) to protect all its operations,
> regardless of whether they are requested by user space or by another
> kernel module.
>
> - Driver B is a block device driver implementing a transparent encrypted
> storage. It uses driver A's in-kernel API for encryption during write
> and decryption during read.
>
> We have squashfs mounted on a block device provided by driver B. And we
> have a user-space process with a plenty of threads in it (call them
> thread 1, 2, 3, ...).
>
> Now, the sequence leading to the deadlock:
>
> 1. Thread 1 needs to encrypt or decrypt some data. It uses char device
> interface provided by driver A. Upon driver entry, it first locks A_mutex.
>
> 2. Thread 2 reads from a mmap'ed file on squashfs. Page fault is
> generated. do_page_fault() read-locks mm->mmap_sem. Then squashfs
> filemap fault handler is called, then read request is sent to driver B,
> then driver B calls an API function from driver A. This function first
> tries to lock A_mutex, and hangs on it.
>
> 3. Thread 3 does a syscall which requires mm->mmap_sem write-locked
> (sometimes it is mmap, sometimes mprotect). It hangs on mm->mmap_sem.
>
> 4. Thread 1 proceeds with handling the request from user space from step
> 1. During copy_to_user() or copy_from_user() page fault is generated.
> do_page_fault() tries to read-lock mm->mmap_sem and hangs on it.

If the user buffer passed to driver A is mapped against file on the block
device, single thread 1 may still deadlock on the mutex A.

>
> This deadlock does not happen if we memset() the entire user space
> buffer in thread 1 before doing the syscall. I.e. we make sure that the

It can't be avoided 100% with the memset() workaround since the user
buffer might be swapped out.

> buffer is fully mapped before the request to driver A, preventing demand
> paging during copy_to/from_user(). We are currently using it as a
> workaround.
>
> So... I realize that in our case the deadlock is caused by our
> proprietary component (driver A) whose authors were smart guys but not
> farsighted enough to anticipate this scenario. Now we are considering
> reworking driver A to make all copy_to/from_user() calls without A_mutex
> locked. This should remove the deadlock source, AFAICS.

Looks there are some similar examples, one of them is b31ca3f5df( sysfs:
fix deadlock).

>
> However, it looks like a general internal kernel architecture problem.
> The whole page fault handling procedure is done with mm->mmap_sem
> read-held, and due to rwsem semantics, down_read/down_write/down_read
> deadlock may happen if two threads are getting page fault and a third
> thread is trying to write-lock mm->mmap_sem. So all the code performing
> page fault handling procedure should be especially careful about
> avoiding such deadlock. But this is a complex procedure involving
> different subsystems, particularly, arbitrary block device driver. So
> any block device driver should be implemented with this in mind. While
> this is probably not documented anywhere.

Maybe it is good to document the lock usage, but the rule isn't much
complicated: if one lock may be held under mmap_sem, the lock can't be
held before copy_to/from_user(), :-)


Thanks,
-- 
Ming Lei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
