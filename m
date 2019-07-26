Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7A7E0C7618B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 05:53:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 323BC21743
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 05:53:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="cYGzbKEh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 323BC21743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9D8336B0007; Fri, 26 Jul 2019 01:53:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9897A6B0008; Fri, 26 Jul 2019 01:53:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7DB878E0002; Fri, 26 Jul 2019 01:53:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 44AB26B0007
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 01:53:01 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id j22so32441916pfe.11
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 22:53:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=qTMkWMk4VGQx15sS5BtWy4Evstd/NFMwWYqYg0rQQA8=;
        b=aQo2qP07Nad6/drJ9XqA+zobHnJRtJ5q1fEezYgKHzSN5FexQkVIkogEQ0EwiTe/zc
         Nnx4IwrsnEQ7G7Mfv/MMAhf0qvUlF6Bcp/NPJhJio1OlYV30kDb/vFOu3tsety6giU8V
         hyxnRax7enGyJOYLETZtJ7e6kDdgYJObuvXC+jmO/CFbBf2jw2d6fhrpX+mBxH0+ITDe
         BiJn1Yzv1b6E6XXYgWIp2wkEFg2y0WjCuWOfhxu93GE7i4ZA9S7WkkBwxyJTDKnG9PSU
         iM2tpGlAbiAa7Jqq4hbFoTWV2txmxm8pXLOcRf+5GPvdPR4lns+tVgghaFZv4cbgnQU6
         4/eA==
X-Gm-Message-State: APjAAAXkS3hbMgYYg0rJatTDa50vo88Q5ovXhMkALto6vMevo7ZZ9jtH
	qXP8UQ7gzLY5vHOF/4KyrclWQS8sYnT4TgPeIwXEkens0Ec5spCjFVdP9/EV+TTpF5JMMI+Vc0U
	I1UEwDMxiE5ZVXDhtFe/CY8WmjrGZcoOrHY0d6Zb1AeAzqSEVyw7Uzf4xbZY0/cnhdA==
X-Received: by 2002:a63:4a51:: with SMTP id j17mr89499590pgl.284.1564120380623;
        Thu, 25 Jul 2019 22:53:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxhTjrvdMtayzeeqZd24C1Rwwv1kl05YttbkVaUtTWrFIy97kttEHKE4HFP7HzcRCH+dbUd
X-Received: by 2002:a63:4a51:: with SMTP id j17mr89499540pgl.284.1564120379809;
        Thu, 25 Jul 2019 22:52:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564120379; cv=none;
        d=google.com; s=arc-20160816;
        b=J35cwoaQXaU8BCg/KiBEzS5jNT7lP5WHRe4MZu+cP3U3Lir11Y6aqwMiX9/bOB++NW
         /W9ll5L/0QTLTHcu4X7xvVegGP76Q8MOyNzprggt+F249UuOpcxCBGyvs8fLYVQ56pjT
         jDOpKfWLH+vFWMhYWfzCifJzJVqPuIEwr9II/L81Tl3IKu/G1lU448RZoj9vax7jbP95
         7z8SsLOZhBz6S67YXTDl75a0vpAcqUfJGmXhpwlhM1GyS1bN6Ba1PRFG9XUvlWzeFYGK
         ojcrjw7zyYvuf5p5SvTfApcKfA1fyyGGk6YJHBmMvgbwTTfY3+SXbq8oVeXv1Q5S/jVa
         MxJg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=qTMkWMk4VGQx15sS5BtWy4Evstd/NFMwWYqYg0rQQA8=;
        b=xcojd9VR+G2BQKIxsaTaOLvQsAJ1JicSzVNjK1cqezfw8yNZOlA6YpkmN1Fib2IZm6
         zNlnPFWSkzvJ2+/xQhgWCJ6BJKXGPDa/7OHibJw0LR5EJKHx6cNwZif2n+pRm0QZ2pNp
         LZkjI7m1bzYN42sGPsZKYnXVNSBuhNoekw9fDuwQp4/HYyjHsK3Dbvdxw89jANy5vJum
         XLFfBL81rbnU+9EWpHY8nc9uX9q2xRK5DOk5ZwpzTP3ISNnCkuYcIedKnWYDeexJXbGR
         9gTqQucXf/5N7kZlNetdz1HBDFiyFtWPskRDgNv49LeCmkMwQ4FfzGPOAgcoWI2rUC0K
         O2vw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=cYGzbKEh;
       spf=pass (google.com: domain of prvs=21101f516b=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=21101f516b=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id s7si20805442plp.66.2019.07.25.22.52.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 22:52:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=21101f516b=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=cYGzbKEh;
       spf=pass (google.com: domain of prvs=21101f516b=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=21101f516b=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148461.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6Q5qvM5004139
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 22:52:59 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=qTMkWMk4VGQx15sS5BtWy4Evstd/NFMwWYqYg0rQQA8=;
 b=cYGzbKEhyWdo5VGRzg3veJjaKtBljDnewaFyiPtQAT0cQP0/2xtTcUCQv7I9A4x2zhyj
 +5vWux/EE1EclvSSYmiXepfDnY1CJDqmZuzpHDeijhe5kd3atWSUkNLQKQHNo7TKLc4R
 pCU4HExRdkwdNCUnCsWcmf5PobbanIE+9hQ= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2tyqae8pwg-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 22:52:58 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:83::4) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Thu, 25 Jul 2019 22:52:53 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id C109A62E300E; Thu, 25 Jul 2019 22:47:14 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>,
        <akpm@linux-foundation.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <peterz@infradead.org>, <oleg@redhat.com>, <rostedt@goodmis.org>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        <srikar@linux.vnet.ibm.com>, Song Liu <songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v9 2/4] uprobe: use original page when all uprobes are removed
Date: Thu, 25 Jul 2019 22:46:52 -0700
Message-ID: <20190726054654.1623433-3-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190726054654.1623433-1-songliubraving@fb.com>
References: <20190726054654.1623433-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-26_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=891 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1907260078
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
 kernel/events/uprobes.c | 62 +++++++++++++++++++++++++++++++----------
 1 file changed, 47 insertions(+), 15 deletions(-)

diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 84fa00497c49..bd248af7310c 100644
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
@@ -177,15 +181,18 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
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
+	}
 
 	if (!PageAnon(old_page)) {
 		dec_mm_counter(mm, mm_counter_file(old_page));
@@ -194,8 +201,9 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 
 	flush_cache_page(vma, addr, pte_pfn(*pvmw.pte));
 	ptep_clear_flush_notify(vma, addr, pvmw.pte);
-	set_pte_at_notify(mm, addr, pvmw.pte,
-			mk_pte(new_page, vma->vm_page_prot));
+	if (new_page)
+		set_pte_at_notify(mm, addr, pvmw.pte,
+				  mk_pte(new_page, vma->vm_page_prot));
 
 	page_remove_rmap(old_page, false);
 	if (!page_mapped(old_page))
@@ -501,8 +509,32 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe, struct mm_struct *mm,
 	copy_highpage(new_page, old_page);
 	copy_to_page(new_page, vaddr, &opcode, UPROBE_SWBP_INSN_SIZE);
 
+	/* try orig_page only for unregister and anonymous old_page */
+	if (!is_register && PageAnon(old_page)) {
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
+				/* let go new_page */
+				put_page(new_page);
+				new_page = NULL;
+
+				/* dec_mm_counter for old_page */
+				dec_mm_counter(mm, MM_ANONPAGES);
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

