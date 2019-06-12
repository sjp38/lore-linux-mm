Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D965C31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 22:06:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C656B20B7C
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 22:06:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="nIbNa+YY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C656B20B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 785716B026B; Wed, 12 Jun 2019 18:06:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 70EF66B026C; Wed, 12 Jun 2019 18:06:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5D6E46B026D; Wed, 12 Jun 2019 18:06:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2685C6B026B
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 18:06:39 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id k36so7802635pgl.7
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 15:06:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=qKr0k6k4xZHZmykxLb47XrFO0p8RI9jBEYkCbTeGgSI=;
        b=DMbliIZ2wc+egBwvLU7K+7oi5ZezlZeacDoJ3ygFbosK/Bd5B0cyLaaToF68/o4XrT
         2/BXih1gri/D8SJ4FdD90uQ8z+5KC74HrLLspqYxt8ZJ4LP/YR/HX/E5fa/UE+nkU0Ba
         00HrBVZy5BaN3fiS7eGPKLvbltm9Nl2uVMJgI0n1SORGLtfUc3eqiXppjA0+NN6xk53N
         8b6zKS1dLaU4kpD4BTDs6Mk4kwLUNs2J4msOZ1Hun4oUTq9Fys2mz6XU3xQBNp5tKZ2m
         YFzrb+sbyuW9xsom3IJVmrepoKjFZWhlZwxbot7xR7IG/NJ46S5H4AIt238fAJZMntD1
         i9kQ==
X-Gm-Message-State: APjAAAVFz14n3PeCErOsY56Op71d3wKAaavbkQZzSetS1dmGHxL+xco/
	8IIQNSoekydC2eRSyX1wH5rkR3AHVlaUFciSLGZ0Af568W5tpVJ53klRlHnEGGAxZLWr9mO9eVo
	ytkLEHJopCJLFdI83QTbkhh5F0PRICF76Koei8igbMTrUKPGB/Untg8prA4xdU07QUQ==
X-Received: by 2002:a17:902:2ae8:: with SMTP id j95mr46055196plb.276.1560377198678;
        Wed, 12 Jun 2019 15:06:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxmhYzMYqYU94+HbGEvMNpUHZXRPXtesZT0DTUe/Tlx/qzUc6Ng5xSbhb31/VtHCMNAztGW
X-Received: by 2002:a17:902:2ae8:: with SMTP id j95mr46055158plb.276.1560377197919;
        Wed, 12 Jun 2019 15:06:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560377197; cv=none;
        d=google.com; s=arc-20160816;
        b=Lhi05Qtvy0p4nGRK6Vu2xjMgNIi4w3Mu4Cqgm6vj4ryosImGptEn2uzNUh0ZmmnINE
         0cdbpzL4V72RVabCKrU336RuiVRdJIOd+iXHy6VsgGfwhgIahCfP58pB85xUuGHgLW+B
         dZmzZGlfNQLFqs8XYVm/AQ1gkB6tjPVGrRdO0lmj9L84o/g9HRy9w9H2pusTjxVOy99Q
         ZgUuEH3+RArtbTUxSTwujO04Erq1qR1QdFDkOM14sYucDLpT/S1SC4FDCFq8Gx+xuosq
         gCrH9nrkznmXfedFvnkilCMAKPjRbT8nq5qLHk3g0gZO+TIKavouRnr66sX7mZWFaa+b
         cMeQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=qKr0k6k4xZHZmykxLb47XrFO0p8RI9jBEYkCbTeGgSI=;
        b=HsNm1bCErmZRI7wPvGBC788Est5ROmcQGgSZcaqV9r12aPxgQsi8gB2jYt6L/OuorN
         eMAoPkoLPIz3TJTTP1+0lsSD/qhydV8JMjbK5BbBErwPZ2NsG0bkC5iBZK5r8ml++lfW
         xvDk/5mj9dc/wpiZJfaTOEPpuhBqj9eDDGB+K12jHVJOuAuifLLAxnh8BuaQMVM4nBNO
         H2ub5XMJy09S1pib47GbP9BtglB2s6Vu91epz93w9ePUbcFHPvBv9fwvxdIXbsEdncfk
         5u7bd4xHIpO3lvwzXFqBcBU6RyNzusmumzTWkI/SP6wVOpwClk5gnPQIVKLwtPIXD/j3
         jy6w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=nIbNa+YY;
       spf=pass (google.com: domain of prvs=106696cf5d=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=106696cf5d=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id s1si853396pgs.62.2019.06.12.15.06.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 15:06:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=106696cf5d=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=nIbNa+YY;
       spf=pass (google.com: domain of prvs=106696cf5d=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=106696cf5d=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148461.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5CM3E9j000799
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 15:06:37 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=qKr0k6k4xZHZmykxLb47XrFO0p8RI9jBEYkCbTeGgSI=;
 b=nIbNa+YYFSAy1ydAmHbF7duS/BDB/NT5auxXJafV3HyQhLjCJy1OblKjxSDOHQDNXn91
 aD4nuqRR0JromRfkZJ3rD4uwnCO5EEuqBwiRvhz6C1x/mE/cSlXl0Yq4wL4t33pHfsgR
 gUotB+3tufuOhPDnR0SnXAV0IjoClztmHhM= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2t34g8s94u-8
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 15:06:37 -0700
Received: from prn-hub02.TheFacebook.com (2620:10d:c081:35::126) by
 prn-hub06.TheFacebook.com (2620:10d:c081:35::130) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Wed, 12 Jun 2019 15:06:23 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::126) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Wed, 12 Jun 2019 15:06:17 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id CFA9262E2CC4; Wed, 12 Jun 2019 15:03:35 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>
CC: <namit@vmware.com>, <peterz@infradead.org>, <oleg@redhat.com>,
        <rostedt@goodmis.org>, <mhiramat@kernel.org>,
        <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <kernel-team@fb.com>, Song Liu
	<songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v3 2/5] uprobe: use original page when all uprobes are removed
Date: Wed, 12 Jun 2019 15:03:16 -0700
Message-ID: <20190612220320.2223898-3-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190612220320.2223898-1-songliubraving@fb.com>
References: <20190612220320.2223898-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-12_13:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=974 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906120153
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

