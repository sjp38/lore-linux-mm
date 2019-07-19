Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 516DFC76195
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 00:12:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E87E321849
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 00:12:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E87E321849
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 51DDC6B0003; Thu, 18 Jul 2019 20:12:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4CECC6B0007; Thu, 18 Jul 2019 20:12:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 396FF6B000A; Thu, 18 Jul 2019 20:12:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 024A46B0003
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 20:12:50 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id i27so17602699pfk.12
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 17:12:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=adHSTxvkdb403F85JTKMgfi0ZTlX67Z5yUGO/ILnTas=;
        b=L0CESTWmsChCNQuGuOlgZY+8lYdhs2Jw+wa34C8C89JSNfcQ0TKzz7DBW87OvhEZQp
         HcuAIFEhVZ17odycKzX32b8bkGe0NhTC/LFeTLPMNOIFUyKTOJUExe8cfLO0OHKMFLHk
         sdnnTycL5ynRGApsQ7DWQDzzcw5PkBe8s4RqBT3Pc3icDfLoHpT6s2AdZfJTPoaVkw1m
         jbr4kOqr8ZevcwbpgmhTdKD7qabUWDCx0R4REcE4CYSti6rpJFyntm++GrBSHZK1Ycw7
         8HsGBn4atLCRdu8DuCT+3oLKKzrKlIgH5QHZ2lhNqF3Zka04YEqr0mgZdN8NKggPUYuR
         U0NQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bo.liu@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=bo.liu@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAV6QyhLLgCuyCsrPDNCdsi2jNWG9luG/WqKr44WS0GLf9CtcU/8
	buCKDTrl++p2Ld8jzr7JLzB0oSwn3BZfuOUjJjvhtVpq6qAiEAxMDg28zDV8EvB0HUIZLVq3SoZ
	XykSLtrn/ytVJtSjJRyKT2AdONfhSLyErDdRFIBoKwIw3XJwhX4UK4xRJdkhDgejUWA==
X-Received: by 2002:a17:902:29a7:: with SMTP id h36mr54643217plb.158.1563495169600;
        Thu, 18 Jul 2019 17:12:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwK25/Z6ryMW6fLinLZJ5FLTnqFicBH6U20QBiKrQkkauMeo2lXfaWKuJDFRVA4OpGwUNfa
X-Received: by 2002:a17:902:29a7:: with SMTP id h36mr54643128plb.158.1563495168216;
        Thu, 18 Jul 2019 17:12:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563495168; cv=none;
        d=google.com; s=arc-20160816;
        b=wLbd5NJVt3vV5UJY5UkgpXOJKh37ewdsYmlxkN73JkQO3KmPYaAS8CLBqdTbpNqMSL
         t1LKMnqnTiLYdfFFRIYZj6kh5gTRGpBlMYa3jlNHHnFHqH4c7y4gpiMJZEEK7+HJQnmz
         fY+2DGX0TEmBwBrOr3utxMBUPZuIDuOgBs4O4rWGA7il8QtaPVVq2H0T++ioZgqLc8Y0
         ZcxPoOru8qeexAN+Q3WB3qmzUTR1M3yNBP4ugBsW+bEA1e/hAvM9sxgk51AI2PPn+klD
         ojf1egRysxwZPVhAv6Z7/+xYYCgRfYJd6GpLBPFnS/THITGksleE9PatGSPFvwq0dhdm
         USEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=adHSTxvkdb403F85JTKMgfi0ZTlX67Z5yUGO/ILnTas=;
        b=RgS/E7KLaCiqyOAwn6zLPni/E53YNJHYWPAto0O+HEyibLQBoi3pql2mVQ7Jz/bn8/
         eCNazX8RUhSfFiFMRrGmiMmBCskAJJAE4nj9rbP9K26n1UwFICygWW+/p/mQMDupPN32
         +uxXinDObotT2l1TTY+PEygzcSkMI1Zd4ci27qIPhylo0xPGIs0InLgMOZ4bw3yUvvLO
         lhdbldO8oPBfWr9xqjGOrcp1C3ZmfHBlTVp5aRB7Fw0wjZtXwP+nj3h8sNqDTGDPH+Tv
         QdYbJbns3cmiLD/szBw3C4ji4UeXWf5BzZLIU4kTiFhQejKW8LvtbGa6v4PhCDaP4QG8
         DgJw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bo.liu@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=bo.liu@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-54.freemail.mail.aliyun.com (out30-54.freemail.mail.aliyun.com. [115.124.30.54])
        by mx.google.com with ESMTPS id w1si750457pll.257.2019.07.18.17.12.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 17:12:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of bo.liu@linux.alibaba.com designates 115.124.30.54 as permitted sender) client-ip=115.124.30.54;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bo.liu@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=bo.liu@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R181e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04400;MF=bo.liu@linux.alibaba.com;NM=1;PH=DS;RN=7;SR=0;TI=SMTPD_---0TXEcbpw_1563495165;
Received: from localhost(mailfrom:bo.liu@linux.alibaba.com fp:SMTPD_---0TXEcbpw_1563495165)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 19 Jul 2019 08:12:45 +0800
From: Liu Bo <bo.liu@linux.alibaba.com>
To: stable@vger.kernel.org
Cc: linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	Jan Kara <jack@suse.cz>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	Peng Tao <tao.peng@linux.alibaba.com>
Subject: [PATCH] mm: fix livelock caused by iterating multi order entry
Date: Fri, 19 Jul 2019 08:12:40 +0800
Message-Id: <1563495160-25647-1-git-send-email-bo.liu@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The livelock can be triggerred in the following pattern,

	while (index < end && pagevec_lookup_entries(&pvec, mapping, index,
				min(end - index, (pgoff_t)PAGEVEC_SIZE),
				indices)) {
		...
		for (i = 0; i < pagevec_count(&pvec); i++) {
			index = indices[i];
			...
		}
		index++; /* BUG */
	}

multi order exceptional entry is not specially considered in
invalidate_inode_pages2_range() and it ended up with a livelock because
both index 0 and index 1 finds the same pmd, but this pmd is binded to
index 0, so index is set to 0 again.

This introduces a helper to take the pmd entry's length into account when
deciding the next index.

Note that there're other users of the above pattern which doesn't need to
fix,

- dax_layout_busy_page
It's been fixed in commit d7782145e1ad
("filesystem-dax: Fix dax_layout_busy_page() livelock")

- truncate_inode_pages_range
This won't loop forever since the exceptional entries are immediately
removed from radix tree after the search.

Fixes: 642261a ("dax: add struct iomap based DAX PMD support")
Cc: <stable@vger.kernel.org> since 4.9 to 4.19
Signed-off-by: Liu Bo <bo.liu@linux.alibaba.com>
---

The problem is gone after commit f280bf092d48 ("page cache: Convert
find_get_entries to XArray"), but since xarray seems too new to backport
to 4.19, I made this fix based on radix tree implementation.

 fs/dax.c            | 19 +++++++++++++++++++
 include/linux/dax.h |  8 ++++++++
 mm/truncate.c       | 26 ++++++++++++++++++++++++--
 3 files changed, 51 insertions(+), 2 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index ac334bc..cd05337 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -764,6 +764,25 @@ int dax_invalidate_mapping_entry_sync(struct address_space *mapping,
 	return __dax_invalidate_mapping_entry(mapping, index, false);
 }
 
+pgoff_t dax_get_multi_order(struct address_space *mapping, pgoff_t index,
+			    void *entry)
+{
+	struct radix_tree_root *pages = &mapping->i_pages;
+	pgoff_t nr_pages = 1;
+
+	if (!dax_mapping(mapping))
+		return nr_pages;
+
+	xa_lock_irq(pages);
+	entry = get_unlocked_mapping_entry(mapping, index, NULL);
+	if (entry)
+		nr_pages = 1UL << dax_radix_order(entry);
+	put_unlocked_mapping_entry(mapping, index, entry);
+	xa_unlock_irq(pages);
+
+	return nr_pages;
+}
+
 static int copy_user_dax(struct block_device *bdev, struct dax_device *dax_dev,
 		sector_t sector, size_t size, struct page *to,
 		unsigned long vaddr)
diff --git a/include/linux/dax.h b/include/linux/dax.h
index a846184..f3c95c6 100644
--- a/include/linux/dax.h
+++ b/include/linux/dax.h
@@ -91,6 +91,8 @@ int dax_writeback_mapping_range(struct address_space *mapping,
 struct page *dax_layout_busy_page(struct address_space *mapping);
 bool dax_lock_mapping_entry(struct page *page);
 void dax_unlock_mapping_entry(struct page *page);
+pgoff_t dax_get_multi_order(struct address_space *mapping, pgoff_t index,
+			    void *entry);
 #else
 static inline bool bdev_dax_supported(struct block_device *bdev,
 		int blocksize)
@@ -134,6 +136,12 @@ static inline bool dax_lock_mapping_entry(struct page *page)
 static inline void dax_unlock_mapping_entry(struct page *page)
 {
 }
+
+static inline pgoff_t dax_get_multi_order(struct address_space *mapping,
+					  pgoff_t index, void *entry)
+{
+	return 1;
+}
 #endif
 
 int dax_read_lock(void);
diff --git a/mm/truncate.c b/mm/truncate.c
index 71b65aa..835911f 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -557,6 +557,8 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
 	while (index <= end && pagevec_lookup_entries(&pvec, mapping, index,
 			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1,
 			indices)) {
+		pgoff_t nr_pages = 1;
+
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
 
@@ -568,6 +570,15 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
 			if (radix_tree_exceptional_entry(page)) {
 				invalidate_exceptional_entry(mapping, index,
 							     page);
+				/*
+				 * Account for multi-order entries at
+				 * the end of the pagevec.
+				 */
+				if (i < pagevec_count(&pvec) - 1)
+					continue;
+
+				nr_pages = dax_get_multi_order(mapping, index,
+							       page);
 				continue;
 			}
 
@@ -607,7 +618,7 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
 		pagevec_remove_exceptionals(&pvec);
 		pagevec_release(&pvec);
 		cond_resched();
-		index++;
+		index += nr_pages;
 	}
 	return count;
 }
@@ -688,6 +699,8 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
 	while (index <= end && pagevec_lookup_entries(&pvec, mapping, index,
 			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1,
 			indices)) {
+		pgoff_t nr_pages = 1;
+
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
 
@@ -700,6 +713,15 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
 				if (!invalidate_exceptional_entry2(mapping,
 								   index, page))
 					ret = -EBUSY;
+				/*
+				 * Account for multi-order entries at
+				 * the end of the pagevec.
+				 */
+				if (i < pagevec_count(&pvec) - 1)
+					continue;
+
+				nr_pages = dax_get_multi_order(mapping, index,
+							       page);
 				continue;
 			}
 
@@ -739,7 +761,7 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
 		pagevec_remove_exceptionals(&pvec);
 		pagevec_release(&pvec);
 		cond_resched();
-		index++;
+		index += nr_pages;
 	}
 	/*
 	 * For DAX we invalidate page tables after invalidating radix tree.  We
-- 
1.8.3.1

