Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id E68086B004F
	for <linux-mm@kvack.org>; Sun, 31 May 2009 06:14:06 -0400 (EDT)
From: pageexec@freemail.hu
Date: Sun, 31 May 2009 12:14:31 +0200
MIME-Version: 1.0
Subject: Re: [patch 5/5] Apply the PG_sensitive flag to the CryptoAPI subsystem
Reply-to: pageexec@freemail.hu
Message-ID: <4A225887.21178.1C8AE762@pageexec.freemail.hu>
In-reply-to: <20090530180540.GE20013@elte.hu>
References: <20090520190519.GE10756@oblivion.subreption.com>, <20090530180540.GE20013@elte.hu>
Content-type: text/plain; charset=US-ASCII
Content-transfer-encoding: 7BIT
Content-description: Mail message body
Sender: owner-linux-mm@kvack.org
To: "Larry H." <research@subreption.com>, Ingo Molnar <mingo@elte.hu>
Cc: linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, linux-crypto@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On 30 May 2009 at 20:05, Ingo Molnar wrote:

> I think there's a rather significant omission here: there's no 
> discussion about on-kernel-stack information leaking out.
> 
> If a thread that does a crypto call happens to leave sensitive 
> on-stack data (this can happen easily as stack variables are not 
> cleared on return), or if a future variant or modification of a 
> crypto algorithm leaves such information around - then there's 
> nothing that keeps that data from potentially leaking out.
> 
> This is not academic and it happens all the time: only look at 
> various crash dumps on lkml. For example this crash shows such 
> leaked information:
> 
> [   96.138788]  [<ffffffff810ab62e>] perf_counter_exit_task+0x10e/0x3f3
> [   96.145464]  [<ffffffff8104cf46>] do_exit+0x2e7/0x722
> [   96.150837]  [<ffffffff810630cf>] ? up_read+0x9/0xb
> [   96.156036]  [<ffffffff8151cc0b>] ? do_page_fault+0x27d/0x2a5
> [   96.162141]  [<ffffffff8104d3f4>] do_group_exit+0x73/0xa0
> [   96.167860]  [<ffffffff8104d433>] sys_exit_group+0x12/0x16
> [   96.173665]  [<ffffffff8100bb2b>] system_call_fastpath+0x16/0x1b
> 
> The 'ffffffff8151cc0b' 64-bit word is actually a leftover from a 
> previous system context. ( And this is at the bottom of the stack 
> that gets cleared all the time - the top of the kernel stack is a 
> lot more more persistent in practice and crypto calls tend to have a 
> healthy stack footprint. )
> 
> So IMO the GFP_SENSITIVE facility (beyond being misnomer - it should 
> be something like GFP_NON_PERSISTENT instead) actually results in 
> _worse_ security in the end: because people (and organizations) 
> 'think' that their keys are safe against information leaks via this 
> space, while they are not. The kernel stack can be freed, be reused 
> by something else partially and then written out to disk (say as 
> part of hibernation) where it's recoverable from the disk image.
> 
> So this whole facility probably only makes sense if all kernel 
> stacks that handle sensitive data are zeroed on free. But i havent 
> seen any kernel thread stack clearing functionality in this 
> patch-set - is it an intentional omission? (or have i missed some 
> aspect of the patch-set)

i think you missed the fact that the page flag based approach had been
abandoned already in favour of unconditional page sanitizing on free
(modulo a kernel boot option). the other approach of doing the sanitizing
on a smaller allocation base (kfree, etc) is orthogonal to this one since
they address the lifetime problem at different levels (i'm just making it
clear since you brought up a freed kernel stack ending up in a hibernation
image and leaving data there, that obviously won't happen as the freed
kernel stack pages will be sanitized on free).

now as for kernel stacks. first of all, the original idea of sanitization
was meant to address userland secrets staying around for too long, little
if any of that is long-lived on kernel stacks.

kernel data lifetime got affected by virtue of doing the sanitization at
the lowest possible level of the page allocator (which was in turn favoured
over the page flag and strict 'userland data only' sanitization due to its
simplicity, a few lines of code literally). so consider that as a fortunate
sideeffect.

with that said, there's certainly room for evolution, both in addressing
more kind of data (it's not only the kernel stack you mention but also the
userland stack whose unused pages can be taken back for example) and/or
reducing lifetime further. i personally never bothered with any of that
because the original request/goal was already addressed.

> Also, there's no discussion about long-lived threads keeping 
> sensitive information in there kernel stack indefinitely.

kernel stack clearing isn't hard to do, just do it on every syscall exit
and in the infinite loop for kernel threads.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
