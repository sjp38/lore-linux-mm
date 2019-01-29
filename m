Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C77F9C282CD
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 00:39:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7FB1921841
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 00:39:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7FB1921841
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 89D6B8E0006; Mon, 28 Jan 2019 19:39:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 68D5F8E000C; Mon, 28 Jan 2019 19:39:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 331E88E000E; Mon, 28 Jan 2019 19:39:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id B50E38E000B
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 19:39:14 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id p3so13023055plk.9
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 16:39:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=EyhXd8rZ4nSo/EtAgiNf2g+ELch4cYLylR2UlgOhqZY=;
        b=qWSDWqg7mH6wycwxkuf44jCzNMYiX/VO5ZCm1OS0YEYh9hf8Hr832Nqr/6nsllaDWH
         F5y/jR2RjNRv1IYL8doguN7vQyV5kn6JluMUAppUjYzUMGYrWgJHto6z+EfzdnPFUm3c
         ddP2Udy5MRCpQm/JVav2IrFFEpSqC5F2aqvSzdTu9CnEIg7X6SGQ4IaRST+lbB4d9dA5
         uWF8KKcM9Bxyw+h9HRsXA4Mz1CMP6FNLM8iClQqKN/eB0WGRlfxm6OkDaSPToZm9bEln
         vtf3pq+puBIngFaJJ7sRxZPhTxrgwpB3bTD0VIONAFHoZB/ukQVPI1BlvYrG3FEkLqCn
         JnOg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukfJeALEC87uatVpbJ+yahE5syqbjx4tNOtkI1J61ISWRB2Ie/Rz
	odM9EJW3JSwv3YgEB6DkjYS9WG0WQIOw4pk1jiWEpxvbz7994ZxNqsZqEupzybOlD7F7Lk4sOHF
	peik9Ga67UMA9bDNpe7VdCoOA6dvjO8lxQ74nydG93puKyVagwAgQ3cpcSfgvDvXWkA==
X-Received: by 2002:a62:6dc7:: with SMTP id i190mr23997750pfc.166.1548722354367;
        Mon, 28 Jan 2019 16:39:14 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4xM2gDU0aK6MEqglVw0ed5ebDxS8spWJExZX/iiFoW9aTktx7O65qJWFCIu42zI5CeKQcC
X-Received: by 2002:a62:6dc7:: with SMTP id i190mr23997692pfc.166.1548722353470;
        Mon, 28 Jan 2019 16:39:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548722353; cv=none;
        d=google.com; s=arc-20160816;
        b=V5QJow5rlBMC1hgpFYlFqD/mNvKhKAQhGbaXFGZU8Vao+KDFObrJV3uCrl/Pei92ja
         yWZJm91FPf+ah1p+xvX6ZWSWK13z0pcpF2NjEqL0OWfti/DWBnxXAypEtQWxFJ1xpvfh
         HPyGQ0GDH9Qfoj+bRyOwnMDZ4fNfZAGAtBx3tX9nLCpi2rmWUdDGuNrVAEvp5zyOZTJj
         UYsNpUdHpbgvPN10mpcFjflL9kvAT95yhCeaL6uHvyx8KR7tN4xXcnC5q8qrpncEqelV
         1SQ727kJ7l4AbKOBwkXWhTMYPxNAl9d4mETvnIix5x3ox9ivrpaKvKxl/pJ4U6V92N2I
         9WBg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=EyhXd8rZ4nSo/EtAgiNf2g+ELch4cYLylR2UlgOhqZY=;
        b=EG+BMZlu9R/IHA2FsTwW7PLLCANRRx054/h6XHtvZiqfuEtTFIcJUhl0G2qq7Ac7HZ
         H7qZY7ZHknUr33YUemJ9jQm/sjgNPp9BA5PctYTA6ova89nXqewPsGl6rQgFvKtV9L3Z
         DjHLToPbwjnskReX58UFuC1vBtC/NhTtWXwUrvDinhb9L4r9g10qqmEhmwQ06YG9wafs
         LiwRwDycUowNZkK/bEiERzxOBHuqJPDaJ9vn0EwS5f5t6QEMw1120gFgJcBEZZ/jm1NR
         rMWR6Jf8JvN1ITJJ7UvMpGTZu2sM+gzbOOoufR6LOEEwdpFLfiRvgkxphGpDDg2BKSun
         9cow==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id s17si4514712pgi.513.2019.01.28.16.39.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 16:39:13 -0800 (PST)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Jan 2019 16:39:12 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,535,1539673200"; 
   d="scan'208";a="133921901"
Received: from rpedgeco-desk5.jf.intel.com ([10.54.75.79])
  by orsmga001.jf.intel.com with ESMTP; 28 Jan 2019 16:39:11 -0800
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
To: Andy Lutomirski <luto@kernel.org>,
	Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org,
	x86@kernel.org,
	hpa@zytor.com,
	Thomas Gleixner <tglx@linutronix.de>,
	Borislav Petkov <bp@alien8.de>,
	Nadav Amit <nadav.amit@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	linux_dti@icloud.com,
	linux-integrity@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	akpm@linux-foundation.org,
	kernel-hardening@lists.openwall.com,
	linux-mm@kvack.org,
	will.deacon@arm.com,
	ard.biesheuvel@linaro.org,
	kristen@linux.intel.com,
	deneen.t.dock@intel.com,
	Nadav Amit <namit@vmware.com>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Masami Hiramatsu <mhiramat@kernel.org>,
	Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH v2 06/20] x86/alternative: use temporary mm for text poking
Date: Mon, 28 Jan 2019 16:34:08 -0800
Message-Id: <20190129003422.9328-7-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Nadav Amit <namit@vmware.com>

text_poke() can potentially compromise the security as it sets temporary
PTEs in the fixmap. These PTEs might be used to rewrite the kernel code
from other cores accidentally or maliciously, if an attacker gains the
ability to write onto kernel memory.

Moreover, since remote TLBs are not flushed after the temporary PTEs are
removed, the time-window in which the code is writable is not limited if
the fixmap PTEs - maliciously or accidentally - are cached in the TLB.
To address these potential security hazards, we use a temporary mm for
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
 arch/x86/kernel/alternative.c | 106 +++++++++++++++++++++++++++-------
 arch/x86/xen/mmu_pv.c         |   2 -
 3 files changed, 84 insertions(+), 26 deletions(-)

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
index ae05fbb50171..76d482a2b716 100644
--- a/arch/x86/kernel/alternative.c
+++ b/arch/x86/kernel/alternative.c
@@ -11,6 +11,7 @@
 #include <linux/stop_machine.h>
 #include <linux/slab.h>
 #include <linux/kdebug.h>
+#include <linux/mmu_context.h>
 #include <asm/text-patching.h>
 #include <asm/alternative.h>
 #include <asm/sections.h>
@@ -683,41 +684,102 @@ __ro_after_init unsigned long poking_addr;
 
 static void *__text_poke(void *addr, const void *opcode, size_t len)
 {
+	bool cross_page_boundary = offset_in_page(addr) + len > PAGE_SIZE;
+	temporary_mm_state_t prev;
+	struct page *pages[2] = {NULL};
 	unsigned long flags;
-	char *vaddr;
-	struct page *pages[2];
-	int i;
+	pte_t pte, *ptep;
+	spinlock_t *ptl;
+	pgprot_t prot;
 
 	/*
-	 * While boot memory allocator is runnig we cannot use struct
-	 * pages as they are not yet initialized.
+	 * While boot memory allocator is running we cannot use struct pages as
+	 * they are not yet initialized.
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
+	 * The lock is not really needed, but this allows to avoid open-coding.
+	 */
+	ptep = get_locked_pte(poking_mm, poking_addr, &ptl);
+
+	/*
+	 * This must not fail; preallocated in poking_init().
+	 */
+	VM_BUG_ON(!ptep);
+
+	/*
+	 * flush_tlb_mm_range() would be called when the poking_mm is not
+	 * loaded. When PCID is in use, the flush would be deferred to the time
+	 * the poking_mm is loaded again. Set the PTE as non-global to prevent
+	 * it from being used when we are done.
+	 */
+	prot = __pgprot(pgprot_val(PAGE_KERNEL) & ~_PAGE_GLOBAL);
+
+	pte = mk_pte(pages[0], prot);
+	set_pte_at(poking_mm, poking_addr, ptep, pte);
+
+	if (cross_page_boundary) {
+		pte = mk_pte(pages[1], prot);
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
+	pte_unmap_unlock(ptep, ptl);
+	/*
+	 * If the text doesn't match what we just wrote; something is
+	 * fundamentally screwy, there's nothing we can really do about that.
+	 */
+	BUG_ON(memcmp(addr, opcode, len));
+
 	local_irq_restore(flags);
 	return addr;
 }
diff --git a/arch/x86/xen/mmu_pv.c b/arch/x86/xen/mmu_pv.c
index 0f4fe206dcc2..82b181fcefe5 100644
--- a/arch/x86/xen/mmu_pv.c
+++ b/arch/x86/xen/mmu_pv.c
@@ -2319,8 +2319,6 @@ static void xen_set_fixmap(unsigned idx, phys_addr_t phys, pgprot_t prot)
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

