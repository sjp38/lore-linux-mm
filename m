Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 68EAF6B0033
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 09:31:30 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id jz4so33260993wjb.5
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 06:31:30 -0800 (PST)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id a2si2633002wmd.120.2017.02.08.06.31.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Feb 2017 06:31:29 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 093E798ECD
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 14:31:29 +0000 (UTC)
Date: Wed, 8 Feb 2017 14:31:28 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH] mm, page_alloc: only use per-cpu allocator for irq-safe
 requests -fix
Message-ID: <20170208143128.25ahymqlyspjcixu@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@kernel.org>

preempt_enable_no_resched() was used based on review feedback that had no
strong objection at the time. It avoided introducing a preemption point
where one didn't exist before which was marginal at best.

However, it is hazardous to the RT tree according to Thomas Gleixner
and is a violation of its expected use according to Peter Zijlstra. In
Peter's own words "the only acceptable use of preempt_enable_no_resched()
is if the next statement is a schedule() variant".

The impact of using preempt_enable in this particular
fast path is negligible. This is a fix to the mmotm patch
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
