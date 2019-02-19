Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5B08C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 13:41:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 54B6121773
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 13:41:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="MwYg0tM3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 54B6121773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E64E58E0003; Tue, 19 Feb 2019 08:41:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E153D8E0002; Tue, 19 Feb 2019 08:41:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D2B8B8E0003; Tue, 19 Feb 2019 08:41:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 919CE8E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 08:41:57 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id 59so14932268plc.13
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 05:41:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Tj1vGXOOGqIORKGSChRdWa7+WffbnM8fv4iQwuJOtH0=;
        b=jcjEb26aaah4MLrRtps5XCkn8ip6pDLKK8Svx+Do8XWMFw4Vg51nOrjCUBPQB+WJGQ
         uoPWO4K2W+fxuXdYNF233UdNZcMlhW/6pmnnSSkMpRkwkdBQ8giO3gBujlj6EOIKkshF
         u3xTfbOVQCKQr6fJsXtv+xd1Zvy6/KTnIsLgv8VgdgjPWKMcxdazqpkDvNI8gZ+tQYph
         H4weky/BUWHOlaQNzDUEpultXDzT+JEdBfpgSv6J7DMxCl+4+mhgKnLOzq3/n1B+Qgf8
         9Hq/0P8nL6/b9Mnbye5TIYDI7JTHwQHWyxmgqn8Btg6g2e/HyE8TbECMiUTAbsowb6gh
         s6sQ==
X-Gm-Message-State: AHQUAuYZnqNqoULy84yQ1l9yfvE2GfCHQ3PJwCJLPvXRXgdGnEaGla+T
	o/8bwYKm1wrWdXOWjglbEVBq8zH7fMjndljPDnh0is8zbO2QNfZ12n8SHuvoyGv4ftysgWO13m3
	iZyhU5mLK0g/7A3ZC1bd5QK6C/3RiXp4kpWm5CEKkMjCiaYwqXzfHMfkF2+Ilt1Zk+g==
X-Received: by 2002:a17:902:f20b:: with SMTP id gn11mr30161438plb.274.1550583717117;
        Tue, 19 Feb 2019 05:41:57 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZwntlpUDqNgSwfHx4AFEsQvwcb6USyzow4B17pNm5AC7VPd4Qd2W4n/F+Dg6yS+cRPVobl
X-Received: by 2002:a17:902:f20b:: with SMTP id gn11mr30161379plb.274.1550583716065;
        Tue, 19 Feb 2019 05:41:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550583716; cv=none;
        d=google.com; s=arc-20160816;
        b=O8bFUz5VjhhwgYaeICMCR91ihqp6W54yEUJntKS3zEaSh9i78Ptzx8laxPSlyWA+6x
         rOf68pVPZJ/Szc4gdTXORvD5a93wxMZFgzkFV6oj3J1S5r/XqcPqn3QyExmrsuS0VcpV
         I+l/6ZEKDRABXNejznIiX3aa34BR9HbC9XPdhGyZIi5yuVi37KgaYRYHAApuiQCAhDc+
         BJ7ABORC1MvsXvQInHjL1EtpsHrAzNssj6LzFQSmC9oCB0jJywVI/o8+HYzpNeWDNK7s
         9RpUS+rbS1dkk/fPtRfhmElxyPEMUb5DbPgSwb+kZryhRVYOVYVWcHlSrP/4ph2ZaHcl
         AfoQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Tj1vGXOOGqIORKGSChRdWa7+WffbnM8fv4iQwuJOtH0=;
        b=HPQyB6MGIpf1Y0EVNfsq3qzTLTgKDQy+uCuZv0vvqumASCFTG3YbcUOelLWU1haR1D
         ijsHFi3/7clHKzyIvaWpWaEFaQkrh6qAlznBVsCSYakm0iMKE85lpB1K39r/NMGHduBm
         nrNWT+cYPQ/hj2s9oC/yI4PR1+qpnutDjX8buPeCL6eiUNP/66D/dsqMIZYgoQPOVFXA
         xYf1z+8vmtGTomd1rYoEhKKo1xBzpUi2BNBipsEiWB9RVp1eaF1liO5SU/aJDdF5hD3Z
         0h5+HRbuxyKY4Jz8L1RlZxfhBASVE1GWgBcgqF5MJOVAsnuRlDvmiH5YhV7r0qgGJc4d
         pBGA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=MwYg0tM3;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a72si13783776pge.100.2019.02.19.05.41.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Feb 2019 05:41:55 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=MwYg0tM3;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=Tj1vGXOOGqIORKGSChRdWa7+WffbnM8fv4iQwuJOtH0=; b=MwYg0tM3lS1qp8OjJ1xnk0sao
	p8TEzIsVFx8lBQnCi3SKtjzH8qwKH9LTgnPp/DncJEYeGFDcrolFhjrVZTWUCd6RXszihJxzxzIwN
	bskQDO++VpQTcUUIIcVVMuiv7WhHGiZ6OTP7xNa8Fkz9gXH3ozghZjs6Td27e5oI7KYaSYF2FEBq9
	9Y/tKhuv6CZY1IGpWL0vkLDGz70tQxDCBfdVlew6rxNTzOEpNWNbaLUhcUDjBj+qQHUCBGfItaxoB
	KqqWe92sJV3TXnz2D2F//eY3CPH/w/UVThwSOZx5V8BXEthCnyBTm0wbMTJz3vJxVDFkm8npUx3FL
	kcd/Unoeg==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gw5ee-0002zx-M8; Tue, 19 Feb 2019 13:41:49 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 372832855E6A6; Tue, 19 Feb 2019 14:41:47 +0100 (CET)
Date: Tue, 19 Feb 2019 14:41:47 +0100
From: Peter Zijlstra <peterz@infradead.org>
To: Will Deacon <will.deacon@arm.com>
Cc: aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org,
	npiggin@gmail.com, linux-arch@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, linux@armlinux.org.uk,
	heiko.carstens@de.ibm.com, riel@surriel.com, tony.luck@intel.com
Subject: Re: [PATCH v6 06/18] asm-generic/tlb: Conditionally provide
 tlb_migrate_finish()
Message-ID: <20190219134147.GZ32494@hirez.programming.kicks-ass.net>
References: <20190219103148.192029670@infradead.org>
 <20190219103233.207580251@infradead.org>
 <20190219124738.GD8501@fuggles.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190219124738.GD8501@fuggles.cambridge.arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 19, 2019 at 12:47:38PM +0000, Will Deacon wrote:
> Fine for now, but I agree that we should drop the hook altogether. AFAICT,
> this only exists to help an ia64 optimisation which looks suspicious to
> me since it uses:
> 
>     mm == current->active_mm && atomic_read(&mm->mm_users) == 1
> 
> to identify a "single-threaded fork()" and therefore perform only local TLB
> invalidation. Even if this was the right thing to do, it's not clear to me
> that tlb_migrate_finish() is called on the right CPU anyway.
> 
> So I'd be keen to remove this hook before it spreads, but in the meantime:

Agreed :-)

The obvious slash and kill patch ... untested

---
 Documentation/core-api/cachetlb.rst |   10 ----------
 arch/ia64/include/asm/machvec.h     |    8 --------
 arch/ia64/include/asm/machvec_sn2.h |    2 --
 arch/ia64/include/asm/tlb.h         |    2 --
 arch/ia64/sn/kernel/sn2/sn2_smp.c   |    7 -------
 arch/nds32/include/asm/tlbflush.h   |    1 -
 include/asm-generic/tlb.h           |    4 ----
 kernel/sched/core.c                 |    1 -
 8 files changed, 35 deletions(-)

--- a/Documentation/core-api/cachetlb.rst
+++ b/Documentation/core-api/cachetlb.rst
@@ -101,16 +101,6 @@ invoke one of the following flush method
 	translations for software managed TLB configurations.
 	The sparc64 port currently does this.
 
-6) ``void tlb_migrate_finish(struct mm_struct *mm)``
-
-	This interface is called at the end of an explicit
-	process migration. This interface provides a hook
-	to allow a platform to update TLB or context-specific
-	information for the address space.
-
-	The ia64 sn2 platform is one example of a platform
-	that uses this interface.
-
 Next, we have the cache flushing interfaces.  In general, when Linux
 is changing an existing virtual-->physical mapping to a new value,
 the sequence will be in one of the following forms::
--- a/arch/ia64/include/asm/machvec.h
+++ b/arch/ia64/include/asm/machvec.h
@@ -30,7 +30,6 @@ typedef void ia64_mv_irq_init_t (void);
 typedef void ia64_mv_send_ipi_t (int, int, int, int);
 typedef void ia64_mv_timer_interrupt_t (int, void *);
 typedef void ia64_mv_global_tlb_purge_t (struct mm_struct *, unsigned long, unsigned long, unsigned long);
-typedef void ia64_mv_tlb_migrate_finish_t (struct mm_struct *);
 typedef u8 ia64_mv_irq_to_vector (int);
 typedef unsigned int ia64_mv_local_vector_to_irq (u8);
 typedef char *ia64_mv_pci_get_legacy_mem_t (struct pci_bus *);
@@ -96,7 +95,6 @@ machvec_noop_bus (struct pci_bus *bus)
 
 extern void machvec_setup (char **);
 extern void machvec_timer_interrupt (int, void *);
-extern void machvec_tlb_migrate_finish (struct mm_struct *);
 
 # if defined (CONFIG_IA64_HP_SIM)
 #  include <asm/machvec_hpsim.h>
@@ -124,7 +122,6 @@ extern void machvec_tlb_migrate_finish (
 #  define platform_send_ipi	ia64_mv.send_ipi
 #  define platform_timer_interrupt	ia64_mv.timer_interrupt
 #  define platform_global_tlb_purge	ia64_mv.global_tlb_purge
-#  define platform_tlb_migrate_finish	ia64_mv.tlb_migrate_finish
 #  define platform_dma_init		ia64_mv.dma_init
 #  define platform_dma_get_ops		ia64_mv.dma_get_ops
 #  define platform_irq_to_vector	ia64_mv.irq_to_vector
@@ -167,7 +164,6 @@ struct ia64_machine_vector {
 	ia64_mv_send_ipi_t *send_ipi;
 	ia64_mv_timer_interrupt_t *timer_interrupt;
 	ia64_mv_global_tlb_purge_t *global_tlb_purge;
-	ia64_mv_tlb_migrate_finish_t *tlb_migrate_finish;
 	ia64_mv_dma_init *dma_init;
 	ia64_mv_dma_get_ops *dma_get_ops;
 	ia64_mv_irq_to_vector *irq_to_vector;
@@ -206,7 +202,6 @@ struct ia64_machine_vector {
 	platform_send_ipi,			\
 	platform_timer_interrupt,		\
 	platform_global_tlb_purge,		\
-	platform_tlb_migrate_finish,		\
 	platform_dma_init,			\
 	platform_dma_get_ops,			\
 	platform_irq_to_vector,			\
@@ -270,9 +265,6 @@ extern const struct dma_map_ops *dma_get
 #ifndef platform_global_tlb_purge
 # define platform_global_tlb_purge	ia64_global_tlb_purge /* default to architected version */
 #endif
-#ifndef platform_tlb_migrate_finish
-# define platform_tlb_migrate_finish	machvec_noop_mm
-#endif
 #ifndef platform_kernel_launch_event
 # define platform_kernel_launch_event	machvec_noop
 #endif
--- a/arch/ia64/include/asm/machvec_sn2.h
+++ b/arch/ia64/include/asm/machvec_sn2.h
@@ -34,7 +34,6 @@ extern ia64_mv_irq_init_t sn_irq_init;
 extern ia64_mv_send_ipi_t sn2_send_IPI;
 extern ia64_mv_timer_interrupt_t sn_timer_interrupt;
 extern ia64_mv_global_tlb_purge_t sn2_global_tlb_purge;
-extern ia64_mv_tlb_migrate_finish_t	sn_tlb_migrate_finish;
 extern ia64_mv_irq_to_vector sn_irq_to_vector;
 extern ia64_mv_local_vector_to_irq sn_local_vector_to_irq;
 extern ia64_mv_pci_get_legacy_mem_t sn_pci_get_legacy_mem;
@@ -77,7 +76,6 @@ extern ia64_mv_pci_fixup_bus_t		sn_pci_f
 #define platform_send_ipi		sn2_send_IPI
 #define platform_timer_interrupt	sn_timer_interrupt
 #define platform_global_tlb_purge       sn2_global_tlb_purge
-#define platform_tlb_migrate_finish	sn_tlb_migrate_finish
 #define platform_pci_fixup		sn_pci_fixup
 #define platform_inb			__sn_inb
 #define platform_inw			__sn_inw
--- a/arch/ia64/include/asm/tlb.h
+++ b/arch/ia64/include/asm/tlb.h
@@ -47,8 +47,6 @@
 #include <asm/tlbflush.h>
 #include <asm/machvec.h>
 
-#define tlb_migrate_finish(mm)	platform_tlb_migrate_finish(mm)
-
 #include <asm-generic/tlb.h>
 
 #endif /* _ASM_IA64_TLB_H */
--- a/arch/ia64/sn/kernel/sn2/sn2_smp.c
+++ b/arch/ia64/sn/kernel/sn2/sn2_smp.c
@@ -120,13 +120,6 @@ void sn_migrate(struct task_struct *task
 		cpu_relax();
 }
 
-void sn_tlb_migrate_finish(struct mm_struct *mm)
-{
-	/* flush_tlb_mm is inefficient if more than 1 users of mm */
-	if (mm == current->mm && mm && atomic_read(&mm->mm_users) == 1)
-		flush_tlb_mm(mm);
-}
-
 static void
 sn2_ipi_flush_all_tlb(struct mm_struct *mm)
 {
--- a/arch/nds32/include/asm/tlbflush.h
+++ b/arch/nds32/include/asm/tlbflush.h
@@ -42,6 +42,5 @@ void local_flush_tlb_page(struct vm_area
 
 void update_mmu_cache(struct vm_area_struct *vma,
 		      unsigned long address, pte_t * pte);
-void tlb_migrate_finish(struct mm_struct *mm);
 
 #endif
--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -604,8 +604,4 @@ static inline void tlb_end_vma(struct mm
 
 #endif /* CONFIG_MMU */
 
-#ifndef tlb_migrate_finish
-#define tlb_migrate_finish(mm) do {} while (0)
-#endif
-
 #endif /* _ASM_GENERIC__TLB_H */
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -1151,7 +1151,6 @@ static int __set_cpus_allowed_ptr(struct
 		/* Need help from migration thread: drop lock and wait. */
 		task_rq_unlock(rq, p, &rf);
 		stop_one_cpu(cpu_of(rq), migration_cpu_stop, &arg);
-		tlb_migrate_finish(p->mm);
 		return 0;
 	} else if (task_on_rq_queued(p)) {
 		/*

