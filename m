Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 1F4036B13F2
	for <linux-mm@kvack.org>; Thu,  2 Feb 2012 21:50:30 -0500 (EST)
Received: by iagz16 with SMTP id z16so5696069iag.14
        for <linux-mm@kvack.org>; Thu, 02 Feb 2012 18:50:29 -0800 (PST)
From: Sha Zhengju <handai.szj@gmail.com>
Subject: [PATCH] memcg: make threshold index in the right position
Date: Fri,  3 Feb 2012 10:49:56 +0800
Message-Id: <1328237396-12453-1-git-send-email-handai.szj@taobao.com>
In-Reply-To: <1328175919-11209-1-git-send-email-handai.szj@taobao.com>
References: <1328175919-11209-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, cgroups@vger.kernel.org
Cc: kamezawa.hiroyu@jp.fujitsu.com, kirill@shutemov.name, Sha Zhengju <handai.szj@taobao.com>

From: Sha Zhengju <handai.szj@taobao.com>

Index current_threshold may point to threshold that just equal to
usage after last call of __mem_cgroup_threshold. But after registering
a new event, it will change (pointing to threshold just below usage).
So make it consistent here.

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
 mm/memcontrol.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 22d94f5..95fc9f07 100644
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
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
