Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id EDE856B0258
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 08:10:03 -0400 (EDT)
Received: by widdq5 with SMTP id dq5so48115415wid.1
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 05:10:03 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id n5si31657564wjr.158.2015.08.24.05.09.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=RC4-SHA bits=128/128);
        Mon, 24 Aug 2015 05:09:54 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 35BAB990DE
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 12:09:53 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 04/12] mm, page_alloc: Only check cpusets when one exists that can be mem-controlled
Date: Mon, 24 Aug 2015 13:09:43 +0100
Message-Id: <1440418191-10894-5-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1440418191-10894-1-git-send-email-mgorman@techsingularity.net>
References: <1440418191-10894-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

David Rientjes correctly pointed out that the "root cpuset may not exclude
mems on the system so, even if mounted, there's no need to check or be
worried about concurrent change when there is only one cpuset".

The three checks for cpusets_enabled() care whether a cpuset exists that
can limit memory, not that cpuset is enabled as such. This patch replaces
cpusets_enabled() with cpusets_mems_enabled() which checks if at least one
cpuset exists that can limit memory and updates the appropriate call sites.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/cpuset.h | 16 +++++++++-------
 mm/page_alloc.c        |  2 +-
 2 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/include/linux/cpuset.h b/include/linux/cpuset.h
index 6eb27cb480b7..1e823870987e 100644
--- a/include/linux/cpuset.h
+++ b/include/linux/cpuset.h
@@ -17,10 +17,6 @@
 #ifdef CONFIG_CPUSETS
 
 extern struct static_key cpusets_enabled_key;
-static inline bool cpusets_enabled(void)
-{
-	return static_key_false(&cpusets_enabled_key);
-}
 
 static inline int nr_cpusets(void)
 {
@@ -28,6 +24,12 @@ static inline int nr_cpusets(void)
 	return static_key_count(&cpusets_enabled_key) + 1;
 }
 
+/* Returns true if a cpuset exists that can set cpuset.mems */
+static inline bool cpusets_mems_enabled(void)
+{
+	return nr_cpusets() > 1;
+}
+
 static inline void cpuset_inc(void)
 {
 	static_key_slow_inc(&cpusets_enabled_key);
@@ -104,7 +106,7 @@ extern void cpuset_print_task_mems_allowed(struct task_struct *p);
  */
 static inline unsigned int read_mems_allowed_begin(void)
 {
-	if (!cpusets_enabled())
+	if (!cpusets_mems_enabled())
 		return 0;
 
 	return read_seqcount_begin(&current->mems_allowed_seq);
@@ -118,7 +120,7 @@ static inline unsigned int read_mems_allowed_begin(void)
  */
 static inline bool read_mems_allowed_retry(unsigned int seq)
 {
-	if (!cpusets_enabled())
+	if (!cpusets_mems_enabled())
 		return false;
 
 	return read_seqcount_retry(&current->mems_allowed_seq, seq);
@@ -139,7 +141,7 @@ static inline void set_mems_allowed(nodemask_t nodemask)
 
 #else /* !CONFIG_CPUSETS */
 
-static inline bool cpusets_enabled(void) { return false; }
+static inline bool cpusets_mems_enabled(void) { return false; }
 
 static inline int cpuset_init(void) { return 0; }
 static inline void cpuset_init_smp(void) {}
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 62ae28d8ae8d..2c1c3bf54d15 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2470,7 +2470,7 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 		if (IS_ENABLED(CONFIG_NUMA) && zlc_active &&
 			!zlc_zone_worth_trying(zonelist, z, allowednodes))
 				continue;
-		if (cpusets_enabled() &&
+		if (cpusets_mems_enabled() &&
 			(alloc_flags & ALLOC_CPUSET) &&
 			!cpuset_zone_allowed(zone, gfp_mask))
 				continue;
-- 
2.4.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
