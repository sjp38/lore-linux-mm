Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5545C28CC0
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 21:36:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8EC6824223
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 21:36:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="LTkQ1wQE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8EC6824223
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0A2BB6B026D; Wed, 29 May 2019 17:36:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EEF596B0273; Wed, 29 May 2019 17:36:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C3CC36B0272; Wed, 29 May 2019 17:36:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7A0DE6B026A
	for <linux-mm@kvack.org>; Wed, 29 May 2019 17:36:54 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id f1so2902184pfb.0
        for <linux-mm@kvack.org>; Wed, 29 May 2019 14:36:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=qndMC0xqMluPTNov9/3iwaOnMII97myVrvnzznwxlUw=;
        b=ZANSFr9ZbjsnlcmC+cLdjhGQLth06hxWNScIqfDa9v2lMqqBGfHIR+eeI8vd0clXYl
         ysmkRUPngBcPt7HOVzrOp+1+tuhJYyGhKD2SQwAJdWgWCNKp54OzLZh8HPhidCNV4WTd
         cXHMUNLyaD6VnBb4mliM1MCGQSBgVN1EU9JGg18Bd1/zwll04tdm1Z823b/Wn+DrdMUh
         QDBBr5OEsVKUHBMndfB3UKw6Og/xO5fZhp2PcA84NK8s3GePmtj01yuUy1ya7KPyixmy
         JqnQaAeo/gsCKfLA9bMCR4qveJf9kH9qIswCNaLPYfgPEi/mAs59kU3vn9WebZo1djwU
         r3Jw==
X-Gm-Message-State: APjAAAX7ki4TFsspf03otl3/i5c9Qx/eOqZtggmdZNtMJIE8Gs5FE1bf
	Ee3ZTP+7hBBzyM01/cFQNhN2S8Yu5oTPN6Hj4xkuBircTHsDlCRi4W240EUijdVGgiSd2eLoSrk
	aj9eyuDpni9b83zJrYpkhAsY5zHv4vXduwmu5DAI80d/1RidQAZF6RcuzrBfjLOA3AQ==
X-Received: by 2002:a17:90a:9dca:: with SMTP id x10mr103429pjv.105.1559165813947;
        Wed, 29 May 2019 14:36:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxV1I+Ej+jSpQKU/0gctSjl2ZFb0xmeOjFhUP6i+XOPKoyRuMJfMkja4K38CnvTQ7rTDuxM
X-Received: by 2002:a17:90a:9dca:: with SMTP id x10mr103373pjv.105.1559165812697;
        Wed, 29 May 2019 14:36:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559165812; cv=none;
        d=google.com; s=arc-20160816;
        b=OwvHQLSV/IeJRJmUopLOUVLnzbC7ZGtIaJUwXUlXSktWHn9D4hxqEJYYU9Wz58t3LI
         yaz3hSA152h6NFku3DLYLCQsVNHqVcyTp0nLyisB/gmJWi+YVIt2+wxCB+zrDFCKsrwE
         /1ZJmadhZ6FCBQ+YgBy6opfrVm87wmk42W85t5X0uW1O3WfagNC5K3JYPd1fAC6S3+7J
         15flbD3OoMCWV6LY8XVKOZwNhezF7amH292x8Y1J79sZ8TCy+xkhhduypYOGc+7tHaqW
         6vhdyxuSyKjMXfy4e4Ca7Fzs0L5Y/NUahOWShGXiPCmEVBqyzaEDU+3OK+qnAGznHJzU
         pATA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=qndMC0xqMluPTNov9/3iwaOnMII97myVrvnzznwxlUw=;
        b=i7hJidAAvBb56i9dzfSxJMxBkufujDSR8K5r89MzsSnMCYgE0bYR2oNlbEeGBaws4h
         30EXDK99s60vh5KmXf/rNwzaPgkuJg1aaTto1+N1BZRUjiOLvx8cAH98sLG0cGcIZc2V
         V34ZIu41yDaHZPFlNNdv6HjF9fnAygvRJq4dpzF8n0n+jiOfA5S4BstcMGmQK6pBfzB/
         6qXU9jjYim6AKJAZGEjFnEh6dJjxJaWh/S3sbN+hDYUNKp7FVY4+EHa93GvzE0XgT7zf
         a+nsJgOVi0qGd5BsWla4E+F1TZgR5SwcrOUb1eJqoEoxI6Gp+K+3itAk75q6AR/flquL
         jgQA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=LTkQ1wQE;
       spf=pass (google.com: domain of prvs=105246f206=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=105246f206=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id x21si691542pjn.61.2019.05.29.14.36.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 May 2019 14:36:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=105246f206=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=LTkQ1wQE;
       spf=pass (google.com: domain of prvs=105246f206=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=105246f206=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148461.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4TLXFaA029780
	for <linux-mm@kvack.org>; Wed, 29 May 2019 14:36:51 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=qndMC0xqMluPTNov9/3iwaOnMII97myVrvnzznwxlUw=;
 b=LTkQ1wQEoMYl6maX4Qm4eWZZSKF3T2qxbtzfn/2yYogdb+4V3LFaHgo8wiAq6NGxBkJd
 aTe758DWrooYpZU6e6V+eiqY1EGkBCpvv9Z69AZbPJDMWWk8QIZwKrbAS3IHE9TcYJkb
 ZWVuxyitfP5YHkU3ABSScb9jAn2gSEVFV0E= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2ssqq9jb6r-8
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 29 May 2019 14:36:50 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::129) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Wed, 29 May 2019 14:36:48 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 47ACB62E215C; Wed, 29 May 2019 14:21:22 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>
CC: <namit@vmware.com>, <peterz@infradead.org>, <oleg@redhat.com>,
        <rostedt@goodmis.org>, <mhiramat@kernel.org>,
        <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        <chad.mynhier@oracle.com>, <mike.kravetz@oracle.com>,
        Song Liu <songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH uprobe, thp 3/4] uprobe: support huge page by only splitting the pmd
Date: Wed, 29 May 2019 14:20:48 -0700
Message-ID: <20190529212049.2413886-4-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190529212049.2413886-1-songliubraving@fb.com>
References: <20190529212049.2413886-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-29_11:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905290134
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Instead of splitting the compound page with FOLL_SPLIT, this patch allows
uprobe to only split pmd for huge pages.

A helper function mm_address_trans_huge(mm, address) was introduced to
test whether the address in mm is pointing to THP.

Signed-off-by: Song Liu <songliubraving@fb.com>
---
 include/linux/huge_mm.h |  8 ++++++++
 kernel/events/uprobes.c | 38 ++++++++++++++++++++++++++++++++------
 mm/huge_memory.c        | 24 ++++++++++++++++++++++++
 3 files changed, 64 insertions(+), 6 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 2d8a40fd06e4..4832d6580969 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -163,6 +163,8 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 void split_huge_pmd_address(struct vm_area_struct *vma, unsigned long address,
 		bool freeze, struct page *page, pgtable_t prealloc_pgtable);
 
+bool mm_address_trans_huge(struct mm_struct *mm, unsigned long address);
+
 void __split_huge_pud(struct vm_area_struct *vma, pud_t *pud,
 		unsigned long address);
 
@@ -302,6 +304,12 @@ static inline void split_huge_pmd_address(struct vm_area_struct *vma,
 		unsigned long address, bool freeze, struct page *page,
 		pgtable_t prealloc_pgtable) {}
 
+static inline bool mm_address_trans_huge(struct mm_struct *mm,
+					 unsigned long address)
+{
+	return false;
+}
+
 #define split_huge_pud(__vma, __pmd, __address)	\
 	do { } while (0)
 
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index ba49da99d2a2..56eeccc2f7a2 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -26,6 +26,7 @@
 #include <linux/percpu-rwsem.h>
 #include <linux/task_work.h>
 #include <linux/shmem_fs.h>
+#include <asm/pgalloc.h>
 
 #include <linux/uprobes.h>
 
@@ -153,7 +154,7 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 {
 	struct mm_struct *mm = vma->vm_mm;
 	struct page_vma_mapped_walk pvmw = {
-		.page = old_page,
+		.page = compound_head(old_page),
 		.vma = vma,
 		.address = addr,
 	};
@@ -165,8 +166,6 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, 0, vma, mm, addr,
 				addr + PAGE_SIZE);
 
-	VM_BUG_ON_PAGE(PageTransHuge(old_page), old_page);
-
 	if (!orig) {
 		err = mem_cgroup_try_charge(new_page, vma->vm_mm, GFP_KERNEL,
 					    &memcg, false);
@@ -188,7 +187,8 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 
 	get_page(new_page);
 	if (orig) {
-		page_add_file_rmap(new_page, false);
+		page_add_file_rmap(compound_head(new_page),
+				   PageTransHuge(compound_head(new_page)));
 		inc_mm_counter(mm, mm_counter_file(new_page));
 		dec_mm_counter(mm, MM_ANONPAGES);
 	} else {
@@ -207,7 +207,8 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 	set_pte_at_notify(mm, addr, pvmw.pte,
 			mk_pte(new_page, vma->vm_page_prot));
 
-	page_remove_rmap(old_page, false);
+	page_remove_rmap(compound_head(old_page),
+			 PageTransHuge(compound_head(old_page)));
 	if (!page_mapped(old_page))
 		try_to_free_swap(old_page);
 	page_vma_mapped_walk_done(&pvmw);
@@ -475,17 +476,42 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe, struct mm_struct *mm,
 	struct vm_area_struct *vma;
 	int ret, is_register, ref_ctr_updated = 0;
 	pgoff_t index;
+	pgtable_t prealloc_pgtable = NULL;
+	unsigned long foll_flags = FOLL_FORCE;
 
 	is_register = is_swbp_insn(&opcode);
 	uprobe = container_of(auprobe, struct uprobe, arch);
 
+	/* do not FOLL_SPLIT yet */
+	ret = get_user_pages_remote(NULL, mm, vaddr, 1,
+			foll_flags, &old_page, &vma, NULL);
+
+	if (ret <= 0)
+		return ret;
+
+	if (mm_address_trans_huge(mm, vaddr)) {
+		prealloc_pgtable = pte_alloc_one(mm);
+		if (likely(prealloc_pgtable)) {
+			split_huge_pmd_address(vma, vaddr, false, NULL,
+					       prealloc_pgtable);
+			goto verify;
+		} else {
+			/* fallback to FOLL_SPLIT */
+			foll_flags |= FOLL_SPLIT;
+			put_page(old_page);
+		}
+	} else {
+		goto verify;
+	}
+
 retry:
 	/* Read the page with vaddr into memory */
 	ret = get_user_pages_remote(NULL, mm, vaddr, 1,
-			FOLL_FORCE | FOLL_SPLIT, &old_page, &vma, NULL);
+			foll_flags, &old_page, &vma, NULL);
 	if (ret <= 0)
 		return ret;
 
+verify:
 	ret = verify_opcode(old_page, vaddr, &opcode);
 	if (ret <= 0)
 		goto put_old;
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index dcb0e30213af..4714871353c0 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2360,6 +2360,30 @@ void split_huge_pmd_address(struct vm_area_struct *vma, unsigned long address,
 	____split_huge_pmd(vma, pmd, address, freeze, page, prealloc_pgtable);
 }
 
+bool mm_address_trans_huge(struct mm_struct *mm, unsigned long address)
+{
+	pgd_t *pgd;
+	p4d_t *p4d;
+	pud_t *pud;
+	pmd_t *pmd;
+
+	pgd = pgd_offset(mm, address);
+	if (!pgd_present(*pgd))
+		return false;
+
+	p4d = p4d_offset(pgd, address);
+	if (!p4d_present(*p4d))
+		return false;
+
+	pud = pud_offset(p4d, address);
+	if (!pud_present(*pud))
+		return false;
+
+	pmd = pmd_offset(pud, address);
+
+	return pmd_trans_huge(*pmd);
+}
+
 void vma_adjust_trans_huge(struct vm_area_struct *vma,
 			     unsigned long start,
 			     unsigned long end,
-- 
2.17.1

