Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C8C0EC76195
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 17:18:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8275F208C0
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 17:18:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8275F208C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5B9896B000C; Thu, 18 Jul 2019 13:18:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F30E8E0001; Thu, 18 Jul 2019 13:18:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2329C6B000C; Thu, 18 Jul 2019 13:18:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id CF4726B000D
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 13:18:14 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id i3so14266263plb.8
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 10:18:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=NXCrhMTaO4zTo6OCihA1hML4myTYbGiHAhWdXmwT3Ck=;
        b=GQKmV94SLIsIvZSN/vnk0cGY8fLf0HagUX3KU/ImoxFgtI916FjKLuW0k4DkYCHXCS
         3mDTfY15kQJOOCS2oYkGnqV4SscjKZorpNMeDG2dbi1ZIn4YXwpouo/rc+1f6EsRAwzg
         JoeUToV9h1NRvtmrvhUv8Gt+yrJEx2TGIHqQ6LrtE4FWILR7Sa82mFOgGDSKBeJfBMUL
         lQnIc3FXL+rnoHyp8VRq/ovp2S5qoXDsjUliS5KreCUpQsQglgSDBdLZwFrytB58mP1K
         7tkY2fCrXO20hEXqPyC99wUBApzyOYsZhMiYJq+wsAPCcqBU9M7ebC6I/JWCRS/WSm1Z
         nwYQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWcSrXfN66oAX2aHFEhKqQfTZulztDH/beMAr52UBvb6F1J7Ft8
	uqOkJn1ZE9lTNLgcFYEHzeVTkD+YZD1jxT8XoccBQSNez48RZEJia5pHYWQTWLgP5eBJ7xo0xGF
	7gvjAFuDUgNPtPPSyMmcBY611RnClnZA4eDSGaI17ZHG9NrI1qFctKFpyF5QQWOaReQ==
X-Received: by 2002:a17:90a:8a15:: with SMTP id w21mr52521982pjn.134.1563470294506;
        Thu, 18 Jul 2019 10:18:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxJ8DCjFCarwqYKzPzMoMyZI/WMZCyKT2d316lg0rExC40UX/g3XIee9pOYKiDHLCLNBMzD
X-Received: by 2002:a17:90a:8a15:: with SMTP id w21mr52521846pjn.134.1563470292649;
        Thu, 18 Jul 2019 10:18:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563470292; cv=none;
        d=google.com; s=arc-20160816;
        b=ioOGQq7vDwlOt7RL10z19g7xHwmVJQlHWBzKEXS0e7edJOK2uGGxqDiGaj9dazPMfw
         rKHHmUxvukjGmtxC7WFwZOel84OOMzwoB22Wyc4HyrwhZSb0Z1g2XtQ4NKdeP9g4AAYO
         iXavZmfVdSMSUAB+y6RMTDkynI3eyKmeTeZ467PYBKfLGBZfJn5KHO8NdXVYMsa9+h/B
         KynyZ4lsQQ3RuucmE3cDn3gTLl9hxer4JYN5mqNvlKUL8Tza6uVYLdUQjOO8GLeNYYMk
         3vOJuHJmYFsCw8c320M3tkd4zw/tZ0eJ8vdnqqoIjTj1bpr6uOai3MGwSfZngl1I0WmT
         F6bQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=NXCrhMTaO4zTo6OCihA1hML4myTYbGiHAhWdXmwT3Ck=;
        b=buNWYqonA4WWbZaZxgKDohGV0HhsBc558TG51V8ArPbMmpk4NwTKAPj7naLDO09uSI
         cSjjnF6+R3BpdKUdN+E5dV6WRBVtoRjSyBnDEbdfwh37Pwxv+DDvgu7xvc56SuVIMQK6
         AT8Uci8fp1ikGqExvGzWOM5OxQA1hqKdqdHGtP9sN0Rm3VTCs1KNnO+5V1g9w+o4ox8J
         F0BRmfQbAMi0Svf1kXc2DlaVZjldBmkxaf1IkF42qvUchJFujW80q4yQ7yj7wBkHjZH5
         HOMtOpA5rmT2kRK95EYXesP7zajJeQFHzfTVU8xexZlRilUHzX+aYU2a7wSTEtKK85xs
         NgAQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-57.freemail.mail.aliyun.com (out30-57.freemail.mail.aliyun.com. [115.124.30.57])
        by mx.google.com with ESMTPS id cf16si1503374plb.346.2019.07.18.10.18.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 10:18:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) client-ip=115.124.30.57;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R721e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04394;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=8;SR=0;TI=SMTPD_---0TXDOr4u_1563470282;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TXDOr4u_1563470282)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 19 Jul 2019 01:18:10 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: vbabka@suse.cz,
	mhocko@kernel.org,
	mgorman@techsingularity.net,
	akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	linux-api@vger.kernel.org
Subject: [v3 PATCH 1/2] mm: mempolicy: make the behavior consistent when MPOL_MF_MOVE* and MPOL_MF_STRICT were specified
Date: Fri, 19 Jul 2019 01:17:53 +0800
Message-Id: <1563470274-52126-2-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1563470274-52126-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1563470274-52126-1-git-send-email-yang.shi@linux.alibaba.com>
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

Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 mm/mempolicy.c | 66 +++++++++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 47 insertions(+), 19 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index f48693f..0e73cc7 100644
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
@@ -488,15 +496,15 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
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
+		/* THP was split, fall through to pte walk */
+		if (ret != 2)
 			return ret;
 	}
 
@@ -519,14 +527,21 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
 		if (!queue_pages_required(page, qp))
 			continue;
 		if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)) {
-			if (!vma_migratable(vma))
+			/* MPOL_MF_STRICT must be specified if we get here */
+			if (!vma_migratable(vma)) {
+				has_unmovable |= true;
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
@@ -1259,11 +1286,12 @@ static long do_mbind(unsigned long start, unsigned long len,
 				putback_movable_pages(&pagelist);
 		}
 
-		if (nr_failed && (flags & MPOL_MF_STRICT))
+		if ((ret > 0) || (nr_failed && (flags & MPOL_MF_STRICT)))
 			err = -EIO;
 	} else
 		putback_movable_pages(&pagelist);
 
+up_out:
 	up_write(&mm->mmap_sem);
  mpol_out:
 	mpol_put(new);
-- 
1.8.3.1

