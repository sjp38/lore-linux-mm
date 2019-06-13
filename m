Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8111C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 10:08:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 98E6B2147A
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 10:08:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 98E6B2147A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 346656B026E; Thu, 13 Jun 2019 06:08:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2F7F86B0271; Thu, 13 Jun 2019 06:08:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1977A6B0272; Thu, 13 Jun 2019 06:08:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id B6C356B026E
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 06:08:24 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id n49so30132653edd.15
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 03:08:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=NXCr3SNbDoBdaUU/fwIzDxeZwSaVeVb+6ef+7qr9xEo=;
        b=dN+r4Z8Kf2yhMwfLKQPRaWuKysAtp3rciNjDkZwoRKwhz17U82DVuk27dr4o1HeTBX
         fTSN74scKB/nR7KoK3EQHXf8IgAWB8NS/2RDWzLKoT/TGk9EIpkzCGjSc7yLjgy2uPQk
         4zDouydOhwfDkukpAbE3ogtROb/zG7t/N2yFxphyLtEPOmUojZtn7PTvPGgfTaM4kbcV
         myzuMj1uFu+mZWvwrjw05ldATU2RU2QK9Uv3ChGduaGgP9JnVcNq3H9DXELsCkTUwqy/
         pwQz4i1Ed1FsVZVH24cJCjumJnH2jhD6WBzXjI7thCFqXLFnlptIVBfd03e2PIVcTaZT
         jpag==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAUC+QLLXfWaR3aNdfYyxl//zg1HvzatpUJfbekeGE6ZaLtSM5OL
	u7YBeTLuh5vV43Cmt91AdcR804E0tIeE0wgKAS5pgnjmZZHFJXXx3dfVFDrqz66ykCJahGbjcJx
	3ICZNULzY0HQq2rRZsfTmSJfbHXL3Js0jBWSIS2/ZmloGePCFdv3A6AH2T/vUEGKueQ==
X-Received: by 2002:a50:b662:: with SMTP id c31mr92802524ede.252.1560420504105;
        Thu, 13 Jun 2019 03:08:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyLawD7UAgSSHTX0Sf2nNdB78pUEszmJGJcmbrI2xlpwOw0dDJNbitBYaOSmOswKcSpLx25
X-Received: by 2002:a50:b662:: with SMTP id c31mr92802377ede.252.1560420502715;
        Thu, 13 Jun 2019 03:08:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560420502; cv=none;
        d=google.com; s=arc-20160816;
        b=yVWRInDmWh8VNRGGt4XQXerC+JX2Qtv70iUfVOHEKwM3/NUQioTaivIxxkA4gyhE8R
         K7WE3AZHbGkNU7pAITocdHT2gBoekFHSSw1y+p6ah+GxYzW5NX77VFtHCKg9Rc4R67EX
         b6O+eo7SXoYp2Zx1WVp/ttFnycpPrQhLPcjvtNX6szcRHuuk+kyNck/GuGPv7m/+NXW9
         2+aeA3V2PojH64Ke4rKxDz9h3S8H7+UI1s2YbNl9EjA1Aytzg0kFy0i9HxQWtGZBkwLA
         70JLLAVW5bDhIqjLak3ThBWOHZ7mFRc6TqH0AxE61InH6XEp27JYoRH3MDfZeUIJRg4G
         4pPQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=NXCr3SNbDoBdaUU/fwIzDxeZwSaVeVb+6ef+7qr9xEo=;
        b=u3+SLZCwcq9fnagwzxtUnT4fSEDOzcDTKbojGGuvy7AlgP8Aq/9tW17UyS5bZ4PJ12
         phgKoNYUQG3QuIAMhmDWQaQfaIxM/4NGrXUVC43sKKe5nNI1omwjAuNlxDIkrz0bZLdd
         eLtRbTXo9GU6dp+czK5nrbGW1E0vkEM7Vz5m/3JWI5sp+0ziEahoS95+SlLGh1/5c67H
         0wUwrhhwR3uQSdNwUQs35MH3d13QsDdI8E1AF4gLPavOpAOop8Y/Y+nBV69FmQ/TMe7u
         oUfJzNreArwGNYPYyLtNwZAxGqMzs6zZ4GBQwOGG6DwdFdhbstaljIQwcpvkd7/IBTXE
         KdGQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id w5si1743976ejv.349.2019.06.13.03.08.22
        for <linux-mm@kvack.org>;
        Thu, 13 Jun 2019 03:08:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 9C804367;
	Thu, 13 Jun 2019 03:08:21 -0700 (PDT)
Received: from p8cg001049571a15.blr.arm.com (p8cg001049571a15.blr.arm.com [10.162.40.191])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 050A83F694;
	Thu, 13 Jun 2019 03:09:54 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: Anshuman Khandual <anshuman.khandual@arm.com>,
	linux-snps-arc@lists.infradead.org,
	linux-mips@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-ia64@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org,
	x86@kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	Mark Rutland <mark.rutland@arm.com>,
	Christophe Leroy <christophe.leroy@c-s.fr>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Andrey Konovalov <andreyknvl@google.com>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Paul Mackerras <paulus@samba.org>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Tony Luck <tony.luck@intel.com>,
	Fenghua Yu <fenghua.yu@intel.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	Andy Lutomirski <luto@kernel.org>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Vineet Gupta <vgupta@synopsys.com>,
	James Hogan <jhogan@kernel.org>,
	Paul Burton <paul.burton@mips.com>,
	Ralf Baechle <ralf@linux-mips.org>
Subject: [PATCH] mm: Generalize and rename notify_page_fault() as kprobe_page_fault()
Date: Thu, 13 Jun 2019 15:37:24 +0530
Message-Id: <1560420444-25737-1-git-send-email-anshuman.khandual@arm.com>
X-Mailer: git-send-email 2.7.4
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Architectures which support kprobes have very similar boilerplate around
calling kprobe_fault_handler(). Use a helper function in kprobes.h to unify
them, based on the x86 code.

This changes the behaviour for other architectures when preemption is
enabled. Previously, they would have disabled preemption while calling the
kprobe handler. However, preemption would be disabled if this fault was
due to a kprobe, so we know the fault was not due to a kprobe handler and
can simply return failure.

This behaviour was introduced in the commit a980c0ef9f6d ("x86/kprobes:
Refactor kprobes_fault() like kprobe_exceptions_notify()")

Cc: linux-snps-arc@lists.infradead.org
Cc: linux-mips@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-ia64@vger.kernel.org
Cc: linuxppc-dev@lists.ozlabs.org
Cc: linux-s390@vger.kernel.org
Cc: linux-sh@vger.kernel.org
Cc: sparclinux@vger.kernel.org
Cc: x86@kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: Christophe Leroy <christophe.leroy@c-s.fr>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Andrey Konovalov <andreyknvl@google.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Russell King <linux@armlinux.org.uk>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Vineet Gupta <vgupta@synopsys.com>
Cc: James Hogan <jhogan@kernel.org>
Cc: Paul Burton <paul.burton@mips.com>
Cc: Ralf Baechle <ralf@linux-mips.org>

Reviewed-by: Dave Hansen <dave.hansen@linux.intel.com>
Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
Questions:

AFAICT there is no equivalent of erstwhile notify_page_fault() during page
fault handling in arc and mips archs which can call this generic function.
Please let me know if that is not the case.

Testing:

- Build and boot tested on arm64 and x86
- Build tested on some other archs (arm, sparc64, alpha, powerpc etc)

Changes in V1:

- Updated commit message per Matthew
- Changed kprobe_page_fault() to return bool per Stephen/Dave/Christophe/Matthew
- Changed kprobe_page_fault() to follow x86 code flow per Dave/Matthew
- Changed kprobe_fault variable as bool in powerpc __do_page_fault()
- Added a comment to kprobe_page_fault() per Dave

Changes in RFC V3: (https://patchwork.kernel.org/patch/10981353/)

- Updated the commit message with an explanation for new preemption behaviour
- Moved notify_page_fault() to kprobes.h with 'static nokprobe_inline' per Matthew
- Changed notify_page_fault() return type from int to bool per Michael Ellerman
- Renamed notify_page_fault() as kprobe_page_fault() per Peterz

Changes in RFC V2: (https://patchwork.kernel.org/patch/10974221/)

- Changed generic notify_page_fault() per Mathew Wilcox
- Changed x86 to use new generic notify_page_fault()
- s/must not/need not/ in commit message per Matthew Wilcox

Changes in RFC V1: (https://patchwork.kernel.org/patch/10968273/)

 arch/arm/mm/fault.c      | 24 +-----------------------
 arch/arm64/mm/fault.c    | 24 +-----------------------
 arch/ia64/mm/fault.c     | 24 +-----------------------
 arch/powerpc/mm/fault.c  | 23 ++---------------------
 arch/s390/mm/fault.c     | 16 +---------------
 arch/sh/mm/fault.c       | 18 ++----------------
 arch/sparc/mm/fault_64.c | 16 +---------------
 arch/x86/mm/fault.c      | 21 ++-------------------
 include/linux/kprobes.h  | 19 +++++++++++++++++++
 9 files changed, 30 insertions(+), 155 deletions(-)

diff --git a/arch/arm/mm/fault.c b/arch/arm/mm/fault.c
index 58f69fa..94a97a4 100644
--- a/arch/arm/mm/fault.c
+++ b/arch/arm/mm/fault.c
@@ -30,28 +30,6 @@
 
 #ifdef CONFIG_MMU
 
-#ifdef CONFIG_KPROBES
-static inline int notify_page_fault(struct pt_regs *regs, unsigned int fsr)
-{
-	int ret = 0;
-
-	if (!user_mode(regs)) {
-		/* kprobe_running() needs smp_processor_id() */
-		preempt_disable();
-		if (kprobe_running() && kprobe_fault_handler(regs, fsr))
-			ret = 1;
-		preempt_enable();
-	}
-
-	return ret;
-}
-#else
-static inline int notify_page_fault(struct pt_regs *regs, unsigned int fsr)
-{
-	return 0;
-}
-#endif
-
 /*
  * This is useful to dump out the page tables associated with
  * 'addr' in mm 'mm'.
@@ -266,7 +244,7 @@ do_page_fault(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 	vm_fault_t fault;
 	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
 
-	if (notify_page_fault(regs, fsr))
+	if (kprobe_page_fault(regs, fsr))
 		return 0;
 
 	tsk = current;
diff --git a/arch/arm64/mm/fault.c b/arch/arm64/mm/fault.c
index a30818e..8fe4bbc 100644
--- a/arch/arm64/mm/fault.c
+++ b/arch/arm64/mm/fault.c
@@ -70,28 +70,6 @@ static inline const struct fault_info *esr_to_debug_fault_info(unsigned int esr)
 	return debug_fault_info + DBG_ESR_EVT(esr);
 }
 
-#ifdef CONFIG_KPROBES
-static inline int notify_page_fault(struct pt_regs *regs, unsigned int esr)
-{
-	int ret = 0;
-
-	/* kprobe_running() needs smp_processor_id() */
-	if (!user_mode(regs)) {
-		preempt_disable();
-		if (kprobe_running() && kprobe_fault_handler(regs, esr))
-			ret = 1;
-		preempt_enable();
-	}
-
-	return ret;
-}
-#else
-static inline int notify_page_fault(struct pt_regs *regs, unsigned int esr)
-{
-	return 0;
-}
-#endif
-
 static void data_abort_decode(unsigned int esr)
 {
 	pr_alert("Data abort info:\n");
@@ -446,7 +424,7 @@ static int __kprobes do_page_fault(unsigned long addr, unsigned int esr,
 	unsigned long vm_flags = VM_READ | VM_WRITE;
 	unsigned int mm_flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
 
-	if (notify_page_fault(regs, esr))
+	if (kprobe_page_fault(regs, esr))
 		return 0;
 
 	tsk = current;
diff --git a/arch/ia64/mm/fault.c b/arch/ia64/mm/fault.c
index 5baeb02..22582f8 100644
--- a/arch/ia64/mm/fault.c
+++ b/arch/ia64/mm/fault.c
@@ -21,28 +21,6 @@
 
 extern int die(char *, struct pt_regs *, long);
 
-#ifdef CONFIG_KPROBES
-static inline int notify_page_fault(struct pt_regs *regs, int trap)
-{
-	int ret = 0;
-
-	if (!user_mode(regs)) {
-		/* kprobe_running() needs smp_processor_id() */
-		preempt_disable();
-		if (kprobe_running() && kprobe_fault_handler(regs, trap))
-			ret = 1;
-		preempt_enable();
-	}
-
-	return ret;
-}
-#else
-static inline int notify_page_fault(struct pt_regs *regs, int trap)
-{
-	return 0;
-}
-#endif
-
 /*
  * Return TRUE if ADDRESS points at a page in the kernel's mapped segment
  * (inside region 5, on ia64) and that page is present.
@@ -116,7 +94,7 @@ ia64_do_page_fault (unsigned long address, unsigned long isr, struct pt_regs *re
 	/*
 	 * This is to handle the kprobes on user space access instructions
 	 */
-	if (notify_page_fault(regs, TRAP_BRKPT))
+	if (kprobe_page_fault(regs, TRAP_BRKPT))
 		return;
 
 	if (user_mode(regs))
diff --git a/arch/powerpc/mm/fault.c b/arch/powerpc/mm/fault.c
index ec6b7ad..bc4e1af 100644
--- a/arch/powerpc/mm/fault.c
+++ b/arch/powerpc/mm/fault.c
@@ -42,26 +42,6 @@
 #include <asm/debug.h>
 #include <asm/kup.h>
 
-static inline bool notify_page_fault(struct pt_regs *regs)
-{
-	bool ret = false;
-
-#ifdef CONFIG_KPROBES
-	/* kprobe_running() needs smp_processor_id() */
-	if (!user_mode(regs)) {
-		preempt_disable();
-		if (kprobe_running() && kprobe_fault_handler(regs, 11))
-			ret = true;
-		preempt_enable();
-	}
-#endif /* CONFIG_KPROBES */
-
-	if (unlikely(debugger_fault_handler(regs)))
-		ret = true;
-
-	return ret;
-}
-
 /*
  * Check whether the instruction inst is a store using
  * an update addressing form which will update r1.
@@ -462,8 +442,9 @@ static int __do_page_fault(struct pt_regs *regs, unsigned long address,
 	int is_write = page_fault_is_write(error_code);
 	vm_fault_t fault, major = 0;
 	bool must_retry = false;
+	bool kprobe_fault = kprobe_page_fault(regs, 11);
 
-	if (notify_page_fault(regs))
+	if (unlikely(debugger_fault_handler(regs) || kprobe_fault))
 		return 0;
 
 	if (unlikely(page_fault_is_bad(error_code))) {
diff --git a/arch/s390/mm/fault.c b/arch/s390/mm/fault.c
index df75d57..1aaae2c 100644
--- a/arch/s390/mm/fault.c
+++ b/arch/s390/mm/fault.c
@@ -67,20 +67,6 @@ static int __init fault_init(void)
 }
 early_initcall(fault_init);
 
-static inline int notify_page_fault(struct pt_regs *regs)
-{
-	int ret = 0;
-
-	/* kprobe_running() needs smp_processor_id() */
-	if (kprobes_built_in() && !user_mode(regs)) {
-		preempt_disable();
-		if (kprobe_running() && kprobe_fault_handler(regs, 14))
-			ret = 1;
-		preempt_enable();
-	}
-	return ret;
-}
-
 /*
  * Find out which address space caused the exception.
  */
@@ -414,7 +400,7 @@ static inline vm_fault_t do_exception(struct pt_regs *regs, int access)
 	 */
 	clear_pt_regs_flag(regs, PIF_PER_TRAP);
 
-	if (notify_page_fault(regs))
+	if (kprobe_page_fault(regs, 14))
 		return 0;
 
 	mm = tsk->mm;
diff --git a/arch/sh/mm/fault.c b/arch/sh/mm/fault.c
index 6defd2c6..74cd4ac 100644
--- a/arch/sh/mm/fault.c
+++ b/arch/sh/mm/fault.c
@@ -24,20 +24,6 @@
 #include <asm/tlbflush.h>
 #include <asm/traps.h>
 
-static inline int notify_page_fault(struct pt_regs *regs, int trap)
-{
-	int ret = 0;
-
-	if (kprobes_built_in() && !user_mode(regs)) {
-		preempt_disable();
-		if (kprobe_running() && kprobe_fault_handler(regs, trap))
-			ret = 1;
-		preempt_enable();
-	}
-
-	return ret;
-}
-
 static void
 force_sig_info_fault(int si_signo, int si_code, unsigned long address,
 		     struct task_struct *tsk)
@@ -415,14 +401,14 @@ asmlinkage void __kprobes do_page_fault(struct pt_regs *regs,
 	if (unlikely(fault_in_kernel_space(address))) {
 		if (vmalloc_fault(address) >= 0)
 			return;
-		if (notify_page_fault(regs, vec))
+		if (kprobe_page_fault(regs, vec))
 			return;
 
 		bad_area_nosemaphore(regs, error_code, address);
 		return;
 	}
 
-	if (unlikely(notify_page_fault(regs, vec)))
+	if (unlikely(kprobe_page_fault(regs, vec)))
 		return;
 
 	/* Only enable interrupts if they were on before the fault */
diff --git a/arch/sparc/mm/fault_64.c b/arch/sparc/mm/fault_64.c
index 8f8a604..6865f9c 100644
--- a/arch/sparc/mm/fault_64.c
+++ b/arch/sparc/mm/fault_64.c
@@ -38,20 +38,6 @@
 
 int show_unhandled_signals = 1;
 
-static inline __kprobes int notify_page_fault(struct pt_regs *regs)
-{
-	int ret = 0;
-
-	/* kprobe_running() needs smp_processor_id() */
-	if (kprobes_built_in() && !user_mode(regs)) {
-		preempt_disable();
-		if (kprobe_running() && kprobe_fault_handler(regs, 0))
-			ret = 1;
-		preempt_enable();
-	}
-	return ret;
-}
-
 static void __kprobes unhandled_fault(unsigned long address,
 				      struct task_struct *tsk,
 				      struct pt_regs *regs)
@@ -285,7 +271,7 @@ asmlinkage void __kprobes do_sparc64_fault(struct pt_regs *regs)
 
 	fault_code = get_thread_fault_code();
 
-	if (notify_page_fault(regs))
+	if (kprobe_page_fault(regs, 0))
 		goto exit_exception;
 
 	si_code = SEGV_MAPERR;
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 46df4c6..5400f4e 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -46,23 +46,6 @@ kmmio_fault(struct pt_regs *regs, unsigned long addr)
 	return 0;
 }
 
-static nokprobe_inline int kprobes_fault(struct pt_regs *regs)
-{
-	if (!kprobes_built_in())
-		return 0;
-	if (user_mode(regs))
-		return 0;
-	/*
-	 * To be potentially processing a kprobe fault and to be allowed to call
-	 * kprobe_running(), we have to be non-preemptible.
-	 */
-	if (preemptible())
-		return 0;
-	if (!kprobe_running())
-		return 0;
-	return kprobe_fault_handler(regs, X86_TRAP_PF);
-}
-
 /*
  * Prefetch quirks:
  *
@@ -1280,7 +1263,7 @@ do_kern_addr_fault(struct pt_regs *regs, unsigned long hw_error_code,
 		return;
 
 	/* kprobes don't want to hook the spurious faults: */
-	if (kprobes_fault(regs))
+	if (kprobe_page_fault(regs, X86_TRAP_PF))
 		return;
 
 	/*
@@ -1311,7 +1294,7 @@ void do_user_addr_fault(struct pt_regs *regs,
 	mm = tsk->mm;
 
 	/* kprobes don't want to hook the spurious faults: */
-	if (unlikely(kprobes_fault(regs)))
+	if (unlikely(kprobe_page_fault(regs, X86_TRAP_PF)))
 		return;
 
 	/*
diff --git a/include/linux/kprobes.h b/include/linux/kprobes.h
index 443d980..04bdaf0 100644
--- a/include/linux/kprobes.h
+++ b/include/linux/kprobes.h
@@ -458,4 +458,23 @@ static inline bool is_kprobe_optinsn_slot(unsigned long addr)
 }
 #endif
 
+/* Returns true if kprobes handled the fault */
+static nokprobe_inline bool kprobe_page_fault(struct pt_regs *regs,
+					      unsigned int trap)
+{
+	if (!kprobes_built_in())
+		return false;
+	if (user_mode(regs))
+		return false;
+	/*
+	 * To be potentially processing a kprobe fault and to be allowed
+	 * to call kprobe_running(), we have to be non-preemptible.
+	 */
+	if (preemptible())
+		return false;
+	if (!kprobe_running())
+		return false;
+	return kprobe_fault_handler(regs, trap);
+}
+
 #endif /* _LINUX_KPROBES_H */
-- 
2.7.4

