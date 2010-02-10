Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id BB4646B0071
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 21:42:21 -0500 (EST)
Received: by ey-out-1920.google.com with SMTP id 13so171139eye.18
        for <linux-mm@kvack.org>; Wed, 10 Feb 2010 15:55:39 -0800 (PST)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: [PATCH mmotm] memcg: check if first threshold crossed
Date: Thu, 11 Feb 2010 01:55:23 +0200
Message-Id: <1265846123-2244-1-git-send-email-kirill@shutemov.name>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

There is a bug in memory thresholds code. We don't check if first
threshold (array index 0) was crossed down. This patch fixes it.

Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Pavel Emelyanov <xemul@openvz.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 41e00c2..a443c30 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3252,7 +3252,7 @@ static void __mem_cgroup_threshold(struct mem_cgroup *memcg, bool swap)
 	 * If none of thresholds below usage is crossed, we read
 	 * only one element of the array here.
 	 */
-	for (; i > 0 && unlikely(t->entries[i].threshold > usage); i--)
+	for (; i >= 0 && unlikely(t->entries[i].threshold > usage); i--)
 		eventfd_signal(t->entries[i].eventfd, 1);
 
 	/* i = current_threshold + 1 */
-- 
1.6.5.8

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
