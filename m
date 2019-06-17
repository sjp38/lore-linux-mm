Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0278C31E5B
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 20:57:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 759FD2080A
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 20:57:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 759FD2080A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E8E218E0002; Mon, 17 Jun 2019 16:57:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E3DD68E0001; Mon, 17 Jun 2019 16:57:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D2C758E0002; Mon, 17 Jun 2019 16:57:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9A2448E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 16:57:02 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id k2so8455953pga.12
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 13:57:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=36LP9IWlmujmK1ehbDnCrqlhx78+IdcVDIvPgQA3+Us=;
        b=AtUbH0aqZ5cT38tS+lNgskhu9k6xVeSLvEACHXRuHj5Fc42riTZvwk0FJu3dm8MpUa
         rIfcq1qvdJLAwp7w3igjNKWNfVGsT9xTcSlDx5Wea0iDJ6L9ZudOxL/9sM8zTL06jedY
         ktU7alWihkAhQeFy0lxNeRZfCm59jGVdHfJpeLrDyDO9VDBw5bEYGDaOncu9VvjCjtiG
         vSEDJZTHoMl2p6Lnkzt66dECEG28FebVUQek1IiexDxu/+pcsKFRZdBltwP8zdzkM+wG
         KxmnOyyGz/1OQb2oDVH6HaEcAI3TF+SO/Z8V2VuBOVjxgTvy8ZZIYw43WNOyp9KWWfTw
         wAbw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.130 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAV6upvu3b2bmMA3huV5jd5OfkHvSSPSML/6/iaIpataw8K10nH1
	hg36jkSIjeajKdI8PaQC/CIqfnlA6frAa5M5F5esMjw/m4KCsW0nmrq/pA4cqLrLmTNU0mok1j8
	eZpyE29sA2dE6xJuHyhkK4KGDQrcVlsz4Vv0VPk9JKKbwew6mp4h3dw9p826NbFJc0g==
X-Received: by 2002:a62:ee05:: with SMTP id e5mr398647pfi.117.1560805021455;
        Mon, 17 Jun 2019 13:57:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw0zbVn9xwqR1JD2nwA4WjHzXYIcfcKr7GaZe0pOLQfm8RLCY88oB8qkWRnIOBMfUG9Ji1t
X-Received: by 2002:a62:ee05:: with SMTP id e5mr354388pfi.117.1560804400727;
        Mon, 17 Jun 2019 13:46:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560804400; cv=none;
        d=google.com; s=arc-20160816;
        b=TIS11UHcpWuQVAidTxud/cz0tfAigDdvSeUNXawfkqcIInBb90CqK5HSxHjtftZXVl
         4OqqYkbQW8rwqXXjpufKB3T22sbqgpOl4nFNfqarMofhQ0AN+saGCnOliP4qfbLaqsj+
         ZSh7BMui7aXpQhWjkOhjSyPOje83YcPrG17LsGCAA4i83Pinja4pWiuzlzTj0qR8aiFl
         MwogC2jWqsR9fSYFtAk+KKKLDUpcus7rAX9KRVOIGsUy82pCo0bw9etlulLyAuObmGgV
         7KiKLABbA2uzp5oVU9CGTUP40S+uppN6g8OoxyRvvz+kjQj5UpOJgWp3FWyuVGu8a17A
         wWVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=36LP9IWlmujmK1ehbDnCrqlhx78+IdcVDIvPgQA3+Us=;
        b=W9rte/fLFWWVNEJ1rYoaWwMZ9rhpHeo3galQqiMkVwnpbVTvF/thH+D+60JSPcC+hs
         4Ix3JRMO2PXfwB/m/DiMDpqex75iCeQBrcBqcZI+Sm3Quq3k5ZbGthbsaNt1NbQiQXcH
         r2xCjv86TCfHLbqGo2Fm1VBNLIisFv7QgxjsnBeCC5T3ZjqWMlsU5MfnN6yhhUSCfs+p
         E8deo/M3pUaDxz4j15HRnEBuRoKQ+XIcA50jZaz0Co45QZghLn6X3uqKmk2R/p9dMYTl
         kUt9KhHgPtkoaoLRt6b+4H7itLQSlXYEkoZ1mpgxPtKjFrT4XpSjQaNu8PHIJG9lIya+
         NNyA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.130 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-130.freemail.mail.aliyun.com (out30-130.freemail.mail.aliyun.com. [115.124.30.130])
        by mx.google.com with ESMTPS id a5si11047026pgt.281.2019.06.17.13.46.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 13:46:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.130 as permitted sender) client-ip=115.124.30.130;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.130 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R741e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04423;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=14;SR=0;TI=SMTPD_---0TURjHX8_1560804391;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TURjHX8_1560804391)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 18 Jun 2019 04:46:38 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: gregkh@linuxfoundation.org,
	akpm@linux-foundation.org,
	aneesh.kumar@linux.ibm.com,
	jstancek@redhat.com,
	mgorman@suse.de,
	minchan@kernel.org,
	namit@vmware.com,
	npiggin@gmail.com,
	peterz@infradead.org,
	will.deacon@arm.com
Cc: yang.shi@linux.alibaba.com,
	stable@vger.kernel.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [5.1-stable PATCH] mm: mmu_gather: remove __tlb_reset_range() for force flush
Date: Tue, 18 Jun 2019 04:46:30 +0800
Message-Id: <1560804390-28494-1-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

A few new fields were added to mmu_gather to make TLB flush smarter for
huge page by telling what level of page table is changed.

__tlb_reset_range() is used to reset all these page table state to
unchanged, which is called by TLB flush for parallel mapping changes for
the same range under non-exclusive lock (i.e. read mmap_sem).  Before
commit dd2283f2605e ("mm: mmap: zap pages with read mmap_sem in
munmap"), the syscalls (e.g. MADV_DONTNEED, MADV_FREE) which may update
PTEs in parallel don't remove page tables.  But, the forementioned
commit may do munmap() under read mmap_sem and free page tables.  This
may result in program hang on aarch64 reported by Jan Stancek.  The
problem could be reproduced by his test program with slightly modified
below.

---8<---

static int map_size = 4096;
static int num_iter = 500;
static long threads_total;

static void *distant_area;

void *map_write_unmap(void *ptr)
{
	int *fd = ptr;
	unsigned char *map_address;
	int i, j = 0;

	for (i = 0; i < num_iter; i++) {
		map_address = mmap(distant_area, (size_t) map_size, PROT_WRITE | PROT_READ,
			MAP_SHARED | MAP_ANONYMOUS, -1, 0);
		if (map_address == MAP_FAILED) {
			perror("mmap");
			exit(1);
		}

		for (j = 0; j < map_size; j++)
			map_address[j] = 'b';

		if (munmap(map_address, map_size) == -1) {
			perror("munmap");
			exit(1);
		}
	}

	return NULL;
}

void *dummy(void *ptr)
{
	return NULL;
}

int main(void)
{
	pthread_t thid[2];

	/* hint for mmap in map_write_unmap() */
	distant_area = mmap(0, DISTANT_MMAP_SIZE, PROT_WRITE | PROT_READ,
			MAP_ANONYMOUS | MAP_PRIVATE, -1, 0);
	munmap(distant_area, (size_t)DISTANT_MMAP_SIZE);
	distant_area += DISTANT_MMAP_SIZE / 2;

	while (1) {
		pthread_create(&thid[0], NULL, map_write_unmap, NULL);
		pthread_create(&thid[1], NULL, dummy, NULL);

		pthread_join(thid[0], NULL);
		pthread_join(thid[1], NULL);
	}
}
---8<---

The program may bring in parallel execution like below:

        t1                                        t2
munmap(map_address)
  downgrade_write(&mm->mmap_sem);
  unmap_region()
  tlb_gather_mmu()
    inc_tlb_flush_pending(tlb->mm);
  free_pgtables()
    tlb->freed_tables = 1
    tlb->cleared_pmds = 1

                                        pthread_exit()
                                        madvise(thread_stack, 8M, MADV_DONTNEED)
                                          zap_page_range()
                                            tlb_gather_mmu()
                                              inc_tlb_flush_pending(tlb->mm);

  tlb_finish_mmu()
    if (mm_tlb_flush_nested(tlb->mm))
      __tlb_reset_range()

__tlb_reset_range() would reset freed_tables and cleared_* bits, but
this may cause inconsistency for munmap() which do free page tables.
Then it may result in some architectures, e.g. aarch64, may not flush
TLB completely as expected to have stale TLB entries remained.

Use fullmm flush since it yields much better performance on aarch64 and
non-fullmm doesn't yields significant difference on x86.

The original proposed fix came from Jan Stancek who mainly debugged this
issue, I just wrapped up everything together.

Fixes: dd2283f2605e ("mm: mmap: zap pages with read mmap_sem in munmap")
Reported-by: Jan Stancek <jstancek@redhat.com>
Tested-by: Jan Stancek <jstancek@redhat.com>
Suggested-by: Will Deacon <will.deacon@arm.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Nick Piggin <npiggin@gmail.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: Nadav Amit <namit@vmware.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: stable@vger.kernel.org  4.20+
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
Signed-off-by: Jan Stancek <jstancek@redhat.com>
---
 mm/mmu_gather.c | 23 ++++++++++++++++++++++-
 1 file changed, 22 insertions(+), 1 deletion(-)

diff --git a/mm/mmu_gather.c b/mm/mmu_gather.c
index f2f03c6..3543b82 100644
--- a/mm/mmu_gather.c
+++ b/mm/mmu_gather.c
@@ -92,9 +92,30 @@ void arch_tlb_finish_mmu(struct mmu_gather *tlb,
 {
 	struct mmu_gather_batch *batch, *next;
 
+	/*
+	 * If there are parallel threads are doing PTE changes on same range
+	 * under non-exclusive lock (e.g., mmap_sem read-side) but defer TLB
+	 * flush by batching, one thread may end up seeing inconsistent PTEs
+	 * and result in having stale TLB entries.  So flush TLB forcefully
+	 * if we detect parallel PTE batching threads.
+	 *
+	 * However, some syscalls, e.g. munmap(), may free page tables, this
+	 * needs force flush everything in the given range. Otherwise this
+	 * may result in having stale TLB entries for some architectures,
+	 * e.g. aarch64, that could specify flush what level TLB.
+	 */
 	if (force) {
+		/*
+		 * The aarch64 yields better performance with fullmm by
+		 * avoiding multiple CPUs spamming TLBI messages at the
+		 * same time.
+		 *
+		 * On x86 non-fullmm doesn't yield significant difference
+		 * against fullmm.
+		 */
+		tlb->fullmm = 1;
 		__tlb_reset_range(tlb);
-		__tlb_adjust_range(tlb, start, end - start);
+		tlb->freed_tables = 1;
 	}
 
 	tlb_flush_mmu(tlb);
-- 
1.8.3.1

