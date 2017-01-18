Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0FCAF6B0038
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 16:51:17 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id d185so32370363pgc.2
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 13:51:17 -0800 (PST)
Received: from mail-pg0-x231.google.com (mail-pg0-x231.google.com. [2607:f8b0:400e:c05::231])
        by mx.google.com with ESMTPS id n123si1410575pga.28.2017.01.18.13.51.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jan 2017 13:51:15 -0800 (PST)
Received: by mail-pg0-x231.google.com with SMTP id 194so7664838pgd.2
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 13:51:15 -0800 (PST)
Date: Wed, 18 Jan 2017 13:51:14 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm] mm, page_alloc: warn_alloc nodemask is NULL when cpusets
 are disabled
Message-ID: <alpine.DEB.2.10.1701181347320.142399@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

The patch "mm, page_alloc: warn_alloc print nodemask" implicitly sets the 
allocation nodemask to cpuset_current_mems_allowed when there is no 
effective mempolicy.  cpuset_current_mems_allowed is only effective when 
cpusets are enabled, which is also printed by warn_alloc(), so setting 
the nodemask to cpuset_current_mems_allowed is redundant and prevents 
debugging issues where ac->nodemask is not set properly in the page 
allocator.

This provides better debugging output since 
cpuset_print_current_mems_allowed() is already provided.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/page_alloc.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3037,7 +3037,6 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 	va_list args;
 	static DEFINE_RATELIMIT_STATE(nopage_rs, DEFAULT_RATELIMIT_INTERVAL,
 				      DEFAULT_RATELIMIT_BURST);
-	nodemask_t *nm = (nodemask) ? nodemask : &cpuset_current_mems_allowed;
 
 	if ((gfp_mask & __GFP_NOWARN) || !__ratelimit(&nopage_rs) ||
 	    debug_guardpage_minorder() > 0)
@@ -3051,11 +3050,16 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 	pr_cont("%pV", &vaf);
 	va_end(args);
 
-	pr_cont(", mode:%#x(%pGg), nodemask=%*pbl\n", gfp_mask, &gfp_mask, nodemask_pr_args(nm));
+	pr_cont(", mode:%#x(%pGg), nodemask=", gfp_mask, &gfp_mask);
+	if (nodemask)
+		pr_cont("%*pbl\n", nodemask_pr_args(nodemask));
+	else
+		pr_cont("(null)\n");
+
 	cpuset_print_current_mems_allowed();
 
 	dump_stack();
-	warn_alloc_show_mem(gfp_mask, nm);
+	warn_alloc_show_mem(gfp_mask, nodemask);
 }
 
 static inline struct page *

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
