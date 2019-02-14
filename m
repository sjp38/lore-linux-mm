Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 73FB9C4360F
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 15:59:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 29EAF218EA
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 15:59:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 29EAF218EA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF4C78E0003; Thu, 14 Feb 2019 10:59:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CA9078E0001; Thu, 14 Feb 2019 10:59:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B1FE78E0003; Thu, 14 Feb 2019 10:59:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 86D368E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 10:59:51 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id r24so6042284qtj.13
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 07:59:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:message-id;
        bh=k9VZwu9YWjzbRtHwba6ia+DxawlSg12+yWxnAGjsdwM=;
        b=odQxmgsf6QOx8bCfAUdy9KFjtVJb3HoQXTlGs2iqrxznCvnWPSVUYM1LkWV8bf8w9x
         cjR61LsHhIwZ4ZHBq+EwqfOeG9U2+NUXrNU1dV9kLmS7C4wgIRUqitBXMDcOBE0rEMKr
         B9JtzuIoLr68c18q4BH+kUNOucQXOOh2ljVAQmCQAFAdjRPzpjTgRShyzA16MEJA31dc
         KqZpfsR0tEkhKZucNS9GZY/lRZuLwit1plFjLzayrK1X/jwFXP53Zfix8TrAl0pTI40s
         oJvmre8sn6S60jMbLl6Eprt20xlcM+C7Khtceh9UP33xnXxZ00RcEg0DsLxuETqaGsaj
         g7CQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAubC0bkwJkgZTaXmxXXKMkRWGo8is0fcYSxmPhUJXVQEARsqKKYT
	F54PoEYb10wqqdIBrmpk2O1/ZAMx/yNl3nrfyPENFtohVpA8+Vz5Sj07r6HOoghYgo8wrOSVya4
	XJBco79t9kZxOMZhlsPVzwkpTh8juJRe3Fv4utHwesDiyMlUinfqg7Q690CIcqS1Awg==
X-Received: by 2002:ac8:101a:: with SMTP id z26mr3663305qti.184.1550159991315;
        Thu, 14 Feb 2019 07:59:51 -0800 (PST)
X-Google-Smtp-Source: AHgI3Iafo9T6GTltnQXwaFoa/TMCDoF/nVPm6m+76SFfP61L/P7gKmiDA71iZz43ycny4z1EbZjj
X-Received: by 2002:ac8:101a:: with SMTP id z26mr3663270qti.184.1550159990538;
        Thu, 14 Feb 2019 07:59:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550159990; cv=none;
        d=google.com; s=arc-20160816;
        b=Xdq9+x6VcBOMoNv3kjEIu+Z2cewy9l5dZzVHG0BG7cSv494WZPgcD8AuUGUJJ53hwU
         TxjWlmf68e5g6DBCufRfMX33NezgWfbAO9mg/Cjbaqd6/jO2jKaeTdetCFx3shg0d7zj
         Uj5vDVJUgKczExsUH5C6b9Ij9XqVHWa8MAsXSrT33N6vaxG7xgyaUYbkwkO/FOgDDkYr
         QFTA1hRr+VhfrdbwchtWjOUP+0ESyc7pG9aKGnE/mPg32o/0DDzSKpecLBa+S/fKyHZD
         qyoYZtNpAbJWv6tt+00mOsoKjJZpob+LlzBISDckgD03183q43vspzyUHfDTCD1XebBQ
         ihYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:date:subject:cc:to:from;
        bh=k9VZwu9YWjzbRtHwba6ia+DxawlSg12+yWxnAGjsdwM=;
        b=NQ11k5tUHyQSELPxYOI+2nAfNsl3LQe8UnFNCBf5VwwqAGcRqgiL+29CwCPeObgXRz
         ldQj5npjV7eIG3ZMUIYBgXImf4ujTW6dRaIwdWPBsuMJyBAGDihpmUPN8eSugrjLzTvo
         rN/p3p9iM2rSgdrG6DUuOI7rKCycfDLBnn/LxmjF5bAcr65qMsmPwPYLaPTLF25gyjL/
         Zz9mK3ZwslmfwvXCRexSw/usQ64V8uEwauKkd2yU4lEqUXoMJxmlcQnIjgBCdM8DEyS9
         GEROXglUKlCmKkSjQBdafSqgnYjcbiOUOSETQbMkEpXP9I94F8/4qN483C+9LKF8EGtF
         wpkg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id b141si345851qka.266.2019.02.14.07.59.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 07:59:50 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1EFhgYt188585
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 10:59:50 -0500
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2qnaq1kqpd-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 10:59:49 -0500
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 14 Feb 2019 15:59:47 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 14 Feb 2019 15:59:44 -0000
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1EFxhpd7602456
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Thu, 14 Feb 2019 15:59:43 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 1C95AAE051;
	Thu, 14 Feb 2019 15:59:43 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 55394AE053;
	Thu, 14 Feb 2019 15:59:41 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Thu, 14 Feb 2019 15:59:41 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Thu, 14 Feb 2019 17:59:40 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>, Palmer Dabbelt <palmer@sifive.com>,
        Richard Kuo <rkuo@codeaurora.org>, linux-arch@vger.kernel.org,
        linux-hexagon@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, linux-riscv@lists.infradead.org,
        Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH 1/4] init: provide a generic free_initmem implementation
Date: Thu, 14 Feb 2019 17:59:34 +0200
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1550159977-8949-1-git-send-email-rppt@linux.ibm.com>
References: <1550159977-8949-1-git-send-email-rppt@linux.ibm.com>
X-TM-AS-GCONF: 00
x-cbid: 19021415-4275-0000-0000-0000030F8541
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19021415-4276-0000-0000-0000381DA1A3
Message-Id: <1550159977-8949-2-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-14_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=723 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902140109
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

For most architectures free_initmem just a wrapper for the same
free_initmem_default(-1) call.
Provide that as a generic implementation marked __weak.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 arch/alpha/mm/init.c      | 6 ------
 arch/arc/mm/init.c        | 8 --------
 arch/c6x/mm/init.c        | 5 -----
 arch/h8300/mm/init.c      | 6 ------
 arch/microblaze/mm/init.c | 5 -----
 arch/nds32/mm/init.c      | 5 -----
 arch/nios2/mm/init.c      | 5 -----
 arch/openrisc/mm/init.c   | 5 -----
 arch/sh/mm/init.c         | 5 -----
 arch/unicore32/mm/init.c  | 5 -----
 arch/xtensa/mm/init.c     | 5 -----
 init/main.c               | 5 +++++
 12 files changed, 5 insertions(+), 60 deletions(-)

diff --git a/arch/alpha/mm/init.c b/arch/alpha/mm/init.c
index a42fc5c..8a8ac09 100644
--- a/arch/alpha/mm/init.c
+++ b/arch/alpha/mm/init.c
@@ -286,12 +286,6 @@ mem_init(void)
 	mem_init_print_info(NULL);
 }
 
-void
-free_initmem(void)
-{
-	free_initmem_default(-1);
-}
-
 #ifdef CONFIG_BLK_DEV_INITRD
 void
 free_initrd_mem(unsigned long start, unsigned long end)
diff --git a/arch/arc/mm/init.c b/arch/arc/mm/init.c
index e1ab2d7..1d08736 100644
--- a/arch/arc/mm/init.c
+++ b/arch/arc/mm/init.c
@@ -207,14 +207,6 @@ void __init mem_init(void)
 	mem_init_print_info(NULL);
 }
 
-/*
- * free_initmem: Free all the __init memory.
- */
-void __ref free_initmem(void)
-{
-	free_initmem_default(-1);
-}
-
 #ifdef CONFIG_BLK_DEV_INITRD
 void __init free_initrd_mem(unsigned long start, unsigned long end)
 {
diff --git a/arch/c6x/mm/init.c b/arch/c6x/mm/init.c
index af5ada0..ca1c182 100644
--- a/arch/c6x/mm/init.c
+++ b/arch/c6x/mm/init.c
@@ -73,8 +73,3 @@ void __init free_initrd_mem(unsigned long start, unsigned long end)
 	free_reserved_area((void *)start, (void *)end, -1, "initrd");
 }
 #endif
-
-void __init free_initmem(void)
-{
-	free_initmem_default(-1);
-}
diff --git a/arch/h8300/mm/init.c b/arch/h8300/mm/init.c
index 6519252..fabf9e3 100644
--- a/arch/h8300/mm/init.c
+++ b/arch/h8300/mm/init.c
@@ -108,9 +108,3 @@ void free_initrd_mem(unsigned long start, unsigned long end)
 	free_reserved_area((void *)start, (void *)end, -1, "initrd");
 }
 #endif
-
-void
-free_initmem(void)
-{
-	free_initmem_default(-1);
-}
diff --git a/arch/microblaze/mm/init.c b/arch/microblaze/mm/init.c
index b17fd8a..4d6fa630 100644
--- a/arch/microblaze/mm/init.c
+++ b/arch/microblaze/mm/init.c
@@ -193,11 +193,6 @@ void free_initrd_mem(unsigned long start, unsigned long end)
 }
 #endif
 
-void free_initmem(void)
-{
-	free_initmem_default(-1);
-}
-
 void __init mem_init(void)
 {
 	high_memory = (void *)__va(memory_start + lowmem_size - 1);
diff --git a/arch/nds32/mm/init.c b/arch/nds32/mm/init.c
index 253f79f..8a1563e 100644
--- a/arch/nds32/mm/init.c
+++ b/arch/nds32/mm/init.c
@@ -244,11 +244,6 @@ void __init mem_init(void)
 	return;
 }
 
-void free_initmem(void)
-{
-	free_initmem_default(-1);
-}
-
 #ifdef CONFIG_BLK_DEV_INITRD
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
diff --git a/arch/nios2/mm/init.c b/arch/nios2/mm/init.c
index 16cea57..362a7a7 100644
--- a/arch/nios2/mm/init.c
+++ b/arch/nios2/mm/init.c
@@ -89,11 +89,6 @@ void __init free_initrd_mem(unsigned long start, unsigned long end)
 }
 #endif
 
-void __ref free_initmem(void)
-{
-	free_initmem_default(-1);
-}
-
 #define __page_aligned(order) __aligned(PAGE_SIZE << (order))
 pgd_t swapper_pg_dir[PTRS_PER_PGD] __page_aligned(PGD_ORDER);
 pte_t invalid_pte_table[PTRS_PER_PTE] __page_aligned(PTE_ORDER);
diff --git a/arch/openrisc/mm/init.c b/arch/openrisc/mm/init.c
index d157310..bf3a160 100644
--- a/arch/openrisc/mm/init.c
+++ b/arch/openrisc/mm/init.c
@@ -227,8 +227,3 @@ void free_initrd_mem(unsigned long start, unsigned long end)
 	free_reserved_area((void *)start, (void *)end, -1, "initrd");
 }
 #endif
-
-void free_initmem(void)
-{
-	free_initmem_default(-1);
-}
diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
index a8e5c0e..bc59332 100644
--- a/arch/sh/mm/init.c
+++ b/arch/sh/mm/init.c
@@ -405,11 +405,6 @@ void __init mem_init(void)
 	mem_init_done = 1;
 }
 
-void free_initmem(void)
-{
-	free_initmem_default(-1);
-}
-
 #ifdef CONFIG_BLK_DEV_INITRD
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
diff --git a/arch/unicore32/mm/init.c b/arch/unicore32/mm/init.c
index 85ef2c6..3aed4d5 100644
--- a/arch/unicore32/mm/init.c
+++ b/arch/unicore32/mm/init.c
@@ -312,11 +312,6 @@ void __init mem_init(void)
 	}
 }
 
-void free_initmem(void)
-{
-	free_initmem_default(-1);
-}
-
 #ifdef CONFIG_BLK_DEV_INITRD
 
 static int keep_initrd;
diff --git a/arch/xtensa/mm/init.c b/arch/xtensa/mm/init.c
index d498610..b51746f 100644
--- a/arch/xtensa/mm/init.c
+++ b/arch/xtensa/mm/init.c
@@ -216,11 +216,6 @@ void free_initrd_mem(unsigned long start, unsigned long end)
 }
 #endif
 
-void free_initmem(void)
-{
-	free_initmem_default(-1);
-}
-
 static void __init parse_memmap_one(char *p)
 {
 	char *oldp;
diff --git a/init/main.c b/init/main.c
index c86a1c8..38d69e0 100644
--- a/init/main.c
+++ b/init/main.c
@@ -1047,6 +1047,11 @@ static inline void mark_readonly(void)
 }
 #endif
 
+void __weak free_initmem(void)
+{
+	free_initmem_default(-1);
+}
+
 static int __ref kernel_init(void *unused)
 {
 	int ret;
-- 
2.7.4

