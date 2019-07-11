Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72C48C74A35
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:26:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2733121019
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:26:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="HGyms/pI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2733121019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D57CC8E00CD; Thu, 11 Jul 2019 10:26:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CE4168E00C4; Thu, 11 Jul 2019 10:26:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A963B8E00CD; Thu, 11 Jul 2019 10:26:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7980C8E00C4
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 10:26:32 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id p12so6933305iog.19
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 07:26:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=Ccv45kVv21CrVP2UQjHtQ159yrdddBRkfeerFm1lQZs=;
        b=RKVKJqrnyGcTkDYad4uF1YBFpKnKXUlSjWA3nEA1BxRk7hH+lvdEO08brX2Nltg+UG
         ORF6ivdoWyd9tdqjyI96Cqqlarx+q6SpIIKzJ8D/UUotipa2jtpL44lc/fQEnmXqYOqi
         lG9rK0AhSOrn2MiEA8IUrPTPVCPfsdXHz5pKhEpZ1AAAkN6oCkmPmYkOBtUEqIk/sfGk
         KRcXjUoZvWEQpLtrJDCAC6Z1icDpo0+xn7GOgv91GdM0CIlIEOSHce4bZVNZBCKmgZie
         rN/OHHNwN88+yn7bI6diG6tF5kxYOr/iVkEQpWP/P3uayfXHNFMO8/UmnyZrOdP1ALyL
         DZ4A==
X-Gm-Message-State: APjAAAWUZuKMOG2RZLP0W7e8B7bHSca7G98oLz+sHWdpkgWWCl+a3ov2
	jy6jHwdeaXTFO7GfLX2fh1cY2CMg4jlMK/9TAUXq2Y5qdm08X+zMfUJ9KvVqgCMNRv2fen3f0tm
	rLdvcwdUKcPJjlVBnu9hd3IXj6IgfN1QeWY5DKBMw5L/bQXIzXTmQgg37Kt953ejutw==
X-Received: by 2002:a6b:5106:: with SMTP id f6mr4265464iob.15.1562855192268;
        Thu, 11 Jul 2019 07:26:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyl8g77ejFaGOQqKS2F9s4PPw6clpgurGnNy5KNSFNGa0dHEk9r5FvW3dUOZhlgenLsprzX
X-Received: by 2002:a6b:5106:: with SMTP id f6mr4265401iob.15.1562855191577;
        Thu, 11 Jul 2019 07:26:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562855191; cv=none;
        d=google.com; s=arc-20160816;
        b=IS3Gx0KwKK5FZngku5uLr4fwIncUh73z3metVCDioOghD7a3RS3kLy9L5s4sXQq9KB
         NEZF9KW1XiO3oQZp+K2tXeag+h/ePlnjZdMxYBnJfTHW48n2zv6aXRF6S3IRVhzVS8rg
         OF22xt/lvok5XiyjXX7f9hFFlBL58g7k/C01U00/avVMxOCLsZ7LGC5CuEIiiLzxhOzo
         MTcCsJkSlYPFz5bmt3QvS4N9vQV5pPSEKEGGhDGNQGy8jZzoRlF9qrbF5/EKoFAccV7K
         6Rk+JVVoh1PB6Tn/hRodZ6Q2jJdPkvDe5k2gyY/JpC0uArT1ST5pVgj+JsmFlpYLfQzD
         Smsg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=Ccv45kVv21CrVP2UQjHtQ159yrdddBRkfeerFm1lQZs=;
        b=awOsdQKEvk7fRhjbIm2EHq+27dgt8K6HemPzd4/RJ2MczB4WPN3GOZ6hzEVPYzEQqk
         ka3PSX8++1tT7whUe/jrZCYvmfpiNiFdMFzSx0urtQfbOi9DAze9pgc3jR0WCUV67F0s
         AoL7qaNEFYEHCLbqdJPnP64H5u6P+RDe6PHW2358YuYsj9nVfrHpOL48XOsDIRUBtMCM
         FFk4jsmYLfr93YBHupMADf6bagKDAMhSyWgmO0X6T0IPpuhEUyOqJRghHBAp996PwsjH
         klxAv669w8Fmfq2GxelE4ASfDTZyQx98TxsJBINQkH1RWVyZ0ptywMnDhr7WP/9zINr8
         1UsQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="HGyms/pI";
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id t17si9199384jam.48.2019.07.11.07.26.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 07:26:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="HGyms/pI";
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6BEOabr100891;
	Thu, 11 Jul 2019 14:26:22 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=Ccv45kVv21CrVP2UQjHtQ159yrdddBRkfeerFm1lQZs=;
 b=HGyms/pISRX5hcPdr6Z5qUYPoK8BQ52EIauuQPyhPhRre44rLyUHzvnoqOTRvXzrwhCv
 OTY05ptHcmicwwbGGPPXQN6m4TPthhy/xClxEZa4yF8uHSsKm7ZSH9u/tLfCQHG6hg1K
 +gEPReBvdFOuXQjB3QhAq8WvFQ4EtwdfdpRMWXWmCpj3REbSSnlT8iB9x+evcMVyxruc
 OTPrrYVoOXTGYADVN58b8Xu0sMhIRq/VtBIXKZS/5/ya9K9aD3oXpTX8QexDk1Ib94j1
 ij8M3PZb4/wsMYxdM8hN/VwLMvqwLeYU8gvZc6wjF0NGEF6IBAOdWQJA2MvUwBG0KojU 6Q== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by aserp2120.oracle.com with ESMTP id 2tjkkq0c8m-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 11 Jul 2019 14:26:21 +0000
Received: from achartre-desktop.fr.oracle.com (dhcp-10-166-106-34.fr.oracle.com [10.166.106.34])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x6BEPcu4021444;
	Thu, 11 Jul 2019 14:26:18 GMT
From: Alexandre Chartre <alexandre.chartre@oracle.com>
To: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
        mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
        dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org,
        kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: konrad.wilk@oracle.com, jan.setjeeilers@oracle.com, liran.alon@oracle.com,
        jwadams@google.com, graf@amazon.de, rppt@linux.vnet.ibm.com,
        alexandre.chartre@oracle.com
Subject: [RFC v2 11/26] mm/asi: Functions to clear ASI page-table entries for a VA range
Date: Thu, 11 Jul 2019 16:25:23 +0200
Message-Id: <1562855138-19507-12-git-send-email-alexandre.chartre@oracle.com>
X-Mailer: git-send-email 1.7.1
In-Reply-To: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
References: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9314 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=905 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1907110162
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Provide functions to clear page-table entries in the ASI page-table for
a specified VA range. Functions also check that the clearing effectively
happens in the ASI page-table and there is no crossing of the ASI
page-table boundary (through references to the kernel page table), so
that the kernel page table is not modified by mistake.

As information (address, size, page-table level) about VA ranges mapped
to the ASI page-table is tracked, clearing is done with just specifying
the start address of the range.

Signed-off-by: Alexandre Chartre <alexandre.chartre@oracle.com>
---
 arch/x86/include/asm/asi.h  |    1 +
 arch/x86/mm/asi_pagetable.c |  134 +++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 135 insertions(+), 0 deletions(-)

diff --git a/arch/x86/include/asm/asi.h b/arch/x86/include/asm/asi.h
index be1c190..919129f 100644
--- a/arch/x86/include/asm/asi.h
+++ b/arch/x86/include/asm/asi.h
@@ -83,6 +83,7 @@ extern bool asi_fault(struct pt_regs *regs, unsigned long error_code,
 extern int asi_map_range(struct asi *asi, void *ptr, size_t size,
 			 enum page_table_level level);
 extern int asi_map(struct asi *asi, void *ptr, unsigned long size);
+extern void asi_unmap(struct asi *asi, void *ptr);
 
 /*
  * Copy the memory mapping for the current module. This is defined as a
diff --git a/arch/x86/mm/asi_pagetable.c b/arch/x86/mm/asi_pagetable.c
index a09a22d..7aee236 100644
--- a/arch/x86/mm/asi_pagetable.c
+++ b/arch/x86/mm/asi_pagetable.c
@@ -670,3 +670,137 @@ int asi_map(struct asi *asi, void *ptr, unsigned long size)
 	return asi_map_range(asi, ptr, size, PGT_LEVEL_PTE);
 }
 EXPORT_SYMBOL(asi_map);
+
+static void asi_clear_pte_range(struct asi *asi, pmd_t *pmd,
+				unsigned long addr, unsigned long end)
+{
+	pte_t *pte;
+
+	pte = asi_pte_offset(asi, pmd, addr);
+	if (IS_ERR(pte))
+		return;
+
+	do {
+		pte_clear(NULL, addr, pte);
+	} while (pte++, addr += PAGE_SIZE, addr < end);
+}
+
+static void asi_clear_pmd_range(struct asi *asi, pud_t *pud,
+				unsigned long addr, unsigned long end,
+				enum page_table_level level)
+{
+	unsigned long next;
+	pmd_t *pmd;
+
+	pmd = asi_pmd_offset(asi, pud, addr);
+	if (IS_ERR(pmd))
+		return;
+
+	do {
+		next = pmd_addr_end(addr, end);
+		if (pmd_none(*pmd) || pmd_present(*pmd))
+			continue;
+		if (level == PGT_LEVEL_PMD || pmd_trans_huge(*pmd) ||
+		    pmd_devmap(*pmd)) {
+			pmd_clear(pmd);
+			continue;
+		}
+		asi_clear_pte_range(asi, pmd, addr, next);
+	} while (pmd++, addr = next, addr < end);
+}
+
+static void asi_clear_pud_range(struct asi *asi, p4d_t *p4d,
+				unsigned long addr, unsigned long end,
+				enum page_table_level level)
+{
+	unsigned long next;
+	pud_t *pud;
+
+	pud = asi_pud_offset(asi, p4d, addr);
+	if (IS_ERR(pud))
+		return;
+
+	do {
+		next = pud_addr_end(addr, end);
+		if (pud_none(*pud))
+			continue;
+		if (level == PGT_LEVEL_PUD || pud_trans_huge(*pud) ||
+		    pud_devmap(*pud)) {
+			pud_clear(pud);
+			continue;
+		}
+		asi_clear_pmd_range(asi, pud, addr, next, level);
+	} while (pud++, addr = next, addr < end);
+}
+
+static void asi_clear_p4d_range(struct asi *asi, pgd_t *pgd,
+				unsigned long addr, unsigned long end,
+				enum page_table_level level)
+{
+	unsigned long next;
+	p4d_t *p4d;
+
+	p4d = asi_p4d_offset(asi, pgd, addr);
+	if (IS_ERR(p4d))
+		return;
+
+	do {
+		next = p4d_addr_end(addr, end);
+		if (p4d_none(*p4d))
+			continue;
+		if (level == PGT_LEVEL_P4D) {
+			p4d_clear(p4d);
+			continue;
+		}
+		asi_clear_pud_range(asi, p4d, addr, next, level);
+	} while (p4d++, addr = next, addr < end);
+}
+
+static void asi_clear_pgd_range(struct asi *asi, pgd_t *pagetable,
+				unsigned long addr, unsigned long end,
+				enum page_table_level level)
+{
+	unsigned long next;
+	pgd_t *pgd;
+
+	pgd = pgd_offset_pgd(pagetable, addr);
+	do {
+		next = pgd_addr_end(addr, end);
+		if (pgd_none(*pgd))
+			continue;
+		if (level == PGT_LEVEL_PGD) {
+			pgd_clear(pgd);
+			continue;
+		}
+		asi_clear_p4d_range(asi, pgd, addr, next, level);
+	} while (pgd++, addr = next, addr < end);
+}
+
+/*
+ * Clear page table entries in the specified ASI page-table.
+ */
+void asi_unmap(struct asi *asi, void *ptr)
+{
+	struct asi_range_mapping *range_mapping;
+	unsigned long addr, end;
+	unsigned long flags;
+
+	spin_lock_irqsave(&asi->lock, flags);
+
+	range_mapping = asi_get_range_mapping(asi, ptr);
+	if (!range_mapping) {
+		pr_debug("ASI %p: UNMAP %px - not mapped\n", asi, ptr);
+		goto done;
+	}
+
+	addr = (unsigned long)range_mapping->ptr;
+	end = addr + range_mapping->size;
+	pr_debug("ASI %p: UNMAP %px/%lx/%d\n", asi, ptr,
+		 range_mapping->size, range_mapping->level);
+	asi_clear_pgd_range(asi, asi->pgd, addr, end, range_mapping->level);
+	list_del(&range_mapping->list);
+	kfree(range_mapping);
+done:
+	spin_unlock_irqrestore(&asi->lock, flags);
+}
+EXPORT_SYMBOL(asi_unmap);
-- 
1.7.1

