Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 3CA266B004A
	for <linux-mm@kvack.org>; Fri,  6 Apr 2012 00:04:28 -0400 (EDT)
Received: by dakh32 with SMTP id h32so2694855dak.9
        for <linux-mm@kvack.org>; Thu, 05 Apr 2012 21:04:27 -0700 (PDT)
From: Sha Zhengju <handai.szj@gmail.com>
Subject: [RESEND, PATCH] memcg: make threshold index in the right position
Date: Fri,  6 Apr 2012 12:04:12 +0800
Message-Id: <1333685052-4614-1-git-send-email-handai.szj@taobao.com>
In-Reply-To: <20120405163758.b2ef6c45.akpm@linux-foundation.org>
References: <20120405163758.b2ef6c45.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, kirill@shutemov.name, Sha Zhengju <handai.szj@taobao.com>

From: Sha Zhengju <handai.szj@taobao.com>

Index current_threshold may point to threshold that just equal to
usage after last call of __mem_cgroup_threshold. But after registering
or unregistering a new event, it will change (pointing to threshold 
just below usage). So make it consistent here.

For example:
now:
        threshold array:  3  [5]  7  9   (usage = 6, [index] = 5)

next turn (after calling __mem_cgroup_threshold):
        threshold array:  3   5  [7]  9   (usage = 7, [index] = 7)

after registering a new event (threshold = 10):
        threshold array:  3  [5]  7  9  10 (usage = 7, [index] = 5)

Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: Kirill A. Shutemov <kirill@shutemov.name>

---
 mm/memcontrol.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 22d94f5..34737b7 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -183,7 +183,7 @@ struct mem_cgroup_threshold {
 
 /* For threshold */
 struct mem_cgroup_threshold_ary {
-	/* An array index points to threshold just below usage. */
+	/* An array index points to threshold just below or equal to usage. */
 	int current_threshold;
 	/* Size of entries[] */
 	unsigned int size;
@@ -4193,7 +4193,7 @@ static void __mem_cgroup_threshold(struct mem_cgroup *memcg, bool swap)
 	usage = mem_cgroup_usage(memcg, swap);
 
 	/*
-	 * current_threshold points to threshold just below usage.
+	 * current_threshold points to threshold just below or equal to usage.
 	 * If it's not true, a threshold was crossed after last
 	 * call of __mem_cgroup_threshold().
 	 */
@@ -4319,14 +4319,15 @@ static int mem_cgroup_usage_register_event(struct cgroup *cgrp,
 	/* Find current threshold */
 	new->current_threshold = -1;
 	for (i = 0; i < size; i++) {
-		if (new->entries[i].threshold < usage) {
+		if (new->entries[i].threshold <= usage) {
 			/*
 			 * new->current_threshold will not be used until
 			 * rcu_assign_pointer(), so it's safe to increment
 			 * it here.
 			 */
 			++new->current_threshold;
-		}
+		} else
+			break;
 	}
 
 	/* Free old spare buffer and save old primary buffer as spare */
@@ -4398,7 +4399,7 @@ static void mem_cgroup_usage_unregister_event(struct cgroup *cgrp,
 			continue;
 
 		new->entries[j] = thresholds->primary->entries[i];
-		if (new->entries[j].threshold < usage) {
+		if (new->entries[j].threshold <= usage) {
 			/*
 			 * new->current_threshold will not be used
 			 * until rcu_assign_pointer(), so it's safe to increment
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
