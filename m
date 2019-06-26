Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E840C48BD6
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 23:44:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 91A522083B
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 23:44:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="FG/yAkhJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 91A522083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2CCE56B0003; Wed, 26 Jun 2019 19:44:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 27C038E0003; Wed, 26 Jun 2019 19:44:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 16B2E8E0002; Wed, 26 Jun 2019 19:44:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id CE4446B0003
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 19:44:32 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id q11so264808pll.22
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 16:44:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=xlyu27i4BKWDtTDp5sLkN0S/hkc+7xT6Xog1XEq7Y/E=;
        b=sU1eY8KqcbRq9lsLdfFvhTG1qmbqJrd47TULNTtlytqDbAZf9aEql5VXkIREEIavRG
         M+VUsLSzaP3GOxkyblBXspDk9J1Ipswa0Uhw2/r6If7WNcbAqNUTQDe8gP3rezxnfKup
         oP9L35fjpWdAje3ljdqm8ZTwnC8+htGJR+ebAO+nwdJKrf7EHz+Iz5Mbdl1Qv5pcxVu7
         nXhkbJLEVye784JbF6kVoZ4Hg0AAH9JbonpdcbH3MBW//ZkXYjnWJtiX3uitZ0kDmqTg
         Tf1QOm9ziBirJ+8ck0FsuX4VFBuNQ5Y+HgzJBee3xjQNE84YUDR6/SgF12aZw/Be/YNK
         2Hiw==
X-Gm-Message-State: APjAAAX4z1k1S7sjA87XIFkIZYPmQL2ZrH8Byjqzm5wOx+PzTArbuNxM
	FEdTz4CJdy2Y+bh1az65FFaXqISwdmviIUBtIRfmMQpI/qtEFRW8GUP6C0XWvk4U9UaQB3qjpzl
	PwOn6xVSwPWItMTUHdAdkd0tbaT48WAOcHoSaQV4Vp07vP7+JsAyg4LsgrjDlj0BBEg==
X-Received: by 2002:a17:902:7687:: with SMTP id m7mr881523pll.310.1561592672408;
        Wed, 26 Jun 2019 16:44:32 -0700 (PDT)
X-Received: by 2002:a17:902:7687:: with SMTP id m7mr881462pll.310.1561592671362;
        Wed, 26 Jun 2019 16:44:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561592671; cv=none;
        d=google.com; s=arc-20160816;
        b=eqGpG4WvSAViRFGWZ5BeGdhtR5sswk1Pb43GkHdyFxZUdyyQE0YqbE8meaV99kldaR
         IGA1aEZQef8QyS5lPE1trsctOxPvLcE3gTXv62lOZdbz6fn7zezmi78GjyHaskLUYLv5
         EQ+7v83ltahFksfolOK5YuN1uSAVN1Ne+f+/pcjrthdjLY0cNvQv+j6OIvth8E2KSw1q
         wvcIrRSbdbHsDwZwTtAkKhRypLKWXG2DMG7m1hauT6MNTDsSIk6m+BHQyJtJYLYvAJwZ
         ReXQPKEOOfX47+J3vHRppt2laznuAJiWlp9bChHC7dC8rOPGVaPKHhADQyeBs/0ghxA0
         tyQw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=xlyu27i4BKWDtTDp5sLkN0S/hkc+7xT6Xog1XEq7Y/E=;
        b=AG87y0BWohnN8hFFjPg8rfErRVKxFBNOn2HQAktu+fxAHUmnsIykY7zlrrY4ebFnnd
         ddNue5kLgSszPlWGx3difFNakHU/pNBkYRBOTVBRcbpJ16OfYkN0GAdBVduD9ZtMUG/K
         uTYChAUHacDHW1wSIePLq1BQz8jywtNRRXXvAkLadYu50OjgVzvuWg9PY19IgdRXUMSx
         pQQkkdjV8Yr1YDxw+57+CXe2n5j7rtZq37H6JamhSzP4xfrXtmdNXMkllHxEUCVgaNUK
         ST6rk6PmBjxp9Ato8HPsOzG4RoLtBLW/hil4whw//5dViEZKzX+6vVD3BDMR7i41Ylwk
         HBoQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b="FG/yAkhJ";
       spf=pass (google.com: domain of semenzato@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=semenzato@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id cu6sor1242439pjb.22.2019.06.26.16.44.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 26 Jun 2019 16:44:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of semenzato@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b="FG/yAkhJ";
       spf=pass (google.com: domain of semenzato@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=semenzato@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=xlyu27i4BKWDtTDp5sLkN0S/hkc+7xT6Xog1XEq7Y/E=;
        b=FG/yAkhJCpxUNMCSa8NuwuzRSCNjYjRN3R91Qo0GRi13hwcbc2KMNnhg3Q+VjIArqU
         9Rz8VJVjtPryt2RSlV+n+Y5isIaU3E94+497uhC+qDMaicgpKBFZIlxlAMCbECPsFEff
         F20nfP03CywGk2QVbHSr3fPtY9yP3SQsMS+qU=
X-Google-Smtp-Source: APXvYqzpBi2FEr2BInoRQ54Nj4XJVpxpRLBZ9cIkIZFqh4qFHkwdaPU36tOaQeT2EPpFUEmh3Q8EZQ==
X-Received: by 2002:a17:90a:cb8e:: with SMTP id a14mr2068792pju.124.1561592670639;
        Wed, 26 Jun 2019 16:44:30 -0700 (PDT)
Received: from luigi2.sfo.corp.google.com ([2620:0:1002:1005:fea5:a80f:c2ef:91c7])
        by smtp.gmail.com with ESMTPSA id p1sm358228pff.74.2019.06.26.16.44.29
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 26 Jun 2019 16:44:29 -0700 (PDT)
From: semenzato@chromium.org
To: linux-mm@kvack.org,
	akpm@linux-foundation.org
Cc: yuzhao@chromium.org,
	bgeffon@chromium.org,
	sonnyrao@chromium.org,
	Luigi Semenzato <semenzato@chromium.org>
Subject: [PATCH 1/1 v5] mm: smaps: split PSS into components
Date: Wed, 26 Jun 2019 16:43:33 -0700
Message-Id: <20190626234333.44608-1-semenzato@chromium.org>
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

All the information is already present in /proc/pid/smaps,
but much more expensive to obtain because of the large size
of that procfs entry.

This patch also removes a small code duplication in smaps_account,
which would have gotten worse otherwise.

Also updated Documentation/filesystems/proc.txt (the smaps
section was a bit stale, and I added a smaps_rollup section)
and Documentation/ABI/testing/procfs-smaps_rollup.

Acked-by: Yu Zhao <yuzhao@chromium.org>
Signed-off-by: Luigi Semenzato <semenzato@chromium.org>
---
 Documentation/ABI/testing/procfs-smaps_rollup | 14 ++-
 Documentation/filesystems/proc.txt            | 41 +++++++--
 fs/proc/task_mmu.c                            | 92 +++++++++++++------
 3 files changed, 105 insertions(+), 42 deletions(-)

diff --git a/Documentation/ABI/testing/procfs-smaps_rollup b/Documentation/ABI/testing/procfs-smaps_rollup
index 0a54ed0d63c9..274df44d8b1b 100644
--- a/Documentation/ABI/testing/procfs-smaps_rollup
+++ b/Documentation/ABI/testing/procfs-smaps_rollup
@@ -3,18 +3,28 @@ Date:		August 2017
 Contact:	Daniel Colascione <dancol@google.com>
 Description:
 		This file provides pre-summed memory information for a
-		process.  The format is identical to /proc/pid/smaps,
+		process.  The format is almost identical to /proc/pid/smaps,
 		except instead of an entry for each VMA in a process,
 		smaps_rollup has a single entry (tagged "[rollup]")
 		for which each field is the sum of the corresponding
 		fields from all the maps in /proc/pid/smaps.
-		For more details, see the procfs man page.
+		Additionally, the fields Pss_Anon, Pss_File and Pss_Shmem
+		are not present in /proc/pid/smaps.  These fields represent
+		the sum of the Pss field of each type (anon, file, shmem).
+		For more details, see Documentation/filesystems/proc.txt
+		and the procfs man page.
 
 		Typical output looks like this:
 
 		00100000-ff709000 ---p 00000000 00:00 0		 [rollup]
+		Size:               1192 kB
+		KernelPageSize:        4 kB
+		MMUPageSize:           4 kB
 		Rss:		     884 kB
 		Pss:		     385 kB
+		Pss_Anon:	     301 kB
+		Pss_File:	      80 kB
+		Pss_Shmem:	       4 kB
 		Shared_Clean:	     696 kB
 		Shared_Dirty:	       0 kB
 		Private_Clean:	     120 kB
diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index 66cad5c86171..e21c975d75f0 100644
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
 
@@ -365,7 +367,7 @@ Table 1-4: Contents of the stat files (as of 2.6.30-rc7)
   exit_code     the thread's exit_code in the form reported by the waitpid system call
 ..............................................................................
 
-The /proc/PID/maps file containing the currently mapped memory regions and
+The /proc/PID/maps file contains the currently mapped memory regions and
 their access permissions.
 
 The format is:
@@ -416,11 +418,14 @@ is not associated with a file:
  or if empty, the mapping is anonymous.
 
 The /proc/PID/smaps is an extension based on maps, showing the memory
-consumption for each of the process's mappings. For each of mappings there
-is a series of lines such as the following:
+consumption for each of the process's mappings. For each mapping (aka Virtual
+Memory Area, or VMA) there is a series of lines such as the following:
 
 08048000-080bc000 r-xp 00000000 03:02 13130      /bin/bash
+
 Size:               1084 kB
+KernelPageSize:        4 kB
+MMUPageSize:           4 kB
 Rss:                 892 kB
 Pss:                 374 kB
 Shared_Clean:        892 kB
@@ -442,11 +447,14 @@ Locked:                0 kB
 THPeligible:           0
 VmFlags: rd ex mr mw me dw
 
-the first of these lines shows the same information as is displayed for the
-mapping in /proc/PID/maps.  The remaining lines show the size of the mapping
-(size), the amount of the mapping that is currently resident in RAM (RSS), the
-process' proportional share of this mapping (PSS), the number of clean and
-dirty private pages in the mapping.
+The first of these lines shows the same information as is displayed for the
+mapping in /proc/PID/maps.  Following lines show the size of the mapping
+(size); the size of each page allocated when backing a VMA (KernelPageSize),
+which is usually the same as the size in the page table entries; the page size
+used by the MMU when backing a VMA (in most cases, the same as KernelPageSize);
+the amount of the mapping that is currently resident in RAM (RSS); the
+process' proportional share of this mapping (PSS); and the number of clean and
+dirty shared and private pages in the mapping.
 
 The "proportional set size" (PSS) of a process is the count of pages it has
 in memory, where each page is divided by the number of processes sharing it.
@@ -531,6 +539,19 @@ guarantees:
 2) If there is something at a given vaddr during the entirety of the
    life of the smaps/maps walk, there will be some output for it.
 
+The /proc/PID/smaps_rollup file includes the same fields as /proc/PID/smaps,
+but their values are the sums of the corresponding values for all mappings of
+the process.  Additionally, it contains these fields:
+
+Pss_Anon
+Pss_File
+Pss_Shmem
+
+They represent the proportional shares of anonymous, file, and shmem pages, as
+described for smaps above.  These fields are omitted in smaps since each
+mapping identifies the type (anon, file, or shmem) of all pages it contains.
+Thus all information in smaps_rollup can be derived from smaps, but at a
+significantly higher cost.
 
 The /proc/PID/clear_refs is used to reset the PG_Referenced and ACCESSED/YOUNG
 bits on both physical and virtual pages associated with a process, and the
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

