Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id D06F26B004D
	for <linux-mm@kvack.org>; Tue,  6 Mar 2012 07:13:36 -0500 (EST)
Received: by ghrr18 with SMTP id r18so2640249ghr.14
        for <linux-mm@kvack.org>; Tue, 06 Mar 2012 04:13:36 -0800 (PST)
From: Sha Zhengju <handai.szj@gmail.com>
Subject: [PATCH] memcg: Free spare array to avoid memory leak
Date: Tue,  6 Mar 2012 20:13:24 +0800
Message-Id: <1331036004-7550-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, cgroups@vger.kernel.org
Cc: kamezawa.hiroyu@jp.fujitsu.com, kirill@shutemov.name, Sha Zhengju <handai.szj@taobao.com>

From: Sha Zhengju <handai.szj@taobao.com>

When the last event is unregistered, there is no need to keep the spare
array anymore. So free it to avoid memory leak.

Signed-off-by: Sha Zhengju <handai.szj@taobao.com>

---
 mm/memcontrol.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 22d94f5..3c09a84 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4412,6 +4412,12 @@ static void mem_cgroup_usage_unregister_event(struct cgroup *cgrp,
 swap_buffers:
 	/* Swap primary and spare array */
 	thresholds->spare = thresholds->primary;
+	/* If all events are unregistered, free the spare array */
+	if (!new) {
+		kfree(thresholds->spare);
+		thresholds->spare = NULL;
+	}
+
 	rcu_assign_pointer(thresholds->primary, new);
 
 	/* To be sure that nobody uses thresholds */
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
