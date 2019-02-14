Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE801C4360F
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 06:45:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A59872229F
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 06:45:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A59872229F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3E89B8E0002; Thu, 14 Feb 2019 01:45:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 397A98E0001; Thu, 14 Feb 2019 01:45:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 288688E0002; Thu, 14 Feb 2019 01:45:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id F3FE08E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 01:45:40 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id i66so4248165qke.21
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 22:45:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:mime-version:content-transfer-encoding:message-id;
        bh=H7nURE1rAfKv+Feq7DYRNNZSbtRUyjYtEOYAowTHEqA=;
        b=PHSp+z/OSMHHlGg/aOIq01WoQ0MdBIJ3DkytmQHwoeUEKEfASUBx2v2bWxN6uzSR12
         F6ujif0CbyfW7LtF/vMAbEof7QqlISCjtpOzu3VVYNNWMOLgLGqH+3mrN5tuSLpzq+zp
         sorqH8oLXBVM0IlIG+kp6v2JHrrC4VItgQmge3LM7nESG+9fVmmkxP+oN8W1wiCF6xau
         nGu7Z57Q6E1/uxF0Hu7ZznSROlJqq7tFCUuIpXLBNLA7XB6WR9Eyf9o+sb9WSgduYbt/
         x4GPH23DMunk/4Ys3R7On5BgVMnX3VSWk2SgCHvg5BYFEz4wLelELpjWiV2D9I45XCfT
         INJQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAubd8AVjIyUg4d8ZvciTzBcyhzdHZfA8okUw5AwG8oIlDVn/2zYn
	OS0TlTZ0mJdlPJqnRikAuViqptxliyZyryaUbhnvVlWJNoTbFqbIOZzS7SilP6IzSUJbTPoSyGT
	vwBcCfeJhPXipJYHdsygS5fIxcZ+5i27YaZvBYhZACBYVZvPf7Ekhv6VjostcX5mR1A==
X-Received: by 2002:ac8:30d3:: with SMTP id w19mr1768950qta.48.1550126740691;
        Wed, 13 Feb 2019 22:45:40 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZwetRVw312NRtyH++MUlr2A7+lPnaiQE196jMwkx4dNP082bh8aqQvXEjJ/IQNx01CKAeH
X-Received: by 2002:ac8:30d3:: with SMTP id w19mr1768920qta.48.1550126739971;
        Wed, 13 Feb 2019 22:45:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550126739; cv=none;
        d=google.com; s=arc-20160816;
        b=HBQvjgi3nLFl2MmjDOnB7xsATeA5YU6ggmuLZCWvd5YoeurHbWT6Tg9TL+UI3jpNiU
         qRnhLHnnFkdUOl4Jb8MQ2SAeaOObIX5UkZivix5/q+rUhotn6H0x1MqSOd+sq/F38Fd8
         P+0SU2mEZERsJiSmmcYwucTWKR/GrEeXP9kByD2rl0M5TmbsJrKfDRUVBRPwYfgPgprV
         BgoB8+V42T7d620jbiBK3ZPtN/4p0KAIo7nZnq8Gie3zEgZeOYb3seaZRBgl0619Xc7E
         1g8APRII6spjzmdzfmAQpEkEaWfIBJIJvRSEQosYPcrN8IrWxV1tH49DYkf1DxIUAnng
         YPPQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:date:subject:cc
         :to:from;
        bh=H7nURE1rAfKv+Feq7DYRNNZSbtRUyjYtEOYAowTHEqA=;
        b=wwdX7GKabTWC3/AxkNi54ZDJMIBtoWEcT+LllNwEhs9OceHYbgbxCyuHijeXC5hxWU
         OcnZ1VOAf2rCW5l+NiOEhF+aFT9ULrVUJsJJT1nR8PJ0o4kWraNJfRiFAJ9NkL829e+X
         HlIVIedGdhpQ+wovjSNHXFY3shRi9gqczJAmFMTAi5EtOiwa3G4mm3TXgGhn/t3DtdPg
         0OgdsJVh4X/kOfKI8YzKIzGaWEjLMIbupSHuLcEGeZKyDctWVTWqcQzPgUBxRN0XMY/+
         WZNQ55Ta+lPHNjqyV8kF0nPzJ/QoAqgF5fMFwO066EiV/PY/qzYDoJDpLgmzVt1iJBI6
         sdhw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 33si789127qtq.391.2019.02.13.22.45.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 22:45:39 -0800 (PST)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1E6XvQj132080
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 01:45:39 -0500
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com [32.97.110.153])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qn25n3s67-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 01:45:39 -0500
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Thu, 14 Feb 2019 06:45:37 -0000
Received: from b03cxnp08027.gho.boulder.ibm.com (9.17.130.19)
	by e35.co.us.ibm.com (192.168.1.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 14 Feb 2019 06:45:34 -0000
Received: from b03ledav003.gho.boulder.ibm.com (b03ledav003.gho.boulder.ibm.com [9.17.130.234])
	by b03cxnp08027.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1E6jYC224969224
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 14 Feb 2019 06:45:34 GMT
Received: from b03ledav003.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id E510C6A04D;
	Thu, 14 Feb 2019 06:45:33 +0000 (GMT)
Received: from b03ledav003.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 6A4206A047;
	Thu, 14 Feb 2019 06:45:32 +0000 (GMT)
Received: from skywalker.ibmuc.com (unknown [9.199.48.88])
	by b03ledav003.gho.boulder.ibm.com (Postfix) with ESMTP;
	Thu, 14 Feb 2019 06:45:31 +0000 (GMT)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH] powerpc/book3s: Remove a few page table update interfaces.
Date: Thu, 14 Feb 2019 12:15:29 +0530
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19021406-0012-0000-0000-0000170AAC92
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00010593; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000279; SDB=6.01160807; UDB=6.00605883; IPR=6.00941363;
 MB=3.00025575; MTD=3.00000008; XFM=3.00000015; UTC=2019-02-14 06:45:36
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19021406-0013-0000-0000-0000563301D5
Message-Id: <20190214064529.26509-1-aneesh.kumar@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-14_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=3 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902140050
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When updating page tables, we need to make sure we fill the page table
entry valid bit. We should be using page table populate interface for
updating the table entries. The page table 'set' interface allows
updating the raw value of page table entry. This can result in
updating the entry wrongly. Remove the 'set' interface so that we avoid
its future usage.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
---
 arch/powerpc/include/asm/book3s/64/pgalloc.h |  8 ++++----
 arch/powerpc/include/asm/book3s/64/pgtable.h | 14 --------------
 2 files changed, 4 insertions(+), 18 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/64/pgalloc.h b/arch/powerpc/include/asm/book3s/64/pgalloc.h
index 9c1173283b96..138bc2ecc0c4 100644
--- a/arch/powerpc/include/asm/book3s/64/pgalloc.h
+++ b/arch/powerpc/include/asm/book3s/64/pgalloc.h
@@ -111,7 +111,7 @@ static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 
 static inline void pgd_populate(struct mm_struct *mm, pgd_t *pgd, pud_t *pud)
 {
-	pgd_set(pgd, __pgtable_ptr_val(pud) | PGD_VAL_BITS);
+	*pgd =  __pgd(__pgtable_ptr_val(pud) | PGD_VAL_BITS);
 }
 
 static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr)
@@ -138,7 +138,7 @@ static inline void pud_free(struct mm_struct *mm, pud_t *pud)
 
 static inline void pud_populate(struct mm_struct *mm, pud_t *pud, pmd_t *pmd)
 {
-	pud_set(pud, __pgtable_ptr_val(pmd) | PUD_VAL_BITS);
+	*pud = __pud(__pgtable_ptr_val(pmd) | PUD_VAL_BITS);
 }
 
 static inline void __pud_free_tlb(struct mmu_gather *tlb, pud_t *pud,
@@ -176,13 +176,13 @@ static inline void __pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmd,
 static inline void pmd_populate_kernel(struct mm_struct *mm, pmd_t *pmd,
 				       pte_t *pte)
 {
-	pmd_set(pmd, __pgtable_ptr_val(pte) | PMD_VAL_BITS);
+	*pmd = __pmd(__pgtable_ptr_val(pte) | PMD_VAL_BITS);
 }
 
 static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmd,
 				pgtable_t pte_page)
 {
-	pmd_set(pmd, __pgtable_ptr_val(pte_page) | PMD_VAL_BITS);
+	*pmd = __pmd(__pgtable_ptr_val(pte_page) | PMD_VAL_BITS);
 }
 
 static inline pgtable_t pmd_pgtable(pmd_t pmd)
diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
index dc71e2b92003..a24e00fb7fa7 100644
--- a/arch/powerpc/include/asm/book3s/64/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
@@ -853,11 +853,6 @@ static inline bool pte_ci(pte_t pte)
 	return false;
 }
 
-static inline void pmd_set(pmd_t *pmdp, unsigned long val)
-{
-	*pmdp = __pmd(val);
-}
-
 static inline void pmd_clear(pmd_t *pmdp)
 {
 	*pmdp = __pmd(0);
@@ -889,11 +884,6 @@ static inline int pmd_bad(pmd_t pmd)
 	return hash__pmd_bad(pmd);
 }
 
-static inline void pud_set(pud_t *pudp, unsigned long val)
-{
-	*pudp = __pud(val);
-}
-
 static inline void pud_clear(pud_t *pudp)
 {
 	*pudp = __pud(0);
@@ -936,10 +926,6 @@ static inline bool pud_access_permitted(pud_t pud, bool write)
 }
 
 #define pgd_write(pgd)		pte_write(pgd_pte(pgd))
-static inline void pgd_set(pgd_t *pgdp, unsigned long val)
-{
-	*pgdp = __pgd(val);
-}
 
 static inline void pgd_clear(pgd_t *pgdp)
 {
-- 
2.20.1

