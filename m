Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D52CC31E48
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 17:10:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 31D25215EA
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 17:10:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazon.de header.i=@amazon.de header.b="jfwfY+5h"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 31D25215EA
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=amazon.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D93CF6B0269; Wed, 12 Jun 2019 13:10:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D43456B026A; Wed, 12 Jun 2019 13:10:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C0B696B026B; Wed, 12 Jun 2019 13:10:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9BF216B0269
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 13:10:55 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id o16so15179650qtj.6
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 10:10:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ux5wirT9zpu2UH49VFUeEuLSRIHtQX+sem65xFY2kAA=;
        b=NufE3aYZkp1aRpFef/3W0fKza0ROvVpPHcKxJo5NqFtY0pyqBhaoHFcARCxeckC1tx
         xW9MCTMd8jiSDAV4h8UPk4sA60ggMk8/M9znneizUbVCljliPSwL5Pyvt1pbrSmn9MmI
         lL6CVIfHCD25g2lhPf3BDYa/mkHvSCvh/KZdKKiAPrTw3N8h/p4wYQQ21uy/UUsCr5qh
         jPGKEmk2ulOtdaQsQoLks2ckdynafxf1Wo4FPMcqixSwUlXaKjJ4Oxi9oGyV9eocSyeH
         cRxhfdq4YBKdKyHia/AQitAZrxvuPk6iFEdX8HSbOADkfUOspvtMRr7OjMF+VY2CbdvY
         mxKA==
X-Gm-Message-State: APjAAAUlOSOHmiiTRMBXOiSgTdiGrnrUmfRAVWPxcI6EWSYQgq3xD2tX
	iItmmQqPE6pB8oPuzuZgTYbtpZgLz7FCtW74dqtpUFn0QbrAj/OwXaE5cmQs38Jnxyzo6QtYNww
	9AMDRpAFqbbT67F5pmwjn+DLiiwzrAL7AvBlAe4U7v/D+QG7I33InEmIG9DUR1A0U3w==
X-Received: by 2002:ac8:303c:: with SMTP id f57mr71745048qte.294.1560359455340;
        Wed, 12 Jun 2019 10:10:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyeK/FuuqunV3BySWYKHa4qZUThV23uRL+msMxGFFuEw4JoHVwuTUW9fjhYoYzwd1xkfFCR
X-Received: by 2002:ac8:303c:: with SMTP id f57mr71744982qte.294.1560359454309;
        Wed, 12 Jun 2019 10:10:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560359454; cv=none;
        d=google.com; s=arc-20160816;
        b=Nv5c0KwEbg5bXftBxPM0jAIm2xBOKv6Oi9BcbmB5QSdGV/iuFISuPvUg5aWe+CdAUi
         y0HAvGUy3+Q5eg4/YUQI1KOy5NNpc0SplbquFpSnTvXPe9OOBnGJcb6GEetDlmRk8Fpz
         jSrCrynPfIZH8GrlK8Lrcx29I6/TxZXusbat0VB9ey1xAzppdA7psui4+XB+Z83fYA/j
         1KRXzmSItp0wpGcZfJQ4R85v3jXTqSpI6AckTmPG2W4TiLWDGFfFi9+MKFOF5nqASQBu
         BkG3QDok0IUbCgYlWQO5qe/cYOBexbPOpnvb4G4x3x2utrvWJrlMuQfVakf1L3oIKwC/
         zkfw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=ux5wirT9zpu2UH49VFUeEuLSRIHtQX+sem65xFY2kAA=;
        b=NsenurRhWtb0iNlwluYulZ7EXgBYueATixpboHgNZ93LLGfq2fLzuDJ4FaPOZptoKP
         K/QVEQc1nF91DE/eKUTF1kQtoUmZMFh9pNTgM6rSk6JFDZOPsDUCu4TnsBHYklyKVFkw
         L7O09oRAXB7xR+Hk02zTgjXTQVzEng3/oXY07xmtNLjTLXG90lf1I2VoUoSDLd91ieZI
         ap9WAq1jbQj+fYuKoAkGQO9h7QRdxxlbbCrIx/xY127IrZ3IIBGWVPPL3yALguHKpQ/s
         2T0sljUwbOksDR/RyLjnYGwkvghdTKLClvBOk5yxM+LEqIwQDkQBXFfxNpRtG+LPC4oJ
         UKFw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazon.de header.s=amazon201209 header.b=jfwfY+5h;
       spf=pass (google.com: domain of prvs=059bff19d=mhillenb@amazon.com designates 72.21.196.25 as permitted sender) smtp.mailfrom="prvs=059bff19d=mhillenb@amazon.com";
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amazon.de
Received: from smtp-fw-2101.amazon.com (smtp-fw-2101.amazon.com. [72.21.196.25])
        by mx.google.com with ESMTPS id h20si10314qkg.262.2019.06.12.10.10.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 10:10:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=059bff19d=mhillenb@amazon.com designates 72.21.196.25 as permitted sender) client-ip=72.21.196.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazon.de header.s=amazon201209 header.b=jfwfY+5h;
       spf=pass (google.com: domain of prvs=059bff19d=mhillenb@amazon.com designates 72.21.196.25 as permitted sender) smtp.mailfrom="prvs=059bff19d=mhillenb@amazon.com";
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amazon.de
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=amazon.de; i=@amazon.de; q=dns/txt; s=amazon201209;
  t=1560359454; x=1591895454;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=ux5wirT9zpu2UH49VFUeEuLSRIHtQX+sem65xFY2kAA=;
  b=jfwfY+5hSFUhdpfBBBqFlENGGtZ/X1/3KA2dCCqGUgXhZAwVFPCEb0c6
   kHIlHs8dYW9moZqejSl0kbYbI/WRAIlLXJUHdAws4bwYPKja0gP3VhYk9
   xQrydJcwwfCsT6JyCIdHIsaTdxuqIsZml/du0Td/nYHx/krJqLZ/iA6sz
   Q=;
X-IronPort-AV: E=Sophos;i="5.62,366,1554768000"; 
   d="scan'208";a="737183030"
Received: from iad6-co-svc-p1-lb1-vlan2.amazon.com (HELO email-inbound-relay-2b-859fe132.us-west-2.amazon.com) ([10.124.125.2])
  by smtp-border-fw-out-2101.iad2.amazon.com with ESMTP; 12 Jun 2019 17:10:52 +0000
Received: from ua08cfdeba6fe59dc80a8.ant.amazon.com (pdx2-ws-svc-lb17-vlan3.amazon.com [10.247.140.70])
	by email-inbound-relay-2b-859fe132.us-west-2.amazon.com (Postfix) with ESMTPS id BEF16222032;
	Wed, 12 Jun 2019 17:10:51 +0000 (UTC)
Received: from ua08cfdeba6fe59dc80a8.ant.amazon.com (ua08cfdeba6fe59dc80a8.ant.amazon.com [127.0.0.1])
	by ua08cfdeba6fe59dc80a8.ant.amazon.com (8.15.2/8.15.2/Debian-3) with ESMTP id x5CHAnko017677;
	Wed, 12 Jun 2019 19:10:49 +0200
Received: (from mhillenb@localhost)
	by ua08cfdeba6fe59dc80a8.ant.amazon.com (8.15.2/8.15.2/Submit) id x5CHAnDT017675;
	Wed, 12 Jun 2019 19:10:49 +0200
From: Marius Hillenbrand <mhillenb@amazon.de>
To: kvm@vger.kernel.org
Cc: Marius Hillenbrand <mhillenb@amazon.de>, linux-kernel@vger.kernel.org,
        kernel-hardening@lists.openwall.com, linux-mm@kvack.org,
        Alexander Graf <graf@amazon.de>, David Woodhouse <dwmw@amazon.co.uk>
Subject: [RFC 03/10] x86/mm, mm,kernel: add teardown for process-local memory to mm cleanup
Date: Wed, 12 Jun 2019 19:08:30 +0200
Message-Id: <20190612170834.14855-4-mhillenb@amazon.de>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190612170834.14855-1-mhillenb@amazon.de>
References: <20190612170834.14855-1-mhillenb@amazon.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Process-local memory uses a dedicated pgd entry in kernel space and its
own page table structure. Hook mm exit functions to cleanup those
dedicated page tables. As a preparation, release any left-over
process-local allocations in the address space.

Signed-off-by: Marius Hillenbrand <mhillenb@amazon.de>
Cc: Alexander Graf <graf@amazon.de>
Cc: David Woodhouse <dwmw@amazon.co.uk>
---
 arch/x86/include/asm/proclocal.h |  11 +++
 arch/x86/mm/Makefile             |   1 +
 arch/x86/mm/proclocal.c          | 131 +++++++++++++++++++++++++++++++
 include/linux/mm_types.h         |   9 +++
 include/linux/proclocal.h        |  16 ++++
 kernel/fork.c                    |   6 ++
 mm/Makefile                      |   1 +
 mm/proclocal.c                   |  35 +++++++++
 8 files changed, 210 insertions(+)
 create mode 100644 arch/x86/include/asm/proclocal.h
 create mode 100644 arch/x86/mm/proclocal.c
 create mode 100644 include/linux/proclocal.h
 create mode 100644 mm/proclocal.c

diff --git a/arch/x86/include/asm/proclocal.h b/arch/x86/include/asm/proclocal.h
new file mode 100644
index 000000000000..a66983e49209
--- /dev/null
+++ b/arch/x86/include/asm/proclocal.h
@@ -0,0 +1,11 @@
+/*
+ * Copyright 2019 Amazon.com, Inc. or its affiliates. All Rights Reserved.
+ */
+#ifndef _ASM_X86_PROCLOCAL_H
+#define _ASM_X86_PROCLOCAL_H
+
+struct mm_struct;
+
+void arch_proclocal_teardown_pages_and_pt(struct mm_struct *mm);
+
+#endif	/* _ASM_X86_PROCLOCAL_H */
diff --git a/arch/x86/mm/Makefile b/arch/x86/mm/Makefile
index e4ffcf74770e..a7c7111eb8f0 100644
--- a/arch/x86/mm/Makefile
+++ b/arch/x86/mm/Makefile
@@ -56,3 +56,4 @@ obj-$(CONFIG_AMD_MEM_ENCRYPT)	+= mem_encrypt_boot.o
 
 obj-$(CONFIG_XPFO)		+= xpfo.o
 
+obj-$(CONFIG_PROCLOCAL) += proclocal.o
diff --git a/arch/x86/mm/proclocal.c b/arch/x86/mm/proclocal.c
new file mode 100644
index 000000000000..c64a8ea6360d
--- /dev/null
+++ b/arch/x86/mm/proclocal.c
@@ -0,0 +1,131 @@
+/*
+ * Architecture-specific code for handling process-local memory on x86-64.
+ *
+ * Copyright 2019 Amazon.com, Inc. or its affiliates. All Rights Reserved.
+ */
+
+#include <linux/list.h>
+#include <linux/mm.h>
+#include <linux/proclocal.h>
+#include <linux/set_memory.h>
+#include <asm/tlb.h>
+
+
+static void unmap_leftover_pages_pte(struct mm_struct *mm, pmd_t *pmd,
+				     unsigned long addr, unsigned long end,
+				     struct list_head *page_list)
+{
+	pte_t *pte;
+	struct page *page;
+
+	for (pte = pte_offset_map(pmd, addr);
+	     addr < end; addr += PAGE_SIZE, pte++) {
+		if (!pte_present(*pte))
+			continue;
+
+		page = pte_page(*pte);
+		pte_clear(mm, addr, pte);
+		set_direct_map_default_noflush(page);
+
+		/*
+		 * scrub page contents. since mm teardown happens from a
+		 * different mm, we cannot just use the process-local virtual
+		 * address; access the page via the physmap instead. note that
+		 * there is a small time frame where leftover data is globally
+		 * visible in the kernel address space.
+		 *
+		 * tbd in later commit: scrub the page via a temporary mapping
+		 * in process-local memory area before re-attaching it to the
+		 * physmap.
+		 */
+		memset(page_to_virt(page), 0, PAGE_SIZE);
+
+		/*
+		 * track page for cleanup later;
+		 * note that the proclocal_next list is used only for regular
+		 * kfree_proclocal, so ripping pages out now is fine.
+		 */
+		INIT_LIST_HEAD(&page->proclocal_next);
+		list_add_tail(&page->proclocal_next, page_list);
+	}
+}
+
+/*
+ * Walk through process-local mappings on each page table level. Avoid code
+ * duplication and use a macro to generate one function for each level.
+ *
+ * The macro generates a function for page table level LEVEL. The function is
+ * passed a pointer to the entry in the page table level ABOVE and recurses into
+ * the page table level BELOW.
+ */
+#define UNMAP_LEFTOVER_LEVEL(LEVEL, ABOVE, BELOW) \
+	static void unmap_leftover_pages_ ## LEVEL (struct mm_struct *mm, ABOVE ## _t *ABOVE,	\
+						    unsigned long addr, unsigned long end,	\
+						    struct list_head *page_list)		\
+	{										\
+		LEVEL ## _t *LEVEL  = LEVEL ## _offset(ABOVE, addr);			\
+		unsigned long next;							\
+		do {									\
+			next = LEVEL ## _addr_end(addr, end);				\
+			if (LEVEL ## _present(*LEVEL))					\
+				unmap_leftover_pages_## BELOW (mm, LEVEL, addr, next, page_list); \
+		} while (LEVEL++, addr = next, addr < end);				\
+	}
+
+UNMAP_LEFTOVER_LEVEL(pmd, pud, pte)
+UNMAP_LEFTOVER_LEVEL(pud, p4d, pmd)
+UNMAP_LEFTOVER_LEVEL(p4d, pgd, pud)
+#undef UNMAP_LEFTOVER_LEVEL
+
+extern void proclocal_release_pages(struct list_head *pages);
+
+static void unmap_free_leftover_proclocal_pages(struct mm_struct *mm)
+{
+	LIST_HEAD(page_list);
+	unsigned long addr = PROCLOCAL_START, next;
+	unsigned long end = PROCLOCAL_START + PROCLOCAL_SIZE;
+
+	/*
+	 * Walk page tables in process-local memory area and handle leftover
+	 * process-local pages. Note that we cannot use the kernel's
+	 * walk_page_range, because that function assumes walking across vmas.
+	 */
+	spin_lock(&mm->page_table_lock);
+	do {
+		pgd_t *pgd = pgd_offset(mm, addr);
+		next = pgd_addr_end(addr, end);
+
+		if (pgd_present(*pgd)) {
+			unmap_leftover_pages_p4d(mm, pgd, addr, next, &page_list);
+		}
+		addr = next;
+	} while (addr < end);
+	spin_unlock(&mm->page_table_lock);
+	/*
+	 * Flush any mappings of process-local pages from the TLBs, so that we
+	 * can release the pages afterwards.
+	 */
+	flush_tlb_mm_range(mm, PROCLOCAL_START, end, PAGE_SHIFT, false);
+	proclocal_release_pages(&page_list);
+}
+
+static void arch_proclocal_teardown_pt(struct mm_struct *mm)
+{
+	struct mmu_gather tlb;
+	/*
+	 * clean up page tables for the whole pgd used exclusively by
+	 * process-local memory.
+	 */
+	unsigned long proclocal_base_pgd = PROCLOCAL_START & PGDIR_MASK;
+	unsigned long proclocal_end_pgd = proclocal_base_pgd + PGDIR_SIZE;
+
+	tlb_gather_mmu(&tlb, mm, proclocal_base_pgd, proclocal_end_pgd);
+	free_pgd_range(&tlb, proclocal_base_pgd, proclocal_end_pgd, 0, 0);
+	tlb_finish_mmu(&tlb, proclocal_base_pgd, proclocal_end_pgd);
+}
+
+void arch_proclocal_teardown_pages_and_pt(struct mm_struct *mm)
+{
+	unmap_free_leftover_proclocal_pages(mm);
+	arch_proclocal_teardown_pt(mm);
+}
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 2fe4dbfcdebd..1cb9243dd299 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -158,6 +158,15 @@ struct page {
 
 		/** @rcu_head: You can use this to free a page by RCU. */
 		struct rcu_head rcu_head;
+
+#ifdef CONFIG_PROCLOCAL
+		struct {	/* PROCLOCAL pages */
+			struct list_head proclocal_next; /* track pages in one allocation */
+			unsigned long _proclocal_pad_1; /* mapping */
+			/* head page of an allocation stores its length */
+			size_t proclocal_nr_pages;
+		};
+#endif
 	};
 
 	union {		/* This union is 4 bytes in size. */
diff --git a/include/linux/proclocal.h b/include/linux/proclocal.h
new file mode 100644
index 000000000000..9dae140c0796
--- /dev/null
+++ b/include/linux/proclocal.h
@@ -0,0 +1,16 @@
+/*
+ * Copyright 2019 Amazon.com, Inc. or its affiliates. All Rights Reserved.
+ */
+#ifndef _PROCLOCAL_H
+#define _PROCLOCAL_H
+
+#ifdef CONFIG_PROCLOCAL
+
+struct mm_struct;
+
+void proclocal_mm_exit(struct mm_struct *mm);
+#else  /* !CONFIG_PROCLOCAL */
+static inline void proclocal_mm_exit(struct mm_struct *mm) { }
+#endif
+
+#endif /* _PROCLOCAL_H */
diff --git a/kernel/fork.c b/kernel/fork.c
index 6e37f5626417..caca6b16ee1e 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -92,6 +92,7 @@
 #include <linux/livepatch.h>
 #include <linux/thread_info.h>
 #include <linux/stackleak.h>
+#include <linux/proclocal.h>
 
 #include <asm/pgtable.h>
 #include <asm/pgalloc.h>
@@ -1051,6 +1052,11 @@ static inline void __mmput(struct mm_struct *mm)
 	exit_mmap(mm);
 	mm_put_huge_zero_page(mm);
 	set_mm_exe_file(mm, NULL);
+	/*
+	 * No real users of this address space left, dropping process-local
+	 * mappings.
+	 */
+	proclocal_mm_exit(mm);
 	if (!list_empty(&mm->mmlist)) {
 		spin_lock(&mmlist_lock);
 		list_del(&mm->mmlist);
diff --git a/mm/Makefile b/mm/Makefile
index e99e1e6ae5ae..029d7e2ee80b 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -100,3 +100,4 @@ obj-$(CONFIG_PERCPU_STATS) += percpu-stats.o
 obj-$(CONFIG_HMM) += hmm.o
 obj-$(CONFIG_MEMFD_CREATE) += memfd.o
 obj-$(CONFIG_XPFO) += xpfo.o
+obj-$(CONFIG_PROCLOCAL) += proclocal.o
diff --git a/mm/proclocal.c b/mm/proclocal.c
new file mode 100644
index 000000000000..72c485c450bf
--- /dev/null
+++ b/mm/proclocal.c
@@ -0,0 +1,35 @@
+/*
+ * mm/proclocal.c
+ *
+ * The code in this file implements process-local mappings in the Linux kernel
+ * address space. This memory is only usable in the process context. With memory
+ * not globally visible in the kernel, it cannot easily be prefetched and leaked
+ * via L1TF.
+ *
+ * Copyright 2019 Amazon.com, Inc. or its affiliates. All Rights Reserved.
+ */
+#include <linux/mm.h>
+#include <linux/proclocal.h>
+#include <linux/set_memory.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+
+#include <asm/proclocal.h>
+#include <asm/pgalloc.h>
+#include <asm/tlb.h>
+
+void proclocal_release_pages(struct list_head *pages)
+{
+	struct page *pos, *n;
+	list_for_each_entry_safe(pos, n, pages, proclocal_next) {
+		list_del(&pos->proclocal_next);
+		__free_page(pos);
+	}
+}
+
+void proclocal_mm_exit(struct mm_struct *mm)
+{
+	pr_debug("proclocal_mm_exit for mm %p pgd %p (current is %p)\n", mm, mm->pgd, current);
+
+	arch_proclocal_teardown_pages_and_pt(mm);
+}
-- 
2.21.0

