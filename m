Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C589C74A54
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:26:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A86C321019
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:26:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="SmfOq+K7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A86C321019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 47C018E00CB; Thu, 11 Jul 2019 10:26:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3684D8E00C4; Thu, 11 Jul 2019 10:26:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 20A358E00CB; Thu, 11 Jul 2019 10:26:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id E20F58E00C4
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 10:26:26 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id s9so6956145iob.11
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 07:26:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=y9IAz60J7qXRlFN2NRsHUzd+qvZ9ZunbWoLTMdcwAx8=;
        b=IxjZRzbuP+atDgfo9Ib/4AaGyDPHVGi79gIIzCLEfmxlI3MXfG/q5kau4K33gNWG6G
         jXxrXdAjT51dtUWe3/B4H5V5O42txlMZacIlwgYIbkhrNe4zwAIvHx8O+N+BedQDW4nt
         Os+Qhp24s9Yks2GnzZ7n06DkvHGlRZ0BBKojZ73k7N1zK/ceC6d9nalXfNhTBrbfpkyw
         LoyK6PuRHJTHdQPoxN226T7mmftWMSrtEm6GGLg44ze57ofCAoUb9ebTajitIhDKEVJ5
         n0eUuZN0UbJuMTE9XdDwTz6WlAZofutxqmD+EtUjF90i5RysMJZhXrDZCiWv7udqrxfW
         IGgg==
X-Gm-Message-State: APjAAAWUCnwFlEVWL99mulRn7bORgvsrNZNCpLQVy6e1U6EO5niZ3Tpl
	mv2iKsJ69nzcqrNXAuXs0OVAzkQhgOudUYoOaIrqrqjK1sOq7xmFjyfduLsc5qqo4p58IS15BnA
	1/eR4MYdM41v5X+l952lz/AaNTkFT68RBMIbAjfGxztTOnQpzufxaWKhgM97/nNF7Lw==
X-Received: by 2002:a05:6638:149:: with SMTP id y9mr4957121jao.76.1562855186684;
        Thu, 11 Jul 2019 07:26:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxuffeQrVjODQEU+acvsnVEem1BLaVQ+GaB+LBCP+bqLxVcBfGDv4D4QQoAuui8di+yALCk
X-Received: by 2002:a05:6638:149:: with SMTP id y9mr4957025jao.76.1562855185763;
        Thu, 11 Jul 2019 07:26:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562855185; cv=none;
        d=google.com; s=arc-20160816;
        b=uZtLipxMM3leaCavWHFN1KwCUJZ2caBOgJhMSPAaD0V42npqEZe0w9GPSYk/6Yu4Y/
         IM9G+P7swW3hq9rzXWBUtVj4SI7AwvnBE6tvAAN3B5hqVOe+jdQJt77p2D0TpR4glssA
         ENPtv2fdfAPlmByuyIbMWuS8Em1rgWu6ZA+TynKRqWcRyGfUsDxO7Cd15xNu4BRcWul+
         auyvDOLo2NcaoqSlSg/Pz1cqZZiKhdnxecql4xC9GK+NSONnbz7lFKZUsGuRwnoqWbmn
         B1eRRG38QdMfiOcFV8B06+h9PUBmnbW/URWm5aDbMinPN8fgQsEqTtFpWZiL69/Pvo+K
         65YA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=y9IAz60J7qXRlFN2NRsHUzd+qvZ9ZunbWoLTMdcwAx8=;
        b=j3UYHq+p7Fn3mNOPHTCZDW+ENNR0QtcyoB08jcM5pbmyxTD81y9n0efUjnM1bFji2T
         OU1ewcikWuiY6s7r5iUI6yyhpH66AXEG7W4U4zXGxRXicP2vIPZmUPN+wWmzNp9ZJof3
         BoTWb8CqIMJulpPjKudmWpnOrI1Euy4hVK9bvdYMDgm5KUBU2wvibRIDR9ryoJbLBiXY
         rFTvmY7osgCS+bmiiTfBUoSuCnM896Pw8e0+dzEvQ42LvuSAWJSIt61bSBX0q41KcHgw
         qijCBlowL+eymaoeEv/x+gJ72HaqVa53tslJwfRK9dD/0do11CZZvrsX8bye41sJTtSF
         HhUw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=SmfOq+K7;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id a17si9049208jap.14.2019.07.11.07.26.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 07:26:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=SmfOq+K7;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6BEOMPI001606;
	Thu, 11 Jul 2019 14:26:13 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=y9IAz60J7qXRlFN2NRsHUzd+qvZ9ZunbWoLTMdcwAx8=;
 b=SmfOq+K7kq1i3rKVZwlHKx3Hxs01appLJg4uPnU/ZriVoOVHCERIDHALooM0c4fIGSBJ
 6sJUwYFar/i1eRJ0bDwA5eXmBBC3pkJst2pWeRiO5XvbO/TYtBqcsljdxwFDY+ygijHk
 H0MYZu44ra2JBIbub0jXMvwYLNtqfrcVe7JBvlbVaiEu0d5hM3uanYLNWIvfENEj46Wm
 gz3Qt8PeZrmim/eo4JN+pfX8fKIq4/XNikWq8u1EuUds0UNZgKC6NbZKX2Q0LuHEumqL
 b5/SpV0/Ww9/ELn0rWmcvfcCc+XgXWqEmOxEsU2TT2yDZ4Zr37YzZrqonMAsPGVng5cD rQ== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp2130.oracle.com with ESMTP id 2tjk2u0dx7-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 11 Jul 2019 14:26:12 +0000
Received: from achartre-desktop.fr.oracle.com (dhcp-10-166-106-34.fr.oracle.com [10.166.106.34])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x6BEPcu1021444;
	Thu, 11 Jul 2019 14:26:09 GMT
From: Alexandre Chartre <alexandre.chartre@oracle.com>
To: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
        mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
        dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org,
        kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: konrad.wilk@oracle.com, jan.setjeeilers@oracle.com, liran.alon@oracle.com,
        jwadams@google.com, graf@amazon.de, rppt@linux.vnet.ibm.com,
        alexandre.chartre@oracle.com
Subject: [RFC v2 08/26] mm/asi: Functions to populate an ASI page-table from a VA range
Date: Thu, 11 Jul 2019 16:25:20 +0200
Message-Id: <1562855138-19507-9-git-send-email-alexandre.chartre@oracle.com>
X-Mailer: git-send-email 1.7.1
In-Reply-To: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
References: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9314 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=917 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1907110162
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Provide functions to copy page-table entries from the kernel page-table
to an ASI page-table for a specified VA range. These functions are based
on the copy_pxx_range() functions defined in mm/memory.c. A difference
is that a level parameter can be specified to indicate the page-table
level (PGD, P4D, PUD PMD, PTE) at which the copy should be done. Also
functions don't rely on mm or vma, and they don't alter the source
page-table even if an entry is bad. Also the VA range start and size
don't need to be page-aligned.

Signed-off-by: Alexandre Chartre <alexandre.chartre@oracle.com>
---
 arch/x86/include/asm/asi.h  |    4 +
 arch/x86/mm/asi_pagetable.c |  205 +++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 209 insertions(+), 0 deletions(-)

diff --git a/arch/x86/include/asm/asi.h b/arch/x86/include/asm/asi.h
index 3d965e6..19656aa 100644
--- a/arch/x86/include/asm/asi.h
+++ b/arch/x86/include/asm/asi.h
@@ -76,6 +76,10 @@ struct asi_session {
 extern bool asi_fault(struct pt_regs *regs, unsigned long error_code,
 		      unsigned long address);
 
+extern int asi_map_range(struct asi *asi, void *ptr, size_t size,
+			 enum page_table_level level);
+extern int asi_map(struct asi *asi, void *ptr, unsigned long size);
+
 /*
  * Function to exit the current isolation. This is used to abort isolation
  * when a task using isolation is scheduled out.
diff --git a/arch/x86/mm/asi_pagetable.c b/arch/x86/mm/asi_pagetable.c
index e17af9e..0169395 100644
--- a/arch/x86/mm/asi_pagetable.c
+++ b/arch/x86/mm/asi_pagetable.c
@@ -394,3 +394,208 @@ static int asi_set_pgd(struct asi *asi, pgd_t *pgd, pgd_t pgd_value)
 
 	return 0;
 }
+
+static int asi_copy_pte_range(struct asi *asi, pmd_t *dst_pmd, pmd_t *src_pmd,
+			      unsigned long addr, unsigned long end)
+{
+	pte_t *src_pte, *dst_pte;
+
+	dst_pte = asi_pte_alloc(asi, dst_pmd, addr);
+	if (IS_ERR(dst_pte))
+		return PTR_ERR(dst_pte);
+
+	addr &= PAGE_MASK;
+	src_pte = pte_offset_map(src_pmd, addr);
+
+	do {
+		asi_set_pte(asi, dst_pte, *src_pte);
+
+	} while (dst_pte++, src_pte++, addr += PAGE_SIZE, addr < end);
+
+	return 0;
+}
+
+static int asi_copy_pmd_range(struct asi *asi, pud_t *dst_pud, pud_t *src_pud,
+			      unsigned long addr, unsigned long end,
+			      enum page_table_level level)
+{
+	pmd_t *src_pmd, *dst_pmd;
+	unsigned long next;
+	int err;
+
+	dst_pmd = asi_pmd_alloc(asi, dst_pud, addr);
+	if (IS_ERR(dst_pmd))
+		return PTR_ERR(dst_pmd);
+
+	src_pmd = pmd_offset(src_pud, addr);
+
+	do {
+		next = pmd_addr_end(addr, end);
+		if (level == PGT_LEVEL_PMD || pmd_none(*src_pmd) ||
+		    pmd_trans_huge(*src_pmd) || pmd_devmap(*src_pmd)) {
+			err = asi_set_pmd(asi, dst_pmd, *src_pmd);
+			if (err)
+				return err;
+			continue;
+		}
+
+		if (!pmd_present(*src_pmd)) {
+			pr_warn("ASI %p: PMD not present for [%lx,%lx]\n",
+				asi, addr, next - 1);
+			pmd_clear(dst_pmd);
+			continue;
+		}
+
+		err = asi_copy_pte_range(asi, dst_pmd, src_pmd, addr, next);
+		if (err) {
+			pr_err("ASI %p: PMD error copying PTE addr=%lx next=%lx\n",
+			       asi, addr, next);
+			return err;
+		}
+
+	} while (dst_pmd++, src_pmd++, addr = next, addr < end);
+
+	return 0;
+}
+
+static int asi_copy_pud_range(struct asi *asi, p4d_t *dst_p4d, p4d_t *src_p4d,
+			      unsigned long addr, unsigned long end,
+			      enum page_table_level level)
+{
+	pud_t *src_pud, *dst_pud;
+	unsigned long next;
+	int err;
+
+	dst_pud = asi_pud_alloc(asi, dst_p4d, addr);
+	if (IS_ERR(dst_pud))
+		return PTR_ERR(dst_pud);
+
+	src_pud = pud_offset(src_p4d, addr);
+
+	do {
+		next = pud_addr_end(addr, end);
+		if (level == PGT_LEVEL_PUD || pud_none(*src_pud) ||
+		    pud_trans_huge(*src_pud) || pud_devmap(*src_pud)) {
+			err = asi_set_pud(asi, dst_pud, *src_pud);
+			if (err)
+				return err;
+			continue;
+		}
+
+		err = asi_copy_pmd_range(asi, dst_pud, src_pud, addr, next,
+					 level);
+		if (err) {
+			pr_err("ASI %p: PUD error copying PMD addr=%lx next=%lx\n",
+			       asi, addr, next);
+			return err;
+		}
+
+	} while (dst_pud++, src_pud++, addr = next, addr < end);
+
+	return 0;
+}
+
+static int asi_copy_p4d_range(struct asi *asi, pgd_t *dst_pgd, pgd_t *src_pgd,
+			      unsigned long addr, unsigned long end,
+			      enum page_table_level level)
+{
+	p4d_t *src_p4d, *dst_p4d;
+	unsigned long next;
+	int err;
+
+	dst_p4d = asi_p4d_alloc(asi, dst_pgd, addr);
+	if (IS_ERR(dst_p4d))
+		return PTR_ERR(dst_p4d);
+
+	src_p4d = p4d_offset(src_pgd, addr);
+
+	do {
+		next = p4d_addr_end(addr, end);
+		if (level == PGT_LEVEL_P4D || p4d_none(*src_p4d)) {
+			err = asi_set_p4d(asi, dst_p4d, *src_p4d);
+			if (err)
+				return err;
+			continue;
+		}
+
+		err = asi_copy_pud_range(asi, dst_p4d, src_p4d, addr, next,
+					 level);
+		if (err) {
+			pr_err("ASI %p: P4D error copying PUD addr=%lx next=%lx\n",
+			       asi, addr, next);
+			return err;
+		}
+
+	} while (dst_p4d++, src_p4d++, addr = next, addr < end);
+
+	return 0;
+}
+
+static int asi_copy_pgd_range(struct asi *asi,
+			      pgd_t *dst_pagetable, pgd_t *src_pagetable,
+			      unsigned long addr, unsigned long end,
+			      enum page_table_level level)
+{
+	pgd_t *src_pgd, *dst_pgd;
+	unsigned long next;
+	int err;
+
+	dst_pgd = pgd_offset_pgd(dst_pagetable, addr);
+	src_pgd = pgd_offset_pgd(src_pagetable, addr);
+
+	do {
+		next = pgd_addr_end(addr, end);
+		if (level == PGT_LEVEL_PGD || pgd_none(*src_pgd)) {
+			err = asi_set_pgd(asi, dst_pgd, *src_pgd);
+			if (err)
+				return err;
+			continue;
+		}
+
+		err = asi_copy_p4d_range(asi, dst_pgd, src_pgd, addr, next,
+					 level);
+		if (err) {
+			pr_err("ASI %p: PGD error copying P4D addr=%lx next=%lx\n",
+			       asi, addr, next);
+			return err;
+		}
+
+	} while (dst_pgd++, src_pgd++, addr = next, addr < end);
+
+	return 0;
+}
+
+/*
+ * Copy page table entries from the current page table (i.e. from the
+ * kernel page table) to the specified ASI page-table. The level
+ * parameter specifies the page-table level (PGD, P4D, PUD PMD, PTE)
+ * at which the copy should be done.
+ */
+int asi_map_range(struct asi *asi, void *ptr, size_t size,
+		  enum page_table_level level)
+{
+	unsigned long addr = (unsigned long)ptr;
+	unsigned long end = addr + ((unsigned long)size);
+	unsigned long flags;
+	int err;
+
+	pr_debug("ASI %p: MAP %px/%lx/%d\n", asi, ptr, size, level);
+
+	spin_lock_irqsave(&asi->lock, flags);
+	err = asi_copy_pgd_range(asi, asi->pgd, current->mm->pgd,
+				 addr, end, level);
+	spin_unlock_irqrestore(&asi->lock, flags);
+
+	return err;
+}
+EXPORT_SYMBOL(asi_map_range);
+
+/*
+ * Copy page-table PTE entries from the current page-table to the
+ * specified ASI page-table.
+ */
+int asi_map(struct asi *asi, void *ptr, unsigned long size)
+{
+	return asi_map_range(asi, ptr, size, PGT_LEVEL_PTE);
+}
+EXPORT_SYMBOL(asi_map);
-- 
1.7.1

