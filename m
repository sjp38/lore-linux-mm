Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id CD6476B02C4
	for <linux-mm@kvack.org>; Tue, 16 May 2017 14:53:17 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id y22so24680589wry.1
        for <linux-mm@kvack.org>; Tue, 16 May 2017 11:53:17 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id q2si2720799wrc.29.2017.05.16.11.53.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 16 May 2017 11:53:16 -0700 (PDT)
Message-Id: <20170516184736.119158930@linutronix.de>
Date: Tue, 16 May 2017 20:42:46 +0200
From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch V2 15/17] mm/vmscan: Adjust system_state checks
References: <20170516184231.564888231@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Disposition: inline;
 filename=mm-vmscan--Adjust-system_state-checks.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, Mark Rutland <mark.rutland@arm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org

To enable smp_processor_id() and might_sleep() debug checks earlier, it's
required to add system states between SYSTEM_BOOTING and SYSTEM_RUNNING.

Adjust the system_state check in kswapd_run() to handle the extra states.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Reviewed-by: Steven Rostedt (VMware) <rostedt@goodmis.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org
---
 mm/vmscan.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3643,7 +3643,7 @@ int kswapd_run(int nid)
 	pgdat->kswapd = kthread_run(kswapd, pgdat, "kswapd%d", nid);
 	if (IS_ERR(pgdat->kswapd)) {
 		/* failure at boot is fatal */
-		BUG_ON(system_state == SYSTEM_BOOTING);
+		BUG_ON(system_state < SYSTEM_RUNNING);
 		pr_err("Failed to start kswapd on node %d\n", nid);
 		ret = PTR_ERR(pgdat->kswapd);
 		pgdat->kswapd = NULL;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
