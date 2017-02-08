Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id E78CB6B0033
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 10:22:01 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id 89so5673838wrr.1
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 07:22:01 -0800 (PST)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id w48si9494470wrc.70.2017.02.08.07.22.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Feb 2017 07:22:00 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id 9257F98EDB
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 15:22:00 +0000 (UTC)
Date: Wed, 8 Feb 2017 15:22:00 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH] mm, page_alloc: only use per-cpu allocator for irq-safe
 requests -fix v2
Message-ID: <20170208152200.ydlvia2c7lm7ln3t@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@kernel.org>

preempt_enable_no_resched() was used based on review feedback that had
no strong objection at the time. The thinking was that it avoided adding
a preemption point where one didn't exist before so the feedback was
applied. This reasoning was wrong.

There was an indirect preemption point as explained by Thomas Gleixner where
an interrupt could set_need_resched() followed by preempt_enable being
a preemption point that matters. This use of preempt_enable_no_resched
is bad from both a mainline and RT perspective and a violation of the
preemption mechanism. Peter Zijlstra noted that "the only acceptable use
of preempt_enable_no_resched() is if the next statement is a schedule()
variant".

The usage was outright broken and I should have stuck to preempt_enable()
as it was originally developed. It's known from previous tests
that there was no detectable difference to the performance by using
preempt_enable_no_resched().

This is a fix to the mmotm patch
mm-page_alloc-only-use-per-cpu-allocator-for-irq-safe-requests.patch

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index eaecb4b145e6..2a36dad03dac 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2520,7 +2520,7 @@ void free_hot_cold_page(struct page *page, bool cold)
 	}
 
 out:
-	preempt_enable_no_resched();
+	preempt_enable();
 }
 
 /*
@@ -2686,7 +2686,7 @@ static struct page *rmqueue_pcplist(struct zone *preferred_zone,
 		__count_zid_vm_events(PGALLOC, page_zonenum(page), 1 << order);
 		zone_statistics(preferred_zone, zone);
 	}
-	preempt_enable_no_resched();
+	preempt_enable();
 	return page;
 }
 

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
