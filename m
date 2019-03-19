Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B615C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 18:36:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2EF442082F
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 18:36:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2EF442082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C72876B0005; Tue, 19 Mar 2019 14:36:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BF9FB6B0006; Tue, 19 Mar 2019 14:36:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A9B086B0007; Tue, 19 Mar 2019 14:36:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6254D6B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 14:36:11 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 14so522382pfh.10
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 11:36:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=140MT132hOrp0Nmm6vW5R7w4piYk0RBlEPc54v7HC28=;
        b=HqTw7sT93gfoYHMaY9sL4SENcVZ4R5wn7ZTj9GK/PSwpjQdeJ7fB2l2XqVdTgG7ZKs
         IayoyZMVIs8sDHE2xdIhxidHimMDxbhXpnPz2A5477UWoPYoE9LbSGyzv+AzK3RFUrh+
         t6UEagIDu75a+ms18wULOjO4dTgODvHVzK/x1+yWk77aJdXW6IUYKPt48cxZqLFEgUY4
         DMwzYx9xeDywcGhRuTR90i0+cR5vydMrMjC1DLk6pvSfmoBsSAVCvKEPyU5DguWV+yID
         v29E7FMoHtg758ZUe5XTCQhZgBXP9zfjypa8oeI86qp0nbOlR3V05Wk+goqbujGWiIms
         htYg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAXKpyubxXa7sNE6fW8Z4oM/D6yVm3OZXYBx5qPmjQesEB2KG2N/
	V+Px81Uk9TJYkSq7wQLpMpIZ+uDsi0szpIFYkBU9/7rQPKIvf5RNSTgTNZizIHYCB0tDcthBJj0
	KUcaxn0ENgnsyOzc9qbFenLLvwXA1hcRQUcBcFFPwJeZFrYXfvQ4Sg9XzvKieEd9cgw==
X-Received: by 2002:a63:2987:: with SMTP id p129mr3095213pgp.390.1553020570884;
        Tue, 19 Mar 2019 11:36:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzvZ+6rY5kSivDWQteNjWbpAG8+AWBQBG1YczT1w7tOQ7Qr9dr/KxLLi/MHbJC3Rz48JOGu
X-Received: by 2002:a63:2987:: with SMTP id p129mr3095125pgp.390.1553020569306;
        Tue, 19 Mar 2019 11:36:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553020569; cv=none;
        d=google.com; s=arc-20160816;
        b=uBGNyC9OTXb9d304tLX8JenTgIKYAcT80M1Qugb8cIfHNtZwo5TlodCTO5YfxN5n3R
         4zEU7r3k48z85X8mwiXDnRqwC5J4w9MeF/SAgG2TukEQnr8kyzUad74dxyXnfzlEAuF3
         fzHxqsL6xW641P1mTk3A+qmmI3bh775UMJT6MDvyFIomZHNvsvoXLP5LhPV8XTGWUNzT
         tw7YqIYTBaqIccsRrboYea6rwo/Ikl0cdJRup/aRMV8iVC909aXQzbxOjL5tyA0lcBZX
         VEua7kBB159gT+zglWIbFfRji9NNDuwq7nK0dFgDJfKiKUjsn0aCP74NnAA06gG2yUX9
         jKDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=140MT132hOrp0Nmm6vW5R7w4piYk0RBlEPc54v7HC28=;
        b=QAank3VdfXT1IbCvC0QiydR9r9NzBFaz/XfmnuiMVcoL2fxhwSaxKI5MfvMdpKoBwV
         /M2FPvzuHjTtaAtv5fm/mIs6N5Ssb8r/6PbF72tcy/PPgrkyE0Z4nbhys9uoRL0bMRK1
         DM0jnaS20EBD0ejRwKT4As1veRBQfAgvcAxsPtzfkXHs8mMH6tsfC/BKwCguuX4mEC0E
         JT8N6VhuBHlSY1Xwtxn3U+rFcTui+89UNCLTxcmxSSQxb2tykJiRbi1Pc/Tsuzin3sLY
         MIQTS2wkxowEV80TRfdhAtQLY3rf4JOJ4+NY+42aPJJ/+m9MxWNrvzp1bXvfco4iFM2L
         rzmA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com. [115.124.30.131])
        by mx.google.com with ESMTPS id g75si12849819pfg.49.2019.03.19.11.36.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 11:36:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.131 as permitted sender) client-ip=115.124.30.131;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R131e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04446;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=9;SR=0;TI=SMTPD_---0TN96ovN_1553020556;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TN96ovN_1553020556)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 20 Mar 2019 02:36:05 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: chrubis@suse.cz,
	vbabka@suse.cz,
	kirill@shutemov.name,
	osalvador@suse.de,
	akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com,
	stable@vger.kernel.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH] mm: mempolicy: make mbind() return -EIO when MPOL_MF_STRICT is specified
Date: Wed, 20 Mar 2019 02:35:56 +0800
Message-Id: <1553020556-38583-1-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When MPOL_MF_STRICT was specified and an existing page was already
on a node that does not follow the policy, mbind() should return -EIO.
But commit 6f4576e3687b ("mempolicy: apply page table walker on
queue_pages_range()") broke the rule.

And, commit c8633798497c ("mm: mempolicy: mbind and migrate_pages
support thp migration") didn't return the correct value for THP mbind()
too.

If MPOL_MF_STRICT is set, ignore vma_migratable() to make sure it reaches
queue_pages_to_pte_range() or queue_pages_pmd() to check if an existing
page was already on a node that does not follow the policy.  And,
non-migratable vma may be used, return -EIO too if MPOL_MF_MOVE or
MPOL_MF_MOVE_ALL was specified.

Tested with https://github.com/metan-ucw/ltp/blob/master/testcases/kernel/syscalls/mbind/mbind02.c

Fixes: 6f4576e3687b ("mempolicy: apply page table walker on queue_pages_range()")
Reported-by: Cyril Hrubis <chrubis@suse.cz>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: stable@vger.kernel.org
Suggested-by: Kirill A. Shutemov <kirill@shutemov.name>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 mm/mempolicy.c | 40 +++++++++++++++++++++++++++++++++-------
 1 file changed, 33 insertions(+), 7 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index abe7a67..401c817 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -447,6 +447,13 @@ static inline bool queue_pages_required(struct page *page,
 	return node_isset(nid, *qp->nmask) == !(flags & MPOL_MF_INVERT);
 }
 
+/*
+ * The queue_pages_pmd() may have three kind of return value.
+ * 1 - pages are placed on he right node or queued successfully.
+ * 0 - THP get split.
+ * -EIO - is migration entry or MPOL_MF_STRICT was specified and an existing
+ *        page was already on a node that does not follow the policy.
+ */
 static int queue_pages_pmd(pmd_t *pmd, spinlock_t *ptl, unsigned long addr,
 				unsigned long end, struct mm_walk *walk)
 {
@@ -456,7 +463,7 @@ static int queue_pages_pmd(pmd_t *pmd, spinlock_t *ptl, unsigned long addr,
 	unsigned long flags;
 
 	if (unlikely(is_pmd_migration_entry(*pmd))) {
-		ret = 1;
+		ret = -EIO;
 		goto unlock;
 	}
 	page = pmd_page(*pmd);
@@ -473,8 +480,15 @@ static int queue_pages_pmd(pmd_t *pmd, spinlock_t *ptl, unsigned long addr,
 	ret = 1;
 	flags = qp->flags;
 	/* go to thp migration */
-	if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
+	if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)) {
+		if (!vma_migratable(walk->vma)) {
+			ret = -EIO;
+			goto unlock;
+		}
+
 		migrate_page_add(page, qp->pagelist, flags);
+	} else
+		ret = -EIO;
 unlock:
 	spin_unlock(ptl);
 out:
@@ -499,8 +513,10 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
 	ptl = pmd_trans_huge_lock(pmd, vma);
 	if (ptl) {
 		ret = queue_pages_pmd(pmd, ptl, addr, end, walk);
-		if (ret)
+		if (ret > 0)
 			return 0;
+		else if (ret < 0)
+			return ret;
 	}
 
 	if (pmd_trans_unstable(pmd))
@@ -521,11 +537,16 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
 			continue;
 		if (!queue_pages_required(page, qp))
 			continue;
-		migrate_page_add(page, qp->pagelist, flags);
+		if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)) {
+			if (!vma_migratable(vma))
+				break;
+			migrate_page_add(page, qp->pagelist, flags);
+		} else
+			break;
 	}
 	pte_unmap_unlock(pte - 1, ptl);
 	cond_resched();
-	return 0;
+	return addr != end ? -EIO : 0;
 }
 
 static int queue_pages_hugetlb(pte_t *pte, unsigned long hmask,
@@ -595,7 +616,12 @@ static int queue_pages_test_walk(unsigned long start, unsigned long end,
 	unsigned long endvma = vma->vm_end;
 	unsigned long flags = qp->flags;
 
-	if (!vma_migratable(vma))
+	/*
+	 * Need check MPOL_MF_STRICT to return -EIO if possible
+	 * regardless of vma_migratable
+	 */ 
+	if (!vma_migratable(vma) &&
+	    !(flags & MPOL_MF_STRICT))
 		return 1;
 
 	if (endvma > end)
@@ -622,7 +648,7 @@ static int queue_pages_test_walk(unsigned long start, unsigned long end,
 	}
 
 	/* queue pages from current vma */
-	if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
+	if (flags & MPOL_MF_VALID)
 		return 0;
 	return 1;
 }
-- 
1.8.3.1

