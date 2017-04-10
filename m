Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id EA0C86B03A0
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 07:58:39 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id t68so64287776iof.16
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 04:58:39 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id s206si7510793itd.97.2017.04.10.04.58.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 10 Apr 2017 04:58:38 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm,page_alloc: Split stall warning and failure warning.
Date: Mon, 10 Apr 2017 20:58:13 +0900
Message-Id: <1491825493-8859-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

Patch "mm: page_alloc: __GFP_NOWARN shouldn't suppress stall warnings"
changed to drop __GFP_NOWARN when calling warn_alloc() for stall warning.
Although I suggested for two times to drop __GFP_NOWARN when warn_alloc()
for stall warning was proposed, Michal Hocko does not want to print stall
warnings when __GFP_NOWARN is given [1][2].

 "I am not going to allow defining a weird __GFP_NOWARN semantic which
  allows warnings but only sometimes. At least not without having a proper
  way to silence both failures _and_ stalls or just stalls. I do not
  really thing this is worth the additional gfp flag."

I don't know whether he is aware of "mm: page_alloc: __GFP_NOWARN
shouldn't suppress stall warnings" patch, but I assume that
no response means he finally accepted this change. Therefore,
this patch splits into a function for reporting allocation stalls
and a function for reporting allocation failures, due to below reasons.

  (1) Dropping __GFP_NOWARN when calling warn_alloc() causes
      "mode:%#x(%pGg)" to report incorrect flags. It can confuse
      developers when scanning the source code for corresponding
      location.

  (2) Not reporting when debug_guardpage_minorder() > 0 causes failing
      to report stall warnings. Stall warnings should not be be disabled
      by debug_guardpage_minorder() > 0 as well as __GFP_NOWARN.

  (3) Sharing warn_alloc() for reporting stalls (which is guaranteed
      to be schedulable context) and for reporting failures (which is
      not guaranteed to be schedulable context) is inconvenient when
      adding a mutex for serializing printk() messages and/or filtering
      events which should be handled for further analysis based on
      function name.

      # stap -F -g -e 'probe kernel.function("warn_alloc").return {
                       if (determine_whether_reason_is_allocation_stall)
                           panic("MemAlloc stall detected."); }'

      # stap -F -g -e 'probe kernel.function("warn_alloc_stall").return {
                       panic("MemAlloc stall detected."); }'

      Although adding allocation watchdog [3] will do it more powerfully,
      allocation watchdog discussion is still stalling. Thus, for now
      I propose triggering from warn_alloc_stall().

[1] http://lkml.kernel.org/r/20160929091040.GE408@dhcp22.suse.cz
[2] http://lkml.kernel.org/r/20170114090613.GD9962@dhcp22.suse.cz
[3] http://lkml.kernel.org/r/1489578541-81526-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
---
 mm/page_alloc.c | 41 ++++++++++++++++++++++++++---------------
 1 file changed, 26 insertions(+), 15 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 32b31d6..bde435d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3124,11 +3124,20 @@ static inline bool should_suppress_show_mem(void)
 	return ret;
 }
 
-static void warn_alloc_show_mem(gfp_t gfp_mask, nodemask_t *nodemask)
+static void warn_alloc_common(gfp_t gfp_mask, nodemask_t *nodemask)
 {
 	unsigned int filter = SHOW_MEM_FILTER_NODES;
 	static DEFINE_RATELIMIT_STATE(show_mem_rs, HZ, 1);
 
+	pr_cont(", mode:%#x(%pGg), nodemask=", gfp_mask, &gfp_mask);
+	if (nodemask)
+		pr_cont("%*pbl\n", nodemask_pr_args(nodemask));
+	else
+		pr_cont("(null)\n");
+
+	cpuset_print_current_mems_allowed();
+
+	dump_stack();
 	if (should_suppress_show_mem() || !__ratelimit(&show_mem_rs))
 		return;
 
@@ -3147,6 +3156,20 @@ static void warn_alloc_show_mem(gfp_t gfp_mask, nodemask_t *nodemask)
 	show_mem(filter, nodemask);
 }
 
+static void warn_alloc_stall(gfp_t gfp_mask, nodemask_t *nodemask,
+			     unsigned long alloc_start, int order)
+{
+	static DEFINE_RATELIMIT_STATE(stall_rs, DEFAULT_RATELIMIT_INTERVAL,
+				      DEFAULT_RATELIMIT_BURST);
+
+	if (!__ratelimit(&stall_rs))
+		return;
+
+	pr_warn("%s: page allocation stalls for %ums, order:%u",
+		current->comm, jiffies_to_msecs(jiffies-alloc_start), order);
+	warn_alloc_common(gfp_mask, nodemask);
+}
+
 void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 {
 	struct va_format vaf;
@@ -3165,17 +3188,7 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 	vaf.va = &args;
 	pr_cont("%pV", &vaf);
 	va_end(args);
-
-	pr_cont(", mode:%#x(%pGg), nodemask=", gfp_mask, &gfp_mask);
-	if (nodemask)
-		pr_cont("%*pbl\n", nodemask_pr_args(nodemask));
-	else
-		pr_cont("(null)\n");
-
-	cpuset_print_current_mems_allowed();
-
-	dump_stack();
-	warn_alloc_show_mem(gfp_mask, nodemask);
+	warn_alloc_common(gfp_mask, nodemask);
 }
 
 static inline struct page *
@@ -3814,9 +3827,7 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 
 	/* Make sure we know about allocations which stall for too long */
 	if (time_after(jiffies, alloc_start + stall_timeout)) {
-		warn_alloc(gfp_mask & ~__GFP_NOWARN, ac->nodemask,
-			"page allocation stalls for %ums, order:%u",
-			jiffies_to_msecs(jiffies-alloc_start), order);
+		warn_alloc_stall(gfp_mask, ac->nodemask, alloc_start, order);
 		stall_timeout += 10 * HZ;
 	}
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
