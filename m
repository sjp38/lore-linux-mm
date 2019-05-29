Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,UNWANTED_LANGUAGE_BODY,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9507C28CC0
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 21:37:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6BD8424223
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 21:37:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="leQ/opXV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6BD8424223
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 282246B026E; Wed, 29 May 2019 17:36:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 10DEE6B0272; Wed, 29 May 2019 17:36:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E0DF16B0274; Wed, 29 May 2019 17:36:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 84B806B026E
	for <linux-mm@kvack.org>; Wed, 29 May 2019 17:36:54 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id i8so2854993pfo.21
        for <linux-mm@kvack.org>; Wed, 29 May 2019 14:36:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=vH2HloBkxs0E6y5mQ4CjNY7e4RAkgwr31RBvR6O3DQc=;
        b=cTasGexP+GlezuLmbCDCqlsCpBcQs3YUqdgdJTIJggvgzTWayYlSiIwTNtsR+BnxjF
         5uDdiiPhedY7x2cwKnnAXPMs/23aU/tCaKVoce9WpZGeQVm9cTBGrYWqr+Q0fujUUYjS
         s/+q0TBVYTk2bW5bmN1O0i6TbKM7pduXXaXhl7T12sbsd4XPwKnCLAV5la0btlpV4GKh
         s0O953c85yB+j+bU7b7D05vo05h+pS0zet0wpCzaJZWuDjJTkuKHEbCiGLFK0CQXzTfA
         cqXAbwR0npTQLekeOIVqj+aBZkgZM3cpfkPtR3zMZpree9Xeq1V5bZuKSTij9H6ksOxM
         OJuA==
X-Gm-Message-State: APjAAAWg7o/VPReIv5XtErHLeqXoQFsSa7ox364toXhK/SI7VV7MHuty
	b2cWZ4tJ7U5ETOpHJTkI5SFtZJhgND2xfc9JWqbR94nlqF1snhvfNi+Vfp7pnaXG4Z6nJ+rMhmz
	OmS1z4p4bur+ki2fTQyQv01R43IFTJMHAQJbIDrXtYpvHnw2//Km4O92AicW0bMn+4A==
X-Received: by 2002:a17:902:ab98:: with SMTP id f24mr25035plr.223.1559165814041;
        Wed, 29 May 2019 14:36:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxuuHkRRTDwkP0+suyjTsMzBKFH7LISuUJ9CnWZjw89Tuo7YiJgHrtnrYSTDlDLKx7pHe3e
X-Received: by 2002:a17:902:ab98:: with SMTP id f24mr24987plr.223.1559165813033;
        Wed, 29 May 2019 14:36:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559165813; cv=none;
        d=google.com; s=arc-20160816;
        b=Do6y24gSrtET62eMRSeYq6nsL8/5TyY9z75FgHCFR41f8Ijsg6n43IQA8JH1s2RGnl
         K5eGgh0L5n+I5wg4obsyi7QnzrY75QhrG2JY3Wsr/InWXID5W2P8faKi8n/M4Axh6Ajf
         M1zrZx1HFwRZDnwQnR13oJ/FgFwiHEIZQbBAPqCi8RYtYRbWMDaHOWOK+l8IBKQdSaB7
         Hk8XF/bREzJEIXXWky27LQeeFcgB+rnRi/hPodxVielLUSbLeCPflwrf0GCu2jHf/fD9
         41MzVI1OLrJlst3zhvgvPtFAybItoRc1hgL0jDNpzSYGzAWfn/VF/QCAm5F5whUqlQRo
         La4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=vH2HloBkxs0E6y5mQ4CjNY7e4RAkgwr31RBvR6O3DQc=;
        b=QGJg8USfC/x4CvkxRcnv3Vu17mr7LDxRGhNj8QbpCZ1r/FB2K+pqzeYQHpZUnSOdGz
         HRCtz5KbtmENfrY1GRVWEm47Pv7RIIE4VHMxVDZw1G+HjImgL07fX0PP9om69sLYFwu/
         NPFe/t3Ku6OgVG2XtFcDEdbFOe7DupLqKUvQQABYKcz7YuO/kRkDrpQ9IR+H0qcr6Iax
         qhDeB8J3MMCnY4cyimcCLiZfq+I2I9wa8Qv1nsEDROatPrCExE74clNPw43tJerT8fuH
         t6us2H7awG0BBLi11qfd0DpWSOB8JYC3jpavaC3eC1RzPxpIIlKq3mOgZeltgO5By86Q
         iSAw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="leQ/opXV";
       spf=pass (google.com: domain of prvs=105246f206=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=105246f206=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id p7si903989pgh.497.2019.05.29.14.36.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 May 2019 14:36:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=105246f206=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="leQ/opXV";
       spf=pass (google.com: domain of prvs=105246f206=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=105246f206=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148461.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4TLXFaE029780
	for <linux-mm@kvack.org>; Wed, 29 May 2019 14:36:52 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=vH2HloBkxs0E6y5mQ4CjNY7e4RAkgwr31RBvR6O3DQc=;
 b=leQ/opXVYpqVUDrxSdj4Ktb74UjnKrLbSU4Q57tkH+Tr8ZlEQE8x7tcWa2DqRRneIB6v
 W5K/0bzvmab0GSW6VbzFxHczPg7EevoFPI2JeUZc7zgyigmd+qtUkTo1UYgWgJxtsI20
 Kdm2ZOn+1azQzr3ZPEXJLQNhUgLy5Q/vLFo= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2ssqq9jb6r-12
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 29 May 2019 14:36:52 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::129) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Wed, 29 May 2019 14:36:48 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id E135662E2076; Wed, 29 May 2019 14:21:16 -0700 (PDT)
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
Subject: [PATCH uprobe, thp 2/4] uprobe: use original page when all uprobes are removed
Date: Wed, 29 May 2019 14:20:47 -0700
Message-ID: <20190529212049.2413886-3-songliubraving@fb.com>
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

Currently, uprobe swaps the target page with a anonymous page in both
install_breakpoint() and remove_breakpoint(). When all uprobes on a page
are removed, the given mm is still using an anonymous page (not the
original page).

This patch allows uprobe to use original page when possible (all uprobes
on the page are already removed).

Signed-off-by: Song Liu <songliubraving@fb.com>
---
 kernel/events/uprobes.c | 43 ++++++++++++++++++++++++++++++++---------
 1 file changed, 34 insertions(+), 9 deletions(-)

diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 78f61bfc6b79..ba49da99d2a2 100644
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
@@ -177,15 +180,22 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
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
+		page_add_file_rmap(new_page, false);
+		inc_mm_counter(mm, mm_counter_file(new_page));
+		dec_mm_counter(mm, MM_ANONPAGES);
+	} else {
+		page_add_new_anon_rmap(new_page, vma, addr, false);
+		mem_cgroup_commit_charge(new_page, memcg, false, false);
+		lru_cache_add_active_or_unevictable(new_page, vma);
+	}
 
 	if (!PageAnon(old_page)) {
 		dec_mm_counter(mm, mm_counter_file(old_page));
@@ -461,9 +471,10 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe, struct mm_struct *mm,
 			unsigned long vaddr, uprobe_opcode_t opcode)
 {
 	struct uprobe *uprobe;
-	struct page *old_page, *new_page;
+	struct page *old_page, *new_page, *orig_page = NULL;
 	struct vm_area_struct *vma;
 	int ret, is_register, ref_ctr_updated = 0;
+	pgoff_t index;
 
 	is_register = is_swbp_insn(&opcode);
 	uprobe = container_of(auprobe, struct uprobe, arch);
@@ -501,6 +512,20 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe, struct mm_struct *mm,
 	copy_highpage(new_page, old_page);
 	copy_to_page(new_page, vaddr, &opcode, UPROBE_SWBP_INSN_SIZE);
 
+	index = vaddr_to_offset(vma, vaddr & PAGE_MASK) >> PAGE_SHIFT;
+	orig_page = find_get_page(vma->vm_file->f_inode->i_mapping, index);
+	if (orig_page) {
+		if (memcmp(page_address(orig_page),
+			   page_address(new_page), PAGE_SIZE) == 0) {
+			/* if new_page matches orig_page, use orig_page */
+			put_page(new_page);
+			new_page = orig_page;
+		} else {
+			put_page(orig_page);
+			orig_page = NULL;
+		}
+	}
+
 	ret = __replace_page(vma, vaddr, old_page, new_page);
 	put_page(new_page);
 put_old:
-- 
2.17.1

