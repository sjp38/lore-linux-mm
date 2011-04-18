Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 54C40900086
	for <linux-mm@kvack.org>; Sun, 17 Apr 2011 23:34:09 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 08F773EE0AE
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 12:34:04 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id DC06045DE55
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 12:34:03 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B92C345DD74
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 12:34:03 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id AB9A7E08001
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 12:34:03 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6883C1DB802C
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 12:34:03 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: mm: convert vma->vm_flags to 64bit
In-Reply-To: <1303091139.28876.152.camel@pasglop>
References: <alpine.LSU.2.00.1104171649350.21405@sister.anvils> <1303091139.28876.152.camel@pasglop>
Message-Id: <20110418123422.9341.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Mon, 18 Apr 2011 12:34:02 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Mundt <lethal@linux-sh.org>, Russell King <linux@arm.linux.org.uk>

Hi

> On Sun, 2011-04-17 at 17:26 -0700, Hugh Dickins wrote:
> > I am surprised that
> > #define VM_EXEC         0x00000004ULL
> > does not cause trouble for arch/arm/kernel/asm-offsets.c,
> > but you tried cross-building it which I never did.
> 
> It would probably cause trouble for a big endian ARM no ? In that case
> it should offset the load by 4.

I think you are talking two thing, VM_EXEC and offsetof(vm_flags).
Therefore I'd explain my code reading result of two.

1) VM_EXEC

arch/arm/kernel/asm-offsets.c
----------------------------------------------------------------
  DEFINE(VM_EXEC,               VM_EXEC);

kbuild.h
----------------------------------------------------------------
#define DEFINE(sym, val) \
        asm volatile("\n->" #sym " %0 " #val : : "i" (val))

In this case, gcc asm() statement recognize C suffix and then
we don't see compile and/or link-time error.

2) vm_flags

arch/arm/kernel/asm-offsets.c
----------------------------------------------------------------
  DEFINE(VMA_VM_FLAGS,          offsetof(struct vm_area_struct, vm_flags));

OK, this is risky. we have to see all of users of this.


arch/arm/mm/proc-macros.S
----------------------------------------------------------------
/*
 * vma_vm_flags - get vma->vm_flags
 */
        .macro  vma_vm_flags, rd, rn
        ldr     \rd, [\rn, #VMA_VM_FLAGS]
        .endm


VMA_VM_FLAGS is only used this macro. then, we only need to see
vma_vm_flags assembler macro.

Next, 

% grep ENDIAN arch/arm/configs/*
arch/arm/configs/ixp2000_defconfig:CONFIG_CPU_BIG_ENDIAN=y
arch/arm/configs/ixp23xx_defconfig:CONFIG_CPU_BIG_ENDIAN=y
arch/arm/configs/ixp4xx_defconfig:CONFIG_CPU_BIG_ENDIAN=y

We only need to care the three subarch.

-----------------------------------------------------------
config ARCH_IXP23XX
        bool "IXP23XX-based"
        depends on MMU
        select CPU_XSC3
        select PCI
        select ARCH_USES_GETTIMEOFFSET
        help
          Support for Intel's IXP23xx (XScale) family of processors.

config ARCH_IXP2000
        bool "IXP2400/2800-based"
        depends on MMU
        select CPU_XSCALE
        select PCI
        select ARCH_USES_GETTIMEOFFSET
        help
          Support for Intel's IXP2400/2800 (XScale) family of processors.

config ARCH_IXP4XX
        bool "IXP4xx-based"
        depends on MMU
        select CPU_XSCALE
        select GENERIC_GPIO
        select GENERIC_CLOCKEVENTS
        select HAVE_SCHED_CLOCK
        select MIGHT_HAVE_PCI
        select DMABOUNCE if PCI
        help
          Support for Intel's IXP4XX (XScale) family of processors.
-----------------------------------------------------------

and they are CONFIG_CPU_XSCALE or CONFIG_CPU_XSC3.

arch/arm/mm/Makefile
-----------------------------------------------------------
obj-$(CONFIG_CPU_XSCALE)        += proc-xscale.o
obj-$(CONFIG_CPU_XSC3)          += proc-xsc3.o

grep -c  vma_vm_flags arch/arm/mm/proc-{xscale,xsc3}.S
arch/arm/mm/proc-xscale.S:0
arch/arm/mm/proc-xsc3.S:0


Then, current big endian user aren't harm from this change.

Of course, I might take mistake. I'm not arm expert. please correct
me if I'm misunderstand.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
