Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5C93C04AB4
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 03:17:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 66FED2081C
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 03:17:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66FED2081C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA1846B0005; Sun, 19 May 2019 23:17:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E51436B0006; Sun, 19 May 2019 23:17:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D67296B0007; Sun, 19 May 2019 23:17:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9CEB76B0005
	for <linux-mm@kvack.org>; Sun, 19 May 2019 23:17:46 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id g11so8234178plt.23
        for <linux-mm@kvack.org>; Sun, 19 May 2019 20:17:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=1OCKhsVDt6kX4UZoiYXTwaT9WYzoqrhZTxEZsyzJ+sY=;
        b=lDS5abQwXT6TmjLuJIuqZizlRCUfqb6tK9Nl8lir/BE/CuDrLDhjcRXOnC8YKuGs3J
         vI9JtKev7APBq0kRHysExnRsMyg0M8JSpOERX1r32gMV2+S5hdgGAX4M3rfcGwFeqrpW
         VjBHGAtIEO03vaCSh/CiE8q2PqYnfe5capZNIDcA0R1ynvdSV08wP5MjqzD8aCoqFyrx
         exWr50mrVk9yx2uqAe7cFBKc09ux9k6TENgl1YJle7CHoywk7oL7KUs3fZdPBPpGMTgT
         yd2hmFJuA674R0B600R8f/o3hC3CY4Q3IZUKF24GiPbtT6mY88HnogjhiK1RlG7Yr0OC
         vWxg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAVxpNmTYC1xFOcQytSiPKbDPRN9V7abUO5CjHo7g4rw3vjDfMi6
	aMLYJ4+IsYSlRiLgxgWQkxXDJUL35f8yUl4cOsK9HW1+i43q44z3amfF2f3jj/EHOR+KxK0g9Ok
	3jLpgg2ah3BvF5abUJz9Rpf/eX471tzmrhC2yF/GDp7T+1vOgGo5X+2eIRv4p1kVyVQ==
X-Received: by 2002:a17:902:f212:: with SMTP id gn18mr11280562plb.106.1558322266282;
        Sun, 19 May 2019 20:17:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwstm6BKlvGkOvnLxmYiQ2jUZFsHniN7LVoJMfM/xBiqipSwZ2kgVoGeBF0T9jhAkPaU7KH
X-Received: by 2002:a17:902:f212:: with SMTP id gn18mr11280509plb.106.1558322265187;
        Sun, 19 May 2019 20:17:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558322265; cv=none;
        d=google.com; s=arc-20160816;
        b=dUfrYWt5OvUZ6g9+ooMVEe/WJgX3oX/8qnk1ZsACFPxNMCYnjzhONXG0gLheQ/LmU2
         DBvrVIfu5boCaixOIOl0GL7LoHdS9hs2kV2qn65gkU/6oZsggifC2QMj2n4jicrNc/b4
         J8JEtmjNqxXGgzudeN3ZpEJy0l0I3OhSSmZ56+tMxIH61/zMEpR+ALPnTT72vGNDhSzD
         1pYZHoFtsp9t8sHuUu7SR2c4mfcmoGNYw9MOOQ5LhDV6b3KxSI4k6QlcUW0YHdxIvvX1
         NAz9NDfUC1FB8miGgTHbpnxCIuRZwFMsk5wAT+Ys8saOjJRftQJkCsYYPR1CKbpt2WtX
         9Mcw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=1OCKhsVDt6kX4UZoiYXTwaT9WYzoqrhZTxEZsyzJ+sY=;
        b=pqIOWl4RiYle131hzoyHPL0xVP014Vq1hY6PKdG6FOLKQw72bS4UD4uaSAJ2ImvqgB
         chfR/MrUTS2q8iS+lozCK5y+asjPZ/tr+9KMtnHVSq2O5CNA4DA7Ucw0g3AgjZNqCV4R
         WOnuRkctpnvVkYEkbsyOY0ZuGcqf8FCL9Cc2/ZsFJXl+fYrjVDvovLlAFVY4Hb5rcD6z
         xUXyG1u2zYaVHG00Wdd/A6peV+fFKz0GJBp0COewoz8tKMyO6lQhxAEA/rYY/4D5xO+l
         aAyhQeVFVqB71SX9dor1smJ8w578RVMIETIJUy7J8Wm3WPYA9bZ6OwFJ9cU73/A+8P+y
         WW+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id 23si16231086pgq.100.2019.05.19.20.17.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 May 2019 20:17:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) client-ip=47.88.44.36;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R121e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07417;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=13;SR=0;TI=SMTPD_---0TSAtqql_1558322252;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TSAtqql_1558322252)
          by smtp.aliyun-inc.com(127.0.0.1);
          Mon, 20 May 2019 11:17:39 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: jstancek@redhat.com,
	peterz@infradead.org,
	will.deacon@arm.com,
	npiggin@gmail.com,
	aneesh.kumar@linux.ibm.com,
	namit@vmware.com,
	minchan@kernel.org,
	mgorman@suse.de,
	akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com,
	stable@vger.kernel.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [v3 PATCH] mm: mmu_gather: remove __tlb_reset_range() for force flush
Date: Mon, 20 May 2019 11:17:32 +0800
Message-Id: <1558322252-113575-1-git-send-email-yang.shi@linux.alibaba.com>
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
v3: Adopted fullmm flush suggestion from Will
v2: Reworked the commit log per Peter and Will
    Adopted the suggestion from Peter

 mm/mmu_gather.c | 24 +++++++++++++++++++-----
 1 file changed, 19 insertions(+), 5 deletions(-)

diff --git a/mm/mmu_gather.c b/mm/mmu_gather.c
index 99740e1..289f8cf 100644
--- a/mm/mmu_gather.c
+++ b/mm/mmu_gather.c
@@ -245,14 +245,28 @@ void tlb_finish_mmu(struct mmu_gather *tlb,
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
 	if (mm_tlb_flush_nested(tlb->mm)) {
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

