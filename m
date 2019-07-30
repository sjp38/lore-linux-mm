Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6AFCC433FF
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 19:31:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5A8C6206A2
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 19:31:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="gUV4eGhv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5A8C6206A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EFED08E0005; Tue, 30 Jul 2019 15:31:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EB0AB8E0001; Tue, 30 Jul 2019 15:31:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D76728E0005; Tue, 30 Jul 2019 15:31:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id B852E8E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 15:31:15 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id b63so48509395ywc.12
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 12:31:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:mime-version;
        bh=i6y9YuM25PmZvfyze3uwWL3WudRVKnCnrUVAiWkqwhw=;
        b=fL+jwTbvzb/I64sNYJvLh1TYldY+q+MrjqbSH15XEJ2mQc63XdD6kaYAbrrLsOxBbK
         481FYbRezo/7wmzD84eUyiZTcTOX12mz9ApTjfy1okW7CNknsznUBVOeKi1H0LaOh5BD
         9d2ToC1VNFzf6zemJIkSoKCIhphf9O+290V/if+U39cw9uirtLMdQYwiz2Cp2rr3RUxl
         W0hkV6uu/NtilI7X+xBkPyKyN7NTSa1BmIi/O7u2Yh7GN98aITB1q582CKNehax1ouD1
         HQ2Sqi/uujI2C3vLOkdMNiP5KgqH2rasJTRgDc0jxfz2K9VMGdyRDEslqmmezHWrQ8GH
         V7nA==
X-Gm-Message-State: APjAAAXBbDWjazARv5evLqlSv0IZmRztXBH6o1purWMMaN1ogaNpmGTJ
	DoDqCSHFj2Fk+ULKzpTBrjYCHEwVipNrKMzDt/6EPjSUS9vVEJfhGuY4Vj+SKREkdXo61d+E6wD
	U6bdtwCEnyjaZJCe0AOHVxzrQ0iSyanEnjCZpFRfLW/Z9Rvu6e9lUM2XodpxW1LGuGQ==
X-Received: by 2002:a25:5f02:: with SMTP id t2mr32386796ybb.448.1564515075485;
        Tue, 30 Jul 2019 12:31:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyLuXGiE7O2qWM1dGfH6Kol01GGGU6Oeau93REjt4bQ06D6eG7J4DuEZtSD4DYa3aOcicBp
X-Received: by 2002:a25:5f02:: with SMTP id t2mr32386741ybb.448.1564515074638;
        Tue, 30 Jul 2019 12:31:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564515074; cv=none;
        d=google.com; s=arc-20160816;
        b=xVXHpl4ppNhihbHT+MIny1JaK/8mKOZChD+WMYqKPB7ed3ltrMob53giifpBF4nCkq
         0BLkt0MrwWdFBaM5ejtbe0fRjP1Wb2sDW0Tydm32x0Nw7OTcsByM+Z6nB5/k+DkXCEwk
         nwnz6ZXu6iMxK5eifUYZI/7Cs92OO68Wluy8Cl3K4dLzJ4Ckl5tKhWV/OKPkvqko2Rbb
         Yi24c8yIsp1Vl6olQXyUQw48KrSWwwaQRN4MRED7ZIDUD/5GfeN+GpL7PPjpU3KPessv
         iKDzE5OSZdr8STJhWzTOgq6gXomZuya480CvusX+1r/LiyM8PCzRxv07/fAmopRZ9D1L
         7ANA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:smtp-origin-cluster:cc:to
         :smtp-origin-hostname:from:smtp-origin-hostprefix:dkim-signature;
        bh=i6y9YuM25PmZvfyze3uwWL3WudRVKnCnrUVAiWkqwhw=;
        b=AI//YEJmt/JM4dvpFcga+o0tQLVZ2wqQU6G1OZbA7DbOWXCZbp7uc79NNc7/v9shvP
         dOXURRVb1o1Su+KKAR24BodwT/mu1SWuCCiR4djySqAuZ65oX+7qWdS7yHTLpcU1A4O+
         h0U5RIYPEVOJM/6Kldy7yvi0xABqZo4ljoa3RT46XgGxUFslRhppXs693V41DTa3vQZ/
         DKyO91P92p+vrvDgMO/Ht3O9G1qmDQF/ensPYdaAmPh90MzSSZfc047wXS4+GsWvKybY
         nuTLy4ZQTBur5FovvKR9JmEba5KgpK46J0b30l5E/wp4aLcr0/m1pi4HZYpWTcY6PL31
         /ayg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=gUV4eGhv;
       spf=pass (google.com: domain of prvs=31148e3214=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=31148e3214=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id b12si23556191ybn.297.2019.07.30.12.31.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 12:31:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=31148e3214=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=gUV4eGhv;
       spf=pass (google.com: domain of prvs=31148e3214=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=31148e3214=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6UJR9Gk020523
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 12:31:14 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : mime-version : content-type; s=facebook;
 bh=i6y9YuM25PmZvfyze3uwWL3WudRVKnCnrUVAiWkqwhw=;
 b=gUV4eGhvcLCGYPWZ3ZzQEw2juJ9XcR+14c8ClxZHxITn54FARz36fRhMmu8qPUKh8LfI
 le0Orbrmm2kiSXF8cA4sjuDE5D1uEtbnVjp2tqP71/K8gYPEI3dG5bLDqLgR8hzp7ck7
 lwHNWDf7ZfKVu65siTSskJX6Fvdz9YZSVW8= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 2u2uy0r15n-7
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 12:31:14 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::126) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Tue, 30 Jul 2019 12:31:09 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 2CA4F62E1D35; Tue, 30 Jul 2019 12:31:06 -0700 (PDT)
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
Subject: [PATCH v11 2/4] uprobe: use original page when all uprobes are removed
Date: Tue, 30 Jul 2019 12:30:59 -0700
Message-ID: <20190730193100.2295258-1-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-30_09:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=892 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1907300196
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
on the page are already removed, and the original page is in page cache
and uptodate).

As suggested by Oleg, we unmap the old_page and let the original page
fault in.

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

