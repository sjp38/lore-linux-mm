Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id BD5DF6B0031
	for <linux-mm@kvack.org>; Mon, 10 Jun 2013 07:14:15 -0400 (EDT)
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MO6007WACJM9YM0@mailout3.samsung.com> for linux-mm@kvack.org;
 Mon, 10 Jun 2013 20:14:13 +0900 (KST)
From: Hyunhee Kim <hyunhee.kim@samsung.com>
Subject: [PATCH] memcg: event control at vmpressure.
Date: Mon, 10 Jun 2013 20:14:13 +0900
Message-id: <021701ce65cb$a3b9c3b0$eb2d4b10$%kim@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Content-language: ko
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: 'Kyungmin Park' <kyungmin.park@samsung.com>

In vmpressure, events are sent to the user space continuously
until the memory state changes. This becomes overheads for user space module
and also consumes power consumption. So, with this patch, vmpressure
remembers
the current level and only sends the event only when new memory state is
different from the current level.

Signed-off-by: Hyunhee Kim <hyunhee.kim@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 include/linux/vmpressure.h |    2 ++
 mm/vmpressure.c            |    4 +++-
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/include/linux/vmpressure.h b/include/linux/vmpressure.h
index 76be077..fa0c0d2 100644
--- a/include/linux/vmpressure.h
+++ b/include/linux/vmpressure.h
@@ -20,6 +20,8 @@ struct vmpressure {
 	struct mutex events_lock;
 
 	struct work_struct work;
+
+	int current_level;
 };
 
 struct mem_cgroup;
diff --git a/mm/vmpressure.c b/mm/vmpressure.c
index 736a601..5f6609c 100644
--- a/mm/vmpressure.c
+++ b/mm/vmpressure.c
@@ -152,9 +152,10 @@ static bool vmpressure_event(struct vmpressure *vmpr,
 	mutex_lock(&vmpr->events_lock);
 
 	list_for_each_entry(ev, &vmpr->events, node) {
-		if (level >= ev->level) {
+		if (level >= ev->level && level != vmpr->current_level) {
 			eventfd_signal(ev->efd, 1);
 			signalled = true;
+			vmpr->current_level = level;
 		}
 	}
 
@@ -371,4 +372,5 @@ void vmpressure_init(struct vmpressure *vmpr)
 	mutex_init(&vmpr->events_lock);
 	INIT_LIST_HEAD(&vmpr->events);
 	INIT_WORK(&vmpr->work, vmpressure_work_fn);
+	vmpr->current_level = -1;
 }
-- 
1.7.9.5


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
