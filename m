Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id E8C346B0085
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 06:47:34 -0400 (EDT)
Date: Thu, 11 Jun 2009 12:45:51 +0200
From: Jesper Nilsson <Jesper.Nilsson@axis.com>
Subject: Re: [PATCH 3/7] percpu: clean up percpu variable definitions
Message-ID: <20090611104550.GQ20504@axis.com>
References: <1243846708-805-1-git-send-email-tj@kernel.org> <1243846708-805-4-git-send-email-tj@kernel.org> <20090601.024006.98975069.davem@davemloft.net> <4A23BD20.5030500@kernel.org> <1243919336.5308.32.camel@pasglop> <4A289E3A.30000@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A289E3A.30000@kernel.org>
Sender: owner-linux-mm@kvack.org
To: Tejun Heo <tj@kernel.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, "JBeulich@novell.com" <JBeulich@novell.com>, "andi@firstfloor.org" <andi@firstfloor.org>, "mingo@elte.hu" <mingo@elte.hu>, "hpa@zytor.com" <hpa@zytor.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "ink@jurassic.park.msu.ru" <ink@jurassic.park.msu.ru>, "rth@twiddle.net" <rth@twiddle.net>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "hskinnemoen@atmel.com" <hskinnemoen@atmel.com>, "cooloney@kernel.org" <cooloney@kernel.org>, Mikael Starvik <mikael.starvik@axis.com>, "dhowells@redhat.com" <dhowells@redhat.com>, "ysato@users.sourceforge.jp" <ysato@users.sourceforge.jp>, "tony.luck@intel.com" <tony.luck@intel.com>, "takata@linux-m32r.org" <takata@linux-m32r.org>, "geert@linux-m68k.org" <geert@linux-m68k.org>, "monstr@monstr.eu" <monstr@monstr.eu>, "ralf@linux-mips.org" <ralf@linux-mips.org>, "kyle@mcmartin.ca" <kyle@mcmartin.ca>, "paulus@samba.org" <paulus@samba.org>, "schwidefsky@de.ibm.com" <schwidefsky@de.ibm.com>, "heiko.carstens@de.ibm.com" <heiko.carstens@de.ibm.com>, "lethal@linux-sh.org" <lethal@linux-sh.org>, "jdike@addtoit.com" <jdike@addtoit.com>, "chris@zankel.net" <chris@zankel.net>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, "jens.axboe@oracle.com" <jens.axboe@oracle.com>, "davej@redhat.com" <davej@redhat.com>, "jeremy@xensource.com" <jeremy@xensource.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jun 05, 2009 at 06:25:30AM +0200, Tejun Heo wrote:
> Benjamin Herrenschmidt wrote:
> > On Mon, 2009-06-01 at 20:36 +0900, Tejun Heo wrote:
> >>> Whether the volatile is actually needed or not, it's bad to have this
> >>> kind of potential behavior changing nugget hidden in this seemingly
> >>> inocuous change.  Especially if you're the poor soul who ends up
> >>> having to debug it :-/
> >> You're right.  Aieee... how do I feed volatile to the DEFINE macro.
> >> I'll think of something.
> > 
> > Or better, work with the cris maintainer to figure out whether it's
> > needed (it probably isn't) and have a pre-requisite patch that removes
> > it before your series :-)
> 
> Yeap, that's worth giving a shot.
> 
> Mikael Starvik, can you please enlighten us why volatile is necessary
> there?

I've talked with Mikael, and we both agreed that this was probably
a legacy from earlier versions, and the volatile is no longer needed.

Confirmed by booting and running some video-streaming on an ARTPEC-3
(CRISv32) board.

You can take the following patch as a pre-requisite, or go the way of
the original patch.

From: Jesper Nilsson <jesper.nilsson@axis.com>
Subject: [PATCH] CRIS: Change DEFINE_PER_CPU of current_pgd to be non volatile.

The DEFINE_PER_CPU of current_pgd was on CRIS defined using volatile,
which is not needed. Remove volatile.

Signed-off-by: Jesper Nilsson <jesper.nilsson@axis.com>
---
 arch/cris/include/asm/mmu_context.h |    3 ++-
 arch/cris/mm/fault.c                |    2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/arch/cris/include/asm/mmu_context.h b/arch/cris/include/asm/mmu_context.h
index 72ba08d..476cd9e 100644
--- a/arch/cris/include/asm/mmu_context.h
+++ b/arch/cris/include/asm/mmu_context.h
@@ -17,7 +17,8 @@ extern void switch_mm(struct mm_struct *prev, struct mm_struct *next,
  * registers like cr3 on the i386
  */
 
-extern volatile DEFINE_PER_CPU(pgd_t *,current_pgd); /* defined in arch/cris/mm/fault.c */
+/* defined in arch/cris/mm/fault.c */
+extern DEFINE_PER_CPU(pgd_t *, current_pgd);
 
 static inline void enter_lazy_tlb(struct mm_struct *mm, struct task_struct *tsk)
 {
diff --git a/arch/cris/mm/fault.c b/arch/cris/mm/fault.c
index c4c76db..84d22ae 100644
--- a/arch/cris/mm/fault.c
+++ b/arch/cris/mm/fault.c
@@ -29,7 +29,7 @@ extern void die_if_kernel(const char *, struct pt_regs *, long);
 
 /* current active page directory */
 
-volatile DEFINE_PER_CPU(pgd_t *,current_pgd);
+DEFINE_PER_CPU(pgd_t *, current_pgd);
 unsigned long cris_signal_return_page;
 
 /*
-- 
1.6.1

> Thanks.
> 
> -- 
> tejun

/^JN - Jesper Nilsson
-- 
               Jesper Nilsson -- jesper.nilsson@axis.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
