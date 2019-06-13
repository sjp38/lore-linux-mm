Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1A3B1C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 17:58:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C9E3920645
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 17:58:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="LRAuwhpR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C9E3920645
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C78A88E0002; Thu, 13 Jun 2019 13:58:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ABE0E8E0006; Thu, 13 Jun 2019 13:58:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C16F8E0002; Thu, 13 Jun 2019 13:58:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5A7C08E0004
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 13:58:02 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id p18so6113997ywe.17
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 10:58:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=qKr0k6k4xZHZmykxLb47XrFO0p8RI9jBEYkCbTeGgSI=;
        b=eideOYUhc5+MxBIN1l8yAXO1dgs/6YkiGhHT9/2NtChDOLVYDefdK91Ho7dWhTN7wx
         uVuueKp2LLolQ+pa56lR5X3KkRohScXoEwOfBEExvdCZGzn0BcmpdHZ+GyyWOKw/U0lI
         K+ONYt2R0kcQkE0yM9lJKyXugx7l+4vXKe3pTeVyrrixOMED0KbHICqu8+4nIwWX2Y5Y
         /y0/6TW/qAb47rxoYjki/U9kDSYWydHXQAj3JQyQ4woT2yhvhe1EvYAjU2ofNc8FY+fM
         6ZuTlwWSmVuCxwcR3kcuiHthwxxJjbckqHFII1CS+hk49MHTLjXZSpfUEeNXtztVf3/1
         t2Cg==
X-Gm-Message-State: APjAAAVT9Z660i68NaVYAumCYaXp0A3dh9LGyNFPw6KkoGWkrYSf0tky
	0O2RG6emWxbbB+qBf/7LQbBbwI4a8hp0Z/NJS6UulvlGsg2ZMSh4yiO1L4Q09QVs6MDFsaFNu36
	d59VTqyhuZn+e5MpCPSi8SWwVqzDRixmESRokd8JumkGd1LdBl76RNWVlhyXuK7Ev9g==
X-Received: by 2002:a81:84cb:: with SMTP id u194mr2708974ywf.297.1560448682101;
        Thu, 13 Jun 2019 10:58:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyJ8cpVcA+TuEFWEvR0U78HJLOjq1v2vBuH1gcmBe9Xxm1SS1UskSbwIUfYjn8bttX0A/jd
X-Received: by 2002:a81:84cb:: with SMTP id u194mr2708951ywf.297.1560448681595;
        Thu, 13 Jun 2019 10:58:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560448681; cv=none;
        d=google.com; s=arc-20160816;
        b=PQMu5xys93nxhWRucMTz171VhYP28qWgQ3v79pzLQdzdGexkupLQw+j1XO3nAq0kM/
         1fFP65jV5CtbJBH7dCebJCyrmrXGTEmFP+/mNVs223fhYJ1MyfRdHDHwFCy53jRPCkYZ
         YsXyhLznEyl+CKAOOaBZyIPvSp05Lgy3F/mfwpr+whBRlamgt88EPDL6V1k72eGX5ErY
         TUriejVajUV6m+XdawPLph3tkVTJ7Olec99jhJhaWxzJ53iRcBV3/AKXhL6Xj0DtKTVo
         5J2gRIajJPWdFDBUU4VzSp45/5IIg2pBsHeUQ8R5G8PX6wPqhBv6akELYT0vRxM6a50X
         gDkA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=qKr0k6k4xZHZmykxLb47XrFO0p8RI9jBEYkCbTeGgSI=;
        b=deDO5HQvITi3NZz5k4p/77amyR8MjBssbcXAjwwiTTtmBjvwR94TZN15jwlr5/etMq
         UHbhyxEmO9OWyhRRgfj8Rz79iHZILic8e4oTO4jJNTu6cfUaOy/tUpGevYJwzM0H/ifd
         MoYx9aJD3Qpt8qPZARLwwbc4QcJ+RKIvL1Fof6hOQIH8qZjz8xU9O1dQZca47+YBFEl7
         zkCJnIjZ+ZRBKINuZ6GHDz9NI5L2fiZ1Mogt9wVcRZhiDdosDW3MBnZXQull4rfw+woM
         HrKf3oORQaerQvKEex1hYBAUOAfhWpZPFK8s0K6dlMcCFN9jvFBcVOU9bsV3sfn5xxAD
         BWJg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=LRAuwhpR;
       spf=pass (google.com: domain of prvs=1067aa1dbb=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1067aa1dbb=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id 201si218264yws.178.2019.06.13.10.58.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 10:58:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1067aa1dbb=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=LRAuwhpR;
       spf=pass (google.com: domain of prvs=1067aa1dbb=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1067aa1dbb=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5DHvvTC009155
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 10:58:01 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=qKr0k6k4xZHZmykxLb47XrFO0p8RI9jBEYkCbTeGgSI=;
 b=LRAuwhpRLdF4NIyM7KSUny260aIUcNCUFEtuZn1db7kJn38FgQfHqB/k4yoVQXMs4bws
 i0VfK22s2wa8aj+9YtUT/oMagjWVVP1gj2OZWjGJ6w4y+SvUDOTPUwXZOpj7y2emxVTl
 5wZElCSmAv2Kza/lGl6l+uTFfhlekmhwLgY= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2t3pr5h370-13
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 10:58:01 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::126) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Thu, 13 Jun 2019 10:58:00 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id A55C062E1C18; Thu, 13 Jun 2019 10:57:58 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>
CC: <oleg@redhat.com>, <rostedt@goodmis.org>, <mhiramat@kernel.org>,
        <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <kernel-team@fb.com>, Song Liu <songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v4 2/5] uprobe: use original page when all uprobes are removed
Date: Thu, 13 Jun 2019 10:57:44 -0700
Message-ID: <20190613175747.1964753-3-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190613175747.1964753-1-songliubraving@fb.com>
References: <20190613175747.1964753-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-13_12:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=987 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906130132
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
 kernel/events/uprobes.c | 45 +++++++++++++++++++++++++++++++++--------
 1 file changed, 37 insertions(+), 8 deletions(-)

diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 78f61bfc6b79..f7c61a1ef720 100644
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
@@ -501,6 +513,23 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe, struct mm_struct *mm,
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
+			if (pages_identical(new_page, orig_page)) {
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

