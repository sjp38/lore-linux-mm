Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B570DC4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 17:37:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 56908206DF
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 17:37:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="A1IlnQsb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 56908206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8D4EA6B026A; Wed,  3 Apr 2019 13:37:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8855B6B026D; Wed,  3 Apr 2019 13:37:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6B0CE6B026F; Wed,  3 Apr 2019 13:37:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3A5EF6B026A
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 13:37:02 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id r21so14208933iod.12
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 10:37:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:in-reply-to:references;
        bh=MmLdvd3g+VOR33kiTfxTpT9StVgXRV1EaevyJ8pqRKM=;
        b=Qq6x7JTtsAVp7Jf7y8aFvpCePzZid/y4awHW5KSMQ/WPqqU3o6GybNAAScLPMIKR7D
         XyGIy22rte3dVMFmJ33JyYFVPdHN+VWFBJoBvl6SYJ6f71H2jhkR+WTVSoWFuN8/Q2KQ
         D1fx896iYuBa+5NKsjhPcilE4esVrdKHn37oVr95AgEIF4vTljo9Ifjk8VJpE+UCtmVe
         Z760ULr8N0OvpqaFxgGi1AxTg+CfX+3dcMVj2MBR+w+kFGKZm5Q5hK6KAxO2CmVZszSo
         ecC4F770g/IlRprJj1gn0IBugNUiaZrIMfOJlbwOlZoz+IjeZSgHYd/prfNwMBWrGEMj
         O09g==
X-Gm-Message-State: APjAAAVzWoxiLEQKrpZLfuCQ32YpodOFQsw1xGBrjkk8YA4n2YIWEeMa
	9Y8Vj/wPLb2b67YmmmhX1lycQv+5w2hIpJG34YJr4P4+aqH6CThfe9m79GCMnpzo83EZJhJ0COx
	2xDuvlXwZtB6XNmpD0xEFOxv3E56zU5cyglHAzOqgQQxDVgxpfcaA3Q0qs9rsjmM4rw==
X-Received: by 2002:a6b:e418:: with SMTP id u24mr1149492iog.128.1554313021981;
        Wed, 03 Apr 2019 10:37:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqysZdWXn47WxCEOSz/Or8sypnIgq07gKUhpAZwnYtDQM83mFuhMgenv6+FcpzhGZ0AtcP/B
X-Received: by 2002:a6b:e418:: with SMTP id u24mr1149419iog.128.1554313021060;
        Wed, 03 Apr 2019 10:37:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554313021; cv=none;
        d=google.com; s=arc-20160816;
        b=Ec3K4PM5mQmYHvjLUQNKl3Enzai3yrHXEaZT/H03c+U+22w+nDNq2B//03PI1QLLle
         J7YKwD6/nt4I7UlSJC7Vk6AZNCS3mpojDMiiPENhMqLqd3CfsHOgiYcVLh5ABkmTnrEQ
         ayWVO9aiXoj1pPOgX/7xau/+b1fGzjx2KIV5EAtL4JaTugYPEx1OgVjrpzJ5vO4kmP/C
         7FE4WGyi8YPjXbrpTKlHADjY2Le034oS6oLFIYEK4YX7bJSjyClPufmrGMwI5PDDbx6R
         xdxFLLEwDoxGpFKLgXAguZjSaEe3FgruxH3a7uxbN2d3HnhXVF3xTvi33mYxQWtdsKUE
         LXMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:references:in-reply-to:message-id:date
         :subject:cc:to:from:dkim-signature;
        bh=MmLdvd3g+VOR33kiTfxTpT9StVgXRV1EaevyJ8pqRKM=;
        b=rVvlr5Is7HC8bNekCpq8ReLadi3xPqWEvT5nrO26b6OJkJPfXylUUFKvdLmzyUIKbX
         6DnL8s4eD0kjIkQONaIKzSbFsJax9gkFiUfeepb1BVVR6KaAv2emgp7vT+5eHQduSMM0
         xMvJe9eXh+y5Sl+OYNpG3x7t8Ymv/5cDHa6h638ip59Qmf9fitDXM9n7ZS5gP9lPDZLX
         nOX8nQgE0CJ2HaSZS7TusJnS6T7/tUPPA9CvjmD1jcdP9xuxFIgYxLXqduZjPG6W0zKR
         uBTp4Urz+DE53CbAQmWwaBJYpPGxH06VYVKcvaYnmyyTZNG1VCt4rVS/Kdr8MqXPlo1r
         +CtA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=A1IlnQsb;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id y4si9365927jan.121.2019.04.03.10.37.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 10:37:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=A1IlnQsb;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x33HNd4U171655;
	Wed, 3 Apr 2019 17:35:54 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : in-reply-to :
 references; s=corp-2018-07-02;
 bh=MmLdvd3g+VOR33kiTfxTpT9StVgXRV1EaevyJ8pqRKM=;
 b=A1IlnQsbVmk3r7/UQc6MdFG/cRK9jKFVE4Bgxh4JAosAGn0Rq0w+/bzoMtqIp222k2xa
 07XSD9hIlM0Pmg9rsVAJJq/JE0OWmaeYHCdw3XNVIFx2cceW+kZ8IikrRB1SHKW2yCAd
 RW7TTYytsps+JD6RjMLkebFQ2smqWV6WN4g49EkBz096AjpZj2YvRX6bSKF1UwNS5zF7
 Q3MZJo5yW3pIoe7JJGihO4P67rz/XassZge0JfcPNF+SQLCIunOcUZ2pVOrdZ0uDG5cH
 8QarNSLrk8AHBL2zD3np5bgQ18hftrVKMCzSWbdsPgVwCZnWSs3kVGoRG9L1KDDtlPim Jg== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by aserp2130.oracle.com with ESMTP id 2rhwydapeu-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 03 Apr 2019 17:35:54 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x33HZLl2152602;
	Wed, 3 Apr 2019 17:35:54 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserp3020.oracle.com with ESMTP id 2rm9mj6gta-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 03 Apr 2019 17:35:54 +0000
Received: from abhmp0005.oracle.com (abhmp0005.oracle.com [141.146.116.11])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x33HZnSR001401;
	Wed, 3 Apr 2019 17:35:49 GMT
Received: from concerto.internal (/10.65.181.37)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 03 Apr 2019 10:35:48 -0700
From: Khalid Aziz <khalid.aziz@oracle.com>
To: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de, ak@linux.intel.com,
        liran.alon@oracle.com, keescook@google.com, konrad.wilk@oracle.com
Cc: Juerg Haefliger <juerg.haefliger@canonical.com>,
        deepa.srinivasan@oracle.com, chris.hyser@oracle.com,
        tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com,
        jcm@redhat.com, boris.ostrovsky@oracle.com, kanth.ghatraju@oracle.com,
        joao.m.martins@oracle.com, jmattson@google.com,
        pradeep.vincent@oracle.com, john.haxby@oracle.com, tglx@linutronix.de,
        kirill.shutemov@linux.intel.com, hch@lst.de, steven.sistare@oracle.com,
        labbott@redhat.com, luto@kernel.org, dave.hansen@intel.com,
        peterz@infradead.org, aaron.lu@intel.com, akpm@linux-foundation.org,
        alexander.h.duyck@linux.intel.com, amir73il@gmail.com,
        andreyknvl@google.com, aneesh.kumar@linux.ibm.com,
        anthony.yznaga@oracle.com, ard.biesheuvel@linaro.org, arnd@arndb.de,
        arunks@codeaurora.org, ben@decadent.org.uk, bigeasy@linutronix.de,
        bp@alien8.de, brgl@bgdev.pl, catalin.marinas@arm.com, corbet@lwn.net,
        cpandya@codeaurora.org, daniel.vetter@ffwll.ch,
        dan.j.williams@intel.com, gregkh@linuxfoundation.org, guro@fb.com,
        hannes@cmpxchg.org, hpa@zytor.com, iamjoonsoo.kim@lge.com,
        james.morse@arm.com, jannh@google.com, jgross@suse.com,
        jkosina@suse.cz, jmorris@namei.org, joe@perches.com,
        jrdr.linux@gmail.com, jroedel@suse.de, keith.busch@intel.com,
        khalid.aziz@oracle.com, khlebnikov@yandex-team.ru, logang@deltatee.com,
        marco.antonio.780@gmail.com, mark.rutland@arm.com,
        mgorman@techsingularity.net, mhocko@suse.com, mhocko@suse.cz,
        mike.kravetz@oracle.com, mingo@redhat.com, mst@redhat.com,
        m.szyprowski@samsung.com, npiggin@gmail.com, osalvador@suse.de,
        paulmck@linux.vnet.ibm.com, pavel.tatashin@microsoft.com,
        rdunlap@infradead.org, richard.weiyang@gmail.com, riel@surriel.com,
        rientjes@google.com, robin.murphy@arm.com, rostedt@goodmis.org,
        rppt@linux.vnet.ibm.com, sai.praneeth.prakhya@intel.com,
        serge@hallyn.com, steve.capper@arm.com, thymovanbeers@gmail.com,
        vbabka@suse.cz, will.deacon@arm.com, willy@infradead.org,
        yang.shi@linux.alibaba.com, yaojun8558363@gmail.com,
        ying.huang@intel.com, zhangshaokun@hisilicon.com,
        iommu@lists.linux-foundation.org, x86@kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        linux-security-module@vger.kernel.org,
        Khalid Aziz <khalid@gonehiking.org>
Subject: [RFC PATCH v9 07/13] arm64/mm: Add support for XPFO
Date: Wed,  3 Apr 2019 11:34:08 -0600
Message-Id: <50011e8d1ae252c6b70806f8d6a2d6dd79cb1a8c.1554248002.git.khalid.aziz@oracle.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <cover.1554248001.git.khalid.aziz@oracle.com>
References: <cover.1554248001.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1554248001.git.khalid.aziz@oracle.com>
References: <cover.1554248001.git.khalid.aziz@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9216 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904030118
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9216 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904030118
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Juerg Haefliger <juerg.haefliger@canonical.com>

Enable support for eXclusive Page Frame Ownership (XPFO) for arm64 and
provide a hook for updating a single kernel page table entry (which is
required by the generic XPFO code).

XPFO doesn't support section/contiguous mappings yet, so let's disable
it if XPFO is turned on.

Thanks to Laura Abbot for the simplification from v5, and Mark Rutland
for pointing out we need NO_CONT_MAPPINGS too.

CC: linux-arm-kernel@lists.infradead.org
Signed-off-by: Juerg Haefliger <juerg.haefliger@canonical.com>
Signed-off-by: Tycho Andersen <tycho@tycho.ws>
Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
Cc: Khalid Aziz <khalid@gonehiking.org>
---
 .../admin-guide/kernel-parameters.txt         |  2 +-
 arch/arm64/Kconfig                            |  1 +
 arch/arm64/mm/Makefile                        |  2 +
 arch/arm64/mm/mmu.c                           |  2 +-
 arch/arm64/mm/xpfo.c                          | 66 +++++++++++++++++++
 5 files changed, 71 insertions(+), 2 deletions(-)
 create mode 100644 arch/arm64/mm/xpfo.c

diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
index e65e3bc1efe0..9fcf8c83031a 100644
--- a/Documentation/admin-guide/kernel-parameters.txt
+++ b/Documentation/admin-guide/kernel-parameters.txt
@@ -2997,7 +2997,7 @@
 
 	nox2apic	[X86-64,APIC] Do not enable x2APIC mode.
 
-	noxpfo		[XPFO,X86-64] Disable eXclusive Page Frame
+	noxpfo		[XPFO,X86-64,ARM64] Disable eXclusive Page Frame
 			Ownership (XPFO) when CONFIG_XPFO is on. Physical
 			pages mapped into user applications will also be
 			mapped in the kernel's address space as if
diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index a4168d366127..9a8d8e649cf8 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -174,6 +174,7 @@ config ARM64
 	select SWIOTLB
 	select SYSCTL_EXCEPTION_TRACE
 	select THREAD_INFO_IN_TASK
+	select ARCH_SUPPORTS_XPFO
 	help
 	  ARM 64-bit (AArch64) Linux support.
 
diff --git a/arch/arm64/mm/Makefile b/arch/arm64/mm/Makefile
index 849c1df3d214..cca3808d9776 100644
--- a/arch/arm64/mm/Makefile
+++ b/arch/arm64/mm/Makefile
@@ -12,3 +12,5 @@ KASAN_SANITIZE_physaddr.o	+= n
 
 obj-$(CONFIG_KASAN)		+= kasan_init.o
 KASAN_SANITIZE_kasan_init.o	:= n
+
+obj-$(CONFIG_XPFO)		+= xpfo.o
diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index b6f5aa52ac67..1673f7443d62 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -453,7 +453,7 @@ static void __init map_mem(pgd_t *pgdp)
 	struct memblock_region *reg;
 	int flags = 0;
 
-	if (rodata_full || debug_pagealloc_enabled())
+	if (rodata_full || debug_pagealloc_enabled() || xpfo_enabled())
 		flags = NO_BLOCK_MAPPINGS | NO_CONT_MAPPINGS;
 
 	/*
diff --git a/arch/arm64/mm/xpfo.c b/arch/arm64/mm/xpfo.c
new file mode 100644
index 000000000000..7866c5acfffb
--- /dev/null
+++ b/arch/arm64/mm/xpfo.c
@@ -0,0 +1,66 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * Copyright (C) 2017 Hewlett Packard Enterprise Development, L.P.
+ * Copyright (C) 2016 Brown University. All rights reserved.
+ *
+ * Authors:
+ *   Juerg Haefliger <juerg.haefliger@hpe.com>
+ *   Vasileios P. Kemerlis <vpk@cs.brown.edu>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published by
+ * the Free Software Foundation.
+ */
+
+#include <linux/mm.h>
+#include <linux/module.h>
+
+#include <asm/tlbflush.h>
+
+/*
+ * Lookup the page table entry for a virtual address and return a pointer to
+ * the entry. Based on x86 tree.
+ */
+static pte_t *lookup_address(unsigned long addr)
+{
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+
+	pgd = pgd_offset_k(addr);
+	if (pgd_none(*pgd))
+		return NULL;
+
+	pud = pud_offset(pgd, addr);
+	if (pud_none(*pud))
+		return NULL;
+
+	pmd = pmd_offset(pud, addr);
+	if (pmd_none(*pmd))
+		return NULL;
+
+	return pte_offset_kernel(pmd, addr);
+}
+
+/* Update a single kernel page table entry */
+inline void set_kpte(void *kaddr, struct page *page, pgprot_t prot)
+{
+	pte_t *pte = lookup_address((unsigned long)kaddr);
+
+	if (unlikely(!pte)) {
+		WARN(1, "xpfo: invalid address %p\n", kaddr);
+		return;
+	}
+
+	set_pte(pte, pfn_pte(page_to_pfn(page), prot));
+}
+EXPORT_SYMBOL_GPL(set_kpte);
+
+inline void xpfo_flush_kernel_tlb(struct page *page, int order)
+{
+	unsigned long kaddr = (unsigned long)page_address(page);
+	unsigned long size = PAGE_SIZE;
+
+	flush_tlb_kernel_range(kaddr, kaddr + (1 << order) * size);
+}
+EXPORT_SYMBOL_GPL(xpfo_flush_kernel_tlb);
-- 
2.17.1

