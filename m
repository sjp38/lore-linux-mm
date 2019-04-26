Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.9 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1CB28C43219
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 07:31:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BEBCF208C3
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 07:31:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BEBCF208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AE68B6B0008; Fri, 26 Apr 2019 03:31:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A01736B0007; Fri, 26 Apr 2019 03:31:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 55CC06B000A; Fri, 26 Apr 2019 03:31:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 17FDE6B000A
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 03:31:48 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id b37so1494087pgl.19
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 00:31:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version;
        bh=mKLi4shgLz2mH8MLU6WsCSQGo+jrfYOaZJ1RA9T3nOs=;
        b=k4cE6ukTyLDOBMndqUL7D4nl0kz/wwZzMqUJa7pr6lwydCdMPBFC9kbYhoCVJkzxuF
         MlGx+ogmVi7J3VU73GSCDGMGMvKYvu8CLYEdWa0wXMBWJlzpqcixdWhqsUB8nxJfE7fm
         fr4J0n6gaSVtuv05+LgU1TllbJu2mv9DSIcqbeWBoNadHCIbDfKDDJ8Z3Jw1qdr5I8/P
         l7ghsnUJWu+DZOJB9Z8sBRF8iPFiaWm5yzRtHAGi+JLOC3Rt8UNzYPPq3CSYUZpQ8bx3
         WAIzZF7tjyHjWLNKNsRETF+gSZj1b4Nelm7nUttpVhO9fcATRalEDoeuBCdhtv/k2L2U
         fgkg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.189 as permitted sender) smtp.mailfrom=namit@vmware.com;       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
X-Gm-Message-State: APjAAAU90gzHelch4L/k5B5T5FavOc1SDS/I6h8ARiIr22KIuPfk2M6H
	eMsL7PXOjbgtKZQsZGR4gpd1Hoeuo+v3kkEakFvYfICR/SM5ICy/+hd/hed1cANbHGbJKlammM5
	tuuGmsoovU7zymUjJFa5E3C4iimSypmlI0WhT4miQ7qW/llmLYK6k12XVJWI150OM6A==
X-Received: by 2002:aa7:8b4c:: with SMTP id i12mr26951793pfd.189.1556263907706;
        Fri, 26 Apr 2019 00:31:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw4wZNoR/QXEW54erprBufNYxe0Ofntb31pVBWevhm1DARj4rBABWq3Uzu3JoPpSEGyzluy
X-Received: by 2002:aa7:8b4c:: with SMTP id i12mr26951717pfd.189.1556263906621;
        Fri, 26 Apr 2019 00:31:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556263906; cv=none;
        d=google.com; s=arc-20160816;
        b=0V7dTZOcRqhiyIQep8n70QsAkmFC2VDXZRFaNbIVCPL5zmm7D7xfrm0U21HgiBtaEs
         VRHBC328uw7NzcAPK0VsPdvwT6L49cfbqnP+lqabw7PoGpoRuBF6+EGu43D8Gu9nC85K
         rdFgzRzqXHtIQrFLx8HM6bcpIhZ/ug0WA/6XEviiW1VnY1tHKstctcBr/enYGs+1+a5G
         l3xjXvbHkI/4kZIVQ7x4lBNs2MUZuS/qCrhWlXbCKtJFh66PxezmQ6w4tgCEKRWKNMIM
         3Bxp3QzFhXYNWVWXL1Xgy1EX3xIr7+BGKOllRmPhptUyHPSbtudLJW4kFc4Y09oJnC1F
         4FTg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from;
        bh=mKLi4shgLz2mH8MLU6WsCSQGo+jrfYOaZJ1RA9T3nOs=;
        b=VrKTjYqJnq5oxB0gUpYBqqFMH0lWDxvium0sZ/kuXm+/vDSh8CRweTOxf2p/Hz9bkt
         hUgzqQtU7HLjBALViILeQIkBg5DasoCQrJrUkO7pZ04dsKEey3eySNSgQpaJr49mkW72
         qW8xWa6vxwLRNAxPElIpnej2tiR8c4t+1McFPuO4j+GMnUxDGdm7Cxd8ySq2CBL5b8/6
         OL/fT0aTdUlkK0Vsown+bY428WRld7+RIvuHUvfmixS1Rsend0xi5xGR85PeBrauCdtS
         INyQcrBur3XhIdT8Gc8qNrN3WdkASwgG6kX0ivHoUyMrBlajjkaqCtyB6qQRrKbGqM8L
         WLAQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.189 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from EX13-EDG-OU-001.vmware.com (ex13-edg-ou-001.vmware.com. [208.91.0.189])
        by mx.google.com with ESMTPS id v82si25417769pfa.42.2019.04.26.00.31.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 26 Apr 2019 00:31:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 208.91.0.189 as permitted sender) client-ip=208.91.0.189;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.189 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from sc9-mailhost3.vmware.com (10.113.161.73) by
 EX13-EDG-OU-001.vmware.com (10.113.208.155) with Microsoft SMTP Server id
 15.0.1156.6; Fri, 26 Apr 2019 00:31:40 -0700
Received: from sc2-haas01-esx0118.eng.vmware.com (sc2-haas01-esx0118.eng.vmware.com [10.172.44.118])
	by sc9-mailhost3.vmware.com (Postfix) with ESMTP id 9879D412A1;
	Fri, 26 Apr 2019 00:31:45 -0700 (PDT)
From: Nadav Amit <namit@vmware.com>
To: Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>
CC: <linux-kernel@vger.kernel.org>, <x86@kernel.org>, <hpa@zytor.com>, Thomas
 Gleixner <tglx@linutronix.de>, Nadav Amit <nadav.amit@gmail.com>, Dave Hansen
	<dave.hansen@linux.intel.com>, <linux_dti@icloud.com>,
	<linux-integrity@vger.kernel.org>, <linux-security-module@vger.kernel.org>,
	<akpm@linux-foundation.org>, <kernel-hardening@lists.openwall.com>,
	<linux-mm@kvack.org>, <will.deacon@arm.com>, <ard.biesheuvel@linaro.org>,
	<kristen@linux.intel.com>, <deneen.t.dock@intel.com>, Rick Edgecombe
	<rick.p.edgecombe@intel.com>, Nadav Amit <namit@vmware.com>, Kees Cook
	<keescook@chromium.org>, Dave Hansen <dave.hansen@intel.com>, Masami
 Hiramatsu <mhiramat@kernel.org>
Subject: [PATCH v5 07/23] x86/alternative: Use temporary mm for text poking
Date: Thu, 25 Apr 2019 17:11:27 -0700
Message-ID: <20190426001143.4983-8-namit@vmware.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190426001143.4983-1-namit@vmware.com>
References: <20190426001143.4983-1-namit@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain
Received-SPF: None (EX13-EDG-OU-001.vmware.com: namit@vmware.com does not
 designate permitted sender hosts)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

text_poke() can potentially compromise security as it sets temporary
PTEs in the fixmap. These PTEs might be used to rewrite the kernel code
from other cores accidentally or maliciously, if an attacker gains the
ability to write onto kernel memory.

Moreover, since remote TLBs are not flushed after the temporary PTEs are
removed, the time-window in which the code is writable is not limited if
the fixmap PTEs - maliciously or accidentally - are cached in the TLB.
To address these potential security hazards, use a temporary mm for
patching the code.

Finally, text_poke() is also not conservative enough when mapping pages,
as it always tries to map 2 pages, even when a single one is sufficient.
So try to be more conservative, and do not map more than needed.

Cc: Andy Lutomirski <luto@kernel.org>
Cc: Kees Cook <keescook@chromium.org>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Masami Hiramatsu <mhiramat@kernel.org>
Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Signed-off-by: Nadav Amit <namit@vmware.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/include/asm/fixmap.h |   2 -
 arch/x86/kernel/alternative.c | 108 +++++++++++++++++++++++++++-------
 arch/x86/xen/mmu_pv.c         |   2 -
 3 files changed, 86 insertions(+), 26 deletions(-)

diff --git a/arch/x86/include/asm/fixmap.h b/arch/x86/include/asm/fixmap.h
index 50ba74a34a37..9da8cccdf3fb 100644
--- a/arch/x86/include/asm/fixmap.h
+++ b/arch/x86/include/asm/fixmap.h
@@ -103,8 +103,6 @@ enum fixed_addresses {
 #ifdef CONFIG_PARAVIRT
 	FIX_PARAVIRT_BOOTMAP,
 #endif
-	FIX_TEXT_POKE1,	/* reserve 2 pages for text_poke() */
-	FIX_TEXT_POKE0, /* first page is last, because allocation is backward */
 #ifdef	CONFIG_X86_INTEL_MID
 	FIX_LNW_VRTC,
 #endif
diff --git a/arch/x86/kernel/alternative.c b/arch/x86/kernel/alternative.c
index 11d5c710a94f..599203876c32 100644
--- a/arch/x86/kernel/alternative.c
+++ b/arch/x86/kernel/alternative.c
@@ -12,6 +12,7 @@
 #include <linux/slab.h>
 #include <linux/kdebug.h>
 #include <linux/kprobes.h>
+#include <linux/mmu_context.h>
 #include <asm/text-patching.h>
 #include <asm/alternative.h>
 #include <asm/sections.h>
@@ -684,41 +685,104 @@ __ro_after_init unsigned long poking_addr;
 
 static void *__text_poke(void *addr, const void *opcode, size_t len)
 {
+	bool cross_page_boundary = offset_in_page(addr) + len > PAGE_SIZE;
+	struct page *pages[2] = {NULL};
+	temp_mm_state_t prev;
 	unsigned long flags;
-	char *vaddr;
-	struct page *pages[2];
-	int i;
+	pte_t pte, *ptep;
+	spinlock_t *ptl;
+	pgprot_t pgprot;
 
 	/*
-	 * While boot memory allocator is runnig we cannot use struct
-	 * pages as they are not yet initialized.
+	 * While boot memory allocator is running we cannot use struct pages as
+	 * they are not yet initialized. There is no way to recover.
 	 */
 	BUG_ON(!after_bootmem);
 
 	if (!core_kernel_text((unsigned long)addr)) {
 		pages[0] = vmalloc_to_page(addr);
-		pages[1] = vmalloc_to_page(addr + PAGE_SIZE);
+		if (cross_page_boundary)
+			pages[1] = vmalloc_to_page(addr + PAGE_SIZE);
 	} else {
 		pages[0] = virt_to_page(addr);
 		WARN_ON(!PageReserved(pages[0]));
-		pages[1] = virt_to_page(addr + PAGE_SIZE);
+		if (cross_page_boundary)
+			pages[1] = virt_to_page(addr + PAGE_SIZE);
 	}
-	BUG_ON(!pages[0]);
+	/*
+	 * If something went wrong, crash and burn since recovery paths are not
+	 * implemented.
+	 */
+	BUG_ON(!pages[0] || (cross_page_boundary && !pages[1]));
+
 	local_irq_save(flags);
-	set_fixmap(FIX_TEXT_POKE0, page_to_phys(pages[0]));
-	if (pages[1])
-		set_fixmap(FIX_TEXT_POKE1, page_to_phys(pages[1]));
-	vaddr = (char *)fix_to_virt(FIX_TEXT_POKE0);
-	memcpy(&vaddr[(unsigned long)addr & ~PAGE_MASK], opcode, len);
-	clear_fixmap(FIX_TEXT_POKE0);
-	if (pages[1])
-		clear_fixmap(FIX_TEXT_POKE1);
-	local_flush_tlb();
-	sync_core();
-	/* Could also do a CLFLUSH here to speed up CPU recovery; but
-	   that causes hangs on some VIA CPUs. */
-	for (i = 0; i < len; i++)
-		BUG_ON(((char *)addr)[i] != ((char *)opcode)[i]);
+
+	/*
+	 * Map the page without the global bit, as TLB flushing is done with
+	 * flush_tlb_mm_range(), which is intended for non-global PTEs.
+	 */
+	pgprot = __pgprot(pgprot_val(PAGE_KERNEL) & ~_PAGE_GLOBAL);
+
+	/*
+	 * The lock is not really needed, but this allows to avoid open-coding.
+	 */
+	ptep = get_locked_pte(poking_mm, poking_addr, &ptl);
+
+	/*
+	 * This must not fail; preallocated in poking_init().
+	 */
+	VM_BUG_ON(!ptep);
+
+	pte = mk_pte(pages[0], pgprot);
+	set_pte_at(poking_mm, poking_addr, ptep, pte);
+
+	if (cross_page_boundary) {
+		pte = mk_pte(pages[1], pgprot);
+		set_pte_at(poking_mm, poking_addr + PAGE_SIZE, ptep + 1, pte);
+	}
+
+	/*
+	 * Loading the temporary mm behaves as a compiler barrier, which
+	 * guarantees that the PTE will be set at the time memcpy() is done.
+	 */
+	prev = use_temporary_mm(poking_mm);
+
+	kasan_disable_current();
+	memcpy((u8 *)poking_addr + offset_in_page(addr), opcode, len);
+	kasan_enable_current();
+
+	/*
+	 * Ensure that the PTE is only cleared after the instructions of memcpy
+	 * were issued by using a compiler barrier.
+	 */
+	barrier();
+
+	pte_clear(poking_mm, poking_addr, ptep);
+	if (cross_page_boundary)
+		pte_clear(poking_mm, poking_addr + PAGE_SIZE, ptep + 1);
+
+	/*
+	 * Loading the previous page-table hierarchy requires a serializing
+	 * instruction that already allows the core to see the updated version.
+	 * Xen-PV is assumed to serialize execution in a similar manner.
+	 */
+	unuse_temporary_mm(prev);
+
+	/*
+	 * Flushing the TLB might involve IPIs, which would require enabled
+	 * IRQs, but not if the mm is not used, as it is in this point.
+	 */
+	flush_tlb_mm_range(poking_mm, poking_addr, poking_addr +
+			   (cross_page_boundary ? 2 : 1) * PAGE_SIZE,
+			   PAGE_SHIFT, false);
+
+	/*
+	 * If the text does not match what we just wrote then something is
+	 * fundamentally screwy; there's nothing we can really do about that.
+	 */
+	BUG_ON(memcmp(addr, opcode, len));
+
+	pte_unmap_unlock(ptep, ptl);
 	local_irq_restore(flags);
 	return addr;
 }
diff --git a/arch/x86/xen/mmu_pv.c b/arch/x86/xen/mmu_pv.c
index a21e1734fc1f..beb44e22afdf 100644
--- a/arch/x86/xen/mmu_pv.c
+++ b/arch/x86/xen/mmu_pv.c
@@ -2318,8 +2318,6 @@ static void xen_set_fixmap(unsigned idx, phys_addr_t phys, pgprot_t prot)
 #elif defined(CONFIG_X86_VSYSCALL_EMULATION)
 	case VSYSCALL_PAGE:
 #endif
-	case FIX_TEXT_POKE0:
-	case FIX_TEXT_POKE1:
 		/* All local page mappings */
 		pte = pfn_pte(phys, prot);
 		break;
-- 
2.17.1

