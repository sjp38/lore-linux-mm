Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 8FD0D6B00A1
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 04:20:00 -0500 (EST)
Received: by mail-pb0-f44.google.com with SMTP id rq2so7222474pbb.17
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 01:20:00 -0800 (PST)
Received: from e23smtp04.au.ibm.com (e23smtp04.au.ibm.com. [202.81.31.146])
        by mx.google.com with ESMTPS id j8si9888194pad.207.2013.12.10.01.19.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 10 Dec 2013 01:19:58 -0800 (PST)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 10 Dec 2013 19:19:55 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 61D232CE8053
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 20:19:53 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBA91g113080628
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 20:01:42 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBA9Jqbo032055
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 20:19:53 +1100
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v4 09/12] sched/numa: fix period_slot recalculation
Date: Tue, 10 Dec 2013 17:19:32 +0800
Message-Id: <1386667175-19952-9-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1386667175-19952-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1386667175-19952-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Changelog:
 v3 -> v4:
  * remove period_slot recalculation

The original code is as intended and was meant to scale the difference
between the NUMA_PERIOD_THRESHOLD and local/remote ratio when adjusting
the scan period. The period_slot recalculation can be dropped.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 kernel/sched/fair.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 7073c76..90b9b88 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1356,7 +1356,6 @@ static void update_task_scan_period(struct task_struct *p,
 		 * scanning faster if shared accesses dominate as it may
 		 * simply bounce migrations uselessly
 		 */
-		period_slot = DIV_ROUND_UP(diff, NUMA_PERIOD_SLOTS);
 		ratio = DIV_ROUND_UP(private * NUMA_PERIOD_SLOTS, (private + shared));
 		diff = (diff * ratio) / NUMA_PERIOD_SLOTS;
 	}
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
