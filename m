Date: Thu, 24 Jan 2008 13:24:48 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [RFC][PATCH 7/8] mem_notify v5: ignore very small zone for prevent incorrect low mem notify.
In-Reply-To: <20080124130348.1760.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080124130348.1760.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20080124132355.1775.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: kosaki.motohiro@jp.fujitsu.com, Marcelo Tosatti <marcelo@kvack.org>, Daniel Spang <daniel.spang@gmail.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>
List-ID: <linux-mm.kvack.org>

on X86, ZONE_DMA is very very small.
it cause undesirable low mem notification.
It should ignored.

but on other some architecture, ZONE_DMA have 4GB.
4GB is large as it is not possible to ignored.

therefore, ignore or not is decided by zone size.

ChangeLog:
	v5: new


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

---
 include/linux/mem_notify.h |    3 +++
 mm/page_alloc.c            |    6 +++++-
 2 files changed, 8 insertions(+), 1 deletion(-)

Index: b/include/linux/mem_notify.h
===================================================================
--- a/include/linux/mem_notify.h	2008-01-23 22:06:04.000000000 +0900
+++ b/include/linux/mem_notify.h	2008-01-23 22:08:02.000000000 +0900
@@ -22,6 +22,9 @@ static inline void memory_pressure_notif
 	unsigned long target;
 	unsigned long pages_high, pages_free, pages_reserve;
 
+	if (unlikely(zone->mem_notify_status == -1))
+		return;
+
 	if (pressure) {
 		target = atomic_long_read(&last_mem_notify) + MEM_NOTIFY_FREQ;
 		if (likely(time_before(jiffies, target)))
Index: b/mm/page_alloc.c
===================================================================
--- a/mm/page_alloc.c	2008-01-23 22:07:57.000000000 +0900
+++ b/mm/page_alloc.c	2008-01-23 22:08:02.000000000 +0900
@@ -3470,7 +3470,11 @@ static void __meminit free_area_init_cor
 		zone->zone_pgdat = pgdat;
 
 		zone->prev_priority = DEF_PRIORITY;
-		zone->mem_notify_status = 0;
+
+		if (zone->present_pages < (pgdat->node_present_pages / 10))
+			zone->mem_notify_status = -1;
+		else
+			zone->mem_notify_status = 0;
 
 		zone_pcp_init(zone);
 		INIT_LIST_HEAD(&zone->active_list);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
