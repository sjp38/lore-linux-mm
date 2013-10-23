Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 986C56B00DC
	for <linux-mm@kvack.org>; Wed, 23 Oct 2013 05:53:45 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id xb12so691108pbc.36
        for <linux-mm@kvack.org>; Wed, 23 Oct 2013 02:53:45 -0700 (PDT)
Received: from psmtp.com ([74.125.245.148])
        by mx.google.com with SMTP id sw1si1497572pbc.312.2013.10.23.02.53.43
        for <linux-mm@kvack.org>;
        Wed, 23 Oct 2013 02:53:44 -0700 (PDT)
Received: by mail-ea0-f169.google.com with SMTP id k11so291172eaj.0
        for <linux-mm@kvack.org>; Wed, 23 Oct 2013 02:53:41 -0700 (PDT)
Date: Wed, 23 Oct 2013 02:53:37 -0700
From: walken@google.com
Subject: Re: [PATCH 3/3] vdso: preallocate new vmas
Message-ID: <20131023095337.GC2862@localhost>
References: <1382057438-3306-1-git-send-email-davidlohr@hp.com>
 <1382057438-3306-4-git-send-email-davidlohr@hp.com>
 <1382325975.2402.3.camel@buesod1.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1382325975.2402.3.camel@buesod1.americas.hpqcorp.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Michel Lespinasse <walken@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Tim Chen <tim.c.chen@linux.intel.com>, aswin@hp.com, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Russell King <linux@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Richard Kuo <rkuo@codeaurora.org>, Ralf Baechle <ralf@linux-mips.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Paul Mundt <lethal@linux-sh.org>, Chris Metcalf <cmetcalf@tilera.com>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>

On Sun, Oct 20, 2013 at 08:26:15PM -0700, Davidlohr Bueso wrote:
> From: Davidlohr Bueso <davidlohr@hp.com>
> Subject: [PATCH v2 3/3] vdso: preallocate new vmas
> 
> With the exception of um and tile, architectures that use
> the install_special_mapping() function, when setting up a
> new vma at program startup, do so with the mmap_sem lock
> held for writing. Unless there's an error, this process
> ends up allocating a new vma through kmem_cache_zalloc,
> and inserting it in the task's address space.
> 
> This patch moves the vma's space allocation outside of
> install_special_mapping(), and leaves the callers to do so
> explicitly, without depending on mmap_sem. The same goes for
> freeing: if the new vma isn't used (and thus the process fails
> at some point), it's caller's responsibility to free it -
> currently this is done inside install_special_mapping.
> 
> Furthermore, uprobes behaves exactly the same and thus now the
> xol_add_vma() function also preallocates the new vma.
> 
> While the changes to x86 vdso handling have been tested on both
> large and small 64-bit systems, the rest of the architectures
> are totally *untested*. Note that all changes are quite similar
> from architecture to architecture.
> 
> Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
> Cc: Russell King <linux@arm.linux.org.uk>
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: Richard Kuo <rkuo@codeaurora.org>
> Cc: Ralf Baechle <ralf@linux-mips.org>
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Paul Mackerras <paulus@samba.org>
> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> Cc: Paul Mundt <lethal@linux-sh.org>
> Cc: Chris Metcalf <cmetcalf@tilera.com>
> Cc: Jeff Dike <jdike@addtoit.com>
> Cc: Richard Weinberger <richard@nod.at>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
> ---
> v2:
> - Simplify install_special_mapping interface (Linus Torvalds)
> - Fix return for uml_setup_stubs when mem allocation fails (Richard Weinberger)

I'm still confused as to why you're seeing any gains with this
one. This code runs during exec when mm isn't shared with any other
threads yet, so why does it matter how long the mmap_sem is held since
nobody else can contend on it ? (well, except for accesses from
/fs/proc/base.c, but I don't see why these would matter in your
benchmarks either).

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
