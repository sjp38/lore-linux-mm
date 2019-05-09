Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 613E3C04AB1
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 23:27:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 02947217F5
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 23:27:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 02947217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 638A06B0003; Thu,  9 May 2019 19:27:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5E9C56B0006; Thu,  9 May 2019 19:27:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4D8406B0007; Thu,  9 May 2019 19:27:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 15CC66B0003
	for <linux-mm@kvack.org>; Thu,  9 May 2019 19:27:08 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id x5so2684324pfi.5
        for <linux-mm@kvack.org>; Thu, 09 May 2019 16:27:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=m1NKf7Apzzv5ExwLCq3+3MdQugdMdmlWNpzov30LcdA=;
        b=t92XbK3M59uGHmnwb+P9PBltc3rsWf1CFjYIO5OxE4wagOItp7K8e//16SUjHyG21X
         bQbgOt6CX7YH2ITWfudzNz6TqrpLSqFsuZkiS0v61BRvg5oVN+vF5V7UmTxR3EKZPEnU
         tfw3Q9dHOSMo1s3GPEBU7anOFHOTj3vrzX8OO0yY1DVzstZ4sBv7DDwx9ipGtg3smAhZ
         5MC6zSFfGPi+MpsbsuOn2jcUrn5RKIMqyWSxIZCEvR30fb72DJlPY9wByTmPQoEgBUio
         e03ju92GR0PTbM6TG20kGyIePjmRK3kDIor/Va4+nvt+RYt6FQTeYxA3ouBTD8A44bRS
         4quA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.44 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAURzBKaN4l7lyLLEI/SghUcaU3iSZ31ut0H47XpoIqLqAA7kZ4d
	iwlWC/1jzNq42TMuvCMdCDkuPbWb8uilf5bw4ejwMiTvwQVGqszKHtvw3MJluHB/UZ8l64LIvFz
	xHlK4+DDRK7wEPK1/3Dx5iFLPOBVfKf0RlV/BTPIuOYgzftf/SVODj//0nAW/CfCXGg==
X-Received: by 2002:a62:2a55:: with SMTP id q82mr9307702pfq.90.1557444427226;
        Thu, 09 May 2019 16:27:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwDoLCbZm0bklCP6Px2HUomyJgGfOMXuay11RZDY0mMCpD++0RZzbKwhDI8xFp2R2xDqR7+
X-Received: by 2002:a62:2a55:: with SMTP id q82mr9307593pfq.90.1557444425648;
        Thu, 09 May 2019 16:27:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557444425; cv=none;
        d=google.com; s=arc-20160816;
        b=XyhRWglwr4y7UEnu7t3drxzbVbw+4EDGKSfZIHIpHHyNnN0oDnD4EOP7IzlxFeuyuG
         f/sBAUrhFPDh8tgtn3RdCc12yeJrxmCJFCjRCyD0zo1xYX7EE8OToJ9XAkMoAVDfP8dY
         ibt4e+axrj6OJbMAn2KL8/ekp3ZKVeVtKhv3mMYMRvqxIoIXds7dR3uNFVsFEWqF7Gro
         sHvjh0Rtp5ciUWOta50DLzyW7lb7aXnML7/jayuF0tNEctx+4SegiobLgAzyaucDQkW+
         ZyimwPdLybSSpUHxsktuDPvaBfJu+PX6+3epPVdJ2hoANUxX8VGH91+RDqNkj0QQUGi7
         Uvng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=m1NKf7Apzzv5ExwLCq3+3MdQugdMdmlWNpzov30LcdA=;
        b=ObJSKqJjvDagO1sinP9OIf8dPNAM7eTxzZWDTMFi2DHObiQ/w2EuLY6AQ0xOo7Qwz5
         cifvcWITVJzEr8/A9FCMSZ9skwyWSiSXEhvVOJGy7wM14pz4meRv2UhrysyRnMKYr4V1
         81Xo9FGNDcASCKeBkhroGiIq5abVBEyG/rz+ZSPozMY4TB3iymrTzkd0blHI/jI/mDCY
         +BDzMNiWf7cSWZEi/TZ/gdxlbKp3a448dhPsAoJXPsvA/owoyx0kSeAKG/YOC7GD+MDJ
         ifO8B959svbwCO/7dQC6y9pTCK5od8Vm/6MnHXrwO790sIrU6Q5SYFNc1wnbHA6JmlGB
         0P3w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.44 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-44.freemail.mail.aliyun.com (out30-44.freemail.mail.aliyun.com. [115.124.30.44])
        by mx.google.com with ESMTPS id 2si5007898ple.275.2019.05.09.16.27.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 May 2019 16:27:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.44 as permitted sender) client-ip=115.124.30.44;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.44 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R101e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04423;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=10;SR=0;TI=SMTPD_---0TRHabNi_1557444414;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TRHabNi_1557444414)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 10 May 2019 07:27:02 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: jstancek@redhat.com,
	peterz@infradead.org,
	will.deacon@arm.com,
	namit@vmware.com,
	minchan@kernel.org,
	mgorman@suse.de
Cc: yang.shi@linux.alibaba.com,
	stable@vger.kernel.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [v2 PATCH] mm: mmu_gather: remove __tlb_reset_range() for force flush
Date: Fri, 10 May 2019 07:26:54 +0800
Message-Id: <1557444414-12090-1-git-send-email-yang.shi@linux.alibaba.com>
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

The original proposed fix came from Jan Stancek who mainly debugged this
issue, I just wrapped up everything together.

Reported-by: Jan Stancek <jstancek@redhat.com>
Tested-by: Jan Stancek <jstancek@redhat.com>
Suggested-by: Peter Zijlstra <peterz@infradead.org>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Nadav Amit <namit@vmware.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: stable@vger.kernel.org
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
Signed-off-by: Jan Stancek <jstancek@redhat.com>
---
v2: Reworked the commit log per Peter and Will
    Adopted the suggestion from Peter

 mm/mmu_gather.c | 39 ++++++++++++++++++++++++++++++++-------
 1 file changed, 32 insertions(+), 7 deletions(-)

diff --git a/mm/mmu_gather.c b/mm/mmu_gather.c
index 99740e1..469492d 100644
--- a/mm/mmu_gather.c
+++ b/mm/mmu_gather.c
@@ -245,14 +245,39 @@ void tlb_finish_mmu(struct mmu_gather *tlb,
 {
 	/*
 	 * If there are parallel threads are doing PTE changes on same range
-	 * under non-exclusive lock(e.g., mmap_sem read-side) but defer TLB
-	 * flush by batching, a thread has stable TLB entry can fail to flush
-	 * the TLB by observing pte_none|!pte_dirty, for example so flush TLB
-	 * forcefully if we detect parallel PTE batching threads.
+	 * under non-exclusive lock (e.g., mmap_sem read-side) but defer TLB
+	 * flush by batching, one thread may end up seeing inconsistent PTEs
+	 * and result in having stale TLB entries.  So flush TLB forcefully
+	 * if we detect parallel PTE batching threads.
+	 *
+	 * However, some syscalls, e.g. munmap(), may free page tables, this
+	 * needs force flush everything in the given range. Otherwise this
+	 * may result in having stale TLB entries for some architectures,
+	 * e.g. aarch64, that could specify flush what level TLB.
 	 */
-	if (mm_tlb_flush_nested(tlb->mm)) {
-		__tlb_reset_range(tlb);
-		__tlb_adjust_range(tlb, start, end - start);
+	if (mm_tlb_flush_nested(tlb->mm) && !tlb->fullmm) {
+		/*
+		 * Since we can't tell what we actually should have
+		 * flushed, flush everything in the given range.
+		 */
+		tlb->freed_tables = 1;
+		tlb->cleared_ptes = 1;
+		tlb->cleared_pmds = 1;
+		tlb->cleared_puds = 1;
+		tlb->cleared_p4ds = 1;
+
+		/*
+		 * Some architectures, e.g. ARM, that have range invalidation
+		 * and care about VM_EXEC for I-Cache invalidation, need force
+		 * vma_exec set.
+		 */
+		tlb->vma_exec = 1;
+
+		/* Force vma_huge clear to guarantee safer flush */
+		tlb->vma_huge = 0;
+
+		tlb->start = start;
+		tlb->end = end;
 	}
 
 	tlb_flush_mmu(tlb);
-- 
1.8.3.1

