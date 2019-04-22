Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA00CC282CE
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 18:59:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6BC90218D3
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 18:59:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6BC90218D3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 903D76B0008; Mon, 22 Apr 2019 14:58:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5F43B6B0269; Mon, 22 Apr 2019 14:58:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 073646B0008; Mon, 22 Apr 2019 14:58:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 934206B000C
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 14:58:44 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id y2so8124222pfn.13
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 11:58:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=uR9dojmxOmmxTLzrNkqbIEwKeNq3pUquy4Aauxui5YA=;
        b=beiFvAnxZ75uOI52zwBjQtycjJIn33eBDyBTXarMYp0Uj/NJJ6HM5vGfMRVg0fSt3Q
         OT/+DO5ERb+aKqEeXUMldmNUIv0bZ38X4unU0IztM8q9x8T7gKvTT3M8ASwB32c5kQjo
         IrRJ/VdcjbO6U9TVq8oxS8NA9IAJxY1EYpZyU03+WSsHCU+E5sm6B1t9q96jKUUjOpaE
         IUp1D3l7DVdUBlcmbOZa4jiTLuaW/sMJVtqqE95bhtdFqT99Oq8KpWtM/Q1rlr+i3hvG
         Jhqt5Fn9MWz1USQxaxwuYcpo+9CDHs8UCVVOzf78F4LHMK9sU4ZO8B2VZL/vD+Qrcdj3
         FBKQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUmfLh+9nKq/2ZZg5RDeBt35G8CPSwpW/G2D5emE+ig6moP7QFV
	ESckn7BrTxtf1zr7pkt02JvRF6nQgixphsPiYQQH1FjVECbzH4RS7w6A1rNU37AiLlwVLdW9zuA
	ZDiCtSDISySWtkIWeW89jrY4mxml4c69BSg3xhIq6w4zwvQDWDI0dToSD/8kMSzABLw==
X-Received: by 2002:a65:4108:: with SMTP id w8mr20379800pgp.236.1555959524169;
        Mon, 22 Apr 2019 11:58:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwl5xHI72qwpU5pl0NGUYw/lgZjHFtjxBKzVsm0jnDm5EKbyzHrCQYZf5ivUaXGtq2VnZbH
X-Received: by 2002:a65:4108:: with SMTP id w8mr20379740pgp.236.1555959523069;
        Mon, 22 Apr 2019 11:58:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555959523; cv=none;
        d=google.com; s=arc-20160816;
        b=pCEoUwziZSZVFXgNK+D4YTsbxmjglHeq0xUX17gVuFVhGN+VJkUIfUqA3fh80czjeG
         aTOh+VpKamAOYXo8rD+ZnA63t0i8Z+CgsHtZhYqC+9NgY5/4ZwZ/cHe6EBC1bxjU/TJN
         x+aTlC6bYLGzSrnEnpQ7ijE2tmj/foS+Dzgr6CpRVL5mZtTUS8Tjw8p0uu5uNkcnDJDr
         /Kw49eXH/mdMFvlVJVXX3nuvgJUclEidQmdFU7jopJXsnzPZzkegx+D9jKgGKttLp81p
         9TzAp/CJjQ0q1U9FM4+gSww2RK+hu1guEVD9MsSPL/YUciEapwZvt2JFrCGC7TZRTcgD
         IW/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=uR9dojmxOmmxTLzrNkqbIEwKeNq3pUquy4Aauxui5YA=;
        b=O6qJMvsO5jDp3U1MkP4BiRiUX9nacwSmZFx+GEe0A/4dTS88UrMJC0NZyOHfAh15h1
         MzqbCBf6vWsKbSip7/EsEbp0wULSRLPBdXTUz3N0IhPX2cHTVnpYA+isKIcmG6C4kJFB
         iB76RMDV+yfItSyz7sHS0S1VUX5Xc6VSvza15uuXVwFz8T7WRu7+TeqTqg+J07PjPrAf
         /SJ4IwRHTIqmHi02kv8X8G+asFHJr4z/HEYvfGkNsEUq2rWMfyRM8q0CrRxS4p2x5lIf
         53aSkauhr9idp5srbQVrkrFO+euaXR3s9jNNf5AOJAk4VVZtK6ZEMuW2XNYYNOSg049A
         GAEw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id a20si5314305pgb.421.2019.04.22.11.58.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Apr 2019 11:58:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 22 Apr 2019 11:58:41 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,382,1549958400"; 
   d="scan'208";a="136417137"
Received: from linksys13920.jf.intel.com (HELO rpedgeco-DESK5.jf.intel.com) ([10.54.75.11])
  by orsmga008.jf.intel.com with ESMTP; 22 Apr 2019 11:58:41 -0700
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
To: Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>,
	Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org,
	x86@kernel.org,
	hpa@zytor.com,
	Thomas Gleixner <tglx@linutronix.de>,
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
Subject: [PATCH v4 07/23] x86/alternative: Use temporary mm for text poking
Date: Mon, 22 Apr 2019 11:57:49 -0700
Message-Id: <20190422185805.1169-8-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190422185805.1169-1-rick.p.edgecombe@intel.com>
References: <20190422185805.1169-1-rick.p.edgecombe@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Nadav Amit <namit@vmware.com>

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

