Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9FB6C48BD6
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 18:04:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7326B21726
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 18:04:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="jpOJUeZ/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7326B21726
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 097ED6B0003; Wed, 26 Jun 2019 14:04:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 049AB8E0003; Wed, 26 Jun 2019 14:04:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E79E38E0002; Wed, 26 Jun 2019 14:04:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id AFCDE6B0003
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 14:04:41 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id p14so1870487plq.1
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 11:04:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=xZqtOCyMzQFdp6VFlt6zwEXeqNexcY0tJ0asBdjWmuA=;
        b=UuWqkyPjmZlxZ+jyqtTR+egmJDfH43k8rqbbbzo006h+J41OK8kkxCLwlM6ufJ2HvT
         VgttIF32PyiK3WQlGCGzBYWqz7tJuQzUAbhsRBe1KE3Vv+s6QtG1/plNEBwMf2tzXx7w
         Ym1ZoJeSQztdtquHSOdf0u6suoa0lU/nOPdGVHWQ1WumPywjLe/eFKpf7NxJEKsGw0cz
         n9LJ8+bq2Y331x8/ES1GgCLc56ur8z4zL9KsQQYloxAHKagUMGR/4fgJBdf0IH3LvxS0
         p1hediQiVWKBzLTaGWoY9fvwFMPVKKeI5Z2CKVnxVat+v8KGQlbMOc+oD/hUL/BCjTkL
         iBoA==
X-Gm-Message-State: APjAAAUCjhUI02YeiDJizegiLorVcN4w11Rp1PdqwkzUuXYnYL4QLtqy
	fOxED5c9sfJ7DuSyNDPR4izyUKZFHlbtgYrYtSLkMasM0xEu5927rQQ3sXmt3WSPXhpK13Oy/Km
	2ADWg0mSBknHAg19xj3MhgArhI3NgnmH2BMSRLa+Yi5QnX9wD7/1SzjuM/xJvSlE7zg==
X-Received: by 2002:a63:ed13:: with SMTP id d19mr4198603pgi.100.1561572281145;
        Wed, 26 Jun 2019 11:04:41 -0700 (PDT)
X-Received: by 2002:a63:ed13:: with SMTP id d19mr4198511pgi.100.1561572280083;
        Wed, 26 Jun 2019 11:04:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561572280; cv=none;
        d=google.com; s=arc-20160816;
        b=bnAhy3j7cDD3NK4v1cISSDWEEHThz6o5DTdHGf4b8q4cl2Y/9/TA4zD3HrgE1teBl5
         ibNoN3NczUEbK5heyhg04zbOvT39cz0su+RiVWotNCxBWK8hoFN9BuiQWK3IE9T52V5d
         Ehz2zL3KlXm7IyBf08OiKAndUETJxKZZ5D4O2W+u+yCKqEdjKXMA6JePE9k9Be+ogRoQ
         vNDDClEgk+QoHhy4+OiH0K1qvSspJuQmCzxfGbZGuiZ9wFz1NawwSu3qXiUV581M+1mB
         a08aVA76H+2FZXnot5NCpoWSWdWMOBW1RKOMWrIqDaGCOIykHQshkKHB6yrBO9Xuo2yP
         ZbQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=xZqtOCyMzQFdp6VFlt6zwEXeqNexcY0tJ0asBdjWmuA=;
        b=0o+2Nwi2cNYUJb/uo5p+F+m++lipupb2KI/j6ksn8KfsDumz8uZQ71lDZus4y6ysKE
         r/uSbz58P8egTz1Iotbz+MMJ37Y5rvyOij6n+PzC0/Y0eUJC2wTyaJlao2v05abZsbcC
         Mu814ODR7Ee+4Kt7BQ7estj7SlqvwBNy/O+tvbL7J0lKwfYv5PPC+biSDYA22+aqqTAO
         ftH1ibH+lm/ksmBtRWasQs4jWAt9NdKCsvsupKjp/kDTlMBRHqxhpBfmj/8lRiKgoEHt
         p7nYIqA9RvnKlkAQKjZaGIup8cGJvwp+2rDwq+GUlsK9HkK/z/ylFmFUyA3jrg1rfYAv
         DFOA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b="jpOJUeZ/";
       spf=pass (google.com: domain of semenzato@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=semenzato@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id bj2sor21243301plb.52.2019.06.26.11.04.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 26 Jun 2019 11:04:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of semenzato@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b="jpOJUeZ/";
       spf=pass (google.com: domain of semenzato@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=semenzato@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=xZqtOCyMzQFdp6VFlt6zwEXeqNexcY0tJ0asBdjWmuA=;
        b=jpOJUeZ/hUfvktWhirjOVpil5CD5asniu17N0x8tEkehoqK4zx6HeGZwCYnKiobCcI
         IMn/UFf+I/29uSMdLH/QuUGPhML6QJ/0jCdvu7pCkP6El2rriGuBppKB3VieF30aJy6M
         zPNERUYu0m6Ruwb2HK34e8japmFkrpA5Ai4NE=
X-Google-Smtp-Source: APXvYqy/2V+V8B/Bwh0IojGPMXgh6LuOv6Rotywt9YQsXQMdZfzPHS6AXBSOjnrcfzJkq8092TsA+A==
X-Received: by 2002:a17:902:bc83:: with SMTP id bb3mr7152039plb.56.1561572279410;
        Wed, 26 Jun 2019 11:04:39 -0700 (PDT)
Received: from luigi2.sfo.corp.google.com ([2620:0:1002:1005:fea5:a80f:c2ef:91c7])
        by smtp.gmail.com with ESMTPSA id x26sm25286583pfq.69.2019.06.26.11.04.38
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 26 Jun 2019 11:04:38 -0700 (PDT)
From: semenzato@chromium.org
To: linux-mm@kvack.org,
	akpm@linux-foundation.org
Cc: yuzhao@chromium.org,
	bgeffon@chromium.org,
	sonnyrao@chromium.org,
	Luigi Semenzato <semenzato@chromium.org>
Subject: [PATCH 1/1] mm: smaps: split PSS into components
Date: Wed, 26 Jun 2019 11:04:29 -0700
Message-Id: <20190626180429.174569-1-semenzato@chromium.org>
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Luigi Semenzato <semenzato@chromium.org>

Report separate components (anon, file, and shmem)
for PSS in smaps_rollup.

This helps understand and tune the memory manager behavior
in consumer devices, particularly mobile devices.  Many of
them (e.g. chromebooks and Android-based devices) use zram
for anon memory, and perform disk reads for discarded file
pages.  The difference in latency is large (e.g. reading
a single page from SSD is 30 times slower than decompressing
a zram page on one popular device), thus it is useful to know
how much of the PSS is anon vs. file.

This patch also removes a small code duplication in smaps_account,
which would have gotten worse otherwise.

Also added missing entry for smaps_rollup in
Documentation/filesystems/proc.txt.

Acked-by: Yu Zhao <yuzhao@chromium.org>
Signed-off-by: Luigi Semenzato <semenzato@chromium.org>
---
 Documentation/filesystems/proc.txt |  6 +-
 fs/proc/task_mmu.c                 | 92 ++++++++++++++++++++----------
 2 files changed, 66 insertions(+), 32 deletions(-)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index 66cad5c86171..b48e85e19877 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -153,9 +153,11 @@ Table 1-1: Process specific entries in /proc
 		symbol the task is blocked in - or "0" if not blocked.
  pagemap	Page table
  stack		Report full stack trace, enable via CONFIG_STACKTRACE
- smaps		an extension based on maps, showing the memory consumption of
+ smaps		An extension based on maps, showing the memory consumption of
 		each mapping and flags associated with it
- numa_maps	an extension based on maps, showing the memory locality and
+ smaps_rollup	Accumulated smaps stats for all mappings of the process.  This
+		can be derived from smaps, but is faster and more convenient
+ numa_maps	An extension based on maps, showing the memory locality and
 		binding policy as well as mem usage (in pages) of each mapping.
 ..............................................................................
 
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 01d4eb0e6bd1..00d110dcd6c2 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -417,17 +417,53 @@ struct mem_size_stats {
 	unsigned long shared_hugetlb;
 	unsigned long private_hugetlb;
 	u64 pss;
+	u64 pss_anon;
+	u64 pss_file;
+	u64 pss_shmem;
 	u64 pss_locked;
 	u64 swap_pss;
 	bool check_shmem_swap;
 };
 
+static void smaps_page_accumulate(struct mem_size_stats *mss,
+		struct page *page, unsigned long size, unsigned long pss,
+		bool dirty, bool locked, bool private)
+{
+	mss->pss += pss;
+
+	if (PageAnon(page))
+		mss->pss_anon += pss;
+	else if (PageSwapBacked(page))
+		mss->pss_shmem += pss;
+	else
+		mss->pss_file += pss;
+
+	if (locked)
+		mss->pss_locked += pss;
+
+	if (dirty || PageDirty(page)) {
+		if (private)
+			mss->private_dirty += size;
+		else
+			mss->shared_dirty += size;
+	} else {
+		if (private)
+			mss->private_clean += size;
+		else
+			mss->shared_clean += size;
+	}
+}
+
 static void smaps_account(struct mem_size_stats *mss, struct page *page,
 		bool compound, bool young, bool dirty, bool locked)
 {
 	int i, nr = compound ? 1 << compound_order(page) : 1;
 	unsigned long size = nr * PAGE_SIZE;
 
+	/*
+	 * First accumulate quantities that depend only on |size| and the type
+	 * of the compound page.
+	 */
 	if (PageAnon(page)) {
 		mss->anonymous += size;
 		if (!PageSwapBacked(page) && !dirty && !PageDirty(page))
@@ -440,42 +476,25 @@ static void smaps_account(struct mem_size_stats *mss, struct page *page,
 		mss->referenced += size;
 
 	/*
+	 * Then accumulate quantities that may depend on sharing, or that may
+	 * differ page-by-page.
+	 *
 	 * page_count(page) == 1 guarantees the page is mapped exactly once.
 	 * If any subpage of the compound page mapped with PTE it would elevate
 	 * page_count().
 	 */
 	if (page_count(page) == 1) {
-		if (dirty || PageDirty(page))
-			mss->private_dirty += size;
-		else
-			mss->private_clean += size;
-		mss->pss += (u64)size << PSS_SHIFT;
-		if (locked)
-			mss->pss_locked += (u64)size << PSS_SHIFT;
+		smaps_page_accumulate(mss, page, size, size << PSS_SHIFT, dirty,
+			locked, true);
 		return;
 	}
-
 	for (i = 0; i < nr; i++, page++) {
 		int mapcount = page_mapcount(page);
-		unsigned long pss = (PAGE_SIZE << PSS_SHIFT);
-
-		if (mapcount >= 2) {
-			if (dirty || PageDirty(page))
-				mss->shared_dirty += PAGE_SIZE;
-			else
-				mss->shared_clean += PAGE_SIZE;
-			mss->pss += pss / mapcount;
-			if (locked)
-				mss->pss_locked += pss / mapcount;
-		} else {
-			if (dirty || PageDirty(page))
-				mss->private_dirty += PAGE_SIZE;
-			else
-				mss->private_clean += PAGE_SIZE;
-			mss->pss += pss;
-			if (locked)
-				mss->pss_locked += pss;
-		}
+		unsigned long pss = PAGE_SIZE << PSS_SHIFT;
+		if (mapcount >= 2)
+			pss /= mapcount;
+		smaps_page_accumulate(mss, page, PAGE_SIZE, pss, dirty, locked,
+				      mapcount < 2);
 	}
 }
 
@@ -754,10 +773,23 @@ static void smap_gather_stats(struct vm_area_struct *vma,
 		seq_put_decimal_ull_width(m, str, (val) >> 10, 8)
 
 /* Show the contents common for smaps and smaps_rollup */
-static void __show_smap(struct seq_file *m, const struct mem_size_stats *mss)
+static void __show_smap(struct seq_file *m, const struct mem_size_stats *mss,
+	bool rollup_mode)
 {
 	SEQ_PUT_DEC("Rss:            ", mss->resident);
 	SEQ_PUT_DEC(" kB\nPss:            ", mss->pss >> PSS_SHIFT);
+	if (rollup_mode) {
+		/*
+		 * These are meaningful only for smaps_rollup, otherwise two of
+		 * them are zero, and the other one is the same as Pss.
+		 */
+		SEQ_PUT_DEC(" kB\nPss_Anon:       ",
+			mss->pss_anon >> PSS_SHIFT);
+		SEQ_PUT_DEC(" kB\nPss_File:       ",
+			mss->pss_file >> PSS_SHIFT);
+		SEQ_PUT_DEC(" kB\nPss_Shmem:      ",
+			mss->pss_shmem >> PSS_SHIFT);
+	}
 	SEQ_PUT_DEC(" kB\nShared_Clean:   ", mss->shared_clean);
 	SEQ_PUT_DEC(" kB\nShared_Dirty:   ", mss->shared_dirty);
 	SEQ_PUT_DEC(" kB\nPrivate_Clean:  ", mss->private_clean);
@@ -794,7 +826,7 @@ static int show_smap(struct seq_file *m, void *v)
 	SEQ_PUT_DEC(" kB\nMMUPageSize:    ", vma_mmu_pagesize(vma));
 	seq_puts(m, " kB\n");
 
-	__show_smap(m, &mss);
+	__show_smap(m, &mss, false);
 
 	seq_printf(m, "THPeligible:    %d\n", transparent_hugepage_enabled(vma));
 
@@ -841,7 +873,7 @@ static int show_smaps_rollup(struct seq_file *m, void *v)
 	seq_pad(m, ' ');
 	seq_puts(m, "[rollup]\n");
 
-	__show_smap(m, &mss);
+	__show_smap(m, &mss, true);
 
 	release_task_mempolicy(priv);
 	up_read(&mm->mmap_sem);
-- 
2.22.0.410.gd8fdbe21b5-goog

