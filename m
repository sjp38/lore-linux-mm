Return-Path: <SRS0=h8p8=S5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.8 required=3.0 tests=DATE_IN_PAST_06_12,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67B27C4321A
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 06:43:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1C4B0208CB
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 06:43:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="p4m/oBqS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1C4B0208CB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 68BBA6B000E; Sat, 27 Apr 2019 02:43:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 63D0C6B0010; Sat, 27 Apr 2019 02:43:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 48D5F6B0266; Sat, 27 Apr 2019 02:43:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0C5B56B000E
	for <linux-mm@kvack.org>; Sat, 27 Apr 2019 02:43:16 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id d12so3580654pfn.9
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 23:43:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=ZPFv6m+iH8EeSMp9wFrys9PGKYZJjpGjv1/CHTAfS5M=;
        b=BHJYMsMs3M2sxMYG7Prjx4we/kxygG/FYXCGYY/pXehpJaGr+vc55mkZC/4tzAf9PJ
         86zFBeQ0xqDfNjpKC2PVZfCJ7G3tnkR4iSu86KuqPOG7eUcv8f2RDoVtgCxSnzAVAlR4
         3EjRbHcBXuxCDX++5d/VADWIjk8A2rdqpGirlOQaxgURTdCgSryB1EIm/15fxRFjzdB/
         H/hIzwsWXiew3R5PuUgJCMBKiPdLXqKjKhN6asNMLYr0ovZir/T5OdrPg3miZn5VBwBK
         Y7YOSfHrTvmTDkM3Z80KIVE8nlCSlU9HvDEF5TRMx9JuWGOO3863VuXx1de6fw/rLRpL
         J1Fw==
X-Gm-Message-State: APjAAAUewK5f0S9VB5iqGam9e4Fr8eEJJm026SQeCXIeALSwl1OZOtVm
	9jJtC9UgtuyefF+9SmyxJl/8MbusOuHqDM2H7EbD23ZFloDPle/DE1ZY5f7uO5ibiXO3WQVQqAP
	RLIfapepDYZJtVVnyKSPDjgW92aPujVHPv1At5eRMPlrIRWCjeuWszlOs5r39UJkHTw==
X-Received: by 2002:a17:902:6b44:: with SMTP id g4mr3053811plt.157.1556347395696;
        Fri, 26 Apr 2019 23:43:15 -0700 (PDT)
X-Received: by 2002:a17:902:6b44:: with SMTP id g4mr3053756plt.157.1556347394392;
        Fri, 26 Apr 2019 23:43:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556347394; cv=none;
        d=google.com; s=arc-20160816;
        b=GIpS4Cgqujum671yS28fl2Nd5KKSwfhOMU9Z44SrhcnADu4zAzeDbpMcUBsmr6AdVj
         RwhhGhBwZbl8vo/r8ipKZASsHtaplj4HFWFtzrlUZjalwDV78rR5oTFq3OcKcrVbvvqh
         xvoB6t9IUs2zAixwP0xrQ4gO8VoUuJfzmOWkETAQOdgaqJQFYvc0ctNEKhaPpsHxaP94
         02canKPYn3NkdSY+Oy6vLTfdI4p0Y4FbDpAKAP03aQIL5mTKV8WHFCaWyxC4uRkqsaou
         eEbA45AVtMzTu1KzuIp5NT0QdgcWkyXg82USzZ8UFugRMerkxaQ3u8WlkZFGCONCRMGm
         TCaw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=ZPFv6m+iH8EeSMp9wFrys9PGKYZJjpGjv1/CHTAfS5M=;
        b=Tyehmbd9C1t5+b79AZshSFn49C97qSmltkmw/1rWBCF9yjYkJn/NROgedA1/Zid1tN
         P0A15PKcnU18FfygDUwXX7h2K9K77Rdy2KUUHuVfgsZQf5uVDvkkDf5/zHypswQTITjv
         hyc6CONW0GfUFtgspXdLINAm9v2FdpQx2yFjLKxt7Zaboca5rWSDPL37PREtE7ISDOnm
         +ZFaRa7ZJ0ZmpWhywEkJv7Pr5SnXmHNuHZWujhnWeM007RUlEaaKb9CSVIkFGaXjNFY3
         zl55KSkMDqetQUNvXTPRgQlfFqLhczLyz/gIcpJwk5QVMKbk7GjyqAOi70Z5POtfWLdw
         NEhw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="p4m/oBqS";
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c20sor7757717pgk.50.2019.04.26.23.43.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Apr 2019 23:43:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="p4m/oBqS";
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=ZPFv6m+iH8EeSMp9wFrys9PGKYZJjpGjv1/CHTAfS5M=;
        b=p4m/oBqSG6KLPf+AqtV3OdSRGsnlwAcOGjTsQ1oMvTgRjsaBLxL2oqlvHbnUOD7DhC
         llMjaQPUwxdsPmzYP1Xk4zg6iskJI0V3bcjSumFgJeyn32g+AQyeuwbnaKNcunnSGV+X
         jFrW4YEgTD0CVzhuajD3RiuuFodFK5pQf/h/OASbcijhEUNJeR4GOVIaxGkMApARhJuz
         heZkZxY0ibC3WGtyGA9X5OpN8Qanr6vPnIs32DNHYf97D5Hp43Bu1zzc+18KCpllyi2H
         mACL4axXMqmHb8f85O6m0qGesKiJyaJ8E2Q7anmXlyeLMnsiSJBU8Ye4Tm8bsUaDuaL0
         //Aw==
X-Google-Smtp-Source: APXvYqyVtXk5iHrU+w85KghleSi1h9IdIHLthG9HVX8BbnAS3s4DC3QPi8s9GkBRV20LWDs74Eyk7w==
X-Received: by 2002:a63:1359:: with SMTP id 25mr46901248pgt.92.1556347393845;
        Fri, 26 Apr 2019 23:43:13 -0700 (PDT)
Received: from sc2-haas01-esx0118.eng.vmware.com ([66.170.99.1])
        by smtp.gmail.com with ESMTPSA id j22sm36460145pfn.129.2019.04.26.23.43.12
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 23:43:13 -0700 (PDT)
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
	Dave Hansen <dave.hansen@intel.com>
Subject: [PATCH v6 07/24] x86/alternative: Initialize temporary mm for patching
Date: Fri, 26 Apr 2019 16:22:46 -0700
Message-Id: <20190426232303.28381-8-nadav.amit@gmail.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190426232303.28381-1-nadav.amit@gmail.com>
References: <20190426232303.28381-1-nadav.amit@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Nadav Amit <namit@vmware.com>

To prevent improper use of the PTEs that are used for text patching, the
next patches will use a temporary mm struct. Initailize it by copying
the init mm.

The address that will be used for patching is taken from the lower area
that is usually used for the task memory. Doing so prevents the need to
frequently synchronize the temporary-mm (e.g., when BPF programs are
installed), since different PGDs are used for the task memory.

Finally, randomize the address of the PTEs to harden against exploits
that use these PTEs.

Cc: Kees Cook <keescook@chromium.org>
Cc: Dave Hansen <dave.hansen@intel.com>
Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Reviewed-by: Masami Hiramatsu <mhiramat@kernel.org>
Tested-by: Masami Hiramatsu <mhiramat@kernel.org>
Suggested-by: Andy Lutomirski <luto@kernel.org>
Signed-off-by: Nadav Amit <namit@vmware.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/include/asm/pgtable.h       |  3 +++
 arch/x86/include/asm/text-patching.h |  2 ++
 arch/x86/kernel/alternative.c        |  3 +++
 arch/x86/mm/init.c                   | 37 ++++++++++++++++++++++++++++
 init/main.c                          |  3 +++
 5 files changed, 48 insertions(+)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 5cfbbb6d458d..6b6bfdfe83aa 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -1038,6 +1038,9 @@ static inline void __meminit init_trampoline_default(void)
 	/* Default trampoline pgd value */
 	trampoline_pgd_entry = init_top_pgt[pgd_index(__PAGE_OFFSET)];
 }
+
+void __init poking_init(void);
+
 # ifdef CONFIG_RANDOMIZE_MEMORY
 void __meminit init_trampoline(void);
 # else
diff --git a/arch/x86/include/asm/text-patching.h b/arch/x86/include/asm/text-patching.h
index f8fc8e86cf01..a75eed841eed 100644
--- a/arch/x86/include/asm/text-patching.h
+++ b/arch/x86/include/asm/text-patching.h
@@ -39,5 +39,7 @@ extern void *text_poke_kgdb(void *addr, const void *opcode, size_t len);
 extern int poke_int3_handler(struct pt_regs *regs);
 extern void *text_poke_bp(void *addr, const void *opcode, size_t len, void *handler);
 extern int after_bootmem;
+extern __ro_after_init struct mm_struct *poking_mm;
+extern __ro_after_init unsigned long poking_addr;
 
 #endif /* _ASM_X86_TEXT_PATCHING_H */
diff --git a/arch/x86/kernel/alternative.c b/arch/x86/kernel/alternative.c
index 0a814d73547a..11d5c710a94f 100644
--- a/arch/x86/kernel/alternative.c
+++ b/arch/x86/kernel/alternative.c
@@ -679,6 +679,9 @@ void *__init_or_module text_poke_early(void *addr, const void *opcode,
 	return addr;
 }
 
+__ro_after_init struct mm_struct *poking_mm;
+__ro_after_init unsigned long poking_addr;
+
 static void *__text_poke(void *addr, const void *opcode, size_t len)
 {
 	unsigned long flags;
diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
index f905a2371080..c25bb00955db 100644
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -22,6 +22,7 @@
 #include <asm/hypervisor.h>
 #include <asm/cpufeature.h>
 #include <asm/pti.h>
+#include <asm/text-patching.h>
 
 /*
  * We need to define the tracepoints somewhere, and tlb.c
@@ -700,6 +701,42 @@ void __init init_mem_mapping(void)
 	early_memtest(0, max_pfn_mapped << PAGE_SHIFT);
 }
 
+/*
+ * Initialize an mm_struct to be used during poking and a pointer to be used
+ * during patching.
+ */
+void __init poking_init(void)
+{
+	spinlock_t *ptl;
+	pte_t *ptep;
+
+	pr_err("%s\n", __func__);
+	poking_mm = copy_init_mm();
+	BUG_ON(!poking_mm);
+
+	/*
+	 * Randomize the poking address, but make sure that the following page
+	 * will be mapped at the same PMD. We need 2 pages, so find space for 3,
+	 * and adjust the address if the PMD ends after the first one.
+	 */
+	poking_addr = TASK_UNMAPPED_BASE;
+	if (IS_ENABLED(CONFIG_RANDOMIZE_BASE))
+		poking_addr += (kaslr_get_random_long("Poking") & PAGE_MASK) %
+			(TASK_SIZE - TASK_UNMAPPED_BASE - 3 * PAGE_SIZE);
+
+	if (((poking_addr + PAGE_SIZE) & ~PMD_MASK) == 0)
+		poking_addr += PAGE_SIZE;
+
+	/*
+	 * We need to trigger the allocation of the page-tables that will be
+	 * needed for poking now. Later, poking may be performed in an atomic
+	 * section, which might cause allocation to fail.
+	 */
+	ptep = get_locked_pte(poking_mm, poking_addr, &ptl);
+	BUG_ON(!ptep);
+	pte_unmap_unlock(ptep, ptl);
+}
+
 /*
  * devmem_is_allowed() checks to see if /dev/mem access to a certain address
  * is valid. The argument is a physical page number.
diff --git a/init/main.c b/init/main.c
index 598e278b46f7..949eed8015ec 100644
--- a/init/main.c
+++ b/init/main.c
@@ -504,6 +504,8 @@ void __init __weak thread_stack_cache_init(void)
 
 void __init __weak mem_encrypt_init(void) { }
 
+void __init __weak poking_init(void) { }
+
 bool initcall_debug;
 core_param(initcall_debug, initcall_debug, bool, 0644);
 
@@ -737,6 +739,7 @@ asmlinkage __visible void __init start_kernel(void)
 	taskstats_init_early();
 	delayacct_init();
 
+	poking_init();
 	check_bugs();
 
 	acpi_subsystem_init();
-- 
2.17.1

