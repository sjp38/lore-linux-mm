Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6B4425F0001
	for <linux-mm@kvack.org>; Sat, 30 May 2009 14:05:48 -0400 (EDT)
Date: Sat, 30 May 2009 20:05:40 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch 5/5] Apply the PG_sensitive flag to the CryptoAPI
	subsystem
Message-ID: <20090530180540.GE20013@elte.hu>
References: <20090520190519.GE10756@oblivion.subreption.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090520190519.GE10756@oblivion.subreption.com>
Sender: owner-linux-mm@kvack.org
To: "Larry H." <research@subreption.com>
Cc: linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, pageexec@freemail.hu, linux-crypto@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>


* Larry H. <research@subreption.com> wrote:

> This patch deploys the use of the PG_sensitive page allocator flag 
> within the CryptoAPI subsystem, in all relevant locations where 
> algorithm and key contexts are allocated.
> 
> Some calls to memset for zeroing the buffers have been removed to 
> avoid duplication of the sanitizing process, since this is already 
> taken care of by the allocator during page freeing.
> 
> The only noticeable impact on performance might be in the 
> blkcipher modifications, although this is likely negligible and 
> balanced with the security benefits of this patch in the long 
> term.

I think there's a rather significant omission here: there's no 
discussion about on-kernel-stack information leaking out.

If a thread that does a crypto call happens to leave sensitive 
on-stack data (this can happen easily as stack variables are not 
cleared on return), or if a future variant or modification of a 
crypto algorithm leaves such information around - then there's 
nothing that keeps that data from potentially leaking out.

This is not academic and it happens all the time: only look at 
various crash dumps on lkml. For example this crash shows such 
leaked information:

[   96.138788]  [<ffffffff810ab62e>] perf_counter_exit_task+0x10e/0x3f3
[   96.145464]  [<ffffffff8104cf46>] do_exit+0x2e7/0x722
[   96.150837]  [<ffffffff810630cf>] ? up_read+0x9/0xb
[   96.156036]  [<ffffffff8151cc0b>] ? do_page_fault+0x27d/0x2a5
[   96.162141]  [<ffffffff8104d3f4>] do_group_exit+0x73/0xa0
[   96.167860]  [<ffffffff8104d433>] sys_exit_group+0x12/0x16
[   96.173665]  [<ffffffff8100bb2b>] system_call_fastpath+0x16/0x1b

The 'ffffffff8151cc0b' 64-bit word is actually a leftover from a 
previous system context. ( And this is at the bottom of the stack 
that gets cleared all the time - the top of the kernel stack is a 
lot more more persistent in practice and crypto calls tend to have a 
healthy stack footprint. )

So IMO the GFP_SENSITIVE facility (beyond being misnomer - it should 
be something like GFP_NON_PERSISTENT instead) actually results in 
_worse_ security in the end: because people (and organizations) 
'think' that their keys are safe against information leaks via this 
space, while they are not. The kernel stack can be freed, be reused 
by something else partially and then written out to disk (say as 
part of hibernation) where it's recoverable from the disk image.

So this whole facility probably only makes sense if all kernel 
stacks that handle sensitive data are zeroed on free. But i havent 
seen any kernel thread stack clearing functionality in this 
patch-set - is it an intentional omission? (or have i missed some 
aspect of the patch-set)

Also, there's no discussion about long-lived threads keeping 
sensitive information in there kernel stack indefinitely.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
