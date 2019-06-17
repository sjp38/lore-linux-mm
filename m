Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D2B3C31E5D
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 20:57:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4DBBC2089E
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 20:57:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4DBBC2089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E65628E0004; Mon, 17 Jun 2019 16:57:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E16938E0001; Mon, 17 Jun 2019 16:57:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CC1258E0004; Mon, 17 Jun 2019 16:57:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 942148E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 16:57:29 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id j36so8453391pgb.20
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 13:57:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=ex6BInwuMkeG339R8YGubjAMNNNriYe0/e4OLReRoIE=;
        b=sEVyxcO0c60MsE3zMsIYnBPWbbuOXZDljqhbY40nqEBdeyOY5WZ1OoDRlSbLeTMZdH
         uhFYWvvVBXLxY/RJr8/Ml5oodzSI7JGIUeb0a+/GcRohYFQLz2vFUhefhHwvAEnVyr/t
         VvCdryhm8Jrk3+O7KagAJhHkY6NIBbhBZyA+Uc3j2DCyj8oRnicnTQTXr5+Xv5KWNW3P
         O7Wkcdp2G3619tRpQ9BKeMzdE0Gbwul4TeHsj9AuenhSkPpNv852j2ZgyNniB0/WwVb2
         KHkAOXezTImoyRNdlXUx5uxS4PafnIP//o/qSesfU71mVfX7i4aaE9ax+dYXVuPHQqUe
         VBAw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWbHbv0hWASaUjO194tvIQuV+ULvlbKkAIgiJRUIUgtdplJ3YLn
	TUUEHLmaRvtBEF+Z8eAzZb7LUMhlrmRWzzv0NZ3QvlSdnni2x3A4VyQKhClJZkVs9E6T/xGno2b
	BjmLlp/R/E/h+J1CixpgboG0gfaxAEYHyel1lv8KuPghH2KItFSdj7hTm8RUcXuHBHg==
X-Received: by 2002:a17:902:86:: with SMTP id a6mr44221252pla.244.1560805049231;
        Mon, 17 Jun 2019 13:57:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyF6unXCl/i0jxF9UaBLRZFDhsylvU9YBQUHctURPzseQJT7OJXkG4iU4/vR4gADH7SBTgz
X-Received: by 2002:a17:902:86:: with SMTP id a6mr44221134pla.244.1560805047915;
        Mon, 17 Jun 2019 13:57:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560805047; cv=none;
        d=google.com; s=arc-20160816;
        b=DspqbQ4DUlHCJc7aZHLMy6nUJpstyt/Apy9kaPrS85B/4bnPb6bPWBWQjcpwCmx05J
         4bfNCO2QizsNCSnBq0tEMECrpd4+luWsuFABRWyIsTIZ4THjxHxPWFWr155oUcjX8m9n
         9ZQXhrw8wIwezRFI01H59dfpdEV7K7wM0uZX/nXDmtdgTvr5nJrckOcNTfFO4iRHTO3Q
         5IxVUZuZfz0MyhncCW9EvV37LHpDjOvbJ2nzdSOH8xtkK7JL1nEnL1GytCJl4HziPQT1
         pZYKcOqR7DcKWUgPnPrOqR4vg4pUEM3jCOYJ2ij79ISJ9s5Bnsdijli1e1++u+Fll9yj
         nofg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=ex6BInwuMkeG339R8YGubjAMNNNriYe0/e4OLReRoIE=;
        b=Vi+JORopKqWXK1lLwBvc+ShMjvSRqpc+FE8EUEeqSVQPExeceYJcUuX5xu2iPFtacG
         Ov3qptTWrtp/0d0GcYnfLUAYZdzzGbQMTnBPdwL5BguXAchjOBv0Y/WAUTGN/9Y68wUC
         kItHE5Q2x9wlPS8a58xx180o7gJFq6i+QaOgrdn9PQZVWRSu/w8gEShBrJzIfHy3enMY
         8KPMSMWaFnvIT3BpB21d+Iulk5eXCQ8YpbGH7jZs64WuR6sWOugvgaeiXO7P6JIG5S9l
         khyg6HgQLJGeVn4iQ3+F3b55b9Bu0D74IhlQp8NPMgl0VXdhNkaqfqRnstUhge5gFlk0
         dHEg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-43.freemail.mail.aliyun.com (out30-43.freemail.mail.aliyun.com. [115.124.30.43])
        by mx.google.com with ESMTPS id f69si340244pjg.43.2019.06.17.13.57.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 13:57:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) client-ip=115.124.30.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R301e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04391;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=14;SR=0;TI=SMTPD_---0TURrDrJ_1560805038;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TURrDrJ_1560805038)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 18 Jun 2019 04:57:25 +0800
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
Subject: [RESEND 5.1-stable PATCH] mm: mmu_gather: remove __tlb_reset_range() for force flush
Date: Tue, 18 Jun 2019 04:57:17 +0800
Message-Id: <1560805037-35324-1-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

commit 7a30df49f63ad92318ddf1f7498d1129a77dd4bd upstream

A few new fields were added to mmu_gather to make TLB flush smarter for
huge page by telling what level of page table is changed.

__tlb_reset_range() is used to reset all these page table state to
unchanged, which is called by TLB flush for parallel mapping changes for
the same range under non-exclusive lock (i.e.  read mmap_sem).

Before commit dd2283f2605e ("mm: mmap: zap pages with read mmap_sem in
munmap"), the syscalls (e.g.  MADV_DONTNEED, MADV_FREE) which may update
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

__tlb_reset_range() would reset freed_tables and cleared_* bits, but this
may cause inconsistency for munmap() which do free page tables.  Then it
may result in some architectures, e.g.  aarch64, may not flush TLB
completely as expected to have stale TLB entries remained.

Use fullmm flush since it yields much better performance on aarch64 and
non-fullmm doesn't yields significant difference on x86.

The original proposed fix came from Jan Stancek who mainly debugged this
issue, I just wrapped up everything together.

Jan's testing results:

v5.2-rc2-24-gbec7550cca10
--------------------------
         mean     stddev
real    37.382   2.780
user     1.420   0.078
sys     54.658   1.855

v5.2-rc2-24-gbec7550cca10 + "mm: mmu_gather: remove __tlb_reset_range() for force flush"
---------------------------------------------------------------------------------------_
         mean     stddev
real    37.119   2.105
user     1.548   0.087
sys     55.698   1.357

[akpm@linux-foundation.org: coding-style fixes]
Link: http://lkml.kernel.org/r/1558322252-113575-1-git-send-email-yang.shi@linux.alibaba.com
Fixes: dd2283f2605e ("mm: mmap: zap pages with read mmap_sem in munmap")
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
Signed-off-by: Jan Stancek <jstancek@redhat.com>
Reported-by: Jan Stancek <jstancek@redhat.com>
Tested-by: Jan Stancek <jstancek@redhat.com>
Suggested-by: Will Deacon <will.deacon@arm.com>
Tested-by: Will Deacon <will.deacon@arm.com>
Acked-by: Will Deacon <will.deacon@arm.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Nick Piggin <npiggin@gmail.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: Nadav Amit <namit@vmware.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: <stable@vger.kernel.org>	[4.20+]
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
---
 mm/mmu_gather.c | 24 +++++++++++++++++++-----
 1 file changed, 19 insertions(+), 5 deletions(-)

diff --git a/mm/mmu_gather.c b/mm/mmu_gather.c
index f2f03c6..a58bd0d 100644
--- a/mm/mmu_gather.c
+++ b/mm/mmu_gather.c
@@ -93,8 +93,17 @@ void arch_tlb_finish_mmu(struct mmu_gather *tlb,
 	struct mmu_gather_batch *batch, *next;
 
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
@@ -249,10 +258,15 @@ void tlb_finish_mmu(struct mmu_gather *tlb,
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
 	bool force = mm_tlb_flush_nested(tlb->mm);
 
-- 
1.8.3.1

