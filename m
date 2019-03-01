Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8B70C43381
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 03:55:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6EF7A2083D
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 03:55:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6EF7A2083D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 29C6E8E0005; Thu, 28 Feb 2019 22:55:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 24D2F8E0003; Thu, 28 Feb 2019 22:55:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0779D8E0006; Thu, 28 Feb 2019 22:55:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id C5FC78E0005
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 22:55:53 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id f70so17634671qke.8
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 19:55:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Uj2/7/hvO+mGUiC6/YMiCNC0Dm4MVZdRYJZtA6ObxH0=;
        b=S2d9xBOh26/lEq6EkcEz0F3/SwWVxrwuM4JqM5wNwx+MEonufdHgLGKhgkT0+WCh5i
         F16EWe8RWW1W6Ru1p0WRI7wWxtdSRubBiMdwuzf6K3l60kUnWcO0PeYpWxC/rHNd39jM
         eV6jTG6W/IwEb35Xr0LvWOWwxiONdos5A9kPTueudiVKPmcf8PXPYlxxDS19JQoocY2a
         +NtBxP83W0REES7yYMDL0UpJeIoLHav45xVotkDVF3BGqU0lZ0SSHj3tvLXJu/DqGsJ9
         UMD+hEVloS2WP2zh0ps6pXd1v3Qwzm9X/cSeYGR8o81zDYl/oWlmAYDjL7lNWGZFxnQE
         IrXw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU7r7YdqxLbz4OiohgCpdANSRcOy4pYog05uCZHESyFjayhUshC
	xNtjl9dBxJhaepHe/VFvTBtCuzvYFPqxSSMJwnQkMe48DjC2Rvqp45ZL1kJp1hfgPFlI7+0APtH
	u6x86pab6tZf60ngoUd53RhSF/nljjvKlgZI9S7zZVxEQsnmxj0PfVhx0zRLukXo9YA==
X-Received: by 2002:a37:a316:: with SMTP id m22mr2275704qke.194.1551412553557;
        Thu, 28 Feb 2019 19:55:53 -0800 (PST)
X-Google-Smtp-Source: APXvYqw98elfTRy3BKhY5wzCU/QLa4eIUfLILyAYaoJeflP2F404aLg1/shaIHjyMDWsmnBB0PcL
X-Received: by 2002:a37:a316:: with SMTP id m22mr2275673qke.194.1551412552508;
        Thu, 28 Feb 2019 19:55:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551412552; cv=none;
        d=google.com; s=arc-20160816;
        b=rKtQFnhwl1FC8fh1IMRfA9IsDB9+XfVQrPnaDxJxKwkwGQdhF2rKOtHOTTqleHNKjh
         SKxDifgI+qXBetQnS91sX4F1YD/MEfzbiAyWC8FcbFmgjBE+8uU8DRc/aFZqnrsq/TPG
         Pv6ckbJ0PMK7mV4Il5OPW5LNqOz4h4bHynVRIPeDoiXD/Jxzfi/Z8P6SVusC83EEgFtH
         zpTSkp1c8F5FzL0llgtHNr4gV7m7b1graKWrOv01ne3k21pOmyEkPMBujjCwnxZfimNP
         f3PBSur532FKV1NiGrGc6lXSTt4khsHc7FExrvdCreMwBpkPJSNmrP2Vs4ixyu1Ly/FO
         UTmg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=Uj2/7/hvO+mGUiC6/YMiCNC0Dm4MVZdRYJZtA6ObxH0=;
        b=pInTDao/5TmzcnjJabUqQKASUwQPYox42fLoLUkQaHVzrS7YuPBfxurzsISPorj05/
         JAK4nBi7c0GUw4fWnKk52HdXl5D2q7RME4KkaBLzLwx2HOHNzRzr7/VUcWfB0y/LHMcZ
         tyi5GvrseI+qPP0lQijcdHcKAZyaDtdVmDJ4tw3R2XNipWge6aViVsCCSGVmuruthpOI
         rXLHuPcQ88xSzEZPYSmT/eD7APRS1012Kmg5xoxcBOLyoDWnsGKUUMVqfKL+aCYQqoIR
         wLO4L/v2RvKwy27ruUhyExxYLq77NMoklA69JTpw6lsZJidJ5bR/wKY7hkeE/eLteqI0
         Ognw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w25si2091073qtw.214.2019.02.28.19.55.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 19:55:52 -0800 (PST)
Received-SPF: pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id AC56343A49;
	Fri,  1 Mar 2019 03:55:51 +0000 (UTC)
Received: from sky.random (ovpn-121-1.rdu2.redhat.com [10.10.121.1])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 678F01001DE9;
	Fri,  1 Mar 2019 03:55:51 +0000 (UTC)
From: Andrea Arcangeli <aarcange@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org,
	Hugh Dickins <hughd@google.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Michal Hocko <mhocko@suse.com>
Subject: [PATCH 2/2] mm: use READ/WRITE_ONCE to access anonymous vmas vm_start/vm_end/vm_pgoff
Date: Thu, 28 Feb 2019 22:55:50 -0500
Message-Id: <20190301035550.1124-3-aarcange@redhat.com>
In-Reply-To: <20190301035550.1124-1-aarcange@redhat.com>
References: <20190301035550.1124-1-aarcange@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Fri, 01 Mar 2019 03:55:51 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This converts the updates under mmap_sem for reading, rmap lock for
writing and PT lock to vm_start/end/pgoff of anonymous vmas to use
WRITE_ONCE().

This also converts some of the accesses under mmap_sem for reading
that are concurrent with the aforementioned WRITE_ONCE()s to use
READ_ONCE().

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/gup.c      | 23 +++++++++++++----------
 mm/internal.h |  3 ++-
 mm/memory.c   |  2 +-
 mm/mmap.c     | 16 ++++++++--------
 mm/rmap.c     |  3 ++-
 mm/vmacache.c |  3 ++-
 6 files changed, 28 insertions(+), 22 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index 75029649baca..5cac5c462b40 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -699,7 +699,7 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		unsigned int page_increm;
 
 		/* first iteration or cross vma bound */
-		if (!vma || start >= vma->vm_end) {
+		if (!vma || start >= READ_ONCE(vma->vm_end)) {
 			vma = find_extend_vma(mm, start);
 			if (!vma && in_gate_area(mm, start)) {
 				ret = get_gate_page(mm, start & PAGE_MASK,
@@ -850,7 +850,7 @@ int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 
 retry:
 	vma = find_extend_vma(mm, address);
-	if (!vma || address < vma->vm_start)
+	if (!vma || address < READ_ONCE(vma->vm_start))
 		return -EFAULT;
 
 	if (!vma_permits_fault(vma, fault_flags))
@@ -1218,8 +1218,8 @@ long populate_vma_page_range(struct vm_area_struct *vma,
 
 	VM_BUG_ON(start & ~PAGE_MASK);
 	VM_BUG_ON(end   & ~PAGE_MASK);
-	VM_BUG_ON_VMA(start < vma->vm_start, vma);
-	VM_BUG_ON_VMA(end   > vma->vm_end, vma);
+	VM_BUG_ON_VMA(start < READ_ONCE(vma->vm_start), vma);
+	VM_BUG_ON_VMA(end   > READ_ONCE(vma->vm_end), vma);
 	VM_BUG_ON_MM(!rwsem_is_locked(&mm->mmap_sem), mm);
 
 	gup_flags = FOLL_TOUCH | FOLL_POPULATE | FOLL_MLOCK;
@@ -1258,7 +1258,7 @@ long populate_vma_page_range(struct vm_area_struct *vma,
 int __mm_populate(unsigned long start, unsigned long len, int ignore_errors)
 {
 	struct mm_struct *mm = current->mm;
-	unsigned long end, nstart, nend;
+	unsigned long end, nstart, nend, vma_start, vma_end;
 	struct vm_area_struct *vma = NULL;
 	int locked = 0;
 	long ret = 0;
@@ -1274,19 +1274,22 @@ int __mm_populate(unsigned long start, unsigned long len, int ignore_errors)
 			locked = 1;
 			down_read(&mm->mmap_sem);
 			vma = find_vma(mm, nstart);
-		} else if (nstart >= vma->vm_end)
+		} else if (nstart >= vma_end)
 			vma = vma->vm_next;
-		if (!vma || vma->vm_start >= end)
+		if (!vma)
 			break;
+		vma_start = READ_ONCE(vma->vm_start);
+		if (vma_start >= end)
+			break;
+		vma_end = READ_ONCE(vma->vm_end);
 		/*
 		 * Set [nstart; nend) to intersection of desired address
 		 * range with the first VMA. Also, skip undesirable VMA types.
 		 */
-		nend = min(end, vma->vm_end);
+		nend = min(end, vma_end);
 		if (vma->vm_flags & (VM_IO | VM_PFNMAP))
 			continue;
-		if (nstart < vma->vm_start)
-			nstart = vma->vm_start;
+		nstart = max(nstart, vma_start);
 		/*
 		 * Now fault in a range of pages. populate_vma_page_range()
 		 * double checks the vma flags, so that it won't mlock pages
diff --git a/mm/internal.h b/mm/internal.h
index f4a7bb02decf..839dbcf3c7ed 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -337,7 +337,8 @@ static inline unsigned long
 __vma_address(struct page *page, struct vm_area_struct *vma)
 {
 	pgoff_t pgoff = page_to_pgoff(page);
-	return vma->vm_start + ((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
+	return READ_ONCE(vma->vm_start) +
+		((pgoff - READ_ONCE(vma->vm_pgoff)) << PAGE_SHIFT);
 }
 
 static inline unsigned long
diff --git a/mm/memory.c b/mm/memory.c
index 896d8aa08c0a..b76b659a026d 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4257,7 +4257,7 @@ int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 			 * we can access using slightly different code.
 			 */
 			vma = find_vma(mm, addr);
-			if (!vma || vma->vm_start > addr)
+			if (!vma || READ_ONCE(vma->vm_start) > addr)
 				break;
 			if (vma->vm_ops && vma->vm_ops->access)
 				ret = vma->vm_ops->access(vma, addr, buf,
diff --git a/mm/mmap.c b/mm/mmap.c
index f901065c4c64..9b84617c11c6 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2240,9 +2240,9 @@ struct vm_area_struct *find_vma(struct mm_struct *mm, unsigned long addr)
 
 		tmp = rb_entry(rb_node, struct vm_area_struct, vm_rb);
 
-		if (tmp->vm_end > addr) {
+		if (READ_ONCE(tmp->vm_end) > addr) {
 			vma = tmp;
-			if (tmp->vm_start <= addr)
+			if (READ_ONCE(tmp->vm_start) <= addr)
 				break;
 			rb_node = rb_node->rb_left;
 		} else
@@ -2399,7 +2399,7 @@ int expand_upwards(struct vm_area_struct *vma, unsigned long address)
 					mm->locked_vm += grow;
 				vm_stat_account(mm, vma->vm_flags, grow);
 				anon_vma_interval_tree_pre_update_vma(vma);
-				vma->vm_end = address;
+				WRITE_ONCE(vma->vm_end, address);
 				anon_vma_interval_tree_post_update_vma(vma);
 				if (vma->vm_next)
 					vma_gap_update(vma->vm_next);
@@ -2480,8 +2480,8 @@ int expand_downwards(struct vm_area_struct *vma,
 					mm->locked_vm += grow;
 				vm_stat_account(mm, vma->vm_flags, grow);
 				anon_vma_interval_tree_pre_update_vma(vma);
-				vma->vm_start = address;
-				vma->vm_pgoff -= grow;
+				WRITE_ONCE(vma->vm_start, address);
+				WRITE_ONCE(vma->vm_pgoff, vma->vm_pgoff - grow);
 				anon_vma_interval_tree_post_update_vma(vma);
 				vma_gap_update(vma);
 				spin_unlock(&mm->page_table_lock);
@@ -2530,7 +2530,7 @@ find_extend_vma(struct mm_struct *mm, unsigned long addr)
 	if (!prev || expand_stack(prev, addr))
 		return NULL;
 	if (prev->vm_flags & VM_LOCKED)
-		populate_vma_page_range(prev, addr, prev->vm_end, NULL);
+		populate_vma_page_range(prev, addr, READ_ONCE(prev->vm_end), NULL);
 	return prev;
 }
 #else
@@ -2549,11 +2549,11 @@ find_extend_vma(struct mm_struct *mm, unsigned long addr)
 	vma = find_vma(mm, addr);
 	if (!vma)
 		return NULL;
-	if (vma->vm_start <= addr)
+	start = READ_ONCE(vma->vm_start);
+	if (start <= addr)
 		return vma;
 	if (!(vma->vm_flags & VM_GROWSDOWN))
 		return NULL;
-	start = vma->vm_start;
 	if (expand_stack(vma, addr))
 		return NULL;
 	if (vma->vm_flags & VM_LOCKED)
diff --git a/mm/rmap.c b/mm/rmap.c
index 0454ecc29537..d8d06bb87381 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -702,7 +702,8 @@ unsigned long page_address_in_vma(struct page *page, struct vm_area_struct *vma)
 	} else
 		return -EFAULT;
 	address = __vma_address(page, vma);
-	if (unlikely(address < vma->vm_start || address >= vma->vm_end))
+	if (unlikely(address < READ_ONCE(vma->vm_start) ||
+		     address >= READ_ONCE(vma->vm_end)))
 		return -EFAULT;
 	return address;
 }
diff --git a/mm/vmacache.c b/mm/vmacache.c
index cdc32a3b02fa..655554c85bdb 100644
--- a/mm/vmacache.c
+++ b/mm/vmacache.c
@@ -77,7 +77,8 @@ struct vm_area_struct *vmacache_find(struct mm_struct *mm, unsigned long addr)
 			if (WARN_ON_ONCE(vma->vm_mm != mm))
 				break;
 #endif
-			if (vma->vm_start <= addr && vma->vm_end > addr) {
+			if (READ_ONCE(vma->vm_start) <= addr &&
+			    READ_ONCE(vma->vm_end) > addr) {
 				count_vm_vmacache_event(VMACACHE_FIND_HITS);
 				return vma;
 			}

