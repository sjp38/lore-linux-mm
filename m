Return-Path: <SRS0=h8p8=S5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.8 required=3.0 tests=DATE_IN_PAST_06_12,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 71E82C43218
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 06:43:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B0E4214C6
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 06:43:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="oILNkBTM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B0E4214C6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 292AC6B0010; Sat, 27 Apr 2019 02:43:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 21C316B0266; Sat, 27 Apr 2019 02:43:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0BEBB6B0269; Sat, 27 Apr 2019 02:43:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id C192D6B0010
	for <linux-mm@kvack.org>; Sat, 27 Apr 2019 02:43:17 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id ba11so3227654plb.21
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 23:43:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=uR9dojmxOmmxTLzrNkqbIEwKeNq3pUquy4Aauxui5YA=;
        b=L0N/t/29dEdme8VzRCpPp9aOjpPnCp2cxAQSz0+rQ9PJXbta2fwiHmcPfmnYF2nlK6
         LPtb27weecs9fLqrZYvRQtGJZiK/ENUoj/UJRwnqCTobikJzxycsS1+Euoh9rsEAukPN
         bkTJ9tviIVgvtImAXDJePlSH/JToYygi3/jB42uaXlFTwq10peBrmcRRhbF02NQu2pMm
         oYUUtUAqimf9QKGasNNqcqPc620mZmrUTE4FKrhdGcYBN0WzKXwpQkI/pCGTYpn5DfRu
         Iow3k7yQw9LvNBRHf+rOKwhpsKXQ3LaKfr8g8LU20xg/5QnK18ghhyQagyak/RcNDzhn
         9kkg==
X-Gm-Message-State: APjAAAVwyhAhlfJaDvoSWH4WsYwcBpy12kwUGFeTyv+Nrnj7qG4mCXAv
	Xf/skCDptkz73v+NrptAeFiNqzqjAQKJZF7jZHW+dIAV4FrbpRIcqAZQZYpaN12OQ4+GGT6k+zU
	7hLUl+FrfjMGbXW53QnCg6ykHSbE1lySOJw1+dPWfc4X8HMgOPpL4qc3qy5RmcflErg==
X-Received: by 2002:a62:1d94:: with SMTP id d142mr51482403pfd.83.1556347397436;
        Fri, 26 Apr 2019 23:43:17 -0700 (PDT)
X-Received: by 2002:a62:1d94:: with SMTP id d142mr51482330pfd.83.1556347396062;
        Fri, 26 Apr 2019 23:43:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556347396; cv=none;
        d=google.com; s=arc-20160816;
        b=h56eidIlWO4zGiSPT0yWEQP041PcqWHl+ewUdL6CcINCposHt97HrOXfKSl17udiCx
         GbrXwPe+VM3aubqVX4rg3l2cjRX9ParPTZd3v1DZOxxaEXcqmjkHvRuqQurriJtY5WYH
         IkROLL5VKJY2NPSLsLVASeofiJttELmamx1OK3Mv90ml1aT/fMultU1xsbC6N1oE8gxc
         IfyeBLi2fhybh/6OOlmFKiHN6To+REX21eMOuKyBXlIv4HKDZdzcS6YmWmaRC8rvGdQL
         jt/Q7VqbqO6aYgTcfHg6CxMk2ZMFdYizzQ5L7AfshCWxQ2ipU2hrff+WGbk9iMf1nxOs
         c5Gg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=uR9dojmxOmmxTLzrNkqbIEwKeNq3pUquy4Aauxui5YA=;
        b=M26/jhWTZf1zc2FNmFfEDyZhya+b/L6IsgPl/SbSIatqA1jwiia9AzV/iN0e8pCGIM
         0anOlJCAqlSR8kXVJU2MKydmI6uqJiFuiBNQ/1JUxgaIsBUbFB/B85dIZSMMY4VgU0TC
         GxddYb9Mp+5d8dhbzNzKXt3LH2kxM8N2M+U8yIobwzbT69LTUBDLYcz2fG+BDXQ3VKEW
         t6PlX/H7TtQ9CsBVlY9HrLFfvT25bSkXxMJmd+F+2T+vuWKs8C9V5owpvDjuqUH9c+aR
         KAwmOwLI3VUWjWQkLqzwM9RkwnU9r1dNJ4tGwWycU8qxD7RJr3oEnaymfkGFyw5EkhGx
         eDkw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=oILNkBTM;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 1sor27121342plz.0.2019.04.26.23.43.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Apr 2019 23:43:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=oILNkBTM;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=uR9dojmxOmmxTLzrNkqbIEwKeNq3pUquy4Aauxui5YA=;
        b=oILNkBTMPI8hbOfV9CTJU+m4eHw0hAUfxbTTNr2/RxOTWPpKbRKo8diZaBeA/Rmbm3
         h5rZrB3HG0y3SmWymgT3Ka+NNLrVVEWGy5GTcbQKRQEA3wiSNrIdF0YIzNUEW260wZEH
         KE+3wzmKUfVn5aWbi1XY/cRblwX7PCPz65YSoU43s/26wSMoHptHFPQTS+iXil5iGEw+
         MKuU4t2I8rSFdXKCm6I3uOxZEQ1YYZq5IGQ+JuIwxQpw5oc2ihHafO/Cd4i7/tLG7zpn
         Edmk3MnDF5/iWexA4JDZ+DyyFjQlaqdQ8ZangVzJbGAkvZg6LY9bd008qQlPu4OkFzMW
         +mVw==
X-Google-Smtp-Source: APXvYqxGAw4qwJwGwZPBWfL5T3kXq42Nxulr2Eo5xhNgNYA2PVHpEfWTNqR9D9nfEhSjkOIDkP0Vjg==
X-Received: by 2002:a17:902:e683:: with SMTP id cn3mr6142181plb.115.1556347395492;
        Fri, 26 Apr 2019 23:43:15 -0700 (PDT)
Received: from sc2-haas01-esx0118.eng.vmware.com ([66.170.99.1])
        by smtp.gmail.com with ESMTPSA id j22sm36460145pfn.129.2019.04.26.23.43.13
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 23:43:14 -0700 (PDT)
From: nadav.amit@gmail.com
To: Peter Zijlstra <peterz@infradead.org>,
	Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>,
	Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org,
	x86@kernel.org,
	hpa@zytor.com,
	Thomas Gleixner <tglx@linutronix.de>,
	Nadav Amit <nadav.amit@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
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
	Rick Edgecombe <rick.p.edgecombe@intel.com>,
	Nadav Amit <namit@vmware.com>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Masami Hiramatsu <mhiramat@kernel.org>
Subject: [PATCH v6 08/24] x86/alternative: Use temporary mm for text poking
Date: Fri, 26 Apr 2019 16:22:47 -0700
Message-Id: <20190426232303.28381-9-nadav.amit@gmail.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190426232303.28381-1-nadav.amit@gmail.com>
References: <20190426232303.28381-1-nadav.amit@gmail.com>
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

