Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 593EDC7618F
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 08:38:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 13BAE227BF
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 08:38:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="n29xeY+n"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 13BAE227BF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6A9556B0005; Wed, 24 Jul 2019 04:38:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 682918E0002; Wed, 24 Jul 2019 04:38:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 500AE6B0008; Wed, 24 Jul 2019 04:38:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id F177C6B0005
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 04:38:20 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id e20so28097063pfd.3
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 01:38:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=Sr6wWULEM6szvGRjJ+9iWCVQfCXAA0jyuXknznuqFcU=;
        b=LfYZo0OXcIHFGErw1BDv+MCZG8S1BCFGkmUYp/WedCGA+//xRk6UqvUs3W1VCbwH1j
         iyzIqOmJE33DcWa1Wjt5wVHWCexdqsjDIbWFa5vIArxtjoEM1jxYIOZet1AOaCFCjuQJ
         5cQ+BuxBR5V7+yH6Uaiud6lOlfxJFZZV2TULGiCdyrCCxEAyrD9ZDkZYzOlKDft4rXEX
         9CA2yH9ripNXyU7FQJeX4KmDfAl/esestNwSaN+1hl27ZjpMJBFDSoDcpqzxmTE7hT+i
         aAQtXPgCoOiumtpfCzUagKI7IY1oFp24/LmUolECdK/8Ne+cyZqwY73yGriFxztkPQXH
         GKJw==
X-Gm-Message-State: APjAAAWxPYo7lTf6UO23KMXv++KMzDZx4uGbArVB0TOqGKFdvIm7D/JT
	lsXqV+zfDPx1Qo6viNid345WK+JeYBB5XxmOzZ5YLnAh/sCaYMcthqQPDlJps2m+obGlAZLJOs3
	LVjUqBt5HIl/rgXfcrrbsptqdwDy94t4PNecRzIOnjMl5z5ol8vEjMBoRS0UViz0uwQ==
X-Received: by 2002:a17:90a:28e4:: with SMTP id f91mr83730812pjd.99.1563957500665;
        Wed, 24 Jul 2019 01:38:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzgoBTIJ3TSxHqDWyKt3GQJ/f6aY79Ppi7ab5U8TSY8XdOolZjifPDX2h8iz5lqzXJkdyKU
X-Received: by 2002:a17:90a:28e4:: with SMTP id f91mr83730772pjd.99.1563957499993;
        Wed, 24 Jul 2019 01:38:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563957499; cv=none;
        d=google.com; s=arc-20160816;
        b=RSgivD/PbkPCh6aeg2v9iG3mNJ/11mr2evXXXfH60vBU3fAlih7Jd2gzZ6rLfehPLO
         KyFzCvN2b0MIbjlvb59MTvNBznug7SPaExMO2lO+RSiZ+PjJZgTwEQNrN1fLsNDFBNYF
         bcuUFsKL5SfgzThJS2o4c6hfDHr4ld6l5mMclJWvfqgKx6WX99nrCaOP3p38zLAJPcHr
         0m4bHrOhNIK1Hw44jIDvUD0duW2Xt2w8KJHj+9FFLyJcVTrZUsAw4vp0ID2VeCsfoWjN
         t3kQ2wCwrHjaE4Tw1KtC3MF/Pe0aB5zSwtN7pvCqACfaHt3CYVmnqfIplvG/Lef8DWwz
         Hvzw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=Sr6wWULEM6szvGRjJ+9iWCVQfCXAA0jyuXknznuqFcU=;
        b=Zg/ZejPzW0RT+D9msZx0+NDqmCTfhlX2ccyt6pz7xY+KOYgGF8RxgGfkO6EtPmh7qq
         NlYLi0UO1M4dlhlO4ZEmyVawZzYzEXvtOWk2BK7zoJVEJUCEpNbwiQ3c7H07AX1SHzba
         MvrbUnKcF75Miidl4BwCyTPSXFqdccT+2IGBMO9LhVX8GNm1ImFfd7oruFCzB8heuOuV
         bnr46Exl2MjZWx3rEkoD4kUHcmgZkkhtapjd7TVWblNcv1OCRYsKna/yyOkySh4Y9b1Y
         EOAvFb9LOhgCqIcXGobqjZUbnjarF9SehZMJ5oXy59YMUID1yluHMraqhgx/b+17r9k9
         zIXw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=n29xeY+n;
       spf=pass (google.com: domain of prvs=21083052e4=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=21083052e4=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id q10si13324994pgf.529.2019.07.24.01.38.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 01:38:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=21083052e4=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=n29xeY+n;
       spf=pass (google.com: domain of prvs=21083052e4=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=21083052e4=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109334.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6O8bZ9x021055
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 01:38:19 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=Sr6wWULEM6szvGRjJ+9iWCVQfCXAA0jyuXknznuqFcU=;
 b=n29xeY+nC4EEVyYZoBVoxKpz0ZfB2ImFgpNVh0tUTMPZVR4x5UOfhkFp/BEIjk7hLtjU
 uG3kE4/BSwPmxryOnjEoDe2UObAVMmf+1Z3TZDcAcvrYsu9WjjoSiyaGo8b6MFx70tti
 bhDPx3oMj8WwxWgv81q5MsKqHnzIZFSD9zQ= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2txe7x91w8-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 01:38:19 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:83::5) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Wed, 24 Jul 2019 01:38:17 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id E96BC62E30DB; Wed, 24 Jul 2019 01:36:11 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>,
        <akpm@linux-foundation.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <peterz@infradead.org>, <oleg@redhat.com>, <rostedt@goodmis.org>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        Song Liu
	<songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v8 2/4] uprobe: use original page when all uprobes are removed
Date: Wed, 24 Jul 2019 01:35:58 -0700
Message-ID: <20190724083600.832091-3-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190724083600.832091-1-songliubraving@fb.com>
References: <20190724083600.832091-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-24_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=970 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1907240097
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
on the page are already removed).

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reviewed-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Signed-off-by: Song Liu <songliubraving@fb.com>
---
 kernel/events/uprobes.c | 46 ++++++++++++++++++++++++++++++++++-------
 1 file changed, 38 insertions(+), 8 deletions(-)

diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 84fa00497c49..6b217bd031ef 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -160,16 +160,19 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 	int err;
 	struct mmu_notifier_range range;
 	struct mem_cgroup *memcg;
+	bool orig = new_page->mapping != NULL;  /* new_page == orig_page */
 
 	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, 0, vma, mm, addr,
 				addr + PAGE_SIZE);
 
 	VM_BUG_ON_PAGE(PageTransHuge(old_page), old_page);
 
-	err = mem_cgroup_try_charge(new_page, vma->vm_mm, GFP_KERNEL, &memcg,
-			false);
-	if (err)
-		return err;
+	if (!orig) {
+		err = mem_cgroup_try_charge(new_page, vma->vm_mm, GFP_KERNEL,
+					    &memcg, false);
+		if (err)
+			return err;
+	}
 
 	/* For try_to_free_swap() and munlock_vma_page() below */
 	lock_page(old_page);
@@ -177,15 +180,24 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 	mmu_notifier_invalidate_range_start(&range);
 	err = -EAGAIN;
 	if (!page_vma_mapped_walk(&pvmw)) {
-		mem_cgroup_cancel_charge(new_page, memcg, false);
+		if (!orig)
+			mem_cgroup_cancel_charge(new_page, memcg, false);
 		goto unlock;
 	}
 	VM_BUG_ON_PAGE(addr != pvmw.address, old_page);
 
 	get_page(new_page);
-	page_add_new_anon_rmap(new_page, vma, addr, false);
-	mem_cgroup_commit_charge(new_page, memcg, false, false);
-	lru_cache_add_active_or_unevictable(new_page, vma);
+	if (orig) {
+		lock_page(new_page);  /* for page_add_file_rmap() */
+		page_add_file_rmap(new_page, false);
+		unlock_page(new_page);
+		inc_mm_counter(mm, mm_counter_file(new_page));
+		dec_mm_counter(mm, MM_ANONPAGES);
+	} else {
+		page_add_new_anon_rmap(new_page, vma, addr, false);
+		mem_cgroup_commit_charge(new_page, memcg, false, false);
+		lru_cache_add_active_or_unevictable(new_page, vma);
+	}
 
 	if (!PageAnon(old_page)) {
 		dec_mm_counter(mm, mm_counter_file(old_page));
@@ -501,6 +513,24 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe, struct mm_struct *mm,
 	copy_highpage(new_page, old_page);
 	copy_to_page(new_page, vaddr, &opcode, UPROBE_SWBP_INSN_SIZE);
 
+	if (!is_register) {
+		struct page *orig_page;
+		pgoff_t index;
+
+		index = vaddr_to_offset(vma, vaddr & PAGE_MASK) >> PAGE_SHIFT;
+		orig_page = find_get_page(vma->vm_file->f_inode->i_mapping,
+					  index);
+
+		if (orig_page) {
+			if (PageUptodate(orig_page) &&
+			    pages_identical(new_page, orig_page)) {
+				put_page(new_page);
+				new_page = orig_page;
+			} else
+				put_page(orig_page);
+		}
+	}
+
 	ret = __replace_page(vma, vaddr, old_page, new_page);
 	put_page(new_page);
 put_old:
-- 
2.17.1

