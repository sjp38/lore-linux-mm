Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B3869C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 05:23:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 662D2206B8
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 05:23:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="QKFOLy2h"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 662D2206B8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0AEBE8E0006; Tue, 30 Jul 2019 01:23:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 039598E0002; Tue, 30 Jul 2019 01:23:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DF37B8E0006; Tue, 30 Jul 2019 01:23:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id B9F038E0002
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 01:23:23 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id b22so48610228yba.4
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 22:23:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=QlY0qULqwL/0inVNzJF/uiGiPZ28zpDBxtshMYBqHLY=;
        b=TmkFHYnkkyWwJ1gcAzgOK8Io2GkEmSYzscGttXHUWd8NEgJ2zcU5YbGP3bOi4jQ2qO
         HKEmHFTHGbznyCEl3V3stHhNwHhGupnaYDcSStU0IVzNsunKoZzDpl/rJdWw6Y2nL5TG
         iXY0QedDd1MjqPiUfkeQPDLBrFuTDh7LYXHpyXZotnDaEiCalLJCc+drGZz2UdEM3RAU
         yq8z4Xas6PJv3lRdvXVWOHAr+JGdv3Dtko5/oROlQkDxf5kG5bKmfmVKhF5pwX2RuYAv
         MYOR8Ot+NhsGllH2OENAhp4FCRILY4zsjVw+xvLri+W9rZnE44B5nbQ6JPsYZwiXvYfe
         BkvA==
X-Gm-Message-State: APjAAAVcIzWjxYCcNL37soHNpG9bKE0+cOkHUpfh0l5hS88/sCtSN01D
	cbevrYwQyQw+QW4IaKyMWl/8FiKw9nOCXZJuHq8Pgt4vGqNcOQRsdBzzVJDU+oO2SKHA+6jeyOy
	ooqrBCYSCWoZzzEynfI7/TehIChSk/mwKz5ZEYxtoDseT5ENiiHW40Qy+rjpAGG4MEQ==
X-Received: by 2002:a25:1584:: with SMTP id 126mr50555060ybv.102.1564464203330;
        Mon, 29 Jul 2019 22:23:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy07fqsDHwQGkzb5iIMomZmwX/O9cBMHCJ2gb/ZdfmK/SVHtQwmezAZ8ns2TaEUoIgUdKE6
X-Received: by 2002:a25:1584:: with SMTP id 126mr50555032ybv.102.1564464202404;
        Mon, 29 Jul 2019 22:23:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564464202; cv=none;
        d=google.com; s=arc-20160816;
        b=UPG3S9nUuGNnAJOzxN+ka1qMNU6bxUo/HDIk+WNRyxRntRx6n9QCefpTfhgSBVbsCy
         QxYVzZ69eC2QTQt1y+m5TGzYaZsI/dbJZ8N6F36zbYzBP+g+UxvDL7eSoOSb004DnUrV
         jJK6EfCqLfNUQzjOV0JFwteDPEoaEeI96MykHOPUrdPV/jBaw1axidcI89nxjAM6/tqE
         BZvPvf4ne6G6N3OX06dN6IvssWuYPRbvP7l/j+LDy0AefErgfmPs7hphwZiyd/NS709T
         8rY73wpxT6kIT08aeQ6Z8/qz5p10iKF6euNbNis7c3lOrKYi0iCtuVEu0/TmBsBnrNan
         Zz3Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=QlY0qULqwL/0inVNzJF/uiGiPZ28zpDBxtshMYBqHLY=;
        b=hqPEEipkel3PepP8BIx5++s2Kiv+JzuMdBiVRxchTisCPSdYu7WPcXZvBf6n0z4UkC
         Kl437o8T8B1zf8grWeVv26pHX4GbgZFnw3L/YcHlYmps/+H23JPSqRwDivafpAGiTCBm
         RqJMZE2SI0JrOFnpdnyYAeQh8gqZreIHar6efeHGFBL/cysqarFJrsm4xl2CxFRjToVZ
         oX/Bg3REDgDG3iyl2Hd4uX9ivULwA3PTutOQGO1X2uA+mxJWD14iclUsNr45FcRMyGhS
         yYvwnPQdwQXNaEqcvc5jLqh6VzWJNRYwZ5CRgz6MixOpcenJSh4fLtcjFIl+di27kejW
         NLfA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=QKFOLy2h;
       spf=pass (google.com: domain of prvs=31148e3214=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=31148e3214=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id x15si16403417ybq.238.2019.07.29.22.23.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 22:23:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=31148e3214=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=QKFOLy2h;
       spf=pass (google.com: domain of prvs=31148e3214=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=31148e3214=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6U5MSXu011167
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 22:23:22 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=QlY0qULqwL/0inVNzJF/uiGiPZ28zpDBxtshMYBqHLY=;
 b=QKFOLy2hzgA8Rq8Q4/CD1W46KzCXyv/J7Jdnwm9AFaj1uLYghPpleofLCCsg7QZmveXY
 oGo7nhzS0iR0dwbknp//DsY/qe52tM4ztvnr1CsUcZ7XBz7i0Wntj60vX8Nmn5nLelu3
 WnzqKfDdcMyH/6JbSAM3O77oN+Br/LATsD4= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 2u260g9x66-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 22:23:21 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::129) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Mon, 29 Jul 2019 22:23:20 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 4A35E62E2FF0; Mon, 29 Jul 2019 22:23:18 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>,
        <akpm@linux-foundation.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <oleg@redhat.com>, <kernel-team@fb.com>,
        <william.kucharski@oracle.com>, <srikar@linux.vnet.ibm.com>,
        Song Liu <songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v10 2/4] uprobe: use original page when all uprobes are removed
Date: Mon, 29 Jul 2019 22:23:03 -0700
Message-ID: <20190730052305.3672336-3-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190730052305.3672336-1-songliubraving@fb.com>
References: <20190730052305.3672336-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-30_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=884 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1907300056
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently, uprobe swaps the target page with a anonymous page in both
install_breakpoint() and remove_breakpoint(). When all uprobes on a page
are removed, the given mm is still using an anonymous page (not the
original page).

This patch allows uprobe to use original page when possible (all uprobes
on the page are already removed). As suggested by Oleg, we unmap the
old_page and let the original page fault in.

Suggested-by: Oleg Nesterov <oleg@redhat.com>
Signed-off-by: Song Liu <songliubraving@fb.com>
---
 kernel/events/uprobes.c | 66 +++++++++++++++++++++++++++++++----------
 1 file changed, 51 insertions(+), 15 deletions(-)

diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 84fa00497c49..648f47553bff 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -143,10 +143,12 @@ static loff_t vaddr_to_offset(struct vm_area_struct *vma, unsigned long vaddr)
  *
  * @vma:      vma that holds the pte pointing to page
  * @addr:     address the old @page is mapped at
- * @page:     the cowed page we are replacing by kpage
- * @kpage:    the modified page we replace page by
+ * @old_page: the page we are replacing by new_page
+ * @new_page: the modified page we replace page by
  *
- * Returns 0 on success, -EFAULT on failure.
+ * If @new_page is NULL, only unmap @old_page.
+ *
+ * Returns 0 on success, negative error code otherwise.
  */
 static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 				struct page *old_page, struct page *new_page)
@@ -166,10 +168,12 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 
 	VM_BUG_ON_PAGE(PageTransHuge(old_page), old_page);
 
-	err = mem_cgroup_try_charge(new_page, vma->vm_mm, GFP_KERNEL, &memcg,
-			false);
-	if (err)
-		return err;
+	if (new_page) {
+		err = mem_cgroup_try_charge(new_page, vma->vm_mm, GFP_KERNEL,
+					    &memcg, false);
+		if (err)
+			return err;
+	}
 
 	/* For try_to_free_swap() and munlock_vma_page() below */
 	lock_page(old_page);
@@ -177,15 +181,20 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 	mmu_notifier_invalidate_range_start(&range);
 	err = -EAGAIN;
 	if (!page_vma_mapped_walk(&pvmw)) {
-		mem_cgroup_cancel_charge(new_page, memcg, false);
+		if (new_page)
+			mem_cgroup_cancel_charge(new_page, memcg, false);
 		goto unlock;
 	}
 	VM_BUG_ON_PAGE(addr != pvmw.address, old_page);
 
-	get_page(new_page);
-	page_add_new_anon_rmap(new_page, vma, addr, false);
-	mem_cgroup_commit_charge(new_page, memcg, false, false);
-	lru_cache_add_active_or_unevictable(new_page, vma);
+	if (new_page) {
+		get_page(new_page);
+		page_add_new_anon_rmap(new_page, vma, addr, false);
+		mem_cgroup_commit_charge(new_page, memcg, false, false);
+		lru_cache_add_active_or_unevictable(new_page, vma);
+	} else
+		/* no new page, just dec_mm_counter for old_page */
+		dec_mm_counter(mm, MM_ANONPAGES);
 
 	if (!PageAnon(old_page)) {
 		dec_mm_counter(mm, mm_counter_file(old_page));
@@ -194,8 +203,9 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 
 	flush_cache_page(vma, addr, pte_pfn(*pvmw.pte));
 	ptep_clear_flush_notify(vma, addr, pvmw.pte);
-	set_pte_at_notify(mm, addr, pvmw.pte,
-			mk_pte(new_page, vma->vm_page_prot));
+	if (new_page)
+		set_pte_at_notify(mm, addr, pvmw.pte,
+				  mk_pte(new_page, vma->vm_page_prot));
 
 	page_remove_rmap(old_page, false);
 	if (!page_mapped(old_page))
@@ -488,6 +498,10 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe, struct mm_struct *mm,
 		ref_ctr_updated = 1;
 	}
 
+	ret = 0;
+	if (!is_register && !PageAnon(old_page))
+		goto put_old;
+
 	ret = anon_vma_prepare(vma);
 	if (ret)
 		goto put_old;
@@ -501,8 +515,30 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe, struct mm_struct *mm,
 	copy_highpage(new_page, old_page);
 	copy_to_page(new_page, vaddr, &opcode, UPROBE_SWBP_INSN_SIZE);
 
+	if (!is_register) {
+		struct page *orig_page;
+		pgoff_t index;
+
+		VM_BUG_ON_PAGE(!PageAnon(old_page), old_page);
+
+		index = vaddr_to_offset(vma, vaddr & PAGE_MASK) >> PAGE_SHIFT;
+		orig_page = find_get_page(vma->vm_file->f_inode->i_mapping,
+					  index);
+
+		if (orig_page) {
+			if (PageUptodate(orig_page) &&
+			    pages_identical(new_page, orig_page)) {
+				/* let go new_page */
+				put_page(new_page);
+				new_page = NULL;
+			}
+			put_page(orig_page);
+		}
+	}
+
 	ret = __replace_page(vma, vaddr, old_page, new_page);
-	put_page(new_page);
+	if (new_page)
+		put_page(new_page);
 put_old:
 	put_page(old_page);
 
-- 
2.17.1

