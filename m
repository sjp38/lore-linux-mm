Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DAE41C7618F
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 21:59:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9941121849
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 21:59:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9941121849
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4B0146B0007; Wed, 17 Jul 2019 17:59:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4394A6B000A; Wed, 17 Jul 2019 17:59:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2DB2A8E0001; Wed, 17 Jul 2019 17:59:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id EAA756B0007
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 17:59:57 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id t18so5445191pgu.20
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 14:59:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=0q3n2ME2A0WBx2Hhy0HNQT8g5UQwULlqyspL3BepubM=;
        b=dxn0QOCtSAH5ahe6R7IsiGvI+9Xf0dzWiFCdj62wmhZ8pD3z1Vk2sao8yffIcwETbS
         vqT49ojRlRw9puz9oeJ6OsbJiTnqgKLdpwjzES0GmxFqj7CNEzDbHXPTzUQN6MvFi43+
         51F+WOThWMudPwN23qOWnzZb7pXdytreSxd5v+Bxfu1eY9Wn048/8hM0WM0wiGQUXuxp
         T2YwGDZfx9N7KvilrHcg8aBTYxB3mYR7beWGbqmjjzjCBrr/UkB8yMdkl1L0pGuAn2Bm
         dbCQhQCUL+r89runDBRBXUOqb7qBRHoXyev2Yk9PAOv6DHP6LBuDYpJdUDUt/ChuBOo3
         +KHw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAW3T6IvvmqBFHBmSiRHyPTLjCSbN2kWdiNgtQqK9puczDLwtNvf
	JCbwKJc2u3TQLu3hpe9ofMJ+k28TsqGmqaRSgGxYIdH/Woo2NU5HuwoGt5pWy57AJko8UHhpE8i
	iIbkBhJRFUn5O58iErFDdRVjQLc3/33rJzFE8JypAza3TLncFu40sC+OI2IduOUJWTA==
X-Received: by 2002:a17:90a:8984:: with SMTP id v4mr46619207pjn.133.1563400797628;
        Wed, 17 Jul 2019 14:59:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyAbx/kpLoSZQkE4+P3fQlRNHKbt3KD09aftcu2lSZqJYIY7lkq+4jf6wkfcLb2VrM/QoX4
X-Received: by 2002:a17:90a:8984:: with SMTP id v4mr46619124pjn.133.1563400796499;
        Wed, 17 Jul 2019 14:59:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563400796; cv=none;
        d=google.com; s=arc-20160816;
        b=JVOPPBhH2e1JHogmvUMUGV/N9d4oqixjtkUYjlwZtYdDtOmmD5+t7A52TOOFdxrpRw
         +QlrBg98lxlMCPt6FvprD3NfydUZlsKJWzX8pPuJakZoIzd0NvRjYl6R3n9CZ4J3B3SQ
         CLci9NXWkarTficJDarZ6R1QFBcxYTBZScwcz6VZJJ6m+oSVHhxRVvC1VtHJCZp9duVp
         m9988b6D1watzmHvOPWdnCjQt9nQKTI56lKQFuF1XEoGCwAId0dUjJD1PUqwZ4CJLTvJ
         S6vm7xFleDdhF2fBo/WPlYl55MxDW3kr0XelbwW4jqv+C0WjYPCOC5L/6hJnQO/DbrYU
         V8cA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=0q3n2ME2A0WBx2Hhy0HNQT8g5UQwULlqyspL3BepubM=;
        b=u9AHCU6T+RzOijs2i0/XuO8EZeEp65NDuVhZzQ9N8RWHfwBBQOj2Vx6Cv9JDrnrLkk
         XO7gNctOBlDmm327UbUBvuHHjzC5gP0dAjUOLwDcaXAidZBdSaPH5NZyFlRY3cTfSQTN
         zeKk4mdx3n8EeqGkZ8Uc0KhX80FZHKMNrXDOlM0kDXz0LFJrAvZsI7vB0U5W/Xp/KBmZ
         hkugrGuLHiIZkDjZB/F1VjOUPymfFDwclHQ4QWBvSsmKVWvviP74ATx/du8kh9d1paSM
         VxCrs8HNw51EXa3yTtp7l7RKb53lfcKWvfTiTPtTRF+Vfu4cS35yCcsxKPvSB+hLXjLR
         EVyw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id n20si23465473plp.395.2019.07.17.14.59.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 14:59:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) client-ip=47.88.44.36;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R631e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04446;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=9;SR=0;TI=SMTPD_---0TX9KWw9_1563400771;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TX9KWw9_1563400771)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 18 Jul 2019 05:59:38 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: hughd@google.com,
	kirill.shutemov@linux.intel.com,
	mhocko@suse.com,
	vbabka@suse.cz,
	rientjes@google.com,
	akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [v4 PATCH 1/2] mm: thp: make transhuge_vma_suitable available for anonymous THP
Date: Thu, 18 Jul 2019 05:59:17 +0800
Message-Id: <1563400758-124759-2-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1563400758-124759-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1563400758-124759-1-git-send-email-yang.shi@linux.alibaba.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The transhuge_vma_suitable() was only available for shmem THP, but
anonymous THP has the same check except pgoff check.  And, it will be
used for THP eligible check in the later patch, so make it available for
all kind of THPs.  This also helps reduce code duplication slightly.

Since anonymous THP doesn't have to check pgoff, so make pgoff check
shmem vma only.

And regroup some functions in include/linux/mm.h to solve compile issue since
transhuge_vma_suitable() needs call vma_is_anonymous() which was defined
after huge_mm.h is included.

Cc: Hugh Dickins <hughd@google.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: David Rientjes <rientjes@google.com>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 include/linux/huge_mm.h | 23 +++++++++++++++++++++++
 include/linux/mm.h      | 34 +++++++++++++++++-----------------
 mm/huge_memory.c        |  2 +-
 mm/memory.c             | 13 -------------
 4 files changed, 41 insertions(+), 31 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 7cd5c15..45ede62 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -121,6 +121,23 @@ static inline bool __transparent_hugepage_enabled(struct vm_area_struct *vma)
 
 bool transparent_hugepage_enabled(struct vm_area_struct *vma);
 
+#define HPAGE_CACHE_INDEX_MASK (HPAGE_PMD_NR - 1)
+
+static inline bool transhuge_vma_suitable(struct vm_area_struct *vma,
+		unsigned long haddr)
+{
+	/* Don't have to check pgoff for anonymous vma */
+	if (!vma_is_anonymous(vma)) {
+		if (((vma->vm_start >> PAGE_SHIFT) & HPAGE_CACHE_INDEX_MASK) !=
+			(vma->vm_pgoff & HPAGE_CACHE_INDEX_MASK))
+			return false;
+	}
+
+	if (haddr < vma->vm_start || haddr + HPAGE_PMD_SIZE > vma->vm_end)
+		return false;
+	return true;
+}
+
 #define transparent_hugepage_use_zero_page()				\
 	(transparent_hugepage_flags &					\
 	 (1<<TRANSPARENT_HUGEPAGE_USE_ZERO_PAGE_FLAG))
@@ -271,6 +288,12 @@ static inline bool transparent_hugepage_enabled(struct vm_area_struct *vma)
 	return false;
 }
 
+static inline bool transhuge_vma_suitable(struct vm_area_struct *vma,
+		unsigned long haddr)
+{
+	return false;
+}
+
 static inline void prep_transhuge_page(struct page *page) {}
 
 #define transparent_hugepage_flags 0UL
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0389c34..beae0ae 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -541,6 +541,23 @@ static inline void vma_set_anonymous(struct vm_area_struct *vma)
 	vma->vm_ops = NULL;
 }
 
+static inline bool vma_is_anonymous(struct vm_area_struct *vma)
+{
+	return !vma->vm_ops;
+}
+
+#ifdef CONFIG_SHMEM
+/*
+ * The vma_is_shmem is not inline because it is used only by slow
+ * paths in userfault.
+ */
+bool vma_is_shmem(struct vm_area_struct *vma);
+#else
+static inline bool vma_is_shmem(struct vm_area_struct *vma) { return false; }
+#endif
+
+int vma_is_stack_for_current(struct vm_area_struct *vma);
+
 /* flush_tlb_range() takes a vma, not a mm, and can care about flags */
 #define TLB_FLUSH_VMA(mm,flags) { .vm_mm = (mm), .vm_flags = (flags) }
 
@@ -1629,23 +1646,6 @@ static inline void cancel_dirty_page(struct page *page)
 
 int get_cmdline(struct task_struct *task, char *buffer, int buflen);
 
-static inline bool vma_is_anonymous(struct vm_area_struct *vma)
-{
-	return !vma->vm_ops;
-}
-
-#ifdef CONFIG_SHMEM
-/*
- * The vma_is_shmem is not inline because it is used only by slow
- * paths in userfault.
- */
-bool vma_is_shmem(struct vm_area_struct *vma);
-#else
-static inline bool vma_is_shmem(struct vm_area_struct *vma) { return false; }
-#endif
-
-int vma_is_stack_for_current(struct vm_area_struct *vma);
-
 extern unsigned long move_page_tables(struct vm_area_struct *vma,
 		unsigned long old_addr, struct vm_area_struct *new_vma,
 		unsigned long new_addr, unsigned long len,
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 885642c..782dd14 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -689,7 +689,7 @@ vm_fault_t do_huge_pmd_anonymous_page(struct vm_fault *vmf)
 	struct page *page;
 	unsigned long haddr = vmf->address & HPAGE_PMD_MASK;
 
-	if (haddr < vma->vm_start || haddr + HPAGE_PMD_SIZE > vma->vm_end)
+	if (!transhuge_vma_suitable(vma, haddr))
 		return VM_FAULT_FALLBACK;
 	if (unlikely(anon_vma_prepare(vma)))
 		return VM_FAULT_OOM;
diff --git a/mm/memory.c b/mm/memory.c
index 89325f9..e2bb51b 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3162,19 +3162,6 @@ static vm_fault_t pte_alloc_one_map(struct vm_fault *vmf)
 }
 
 #ifdef CONFIG_TRANSPARENT_HUGE_PAGECACHE
-
-#define HPAGE_CACHE_INDEX_MASK (HPAGE_PMD_NR - 1)
-static inline bool transhuge_vma_suitable(struct vm_area_struct *vma,
-		unsigned long haddr)
-{
-	if (((vma->vm_start >> PAGE_SHIFT) & HPAGE_CACHE_INDEX_MASK) !=
-			(vma->vm_pgoff & HPAGE_CACHE_INDEX_MASK))
-		return false;
-	if (haddr < vma->vm_start || haddr + HPAGE_PMD_SIZE > vma->vm_end)
-		return false;
-	return true;
-}
-
 static void deposit_prealloc_pte(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
-- 
1.8.3.1

