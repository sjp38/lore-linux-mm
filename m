Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 31F72C76195
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 17:21:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E09E221874
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 17:21:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E09E221874
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2DDD76B0006; Fri, 19 Jul 2019 13:21:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 28E066B0008; Fri, 19 Jul 2019 13:21:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 155BB8E0001; Fri, 19 Jul 2019 13:21:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id CE91D6B0006
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 13:21:32 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id j12so16144864pll.14
        for <linux-mm@kvack.org>; Fri, 19 Jul 2019 10:21:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=Q5UKXC7LYiMDqx8x3fw7Vx9X9Hz8iQ9GRljmGU74pSM=;
        b=HQheIi84VMst1XI3hC5MDa8ogzqU9rbCgmFptHBz4ZycIhybqyXZRDPqbRbX7Wrp6r
         RuM3YIPf6NJGh27/njszC6v2EdIiBxZXXGP/xwTIudoJ+5QbBnHcxINTxOrxIbi/Wd3k
         ZmHMSg2jlOhhmXZfgSAqLVhtEzDCu2Cdonr61+amQ5LF2iNS7PfZ4CW3irdwuUWyueC0
         ThNeLckKfOdApL/8Z0aibggTyyGcMItxRZDxl7jXHokYSjeJEek9wgTqMtvAzax89Fof
         PA+UkoMXMNpTCkylhg+sA08+4nmp/CnmLEWH7AedlAKnlmd3iqYcDKCLiTiVhmaqwHzo
         N5gw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUuzzcJxIiJLoxk7OgUOoEeCH7IdF0jfFYLwOeuLyVh+3Tu8qMK
	DMvqWBj24gQXAP3tZON5d4TMpmJ6Gj+QWPW0KHsPXhmoTilmNvMaH18Sx4ZaZv1Ft9WYRYK8fji
	kSFMSNzhLN4M68UdAl+MKZIIOL0aYp/jODOIOT4XE6UBt2pamT6T2NM9k4TIaMbhTfA==
X-Received: by 2002:a63:ef4b:: with SMTP id c11mr52483112pgk.129.1563556892418;
        Fri, 19 Jul 2019 10:21:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzC8eGttVXOmSeuLfLDSfP67iqUPynsjC9vm+hJpON3onZVG0YEdr9spLYrAxWcm+8fn5KP
X-Received: by 2002:a63:ef4b:: with SMTP id c11mr52482955pgk.129.1563556890320;
        Fri, 19 Jul 2019 10:21:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563556890; cv=none;
        d=google.com; s=arc-20160816;
        b=UUiDc1hf9JSFnYOzP816Y95vsbmSaqD4BTQp6eaadY69D46H3NKgSefEGENLlu4tt2
         7Pb2wJ7v7mweafjqhYgEAlrs2z8oqCZA8bEmN/ofrWkvyDsoYc4ZMptLub204Fm5a2sF
         5yEnRIXj9Vk3+ZkaiforCFDzLaNzYqhQTj+p+xcJtDJBZMn1wDcroIOyElLbpVCCOWlK
         XiejxXux+ZdKxyfZofqylHR+i95/Q1n3RnoqbLpv3B4KDTGQ2BDbxfd80jMmJSymE6VG
         ScecUOCVpHaTmKwCkC6zKH7dea5lzmuBuN7zQLzKMHZps1iorPGq9N1fOYAMlt8sc9FD
         /TvQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=Q5UKXC7LYiMDqx8x3fw7Vx9X9Hz8iQ9GRljmGU74pSM=;
        b=N+Oex6MXV1gh5D8Fc2v50xtmiOEz8by5ne+nuQwbhPJhD9S9soDMWdyTWjqPgG5A+T
         8eRgYrhEy2TO3h73fggOAc5PajLWZjBDd3Sz2S/ebLH7x+BRUppYP+D9ARhf/q5CroBC
         7jJHQNA/DVEOHl7j0+txju8bupQxeZ4a0ZjNdGhuTzpKxLEI840dMk0OE/ZW/2M3Echa
         PLVWiIdHNoApKVyKhSXgafw/wdchtgpfSR1UpWAvWycgDF//aTaMVPoyPvq+hqJK9HOq
         yIEGuRI3cqzkX0XEl9rZI+1ROfrFVIWheUH9j0lE2I0nWdcMFm1PU/c82mAfOpSbpny6
         /EGQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id n184si146790pgn.399.2019.07.19.10.21.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jul 2019 10:21:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) client-ip=47.88.44.37;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R811e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e01422;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=8;SR=0;TI=SMTPD_---0TXIdl-p_1563556863;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TXIdl-p_1563556863)
          by smtp.aliyun-inc.com(127.0.0.1);
          Sat, 20 Jul 2019 01:21:14 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: vbabka@suse.cz,
	mhocko@kernel.org,
	mgorman@techsingularity.net,
	akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	linux-api@vger.kernel.org
Subject: [v4 PATCH 1/2] mm: mempolicy: make the behavior consistent when MPOL_MF_MOVE* and MPOL_MF_STRICT were specified
Date: Sat, 20 Jul 2019 01:21:01 +0800
Message-Id: <1563556862-54056-2-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1563556862-54056-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1563556862-54056-1-git-send-email-yang.shi@linux.alibaba.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When both MPOL_MF_MOVE* and MPOL_MF_STRICT was specified, mbind() should
try best to migrate misplaced pages, if some of the pages could not be
migrated, then return -EIO.

There are three different sub-cases:
1. vma is not migratable
2. vma is migratable, but there are unmovable pages
3. vma is migratable, pages are movable, but migrate_pages() fails

If #1 happens, kernel would just abort immediately, then return -EIO,
after the commit a7f40cfe3b7ada57af9b62fd28430eeb4a7cfcb7 ("mm:
mempolicy: make mbind() return -EIO when MPOL_MF_STRICT is specified").

If #3 happens, kernel would set policy and migrate pages with best-effort,
but won't rollback the migrated pages and reset the policy back.

Before that commit, they behaves in the same way.  It'd better to keep
their behavior consistent.  But, rolling back the migrated pages and
resetting the policy back sounds not feasible, so just make #1 behave as
same as #3.

Userspace will know that not everything was successfully migrated (via
-EIO), and can take whatever steps it deems necessary - attempt rollback,
determine which exact page(s) are violating the policy, etc.

Make queue_pages_range() return 1 to indicate there are unmovable pages
or vma is not migratable.

The #2 is not handled correctly in the current kernel, the following
patch will fix it.

Reviewed-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 mm/mempolicy.c | 68 +++++++++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 48 insertions(+), 20 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index f48693f..932c268 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -429,11 +429,14 @@ static inline bool queue_pages_required(struct page *page,
 }
 
 /*
- * queue_pages_pmd() has three possible return values:
- * 1 - pages are placed on the right node or queued successfully.
- * 0 - THP was split.
- * -EIO - is migration entry or MPOL_MF_STRICT was specified and an existing
- *        page was already on a node that does not follow the policy.
+ * queue_pages_pmd() has four possible return values:
+ * 0 - pages are placed on the right node or queued successfully.
+ * 1 - there is unmovable page, and MPOL_MF_MOVE* & MPOL_MF_STRICT were
+ *     specified.
+ * 2 - THP was split.
+ * -EIO - is migration entry or only MPOL_MF_STRICT was specified and an
+ *        existing page was already on a node that does not follow the
+ *        policy.
  */
 static int queue_pages_pmd(pmd_t *pmd, spinlock_t *ptl, unsigned long addr,
 				unsigned long end, struct mm_walk *walk)
@@ -451,19 +454,17 @@ static int queue_pages_pmd(pmd_t *pmd, spinlock_t *ptl, unsigned long addr,
 	if (is_huge_zero_page(page)) {
 		spin_unlock(ptl);
 		__split_huge_pmd(walk->vma, pmd, addr, false, NULL);
+		ret = 2;
 		goto out;
 	}
-	if (!queue_pages_required(page, qp)) {
-		ret = 1;
+	if (!queue_pages_required(page, qp))
 		goto unlock;
-	}
 
-	ret = 1;
 	flags = qp->flags;
 	/* go to thp migration */
 	if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)) {
 		if (!vma_migratable(walk->vma)) {
-			ret = -EIO;
+			ret = 1;
 			goto unlock;
 		}
 
@@ -479,6 +480,13 @@ static int queue_pages_pmd(pmd_t *pmd, spinlock_t *ptl, unsigned long addr,
 /*
  * Scan through pages checking if pages follow certain conditions,
  * and move them to the pagelist if they do.
+ *
+ * queue_pages_pte_range() has three possible return values:
+ * 0 - pages are placed on the right node or queued successfully.
+ * 1 - there is unmovable page, and MPOL_MF_MOVE* & MPOL_MF_STRICT were
+ *     specified.
+ * -EIO - only MPOL_MF_STRICT was specified and an existing page was already
+ *        on a node that does not follow the policy.
  */
 static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
 			unsigned long end, struct mm_walk *walk)
@@ -488,17 +496,17 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
 	struct queue_pages *qp = walk->private;
 	unsigned long flags = qp->flags;
 	int ret;
+	bool has_unmovable = false;
 	pte_t *pte;
 	spinlock_t *ptl;
 
 	ptl = pmd_trans_huge_lock(pmd, vma);
 	if (ptl) {
 		ret = queue_pages_pmd(pmd, ptl, addr, end, walk);
-		if (ret > 0)
-			return 0;
-		else if (ret < 0)
+		if (ret != 2)
 			return ret;
 	}
+	/* THP was split, fall through to pte walk */
 
 	if (pmd_trans_unstable(pmd))
 		return 0;
@@ -519,14 +527,21 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
 		if (!queue_pages_required(page, qp))
 			continue;
 		if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)) {
-			if (!vma_migratable(vma))
+			/* MPOL_MF_STRICT must be specified if we get here */
+			if (!vma_migratable(vma)) {
+				has_unmovable = true;
 				break;
+			}
 			migrate_page_add(page, qp->pagelist, flags);
 		} else
 			break;
 	}
 	pte_unmap_unlock(pte - 1, ptl);
 	cond_resched();
+
+	if (has_unmovable)
+		return 1;
+
 	return addr != end ? -EIO : 0;
 }
 
@@ -639,7 +654,13 @@ static int queue_pages_test_walk(unsigned long start, unsigned long end,
  *
  * If pages found in a given range are on a set of nodes (determined by
  * @nodes and @flags,) it's isolated and queued to the pagelist which is
- * passed via @private.)
+ * passed via @private.
+ *
+ * queue_pages_range() has three possible return values:
+ * 1 - there is unmovable page, but MPOL_MF_MOVE* & MPOL_MF_STRICT were
+ *     specified.
+ * 0 - queue pages successfully or no misplaced page.
+ * -EIO - there is misplaced page and only MPOL_MF_STRICT was specified.
  */
 static int
 queue_pages_range(struct mm_struct *mm, unsigned long start, unsigned long end,
@@ -1182,6 +1203,7 @@ static long do_mbind(unsigned long start, unsigned long len,
 	struct mempolicy *new;
 	unsigned long end;
 	int err;
+	int ret;
 	LIST_HEAD(pagelist);
 
 	if (flags & ~(unsigned long)MPOL_MF_VALID)
@@ -1243,10 +1265,15 @@ static long do_mbind(unsigned long start, unsigned long len,
 	if (err)
 		goto mpol_out;
 
-	err = queue_pages_range(mm, start, end, nmask,
+	ret = queue_pages_range(mm, start, end, nmask,
 			  flags | MPOL_MF_INVERT, &pagelist);
-	if (!err)
-		err = mbind_range(mm, start, end, new);
+
+	if (ret < 0) {
+		err = -EIO;
+		goto up_out;
+	}
+
+	err = mbind_range(mm, start, end, new);
 
 	if (!err) {
 		int nr_failed = 0;
@@ -1259,13 +1286,14 @@ static long do_mbind(unsigned long start, unsigned long len,
 				putback_movable_pages(&pagelist);
 		}
 
-		if (nr_failed && (flags & MPOL_MF_STRICT))
+		if ((ret > 0) || (nr_failed && (flags & MPOL_MF_STRICT)))
 			err = -EIO;
 	} else
 		putback_movable_pages(&pagelist);
 
+up_out:
 	up_write(&mm->mmap_sem);
- mpol_out:
+mpol_out:
 	mpol_put(new);
 	return err;
 }
-- 
1.8.3.1

