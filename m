Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72DF8C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 00:03:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 21103222CC
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 00:03:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="VjSTr/Aq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 21103222CC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0A9008E000C; Wed, 13 Feb 2019 19:02:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 05D488E0005; Wed, 13 Feb 2019 19:02:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E8B2E8E000C; Wed, 13 Feb 2019 19:02:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9C1458E0005
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 19:02:58 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id d3so2853978pgv.23
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 16:02:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:in-reply-to:references;
        bh=iAUhMQrV5BcM9lvrtcT+KJw+jAn1o1A4vhSmYo6KfrI=;
        b=b6alK2/z+0CFtLq5myWxZGQPSl5JWSBB7fzSkU5aO+sjCRW33DjEP/fQCZROdCTNZr
         pqgv+mxEhf1EiXDuUTCDE/9xBLHbDLk1h0+gkTMClKMbjNdY49HjD2jDpQvjhboDGmoC
         PscJocaJS9MYz+AsoDkIHjg7U9akjVAzYq9HJ1DmGwI0rRaHheeRoO4bVD3qdmqoadKx
         crhfu6PluatTGl44DUerX4F3BJ/ppSPbUTmoWuCE3VZvrSQA5ST5Ysb7EAhP697Xxsv2
         zC3dzFhzDPQQ8GaPUyw1UdYKLgkXvqi3aPvrtHmQSusQ2lk6yKkhtOwE0F+bimtbYvHM
         srRw==
X-Gm-Message-State: AHQUAuYEgYbWLHK7CMo0Dfpu4xbXq4wCzgCtCbNC7zaQwq3S4OyvWsOd
	RoxLoaW6GB0P+qTh5negfvF/ipQ93WFB7bItXbUIrZ2MpTMfn0RBxzCMKi2ws8xZGrEXiBZVRT6
	cJ9EByKKB23jeS7q035bNZFZSmguNDhJoYHcvPf2RMje+SqEfyJUGkQQcrc9Psp3Yrw==
X-Received: by 2002:a17:902:28c1:: with SMTP id f59mr918824plb.37.1550102578275;
        Wed, 13 Feb 2019 16:02:58 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYVCohG/AKnTpehFrSpF5OZNDBmVXXiu82b41xr9olfcOzQgSumzSAfPFj80EwT/Pmz1Zbr
X-Received: by 2002:a17:902:28c1:: with SMTP id f59mr918739plb.37.1550102577347;
        Wed, 13 Feb 2019 16:02:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550102577; cv=none;
        d=google.com; s=arc-20160816;
        b=IrsZSwSqkY7uj5B+/wwhseskymOgz7FdrOy4FLXRibg4ijnP3KqDPFemG/lDbGInqv
         6ROzyBc0dmzb6xVnkTDsbKLVScH2qvd83KYWc4QoaMuY59jK16Q1avqbstOnDYxSRHpL
         MmYO7K8B7IWqwGp/viaF19DmvuNW71tT38V/CNJSQNtmS4K3nwduwOCGvB0QCfNARpBK
         Zace/TBrQC0DsWzZ+0LvroBLB+ZUfgnyQZ1SYleJllxyXvUoxVDgdy44knymUYpQr0gc
         Pkef5Rl95dW+gauR3XFZMdia4573DupapsoRJqWKBTgPgdON7Vlp/vgQFpH+dx0y2qw2
         OocQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:references:in-reply-to:message-id:date
         :subject:cc:to:from:dkim-signature;
        bh=iAUhMQrV5BcM9lvrtcT+KJw+jAn1o1A4vhSmYo6KfrI=;
        b=a/dxRy5YLsOO5L5/dl/VrhvbAwxW+JQ+8Y9BwGxLmlUrU8FtGtDk2OUsxOVM3MEHNI
         Mfw7dNXqmCqtzckCuFTSIORYEn6LImbgd/diinI0WUgoAOt/qcxnM+9KDjF9Y4pqdwU4
         ueLU3/UG4BBaVk3uhJ6dcUFVdy4nsHAQHlLmGdHXkhcZq0C5fVWGxd9Q/iQXdeCvjbQN
         Cj0s1hYQgqRJbHYMVkDcmoNoDJuTSoYbhOkwRCJcnF1Em9eEObmPfzZxzjSWxTEUzFoh
         qfFE+CdU12CS5nb56v1PcOkNWCfh5Y9j4yCbYEYs7yhg9YL/aLbsYu4wCtWqXZ+tengT
         m+Lg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="VjSTr/Aq";
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id y71si761140pfd.96.2019.02.13.16.02.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 16:02:57 -0800 (PST)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="VjSTr/Aq";
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1DNwvnk099503;
	Thu, 14 Feb 2019 00:02:10 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : in-reply-to :
 references; s=corp-2018-07-02;
 bh=iAUhMQrV5BcM9lvrtcT+KJw+jAn1o1A4vhSmYo6KfrI=;
 b=VjSTr/AqEcZZcnT253Enimw080YefgzZ6lczl9mWxonAMufYwkCcF3dwQch6ueHmg70i
 dJpR3VkpqqCo5MrMJg08cXPCQwRMg0ItEUkV50un7KCD9qy/0d+vUhhjmxELv5vDsXg3
 Ec8x2cdR9pfsnnCSj5tyMVOUNuafN0UEGEnMrvyKFP6U+tH7zegPGoK2cHWcMcllXHpR
 1PT/VRty4pVVnHKlT/GtTFe+lLr6OSdMuZAJLbsu2cPVgpX0UlpaWQ5YfTTR1EgTiKBX
 JspamAuYU1IEU+REu+zfOfbB5ugsNlyZSl+JykVJwE4cXEWuAqhvosNaLi5M380H3gN0 KA== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2120.oracle.com with ESMTP id 2qhree55mx-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 14 Feb 2019 00:02:10 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x1E029GD008227
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 14 Feb 2019 00:02:09 GMT
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x1E027gu001545;
	Thu, 14 Feb 2019 00:02:07 GMT
Received: from concerto.internal (/24.9.64.241)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 13 Feb 2019 16:02:06 -0800
From: Khalid Aziz <khalid.aziz@oracle.com>
To: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de, ak@linux.intel.com,
        torvalds@linux-foundation.org, liran.alon@oracle.com,
        keescook@google.com, akpm@linux-foundation.org, mhocko@suse.com,
        catalin.marinas@arm.com, will.deacon@arm.com, jmorris@namei.org,
        konrad.wilk@oracle.com
Cc: Juerg Haefliger <juerg.haefliger@canonical.com>,
        deepa.srinivasan@oracle.com, chris.hyser@oracle.com,
        tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com,
        jcm@redhat.com, boris.ostrovsky@oracle.com, kanth.ghatraju@oracle.com,
        oao.m.martins@oracle.com, jmattson@google.com,
        pradeep.vincent@oracle.com, john.haxby@oracle.com, tglx@linutronix.de,
        kirill.shutemov@linux.intel.com, hch@lst.de, steven.sistare@oracle.com,
        labbott@redhat.com, luto@kernel.org, dave.hansen@intel.com,
        peterz@infradead.org, kernel-hardening@lists.openwall.com,
        linux-mm@kvack.org, x86@kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        Tycho Andersen <tycho@docker.com>,
        Khalid Aziz <khalid.aziz@oracle.com>
Subject: [RFC PATCH v8 05/14] arm64/mm: Add support for XPFO
Date: Wed, 13 Feb 2019 17:01:28 -0700
Message-Id: <4a7b373b438d5b93999349c648189bd5ba8f9198.1550088114.git.khalid.aziz@oracle.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <cover.1550088114.git.khalid.aziz@oracle.com>
References: <cover.1550088114.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1550088114.git.khalid.aziz@oracle.com>
References: <cover.1550088114.git.khalid.aziz@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9166 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902130157
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Juerg Haefliger <juerg.haefliger@canonical.com>

Enable support for eXclusive Page Frame Ownership (XPFO) for arm64 and
provide a hook for updating a single kernel page table entry (which is
required by the generic XPFO code).

CC: linux-arm-kernel@lists.infradead.org
Signed-off-by: Juerg Haefliger <juerg.haefliger@canonical.com>
Signed-off-by: Tycho Andersen <tycho@docker.com>
Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
---
v6:
	- use flush_tlb_kernel_range() instead of __flush_tlb_one()

v8:
	- Add check for NULL pte in set_kpte()

 arch/arm64/Kconfig     |  1 +
 arch/arm64/mm/Makefile |  2 ++
 arch/arm64/mm/xpfo.c   | 64 ++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 67 insertions(+)
 create mode 100644 arch/arm64/mm/xpfo.c

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index ea2ab0330e3a..f0a9c0007d23 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -171,6 +171,7 @@ config ARM64
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
diff --git a/arch/arm64/mm/xpfo.c b/arch/arm64/mm/xpfo.c
new file mode 100644
index 000000000000..1f790f7746ad
--- /dev/null
+++ b/arch/arm64/mm/xpfo.c
@@ -0,0 +1,64 @@
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
+
+inline void xpfo_flush_kernel_tlb(struct page *page, int order)
+{
+	unsigned long kaddr = (unsigned long)page_address(page);
+	unsigned long size = PAGE_SIZE;
+
+	flush_tlb_kernel_range(kaddr, kaddr + (1 << order) * size);
+}
-- 
2.17.1

