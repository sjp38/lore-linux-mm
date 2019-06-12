Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5AC93C31E48
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 17:11:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0883E21734
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 17:11:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazon.de header.i=@amazon.de header.b="MBgrCVd8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0883E21734
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=amazon.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9E9F16B026A; Wed, 12 Jun 2019 13:11:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 99A666B026B; Wed, 12 Jun 2019 13:11:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 83A386B026C; Wed, 12 Jun 2019 13:11:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f199.google.com (mail-vk1-f199.google.com [209.85.221.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5B5826B026A
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 13:11:06 -0400 (EDT)
Received: by mail-vk1-f199.google.com with SMTP id 184so5316172vku.17
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 10:11:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=0sTYNypMH60bWy7mpyTtzOSWmLkHItIqbVNN5O//Yh4=;
        b=N62V277lb72uOsISKo53PmCz1vmm2pQ76TGvdj8Uo+PVqZYXyZol3Rk1EClZQ9oMle
         GFHJZbCyhZLIJVAtChkt/8BII9RfqpvvGaIYB+gdyd39lUJVLPNSI+mZgyb3OBk31rwW
         iJ+gKgQK3CW8MbQt8Y+372KXA2oygk9WvVyLvIzI2naAhioOP2QIQYtGh3vfy06hz4Xk
         BF30Iy40QAXHYnatoHdmCF6kVhBXijZDx0zugHVfYH8pA3FUJQZzRh8xDOoEL7t9Nuir
         5Oq1Jtvufn5p5J/7yKDt42W/2a7BIhnSidYhPuGQw+4nb9px6w1QwrqnGmKAtExAES7D
         JDZQ==
X-Gm-Message-State: APjAAAX8tPkwQPWZSSWYxIBabkj5HEgOQYpY3T/RDJJ/o6NRaHVz5rcF
	FIAL0J9jrVGoleduefA7fwifQJC2c+QhmOohhcK/GHvs3viyIl5o6DBuHFQSNImBOxMLoOpntCn
	Ev8ypVprL8nMYB90n4N/ZBky9XhetPB2paGp0hDYf2umSNbOBVu5Nes985ZuOAjG2cA==
X-Received: by 2002:a67:3310:: with SMTP id z16mr26391095vsz.75.1560359466027;
        Wed, 12 Jun 2019 10:11:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzgdPbu1P3WKo4zfgFwhzp4vw3SGdSjeRjGlmJijXPx/Mbp/hTT8qDJ1YIDfUUB9FKJ/961
X-Received: by 2002:a67:3310:: with SMTP id z16mr26390998vsz.75.1560359465199;
        Wed, 12 Jun 2019 10:11:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560359465; cv=none;
        d=google.com; s=arc-20160816;
        b=k59xw9pTyoT9ypTwzaTqv6lGBF5uG7MjBKA8jn1z2J6mNbC74awfq9yRzfXK33uyR9
         3jNax9eTysrzdkNbOVC/a6hHG24TfnvcrJZGOfWeT+xp0h9ErtdHUZFrGJsKemBFdvR8
         cbUFxNXZio0s533/YAjpjbRb1JFpeptddPAhRj8hq5j/cgYccJx9z/iZVZXO4SmOGowv
         1nWjC47jqK4Jlm77ABFK/eMHj9GpCEboEt6S+cOavskJ8fBs6zvTDbimlGKadZ8CPocT
         reWCX3vKBpDRGVi1bfOaWs5aKHcPt8pNG+g1XblmSrERLiwT2oUiMecDnaDdCNtkyXAH
         zkOA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=0sTYNypMH60bWy7mpyTtzOSWmLkHItIqbVNN5O//Yh4=;
        b=JeMXA2C4t07l18xfsjPNkNRHwzLJ2nYTXzmz70D8Hda++mEEEhnXw5GIbTlw2Ejx3o
         h4dIsiZ37WFW4ZQfSLa9j07a9ZHyD+4dmpAyjTUFr/m6GYIio+eIN734X4NFcwlOlgWi
         4Qj8kB0lp+tWIlFwbVqgX++xvuuJz/9Z6asb1RirRqIsBm2Pr/o4hsj4WxSMB/dXs7NX
         UBym20091ZV0+wELokx5NsTq/CUT4G+jv2qxkJBOGBmiamLrhkWhvbyLxNgoqQ1ckWhm
         rK+xC3ryd25Mc7Sa2302kJuHc35vJJa8RQx046wFv4UerC43qg+ijCIvZZ33cuwHf8Tk
         ZgwA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazon.de header.s=amazon201209 header.b=MBgrCVd8;
       spf=pass (google.com: domain of prvs=059bff19d=mhillenb@amazon.com designates 207.171.184.25 as permitted sender) smtp.mailfrom="prvs=059bff19d=mhillenb@amazon.com";
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amazon.de
Received: from smtp-fw-9101.amazon.com (smtp-fw-9101.amazon.com. [207.171.184.25])
        by mx.google.com with ESMTPS id j65si57881uaj.137.2019.06.12.10.11.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 10:11:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=059bff19d=mhillenb@amazon.com designates 207.171.184.25 as permitted sender) client-ip=207.171.184.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazon.de header.s=amazon201209 header.b=MBgrCVd8;
       spf=pass (google.com: domain of prvs=059bff19d=mhillenb@amazon.com designates 207.171.184.25 as permitted sender) smtp.mailfrom="prvs=059bff19d=mhillenb@amazon.com";
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amazon.de
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=amazon.de; i=@amazon.de; q=dns/txt; s=amazon201209;
  t=1560359464; x=1591895464;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=0sTYNypMH60bWy7mpyTtzOSWmLkHItIqbVNN5O//Yh4=;
  b=MBgrCVd8jCI4l1yaw0sMHNDBjU5mm9Ebt7iuhz3JWBMyZCcE+oBHcksX
   f+UfS6SbbfIRlhR3qnbPL8WTVS9WeouoI7sS69+1wNNWoQWUCp+WJT+0F
   DfMXlSqX2h/838hVw+BHUvRnd5ldag1i75kYxYlYtBvItJi0kkIEu82r+
   k=;
X-IronPort-AV: E=Sophos;i="5.62,366,1554768000"; 
   d="scan'208";a="810038987"
Received: from sea3-co-svc-lb6-vlan3.sea.amazon.com (HELO email-inbound-relay-2a-f14f4a47.us-west-2.amazon.com) ([10.47.22.38])
  by smtp-border-fw-out-9101.sea19.amazon.com with ESMTP; 12 Jun 2019 17:11:03 +0000
Received: from ua08cfdeba6fe59dc80a8.ant.amazon.com (pdx2-ws-svc-lb17-vlan3.amazon.com [10.247.140.70])
	by email-inbound-relay-2a-f14f4a47.us-west-2.amazon.com (Postfix) with ESMTPS id 4CB18A228E;
	Wed, 12 Jun 2019 17:11:02 +0000 (UTC)
Received: from ua08cfdeba6fe59dc80a8.ant.amazon.com (ua08cfdeba6fe59dc80a8.ant.amazon.com [127.0.0.1])
	by ua08cfdeba6fe59dc80a8.ant.amazon.com (8.15.2/8.15.2/Debian-3) with ESMTP id x5CHB090017869;
	Wed, 12 Jun 2019 19:11:00 +0200
Received: (from mhillenb@localhost)
	by ua08cfdeba6fe59dc80a8.ant.amazon.com (8.15.2/8.15.2/Submit) id x5CHAxh5017849;
	Wed, 12 Jun 2019 19:10:59 +0200
From: Marius Hillenbrand <mhillenb@amazon.de>
To: kvm@vger.kernel.org
Cc: Marius Hillenbrand <mhillenb@amazon.de>, linux-kernel@vger.kernel.org,
        kernel-hardening@lists.openwall.com, linux-mm@kvack.org,
        Alexander Graf <graf@amazon.de>, David Woodhouse <dwmw@amazon.co.uk>
Subject: [RFC 04/10] mm: allocate virtual space for process-local memory
Date: Wed, 12 Jun 2019 19:08:32 +0200
Message-Id: <20190612170834.14855-5-mhillenb@amazon.de>
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

Implement first half of kmalloc and kfree for process-local memory,
which deals with allocating virtual address ranges in the process-local
memory area.

While the process-local mappings will be visible only in a
single address space, the address of each allocation is still unique to
aid in debugging (e.g., to see page faults instead of silent invalid
accesses). For that purpose, use a global allocator for virtual address
ranges of process-local mappings. Note that the single centralized lock
is good enough for our use case.

Signed-off-by: Marius Hillenbrand <mhillenb@amazon.de>
Cc: Alexander Graf <graf@amazon.de>
Cc: David Woodhouse <dwmw@amazon.co.uk>
---
 arch/x86/mm/proclocal.c   |   7 +-
 include/linux/mm_types.h  |   4 +
 include/linux/proclocal.h |  19 +++++
 mm/proclocal.c            | 150 ++++++++++++++++++++++++++++++++++++++
 4 files changed, 179 insertions(+), 1 deletion(-)

diff --git a/arch/x86/mm/proclocal.c b/arch/x86/mm/proclocal.c
index c64a8ea6360d..dd641995cc9f 100644
--- a/arch/x86/mm/proclocal.c
+++ b/arch/x86/mm/proclocal.c
@@ -10,6 +10,8 @@
 #include <linux/set_memory.h>
 #include <asm/tlb.h>
 
+extern void handle_proclocal_page(struct mm_struct *mm, struct page *page,
+				  unsigned long addr);
 
 static void unmap_leftover_pages_pte(struct mm_struct *mm, pmd_t *pmd,
 				     unsigned long addr, unsigned long end,
@@ -27,6 +29,8 @@ static void unmap_leftover_pages_pte(struct mm_struct *mm, pmd_t *pmd,
 		pte_clear(mm, addr, pte);
 		set_direct_map_default_noflush(page);
 
+		/* callback to non-arch allocator */
+		handle_proclocal_page(mm, page, addr);
 		/*
 		 * scrub page contents. since mm teardown happens from a
 		 * different mm, we cannot just use the process-local virtual
@@ -126,6 +130,7 @@ static void arch_proclocal_teardown_pt(struct mm_struct *mm)
 
 void arch_proclocal_teardown_pages_and_pt(struct mm_struct *mm)
 {
-	unmap_free_leftover_proclocal_pages(mm);
+	if (mm->proclocal_nr_pages)
+		unmap_free_leftover_proclocal_pages(mm);
 	arch_proclocal_teardown_pt(mm);
 }
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 1cb9243dd299..4bd8737cc7a6 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -510,6 +510,10 @@ struct mm_struct {
 		/* HMM needs to track a few things per mm */
 		struct hmm *hmm;
 #endif
+
+#ifdef CONFIG_PROCLOCAL
+		size_t proclocal_nr_pages;
+#endif
 	} __randomize_layout;
 
 	/*
diff --git a/include/linux/proclocal.h b/include/linux/proclocal.h
index 9dae140c0796..c408e0d1104c 100644
--- a/include/linux/proclocal.h
+++ b/include/linux/proclocal.h
@@ -8,8 +8,27 @@
 
 struct mm_struct;
 
+void *kmalloc_proclocal(size_t size);
+void *kzalloc_proclocal(size_t size);
+void kfree_proclocal(void *vaddr);
+
 void proclocal_mm_exit(struct mm_struct *mm);
 #else  /* !CONFIG_PROCLOCAL */
+static inline void *kmalloc_proclocal(size_t size)
+{
+	return kmalloc(size, GFP_KERNEL);
+}
+
+static inline void * kzalloc_proclocal(size_t size)
+{
+	return kzalloc(size, GFP_KERNEL);
+}
+
+static inline void kfree_proclocal(void *vaddr)
+{
+	kfree(vaddr);
+}
+
 static inline void proclocal_mm_exit(struct mm_struct *mm) { }
 #endif
 
diff --git a/mm/proclocal.c b/mm/proclocal.c
index 72c485c450bf..7a6217faf765 100644
--- a/mm/proclocal.c
+++ b/mm/proclocal.c
@@ -8,6 +8,7 @@
  *
  * Copyright 2019 Amazon.com, Inc. or its affiliates. All Rights Reserved.
  */
+#include <linux/genalloc.h>
 #include <linux/mm.h>
 #include <linux/proclocal.h>
 #include <linux/set_memory.h>
@@ -18,6 +19,43 @@
 #include <asm/pgalloc.h>
 #include <asm/tlb.h>
 
+static pte_t *pte_lookup_map(struct mm_struct *mm, unsigned long kvaddr)
+{
+	pgd_t *pgd = pgd_offset(mm, kvaddr);
+	p4d_t *p4d;
+	pud_t *pud;
+	pmd_t *pmd;
+
+	if (IS_ERR_OR_NULL(pgd) || !pgd_present(*pgd))
+		return ERR_PTR(-1);
+
+	p4d = p4d_offset(pgd, kvaddr);
+	if (IS_ERR_OR_NULL(p4d) || !p4d_present(*p4d))
+		return ERR_PTR(-1);
+
+	pud = pud_offset(p4d, kvaddr);
+	if (IS_ERR_OR_NULL(pud) || !pud_present(*pud))
+		return ERR_PTR(-1);
+
+	pmd = pmd_offset(pud, kvaddr);
+	if (IS_ERR_OR_NULL(pmd) || !pmd_present(*pmd))
+		return ERR_PTR(-1);
+
+	return pte_offset_map(pmd, kvaddr);
+}
+
+static struct page *proclocal_find_first_page(struct mm_struct *mm, const void *kvaddr)
+{
+	pte_t *ptep = pte_lookup_map(mm, (unsigned long) kvaddr);
+
+	if(IS_ERR_OR_NULL(ptep))
+		return NULL;
+	if (!pte_present(*ptep))
+		return NULL;
+
+	return pfn_to_page(pte_pfn(*ptep));
+}
+
 void proclocal_release_pages(struct list_head *pages)
 {
 	struct page *pos, *n;
@@ -27,9 +65,121 @@ void proclocal_release_pages(struct list_head *pages)
 	}
 }
 
+static DEFINE_SPINLOCK(proclocal_lock);
+static struct gen_pool *allocator;
+
+static int proclocal_allocator_init(void)
+{
+	int rc;
+
+	allocator = gen_pool_create(PAGE_SHIFT, -1);
+	if (unlikely(IS_ERR(allocator)))
+		return PTR_ERR(allocator);
+	if (!allocator)
+		return -1;
+
+	rc = gen_pool_add(allocator, PROCLOCAL_START, PROCLOCAL_SIZE, -1);
+
+	if (rc)
+		gen_pool_destroy(allocator);
+
+	return rc;
+}
+late_initcall(proclocal_allocator_init);
+
+static void *alloc_virtual(size_t nr_pages)
+{
+	void *kvaddr;
+	spin_lock(&proclocal_lock);
+	kvaddr = (void *)gen_pool_alloc(allocator, nr_pages * PAGE_SIZE);
+	spin_unlock(&proclocal_lock);
+	return kvaddr;
+}
+
+static void free_virtual(const void *kvaddr, size_t nr_pages)
+{
+	spin_lock(&proclocal_lock);
+	gen_pool_free(allocator, (unsigned long)kvaddr,
+			     nr_pages * PAGE_SIZE);
+	spin_unlock(&proclocal_lock);
+}
+
+void *kmalloc_proclocal(size_t size)
+{
+	void *kvaddr = NULL;
+	size_t nr_pages = round_up(size, PAGE_SIZE) / PAGE_SIZE;
+	size_t nr_pages_virtual = nr_pages + 1; /* + guard page */
+
+	BUG_ON(!current);
+	if (!size)
+		return ZERO_SIZE_PTR;
+	might_sleep();
+
+	kvaddr = alloc_virtual(nr_pages_virtual);
+
+	if (IS_ERR_OR_NULL(kvaddr))
+		return kvaddr;
+
+	/* tbd: subsequent patch will allocate and map physical pages */
+
+	return kvaddr;
+}
+EXPORT_SYMBOL(kmalloc_proclocal);
+
+void * kzalloc_proclocal(size_t size)
+{
+	void * kvaddr = kmalloc_proclocal(size);
+
+	if (!IS_ERR_OR_NULL(kvaddr))
+		memset(kvaddr, 0, size);
+	return kvaddr;
+}
+EXPORT_SYMBOL(kzalloc_proclocal);
+
+void kfree_proclocal(void *kvaddr)
+{
+	struct page *first_page;
+	int nr_pages;
+	struct mm_struct *mm;
+
+	if (!kvaddr || kvaddr == ZERO_SIZE_PTR)
+		return;
+
+	pr_debug("kfree for %p (current %p mm %p)\n", kvaddr,
+		 current, current ? current->mm : 0);
+
+	BUG_ON((unsigned long)kvaddr < PROCLOCAL_START);
+	BUG_ON((unsigned long)kvaddr >= (PROCLOCAL_START + PROCLOCAL_SIZE));
+	BUG_ON(!current);
+
+	mm = current->mm;
+	down_write(&mm->mmap_sem);
+	first_page = proclocal_find_first_page(mm, kvaddr);
+	if (IS_ERR_OR_NULL(first_page)) {
+		pr_err("double-free?!\n");
+		BUG();
+	} /* double-free? */
+	nr_pages = first_page->proclocal_nr_pages;
+	BUG_ON(!nr_pages);
+	mm->proclocal_nr_pages -= nr_pages;
+	/* subsequent patch will unmap and release physical pages */
+	up_write(&mm->mmap_sem);
+
+	free_virtual(kvaddr, nr_pages + 1);
+}
+EXPORT_SYMBOL(kfree_proclocal);
+
 void proclocal_mm_exit(struct mm_struct *mm)
 {
 	pr_debug("proclocal_mm_exit for mm %p pgd %p (current is %p)\n", mm, mm->pgd, current);
 
 	arch_proclocal_teardown_pages_and_pt(mm);
 }
+
+void handle_proclocal_page(struct mm_struct *mm, struct page *page,
+				  unsigned long addr)
+{
+	if (page->proclocal_nr_pages) {
+		free_virtual((void *)addr, page->proclocal_nr_pages + 1);
+	}
+}
-- 
2.21.0

