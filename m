Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C574FC74A54
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:26:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7D6DA21670
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:26:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="j/8IHCr9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7D6DA21670
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0F8BB8E00C8; Thu, 11 Jul 2019 10:26:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 081A38E00C4; Thu, 11 Jul 2019 10:26:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E65F98E00C8; Thu, 11 Jul 2019 10:26:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id C38558E00C4
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 10:26:22 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id c5so6904127iom.18
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 07:26:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=385wpu4NDusZzlrvO4wdMoGEKubdnUYw4N6zqr4muDU=;
        b=cG6fKZ3VeUElWj3A9w1ew9h2UjSs1fvJb/bsxXJohFkjRsSTMPMFihUSxjaiXuxAOi
         s2IX4lN11e5dIRGxJfD/wbROzqC6zAmgJB33PJFZ2AjZmcP993U2suagiVhBB/XQMrPt
         B9KpPlp+6cHMxwCSRc2aTvpK/lJSuPbmm3Y/GjbOFvE4MFJVC5kawKm7cRmDIt+PWeeS
         wYq1dnUek3ROZnyPatXy7PKyClzjsIl7QHjZH8oFFWlFs9nT+HYGRYfpsX3GrgCEFb13
         pzbLFgyhmxYs21IyTzuC070oMR5fkvmh4QulE0wRrrWB639sWE9R2cNDc7AdvCNTyNQi
         UG3Q==
X-Gm-Message-State: APjAAAV0xd74y8Grw1eHW6R3DPUr0MJJWVx4Z0xZF/0MddOOQX4lv2IE
	0MKCYQYTWaZdi6L8Z7E567JZvSOw/EZy4FAnVLfdr/tzw3qS5KnuC84etdeJEnn5rUh3NS9YvdG
	FbOd2JnnIsI9qR0y0cYgkXhNm6VFMdmj4TmDr/1YG6IW2ePaWHu8xjsG7/DbhKA17YQ==
X-Received: by 2002:a5d:9643:: with SMTP id d3mr4775857ios.227.1562855182587;
        Thu, 11 Jul 2019 07:26:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwDexv5X+iHb0htnuAlGjnV0d+rO9gQ5F7JJfMSHftJaVfAK0TACi8VzCKIOmmIyEZxmhav
X-Received: by 2002:a5d:9643:: with SMTP id d3mr4775793ios.227.1562855181934;
        Thu, 11 Jul 2019 07:26:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562855181; cv=none;
        d=google.com; s=arc-20160816;
        b=PWSNgQObdccPDXnzVrLh+8OxP+95T/4f3IungOaXgkWKpEP4LxGbg8FAsxwnczkNuQ
         caezh+s/1DkrTvS6twUWXTmxmT1buTduwWb0RP3+V3zHaortcFT7uUvIBaceCe23ni2p
         R3Hun4T98IwRi0dq5zUnWm1iNUCBMBSxpIAey/AeMx/uLxNdXU+NZ9+68mQuAso4LJWb
         AMwxI+lhPQfKY7DCd6WluczwCFAQeNj5kiUSpAKs4M7AZyC3j412f/mgRjRvsDy7OJsk
         3cS9gkNoQltFBucNG2U4MZnrqo0wN0p8/0ymf+kFBhhMsftqK3F/LRNmyonPO+zSlLDV
         M+fA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=385wpu4NDusZzlrvO4wdMoGEKubdnUYw4N6zqr4muDU=;
        b=AuYLT6A0ztFSCFeBYnMC8wiSnEs/O5l+ESsWx7bsVjYWYZDsDwTGsoQ3t6dtm0hox6
         Z84keEWmpphCFYEsWxnt0uNETljCmILRSSCnqEs5ek80KGWvK02I0BrWSOuslMLDjtdU
         JcsC4mZ9D4ibQ/b2oYDYd1oVLDZ6D3Rh6kvVUUypwvvwEf/eoAYW9FpNEGL8vor5461t
         renr9amnRVP2su6vrfKZH8Do//tMi+LnVUQ5/iLG3UchcSaNyJMJuWl5UVpCEL6AoU7d
         HtsqYId7bFxU3HEcn0f8NoB6bLoZv0dF0nd0T3sO7oHFDytMATkjcKPst7LOuiEP3dYk
         v1KA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="j/8IHCr9";
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id g12si9223876jao.11.2019.07.11.07.26.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 07:26:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="j/8IHCr9";
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6BEO7tr013226;
	Thu, 11 Jul 2019 14:26:10 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=385wpu4NDusZzlrvO4wdMoGEKubdnUYw4N6zqr4muDU=;
 b=j/8IHCr9S0gUaWnFi3Upjzuz55gy9Ljh6nfaWePnOoytFJ9B7SnJKULz74C3ywY6RXqi
 e2nlqVa9W7MNYSdP2Vf2C/oYboYtNcwS8EW9VbU8cIsaN6Fl9HN5Irx/xBWUPbwuO3Rb
 pA8nC/jt3qZSlX5P9mWE6i1BavyZZ35GVGnmvivmjOvqS8a8/Z0v3tfm2TkPowKHagRD
 jG7N8dpzCgLK0VRzFa0NpGxGayMyo+vj0XV5/GWaoX6BlSffhi7TdWAzW0NBMvhvqMgW
 Mi7BkTLlSEZlEqWrGTNR/OK6j6uUWeCyQ/O4mFUX/8vA2YAylUPyhsIeKxT9HDn0UNu4 +A== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp2120.oracle.com with ESMTP id 2tjm9r0bn2-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 11 Jul 2019 14:26:09 +0000
Received: from achartre-desktop.fr.oracle.com (dhcp-10-166-106-34.fr.oracle.com [10.166.106.34])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x6BEPcu0021444;
	Thu, 11 Jul 2019 14:26:06 GMT
From: Alexandre Chartre <alexandre.chartre@oracle.com>
To: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
        mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
        dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org,
        kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: konrad.wilk@oracle.com, jan.setjeeilers@oracle.com, liran.alon@oracle.com,
        jwadams@google.com, graf@amazon.de, rppt@linux.vnet.ibm.com,
        alexandre.chartre@oracle.com
Subject: [RFC v2 07/26] mm/asi: Add ASI page-table entry set functions
Date: Thu, 11 Jul 2019 16:25:19 +0200
Message-Id: <1562855138-19507-8-git-send-email-alexandre.chartre@oracle.com>
X-Mailer: git-send-email 1.7.1
In-Reply-To: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
References: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9314 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1907110162
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add wrappers around the page table entry (pgd/p4d/pud/pmd) set
functions which check that an existing entry is not being
overwritten.

Signed-off-by: Alexandre Chartre <alexandre.chartre@oracle.com>
---
 arch/x86/mm/asi_pagetable.c |  124 +++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 124 insertions(+), 0 deletions(-)

diff --git a/arch/x86/mm/asi_pagetable.c b/arch/x86/mm/asi_pagetable.c
index 0fc6d59..e17af9e 100644
--- a/arch/x86/mm/asi_pagetable.c
+++ b/arch/x86/mm/asi_pagetable.c
@@ -270,3 +270,127 @@ static bool asi_valid_offset(struct asi *asi, void *offset)
 
 	return p4d;
 }
+
+/*
+ * asi_set_pXX() functions are equivalent to kernel set_pXX() functions
+ * but, in addition, they ensure that they are not overwriting an already
+ * existing reference in the page table. Otherwise an error is returned.
+ */
+static int asi_set_pte(struct asi *asi, pte_t *pte, pte_t pte_value)
+{
+#ifdef DEBUG
+	/*
+	 * The pte pointer should come from asi_pte_alloc() or asi_pte_offset()
+	 * both of which check if the pointer is in the kernel isolation page
+	 * table. So this is a paranoid check to ensure the pointer is really
+	 * in the kernel page table.
+	 */
+	if (!asi_valid_offset(asi, pte)) {
+		pr_err("ASI %p: PTE %px not found\n", asi, pte);
+		return -EINVAL;
+	}
+#endif
+	set_pte(pte, pte_value);
+
+	return 0;
+}
+
+static int asi_set_pmd(struct asi *asi, pmd_t *pmd, pmd_t pmd_value)
+{
+#ifdef DEBUG
+	/*
+	 * The pmd pointer should come from asi_pmd_alloc() or asi_pmd_offset()
+	 * both of which check if the pointer is in the kernel isolation page
+	 * table. So this is a paranoid check to ensure the pointer is really
+	 * in the kernel page table.
+	 */
+	if (!asi_valid_offset(asi, pmd)) {
+		pr_err("ASI %p: PMD %px not found\n", asi, pmd);
+		return -EINVAL;
+	}
+#endif
+	if (pmd_val(*pmd) == pmd_val(pmd_value))
+		return 0;
+
+	if (!pmd_none(*pmd)) {
+		pr_err("ASI %p: PMD %px overwriting %lx with %lx\n",
+		       asi, pmd, pmd_val(*pmd), pmd_val(pmd_value));
+		return -EBUSY;
+	}
+
+	set_pmd(pmd, pmd_value);
+
+	return 0;
+}
+
+static int asi_set_pud(struct asi *asi, pud_t *pud, pud_t pud_value)
+{
+#ifdef DEBUG
+	/*
+	 * The pud pointer should come from asi_pud_alloc() or asi_pud_offset()
+	 * both of which check if the pointer is in the kernel isolation page
+	 * table. So this is a paranoid check to ensure the pointer is really
+	 * in the kernel page table.
+	 */
+	if (!asi_valid_offset(asi, pud)) {
+		pr_err("ASI %p: PUD %px not found\n", asi, pud);
+		return -EINVAL;
+	}
+#endif
+	if (pud_val(*pud) == pud_val(pud_value))
+		return 0;
+
+	if (!pud_none(*pud)) {
+		pr_err("ASI %p: PUD %px overwriting %lx with %lx\n",
+		       asi, pud, pud_val(*pud), pud_val(pud_value));
+		return -EBUSY;
+	}
+
+	set_pud(pud, pud_value);
+
+	return 0;
+}
+
+static int asi_set_p4d(struct asi *asi, p4d_t *p4d, p4d_t p4d_value)
+{
+#ifdef DEBUG
+	/*
+	 * The p4d pointer should come from asi_p4d_alloc() or asi_p4d_offset()
+	 * both of which check if the pointer is in the kernel isolation page
+	 * table. So this is a paranoid check to ensure the pointer is really
+	 * in the kernel page table.
+	 */
+	if (!asi_valid_offset(asi, p4d)) {
+		pr_err("ASI %p: P4D %px not found\n", asi, p4d);
+		return -EINVAL;
+	}
+#endif
+	if (p4d_val(*p4d) == p4d_val(p4d_value))
+		return 0;
+
+	if (!p4d_none(*p4d)) {
+		pr_err("ASI %p: P4D %px overwriting %lx with %lx\n",
+		       asi, p4d, p4d_val(*p4d), p4d_val(p4d_value));
+		return -EBUSY;
+	}
+
+	set_p4d(p4d, p4d_value);
+
+	return 0;
+}
+
+static int asi_set_pgd(struct asi *asi, pgd_t *pgd, pgd_t pgd_value)
+{
+	if (pgd_val(*pgd) == pgd_val(pgd_value))
+		return 0;
+
+	if (!pgd_none(*pgd)) {
+		pr_err("ASI %p: PGD %px overwriting %lx with %lx\n",
+		       asi, pgd, pgd_val(*pgd), pgd_val(pgd_value));
+		return -EBUSY;
+	}
+
+	set_pgd(pgd, pgd_value);
+
+	return 0;
+}
-- 
1.7.1

