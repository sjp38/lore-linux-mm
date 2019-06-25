Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 07EBAC48BD6
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 23:53:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B22FD208E3
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 23:53:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="RtFUfJbt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B22FD208E3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 774698E0005; Tue, 25 Jun 2019 19:53:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6FDDB8E0003; Tue, 25 Jun 2019 19:53:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 579968E0005; Tue, 25 Jun 2019 19:53:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2D2D28E0003
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 19:53:37 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id u9so1499441ybb.14
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 16:53:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=YzvayIkmd6XFy7Z87fb6rHJsaY4AzAfNVKftttxQWf8=;
        b=EJ5XhjT6ND+fUjP2cMPpLKwfmCLSBNM5CU+RFLTqphubLibqKk1yBdZ0kKZpVHh+FQ
         7lxTVzEOGeSfl2W62zTTu10I07aRpDnl07+AgiX8H1HAzzuDxjm/3VZzdRAkgTwz6ZPJ
         cJ5ZObCJY3/hFFATAcnHhSO3qUoR+R+yEr8eyTFgtxlEdLMEZlSZ5730tWmSB0PkASa9
         bvrBAA1Oq5oDhhQG/uy/hbvMEzrBbVsJuslmxjSTGPDfJLFXlVaK7TwbgG6j/l7wVcDC
         AUnbu8YqEmfy/xE2fluKEYV1RFWHTagtNeETCDB6HDx1YiBHtnwTtAq7efZl4238l+Ss
         S9mQ==
X-Gm-Message-State: APjAAAW/NECB75ppQfeYFUQIXUSXcqX4etMT/uAKZxvNsd25BarSjoUC
	m5Glhwmwkswvf4dsyjEk0/9bhGoVOHQc9R0NJMhI1yf3o6j2BruvwZj3g7hO7Fp6quqNRTELtq8
	kf3m3Ev71hjuwthtIwlkxC/KoHv6SdHgChRx/4aqxucgt2m/h7KSqLFygitSxuKUJEw==
X-Received: by 2002:a81:6082:: with SMTP id u124mr940757ywb.241.1561506816981;
        Tue, 25 Jun 2019 16:53:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzM4kfLnDKHmszK4Tp3bZDDPe3amNZWKaDjVg9s6wX0KJPtCE8ErPCvM+DmrQQNLqogso45
X-Received: by 2002:a81:6082:: with SMTP id u124mr940741ywb.241.1561506816455;
        Tue, 25 Jun 2019 16:53:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561506816; cv=none;
        d=google.com; s=arc-20160816;
        b=yF/m69YG/L61UKZJyEizQbcBGYpGjLsFYNYdrftK0PPK9UfewADM1RmIgvf5L2jDRd
         X5Qgx6yXGZnXVDVMNgKlM+A5loB0exMBQ3FZKttOpeG7aZmpofK5I87sB0rKNao9xnYF
         uhsJVLRVfPe5PzWnmTZQlEPgMhj91f7Inz8FjKqCSsabO6AfUOQai1kXnmupmr6EeIuF
         v/8djaE2dBexJsHgik+uHe0ErEX6IQfANRCC+hSADn2McgJBKPOZ7MPvacyHBz2POvZj
         keNjDXccueh+2nWMxaP8vHuKAWUeJZk4FejwJNocQl/4HGGjEKjQ6gJrW0JY3Blp1pCb
         pDfg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=YzvayIkmd6XFy7Z87fb6rHJsaY4AzAfNVKftttxQWf8=;
        b=WWaD2/ziW1qYVmY4PiFVHARIr3xOM5dLx5JVtcEJ826sDu8bCupDppFAEe5KlzoRfN
         3e2iR/XBZjXFkPGgV5bnYSRsmlAmaLG1eCl3pKWLG0LMlw3sC8u4EWWqlKK30GenILMz
         YMNFyzM/49X7sVU1AFjNqCEnZ2CaBxqWhC+e/KENS8UOFRoegFuGJpitSPNv4V+nA//W
         Mt6HLOuh/wUJ/MzBpkswNwK5jUw0WxC1fVNecPRVaH8hQkQ0qu57yWea0NMBnXLWaZLg
         hW8S8UmOR1F9Ue2xW6efo93Eq1yzH24O91UhPhsmmvkzGGA24Qsm+MUf36BAXZRA6CXL
         e4bw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=RtFUfJbt;
       spf=pass (google.com: domain of prvs=1079b839a8=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1079b839a8=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id y16si5549304ybg.452.2019.06.25.16.53.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 16:53:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1079b839a8=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=RtFUfJbt;
       spf=pass (google.com: domain of prvs=1079b839a8=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1079b839a8=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5PNqLO5027784
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 16:53:36 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=YzvayIkmd6XFy7Z87fb6rHJsaY4AzAfNVKftttxQWf8=;
 b=RtFUfJbt1MHzqzGshzQevaSsS2nNZVwt0uHkXeJMVYRCMDWfT9/sHO4ZkpKJErfWounv
 rM3hcwLXV41yESC+6Al8uHVRA2kz7lhWvvuV13Gr9e3xWFf8bzvlsc7uhDYkH8tw0wjq
 nWZ/PHEQqcdCOkQq3rYX/anPuq8acBF39ZQ= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0b-00082601.pphosted.com with ESMTP id 2tbqn21enk-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 16:53:36 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:82::f) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Tue, 25 Jun 2019 16:53:35 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id BCEF762E1F8B; Tue, 25 Jun 2019 16:53:34 -0700 (PDT)
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
Subject: [PATCH v7 2/4] uprobe: use original page when all uprobes are removed
Date: Tue, 25 Jun 2019 16:53:23 -0700
Message-ID: <20190625235325.2096441-3-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190625235325.2096441-1-songliubraving@fb.com>
References: <20190625235325.2096441-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-25_16:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906250196
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

