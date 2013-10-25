Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id A0EF56B00DD
	for <linux-mm@kvack.org>; Thu, 24 Oct 2013 20:55:57 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id wz7so2792832pbc.24
        for <linux-mm@kvack.org>; Thu, 24 Oct 2013 17:55:57 -0700 (PDT)
Received: from psmtp.com ([74.125.245.151])
        by mx.google.com with SMTP id yh6si3337857pab.266.2013.10.24.17.55.56
        for <linux-mm@kvack.org>;
        Thu, 24 Oct 2013 17:55:56 -0700 (PDT)
Message-ID: <1382662541.2373.20.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH 3/3] vdso: preallocate new vmas
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Thu, 24 Oct 2013 17:55:41 -0700
In-Reply-To: <20131023095337.GC2862@localhost>
References: <1382057438-3306-1-git-send-email-davidlohr@hp.com>
	 <1382057438-3306-4-git-send-email-davidlohr@hp.com>
	 <1382325975.2402.3.camel@buesod1.americas.hpqcorp.net>
	 <20131023095337.GC2862@localhost>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: walken@google.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Tim Chen <tim.c.chen@linux.intel.com>, aswin@hp.com, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Russell King <linux@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Richard Kuo <rkuo@codeaurora.org>, Ralf Baechle <ralf@linux-mips.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Paul Mundt <lethal@linux-sh.org>, Chris Metcalf <cmetcalf@tilera.com>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>

On Wed, 2013-10-23 at 02:53 -0700, walken@google.com wrote:
> On Sun, Oct 20, 2013 at 08:26:15PM -0700, Davidlohr Bueso wrote:
> > From: Davidlohr Bueso <davidlohr@hp.com>
> > Subject: [PATCH v2 3/3] vdso: preallocate new vmas
> > 
> > With the exception of um and tile, architectures that use
> > the install_special_mapping() function, when setting up a
> > new vma at program startup, do so with the mmap_sem lock
> > held for writing. Unless there's an error, this process
> > ends up allocating a new vma through kmem_cache_zalloc,
> > and inserting it in the task's address space.
> > 
> > This patch moves the vma's space allocation outside of
> > install_special_mapping(), and leaves the callers to do so
> > explicitly, without depending on mmap_sem. The same goes for
> > freeing: if the new vma isn't used (and thus the process fails
> > at some point), it's caller's responsibility to free it -
> > currently this is done inside install_special_mapping.
> > 
> > Furthermore, uprobes behaves exactly the same and thus now the
> > xol_add_vma() function also preallocates the new vma.
> > 
> > While the changes to x86 vdso handling have been tested on both
> > large and small 64-bit systems, the rest of the architectures
> > are totally *untested*. Note that all changes are quite similar
> > from architecture to architecture.
> > 
> > Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
> > Cc: Russell King <linux@arm.linux.org.uk>
> > Cc: Catalin Marinas <catalin.marinas@arm.com>
> > Cc: Will Deacon <will.deacon@arm.com>
> > Cc: Richard Kuo <rkuo@codeaurora.org>
> > Cc: Ralf Baechle <ralf@linux-mips.org>
> > Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> > Cc: Paul Mackerras <paulus@samba.org>
> > Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> > Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> > Cc: Paul Mundt <lethal@linux-sh.org>
> > Cc: Chris Metcalf <cmetcalf@tilera.com>
> > Cc: Jeff Dike <jdike@addtoit.com>
> > Cc: Richard Weinberger <richard@nod.at>
> > Cc: Thomas Gleixner <tglx@linutronix.de>
> > Cc: Ingo Molnar <mingo@redhat.com>
> > Cc: "H. Peter Anvin" <hpa@zytor.com>
> > Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
> > ---
> > v2:
> > - Simplify install_special_mapping interface (Linus Torvalds)
> > - Fix return for uml_setup_stubs when mem allocation fails (Richard Weinberger)
> 
> I'm still confused as to why you're seeing any gains with this
> one. This code runs during exec when mm isn't shared with any other
> threads yet, so why does it matter how long the mmap_sem is held since
> nobody else can contend on it ? (well, except for accesses from
> /fs/proc/base.c, but I don't see why these would matter in your
> benchmarks either).

Yeah, that's why I dropped the performance numbers from the changelog in
v2, of course any differences are within the noise range. When I did the
initial runs I was scratching my head as to why I was seeing benefits,
but it was most likely a matter of clock frequency differences, and I no
longer see such boosts.

Thanks,
Davidlohr


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
