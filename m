Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2AACFC433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 23:37:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D3A2D20880
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 23:37:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="bpp63PKW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D3A2D20880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 69B9D6B0008; Wed,  7 Aug 2019 19:37:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 64D666B000A; Wed,  7 Aug 2019 19:37:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5164A6B000C; Wed,  7 Aug 2019 19:37:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 19A326B0008
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 19:37:40 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id b18so56538191pgg.8
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 16:37:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=i6y9YuM25PmZvfyze3uwWL3WudRVKnCnrUVAiWkqwhw=;
        b=qhHgXBo+OrnyhHMeUAVfFmxKdTwm0BUrQvLoh5iP4HD6UX0kLqkkKjfFLbxHcAd+79
         qntvPrblB9/lj7rpTumw0L7oPiEYvWrGWzwQSIrQyL4c8JLEHptQTi0SvgNWvTHcMjR0
         BQKBojIUhQC26zNwv8ALa844xfCiu5ifRbjUNaWgmoLhFO5IIY4l1LUVpgFDAkUM6LfW
         W3F2fHz5WXmlX7rwT4XIi04MSrjLcPWSFPn/YnhvLUhwJS16Xt06xO8AHL0JwcnC8JZH
         9QRLRk535L40ryPW0qndIcHgQcAjVSMG09WzjbNek2YRPUp0inQC1syawbB2gROgRKuo
         FUDw==
X-Gm-Message-State: APjAAAU9bdGxOslnMaPA3Wgap4XpVeOlamgaK5YUBvhiMkk0XFB8VqYi
	ITJm5M2R3caIQR/Cdk4fXCSfURw23WZs4fpU6CSvB3A3/xAEkRuofBd0DBMeIDIYmd1KTN70Apy
	t73/ZfdUX3UxMkABlJ34wku51SGuz1wuuMwQk/7/z6vdSAjrAp/UoymLXoS2JNEAplg==
X-Received: by 2002:a17:90a:5884:: with SMTP id j4mr952747pji.142.1565221059711;
        Wed, 07 Aug 2019 16:37:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxGGlHo5lJAJXYDtOpTyf70Uhy2I14WcupaaAk7zMuBp2anrgriLhosw8y/lNQkhdgBwRUe
X-Received: by 2002:a17:90a:5884:: with SMTP id j4mr952692pji.142.1565221058791;
        Wed, 07 Aug 2019 16:37:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565221058; cv=none;
        d=google.com; s=arc-20160816;
        b=U3FNiXgSwiXDfWOt1xvOk93317MQhLT34qOolAw9RZteXwrnJvB/cdMP2blpkOaKaT
         x2wdR186hxWLblEUHroz+GwjsPnVzOL8/NXHdI3pHZ49Ek4ViCX5tJAZcy27kag7xyGV
         DGhuYNP0ZH8C4PoTw4K10DYaR07hbpTrO/M3S8Uvn6Ih4fYog0Y+IW4uXlZISlRLES5V
         P/UskXZDNbf5AVe4lPDEy1I/6igAicQtTO8VQocbnUABnCrYXbJjn7tTM3mbtBVznMwp
         7G8hIY/VBt6Ur62F2IBNpc2+Q1zCwa3Y5bsSWTyxr1H8YdqXbP3PtiTqLrhWuiXp21IC
         tXCA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=i6y9YuM25PmZvfyze3uwWL3WudRVKnCnrUVAiWkqwhw=;
        b=pvP/LQm9cnKRJpTpV95sgQboNWQOCIY53YwhIMplJp8bwvXmJ7KmEdGVCaMGFCvw7m
         XrNO/OiDTjIcy3F9FTGPtWvc0NPTvOr3eCK52lsKfGxhFpe0jwCwvUe+cQp2yd1nAkj7
         QOHMwfwRmXcx1iebW396nJ1CU3idU+QPs4y8riHzO/fVXTXo7LFxXjzqqW1Z+p8qb0pR
         1g+Al4o/3Dq2ypsLPbVb9HPDgoVyGi3OS6xXs8Gy0+yUGIcQPutOc3wcfrdmSr2PkxQK
         Y4sEExRWZtc3XQf5POhZYZ1wt3fU8sfH1a3IgZ2KUos0mw+lIv77rM/bGTadrJsw61V8
         llhA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=bpp63PKW;
       spf=pass (google.com: domain of prvs=31225916b7=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=31225916b7=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id g24si51361346pfi.119.2019.08.07.16.37.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 16:37:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=31225916b7=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=bpp63PKW;
       spf=pass (google.com: domain of prvs=31225916b7=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=31225916b7=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x77NZ1TG031673
	for <linux-mm@kvack.org>; Wed, 7 Aug 2019 16:37:38 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=i6y9YuM25PmZvfyze3uwWL3WudRVKnCnrUVAiWkqwhw=;
 b=bpp63PKWsG2+WIjAGLPTp20V2vkMPg1W0rHosWw7cWWyRbR7K2CIjvInurtiSWuPSOBz
 UYflakVwnggiwLhplauukSIm7Cc1Ar5vmU1wdsc5M2KSJWHsj+++YlBq1Mq3dE7Puwpr
 +yG3PKVTReooHvg4Q5S18V19vVsNzsAntHI= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2u87ufg4d8-6
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 07 Aug 2019 16:37:38 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:83::6) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Wed, 7 Aug 2019 16:37:37 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 1AA3862E2D9E; Wed,  7 Aug 2019 16:37:37 -0700 (PDT)
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
Subject: [PATCH v12 2/6] uprobe: use original page when all uprobes are removed
Date: Wed, 7 Aug 2019 16:37:25 -0700
Message-ID: <20190807233729.3899352-3-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190807233729.3899352-1-songliubraving@fb.com>
References: <20190807233729.3899352-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-07_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=949 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908070208
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

