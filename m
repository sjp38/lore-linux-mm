Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9BB5BC10F11
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 18:59:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 56D4D218B0
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 18:59:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 56D4D218B0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 13CBB6B026D; Mon, 22 Apr 2019 14:58:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0F2326B0271; Mon, 22 Apr 2019 14:58:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E7E8E6B0270; Mon, 22 Apr 2019 14:58:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id B09F56B026D
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 14:58:54 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id o8so8479848pgq.5
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 11:58:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=u6wlgWiwWVaBEbsh01acCfZKxBAGv1NeORm+6C+eZcs=;
        b=J1fvC/5g06QT9RD0qDyMxV/COfdsmer73wVRDFCSCwrYjsgUGjVKpa19u/mH4S5RMQ
         yrOrBUGipNw8KF3GLqTtDc/lOPCB/HsZsQI4PC0jjKlf4lJTJALLz70HmppGzFMYKkpr
         WBQGzOHbHyt0yDzFE3t7UqQjnXqnQfV4rAa8wQMAHJRbE/vPe3HHwdl6VchnZWGGOMLM
         lyZEL/RaYWWt5ovG6M26RSRRpoBaHH08rQ0l/4uw7Z+tnC+ivsf5wlXhV2wNVwoCy/XP
         s7jUPjbSTzpy/K9m54UBjvHc9Vtcu4sCwH4kuoFJ1WWyiU8j9IpblhsV8TEL5+VzWkGR
         vFeQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWxZMm1ES07vHoJq7eGmndygMDqoPNYB78FH0s6I26CujGA4NQi
	qChLEKkPYmsK8I8xG8dH51cie9xes+mf5HgeuU7fpE+Sb34aS4jDGjpW2+buSo1BSNIbEBc09ua
	0p5t2WIwk79DhYetZHdNSkHYiAlpjbQwD0YniAw1C0D3lvEgLtDR7VJQdrt+Zv9yqJg==
X-Received: by 2002:a17:902:f215:: with SMTP id gn21mr11673917plb.146.1555959534311;
        Mon, 22 Apr 2019 11:58:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy/TMDilYNCfR7/YsZ7Ol4OlN3HWT0ZR3IaEn+/cG3vbb4M9v6r44UJYbNaEUSnbPaPgBE8
X-Received: by 2002:a17:902:f215:: with SMTP id gn21mr11673295plb.146.1555959523027;
        Mon, 22 Apr 2019 11:58:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555959523; cv=none;
        d=google.com; s=arc-20160816;
        b=sj5Tv/K6wm5TcGPqMZoTmR99y94kVe/6UrXrNApKGExU665fTPtS3RhM2PqERbitER
         njYKHmV7zbYjcelrhoXBNeJ5NB8T3NuHizzyiz9i4F6WGmHhgVTukEXa8kGNYU/j10O4
         wmNSaxQ64Rw3E0aX437aHOHdWMhUjNeBVoAcovj8AoHX2RJ20KAIudSKBiSPJn26cWJX
         1CAM24yOJi3nkYVyqnTiNI4JokjgVbVVwMSmd8+eXwj3Z00Fau1OUTs0PylPq28nN5dl
         X8T8UvkEA4JZVNcl2izlzO5Tfvibw0MtvkiqFwWxQM28ny9mO1iAXiOgmY4Ob6nHYreq
         zIUw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=u6wlgWiwWVaBEbsh01acCfZKxBAGv1NeORm+6C+eZcs=;
        b=gEXeQXy+hMd6oPrOxbStd0KuaGtQK/FmtUlfeXWBn0J/ZGzQctLjB3MoyuK3T4L83a
         1mTrfHhet8Ck3uX0tnV0QoVC/7dCRqa1wO9xel8MaGidoADj52foU6Y0JfniVqu5wisz
         Vl84z1Flj5s+GqUWCJmeNX5hM0h/4BHKTNuh+QoPbZCavLbNZMExFsoUPwCh/PY0nLnl
         viOqPrl/GQrcucZxDQ9b+iLT38mE78HaLGZ5PG1GVYKSW1UXr2apahW9wgiD7wcBc2Tt
         GtxyxFYNa0qGEVdMdsYsKISXyqDJZqzFU6FdY/c0cvD2Etyzpx2uUMCMiAydwYw/Dv6v
         sMdA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id a2si12975117pgn.530.2019.04.22.11.58.42
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
   d="scan'208";a="136417134"
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
	Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH v4 06/23] x86/alternative: Initialize temporary mm for patching
Date: Mon, 22 Apr 2019 11:57:48 -0700
Message-Id: <20190422185805.1169-7-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190422185805.1169-1-rick.p.edgecombe@intel.com>
References: <20190422185805.1169-1-rick.p.edgecombe@intel.com>
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
 arch/x86/mm/init_64.c                | 36 ++++++++++++++++++++++++++++
 init/main.c                          |  3 +++
 5 files changed, 47 insertions(+)

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
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index bccff68e3267..125c8c48aa24 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -53,6 +53,7 @@
 #include <asm/init.h>
 #include <asm/uv/uv.h>
 #include <asm/setup.h>
+#include <asm/text-patching.h>
 
 #include "mm_internal.h"
 
@@ -1383,6 +1384,41 @@ unsigned long memory_block_size_bytes(void)
 	return memory_block_size_probed;
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
 #ifdef CONFIG_SPARSEMEM_VMEMMAP
 /*
  * Initialise the sparsemem vmemmap using huge-pages at the PMD level.
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

