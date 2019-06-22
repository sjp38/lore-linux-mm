Return-Path: <SRS0=rpDk=UV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B650C43613
	for <linux-mm@archiver.kernel.org>; Sat, 22 Jun 2019 00:01:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B560620881
	for <linux-mm@archiver.kernel.org>; Sat, 22 Jun 2019 00:01:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="EpfTC14a"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B560620881
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 698DC8E0008; Fri, 21 Jun 2019 20:01:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 649778E0001; Fri, 21 Jun 2019 20:01:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 539BE8E0008; Fri, 21 Jun 2019 20:01:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1D8B38E0001
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 20:01:43 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id s195so4985155pgs.13
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 17:01:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=qKr0k6k4xZHZmykxLb47XrFO0p8RI9jBEYkCbTeGgSI=;
        b=sfj3uhY4FAgfB7NxkAoXwtNea8pZ1dxoL9euDEx5grDsfjYvjTGxuJukhQCuPuiVH0
         /zWMPHNP6pvyC5oZDxF2iHKI5LqXatXdkJ7ZSkCeZxIgr6pJEi2pH8iD4f2sapQ1YKbu
         sPvjSMGgdFPDqxy2Oec41qGjCuVhLWsxAadZP65AmXfbsfXQfLIjL2i8NHQHcZCte1iV
         AoUCKChTYQ7yZpeh3BGpI2D8dqULcoCgFZ0Flj0s0PyoVyjLvc/PPj92/iV5tF4mRdaV
         6Kn53VLls2axgYrEO5QLEf2rybPMd02V8EXZ7XWWOKTNZp3S3twHbk59lIigLPke4Nrs
         SP1A==
X-Gm-Message-State: APjAAAU8MFc1MvCX4xmzqsdPPA8MOzGLoxoyOtwfWjA3MOwFqsHfX5Rs
	mEyo4acIq936XV99LHNoFtAU7/35oFlUhNYeeFtA1Tgtgxw2r4Ae4oDpmB674cr2p6bFRHD0uKl
	xzNNFytgZ66Av5gtjq9kNoV4fl/Qd7DH/sPKh6eukCNkny95DqYOEtwhYzcU9BVFCHQ==
X-Received: by 2002:a17:90a:a00d:: with SMTP id q13mr9802592pjp.80.1561161702730;
        Fri, 21 Jun 2019 17:01:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxDuyGb2qE8vxWyIfRUfa2Bs6G/aEUj/o0D+Hf/lSMxUUdodrqW+NC8sRMYHVQyz2zvf0S7
X-Received: by 2002:a17:90a:a00d:: with SMTP id q13mr9802539pjp.80.1561161702094;
        Fri, 21 Jun 2019 17:01:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561161702; cv=none;
        d=google.com; s=arc-20160816;
        b=n3tncKq78wCLTMM4gRlyFsypRO2aK+SQG4Q1IyuEOrn4YqQER9uduNod0To00/DgjN
         z4gQfxO7flOAU11SqXI2nxmG+41AqfomliKzgn1OoB13QT3B1gXXOm/9EnOY6hoi+hLR
         eIlGSp37fV7RNG34zEGs0RHmc+tMFFfQEXSvV6j9DEbfxEBe9oShk79WId+jrc3G7T2m
         TRLJYVmfy7GquA8rhv2LNors9xXLk7G6mhyO9oFc2v7SdKOld+Ky4uJkPkW0MDMEUtkz
         uCX52JdseRWENcPom2ydluefYnGvSgHC7P8B3sve9AaroyISRhpFI+cmNVGTGmRrC+yh
         VE6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=qKr0k6k4xZHZmykxLb47XrFO0p8RI9jBEYkCbTeGgSI=;
        b=FK9oD/P5QrVnZm7voxN6NI/VS1sB/6mOOuYimOns/XWIgJZ8ElbLfgCU3Xbc46U9tr
         kgqNBNOtCx6wRk67JpVNO92b7XooHpNnco/raJ0JsjE9kJj/j68EAt1LejsjvGVOYika
         Aoq77/ePV0bIsm/0N8G2BIue5/NuB79mMn5KHVs5vS8n8ERl9/4UbraBpMztkjZL1u4m
         f/oYyrmsSFnNAKVnp+c4jDkfqHKG44G6AMY9qPJCHTNBQYp/dJSapAM9Q09lakDT5fFB
         2wr9AfmQ1seZuXP7sH1dkNQddE3mfJmjGcOGOfICEU0BF3oAgPJPXTY7j8nBry4IYay6
         CLIg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=EpfTC14a;
       spf=pass (google.com: domain of prvs=1076a8f7d5=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1076a8f7d5=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id h32si4180894pld.402.2019.06.21.17.01.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 17:01:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1076a8f7d5=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=EpfTC14a;
       spf=pass (google.com: domain of prvs=1076a8f7d5=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1076a8f7d5=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148461.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5LNr924018757
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 17:01:41 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=qKr0k6k4xZHZmykxLb47XrFO0p8RI9jBEYkCbTeGgSI=;
 b=EpfTC14aDequsN24ugMVjz7cSVSmNk/9t1KWhsJJOj4AW/9APHs+9tK0sHr1h0KeLCRc
 hLhyS9GSaaJ+LXrNaoDykrEtFxZ2mhqh7WVPiilxuY2wsF3UJwVtlJLWhfochv5C9bof
 UtZsoJbO05yxTdznP+nAq7KAONnGflnalAo= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2t90est208-9
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 17:01:41 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::130) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Fri, 21 Jun 2019 17:01:22 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id CAA2862E2D56; Fri, 21 Jun 2019 17:01:20 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <peterz@infradead.org>, <oleg@redhat.com>, <rostedt@goodmis.org>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        Song Liu
	<songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v5 2/5] uprobe: use original page when all uprobes are removed
Date: Fri, 21 Jun 2019 17:01:06 -0700
Message-ID: <20190622000109.914695-3-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190622000109.914695-1-songliubraving@fb.com>
References: <20190622000109.914695-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-21_16:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=996 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906210182
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

