Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id C36C06B0005
	for <linux-mm@kvack.org>; Wed,  6 Jun 2018 10:02:58 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id b12-v6so3659444wrs.10
        for <linux-mm@kvack.org>; Wed, 06 Jun 2018 07:02:58 -0700 (PDT)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id d6-v6si715978edk.225.2018.06.06.07.02.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Jun 2018 07:02:57 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id E27F61C2731
	for <linux-mm@kvack.org>; Wed,  6 Jun 2018 15:02:56 +0100 (IST)
Date: Wed, 6 Jun 2018 15:02:55 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH] mremap: Increase LATENCY_LIMIT of mremap to reduce the
 number of TLB shootdowns
Message-ID: <20180606140255.br5ztpeqdmwfto47@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, mhocko@kernel.org, vbabka@suse.cz, Aaron Lu <aaron.lu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Commit 5d1904204c99 ("mremap: fix race between mremap() and page cleanning")
fixed races between mremap and other operations for both file-backed and
anonymous mappings. The file-backed was the most critical as it allowed the
possibility that data could be changed on a physical page after page_mkclean
returned which could trigger data loss or data integrity issues. A customer
reported that the cost of the TLBs for anonymous regressions was excessive
and resulting in a 30-50% drop in performance overall since this commit
on a microbenchmark. Unfortunately I neither have access to the test-case
nor can I describe what it does other than saying that mremap operations
dominate heavily.

This patch increases the LATENCY_LIMIT to handle TLB flushes on a
PMD boundary instead of every 64 pages. This reduces the number of TLB
shootdowns by a factor of 8 which is not reported to completely restore
performance but gets it within an acceptable percentage. The given metric
here is simply described as "higher is better".

Baseline that was known good
002:  Metric:       91.05
004:  Metric:      109.45
008:  Metric:       73.08
016:  Metric:       58.14
032:  Metric:       61.09
064:  Metric:       57.76
128:  Metric:       55.43

Current
001:  Metric:       54.98
002:  Metric:       56.56
004:  Metric:       41.22
008:  Metric:       35.96
016:  Metric:       36.45
032:  Metric:       35.71
064:  Metric:       35.73
128:  Metric:       34.96

With patch
001:  Metric:       61.43
002:  Metric:       81.64
004:  Metric:       67.92
008:  Metric:       51.67
016:  Metric:       50.47
032:  Metric:       52.29
064:  Metric:       50.01
128:  Metric:       49.04

So for low threads, it's not restored but for larger number of threads,
it's closer to the "known good" baseline. The downside is that PTL lock
hold times will be slightly higher but it's unlikely that an mremap and
another operation will contend on the same PMD. This is the first time I
encountered a realistic workload that was mremap intensive (thousands of
calls per second with small ranges dominating).

Using a different mremap-intensive workload that is not representative of
the real workload there is little difference observed outside of noise in
the headline metrics However, the TLB shootdowns are reduced by 11% on
average and at the peak, TLB shootdowns were reduced by 21%. Interrupts
were sampled every second while the workload ran to get those figures.
It's known that the figures will vary as the non-representative load is
non-deterministic.

An alternative patch was posted that should have significantly reduced the
TLB flushes but unfortunately it does not perform as well as this version
on the customer test case. If revisited, the two patches can stack on top
of each other.

Signed-off-by: Mel Gorman <mgorman@suse.com>
---
 mm/mremap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/mremap.c b/mm/mremap.c
index 049470aa1e3e..b5017cb2e1e9 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -191,7 +191,7 @@ static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
 		drop_rmap_locks(vma);
 }
 
-#define LATENCY_LIMIT	(64 * PAGE_SIZE)
+#define LATENCY_LIMIT	(PMD_SIZE)
 
 unsigned long move_page_tables(struct vm_area_struct *vma,
 		unsigned long old_addr, struct vm_area_struct *new_vma,
