Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 20733C74A35
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:26:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D223621019
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:26:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="lJAKdulh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D223621019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2CEB38E00CA; Thu, 11 Jul 2019 10:26:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E2058E00C4; Thu, 11 Jul 2019 10:26:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EDBBA8E00CA; Thu, 11 Jul 2019 10:26:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id B225D8E00C4
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 10:26:25 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id e20so6913645ioe.12
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 07:26:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=lCtyGi9lNXZNoOqW5lwUfawQTHm8Gs8rgqwuOoYVSXg=;
        b=ZhuRrSFlanx/heka0lEcveK+B3L5m+c3gQVsScc27RX/gScwbqwZXS2WvFbWz5en45
         6xbMFWRG4lyVkFOdXg0PMOxG52RAEqRrKR5bW8pSIju2Jwbw3xwRmD2udLhuo/v2s3th
         FsGoeApCBk10UR+FA6RY1CjBmx8hZT6PdiwaQP0ce6hCf8yH9QPiEIAlMXr76VQA/bwj
         EWzi5f6rKebQEA0KP4wbXucJtcOJKeoP7IZlKHg24GUUJn0vl8wItJ8BnSW7y5q1gBH6
         18BlWSX4wh1DIXzN4cLfh91GpbQuBbLBFl65hSr+2vYjjsQSMsP//MbWSuA02VIYMOWb
         N2ZA==
X-Gm-Message-State: APjAAAX/bDzOi2mcMD/zCLbmKEl83AkZoH/h63nLzoF0yn16kSQISkkH
	7oSaKE4dUuyPOrkhclGGP0fDsQ+pkljGgu9OQ1pPZKoqNB30Z7gj8CTBTHKbOwByvK4LTJeyQSJ
	OW2lMH4tlckecXiwHLhVQAl2Jc3PLpTRVywTvtfMTHyD5iD11X5mrT3EDrszOA+AuXA==
X-Received: by 2002:a5d:9618:: with SMTP id w24mr4565730iol.279.1562855185484;
        Thu, 11 Jul 2019 07:26:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyyrzmkEJJRjnLreD8mMgEz+wk/BP34MmMCpog6yLC1ygb8MV8E6qEBUktSVhyCDrWLzQuf
X-Received: by 2002:a5d:9618:: with SMTP id w24mr4565676iol.279.1562855184865;
        Thu, 11 Jul 2019 07:26:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562855184; cv=none;
        d=google.com; s=arc-20160816;
        b=u198FC2sNGT/6W/KHmf4UT1U/vqj4nqHJMvl8Ou5/CWennR66ex8PLjMgGlbhPJcuO
         Z29qAZVt0fyzYRe1ZT4/FGWRuQlXgFtIOex08qSmozot4A7Zyn7uYiVKb+WYqWfMvLEs
         NgED/YNNG4CkrTaKvExpd1mhF0zGlcD6MkfhxXPOOJyjgSv3LWe4AxFvC9nJyn8vkjLI
         ght6gcsfdw+99cA5yc061t2CQr/ttDjNAB55STsetVfHvwvmAIZMENo3gm7Vh/bxzfjk
         M/L1akGwJvndcyDFqA6fY3tzVHLjC+dfTxlXr7MPxjNR1IngE66vGu8ll5AmCAwgQCQ0
         cDyg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=lCtyGi9lNXZNoOqW5lwUfawQTHm8Gs8rgqwuOoYVSXg=;
        b=jI+zO5RVEvtiZJNtWjMQLs8gRNthu754PsPgfLmY7XjhpMH8mTr6Ex1CybejkOS4oS
         sCmK/fo98gwXsxjuGtVqttl8oY1p50RGNMxUMGl7qFCeh6SinOHvyS5AwBoI8RgDZVpu
         pLeZitAO/ngEjw3AOIIhKuaZKPJIfP2ExAYNxQf5LR95yIjkAXQ57xUrLsLNusWcLt0V
         UvqW69+8ZxNA9r3UBj1qk4nDqnRkpnwocQ578mjND7ZEiWYyqLZgitfKFEefFsQLg8OI
         l3tOh6t1bwPZtex0lfB/9Gkt6H5sIjj3tbVv96kLV0O5FsBgOlsv78gG5l32JN/FYrUi
         1yfg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=lJAKdulh;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id h6si9010051jaa.71.2019.07.11.07.26.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 07:26:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=lJAKdulh;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6BEO7Xi100417;
	Thu, 11 Jul 2019 14:26:11 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=lCtyGi9lNXZNoOqW5lwUfawQTHm8Gs8rgqwuOoYVSXg=;
 b=lJAKdulhKeHbnYjRsyD5nMQD+gRQsuPOeXQdtSSCbufwUKXgsEfUN2Rz5GYHTyi0V/o7
 /7wfZKsgL4wiSMWTnhXm2xWq6UxcJMo9Wcw35HV4xUxxM34clQuAg7xvJmhbR4yOZmCW
 HtxhTH15oHUeFU7K6yML/HzF46ooAQ0oDiETifZF8/K0Eb+1V8sYTyAXh2PY56Cglqe0
 4to8Zt1JMHQxjc6IQGJB++dychz0/PvHCxVVbx1+c6+qGz1P2iNzE3+TWmWcb+jtnmaE
 8hDeydy1NGeaojoYQskyTsqpWzZDVRocAyhp4SKVywbNL71DbkjE7rT5ZK2hAsuvr/wq nA== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by aserp2120.oracle.com with ESMTP id 2tjkkq0c74-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 11 Jul 2019 14:26:11 +0000
Received: from achartre-desktop.fr.oracle.com (dhcp-10-166-106-34.fr.oracle.com [10.166.106.34])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x6BEPctx021444;
	Thu, 11 Jul 2019 14:26:02 GMT
From: Alexandre Chartre <alexandre.chartre@oracle.com>
To: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
        mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
        dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org,
        kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: konrad.wilk@oracle.com, jan.setjeeilers@oracle.com, liran.alon@oracle.com,
        jwadams@google.com, graf@amazon.de, rppt@linux.vnet.ibm.com,
        alexandre.chartre@oracle.com
Subject: [RFC v2 06/26] mm/asi: Add ASI page-table entry allocation functions
Date: Thu, 11 Jul 2019 16:25:18 +0200
Message-Id: <1562855138-19507-7-git-send-email-alexandre.chartre@oracle.com>
X-Mailer: git-send-email 1.7.1
In-Reply-To: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
References: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9314 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1907110162
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add functions to allocate p4d/pud/pmd/pte pages for an ASI page-table
and keep track of them.

Signed-off-by: Alexandre Chartre <alexandre.chartre@oracle.com>
---
 arch/x86/mm/asi_pagetable.c |  111 +++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 111 insertions(+), 0 deletions(-)

diff --git a/arch/x86/mm/asi_pagetable.c b/arch/x86/mm/asi_pagetable.c
index a89e02e..0fc6d59 100644
--- a/arch/x86/mm/asi_pagetable.c
+++ b/arch/x86/mm/asi_pagetable.c
@@ -4,6 +4,8 @@
  *
  */
 
+#include <linux/mm.h>
+
 #include <asm/asi.h>
 
 /*
@@ -159,3 +161,112 @@ static bool asi_valid_offset(struct asi *asi, void *offset)
 
 	return p4d;
 }
+
+/*
+ * asi_pXX_alloc() functions are equivalent to kernel pXX_alloc() functions
+ * but, in addition, they keep track of new pages allocated for the specified
+ * ASI.
+ */
+
+static pte_t *asi_pte_alloc(struct asi *asi, pmd_t *pmd, unsigned long addr)
+{
+	struct page *page;
+	pte_t *pte;
+	int err;
+
+	if (pmd_none(*pmd)) {
+		page = alloc_page(GFP_KERNEL | __GFP_ZERO);
+		if (!page)
+			return ERR_PTR(-ENOMEM);
+		pte = (pte_t *)page_address(page);
+		err = asi_add_backend_page(asi, pte, PGT_LEVEL_PTE);
+		if (err) {
+			free_page((unsigned long)pte);
+			return ERR_PTR(err);
+		}
+		set_pmd_safe(pmd, __pmd(__pa(pte) | _KERNPG_TABLE));
+		pte = pte_offset_map(pmd, addr);
+	} else {
+		pte = asi_pte_offset(asi, pmd,  addr);
+	}
+
+	return pte;
+}
+
+static pmd_t *asi_pmd_alloc(struct asi *asi, pud_t *pud, unsigned long addr)
+{
+	struct page *page;
+	pmd_t *pmd;
+	int err;
+
+	if (pud_none(*pud)) {
+		page = alloc_page(GFP_KERNEL | __GFP_ZERO);
+		if (!page)
+			return ERR_PTR(-ENOMEM);
+		pmd = (pmd_t *)page_address(page);
+		err = asi_add_backend_page(asi, pmd, PGT_LEVEL_PMD);
+		if (err) {
+			free_page((unsigned long)pmd);
+			return ERR_PTR(err);
+		}
+		set_pud_safe(pud, __pud(__pa(pmd) | _KERNPG_TABLE));
+		pmd = pmd_offset(pud, addr);
+	} else {
+		pmd = asi_pmd_offset(asi, pud, addr);
+	}
+
+	return pmd;
+}
+
+static pud_t *asi_pud_alloc(struct asi *asi, p4d_t *p4d, unsigned long addr)
+{
+	struct page *page;
+	pud_t *pud;
+	int err;
+
+	if (p4d_none(*p4d)) {
+		page = alloc_page(GFP_KERNEL | __GFP_ZERO);
+		if (!page)
+			return ERR_PTR(-ENOMEM);
+		pud = (pud_t *)page_address(page);
+		err = asi_add_backend_page(asi, pud, PGT_LEVEL_PUD);
+		if (err) {
+			free_page((unsigned long)pud);
+			return ERR_PTR(err);
+		}
+		set_p4d_safe(p4d, __p4d(__pa(pud) | _KERNPG_TABLE));
+		pud = pud_offset(p4d, addr);
+	} else {
+		pud = asi_pud_offset(asi, p4d, addr);
+	}
+
+	return pud;
+}
+
+static p4d_t *asi_p4d_alloc(struct asi *asi, pgd_t *pgd, unsigned long addr)
+{
+	struct page *page;
+	p4d_t *p4d;
+	int err;
+
+	if (!pgtable_l5_enabled())
+		return (p4d_t *)pgd;
+
+	if (pgd_none(*pgd)) {
+		page = alloc_page(GFP_KERNEL | __GFP_ZERO);
+		if (!page)
+			return ERR_PTR(-ENOMEM);
+		p4d = (p4d_t *)page_address(page);
+		err = asi_add_backend_page(asi, p4d, PGT_LEVEL_P4D);
+		if (err) {
+			free_page((unsigned long)p4d);
+			return ERR_PTR(err);
+		}
+		set_pgd_safe(pgd, __pgd(__pa(p4d) | _KERNPG_TABLE));
+		p4d = p4d_offset(pgd, addr);
+	} else {
+		p4d = asi_p4d_offset(asi, pgd, addr);
+	}
+
+	return p4d;
+}
-- 
1.7.1

