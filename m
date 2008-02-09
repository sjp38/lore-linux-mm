Received: by py-out-1112.google.com with SMTP id f47so4291362pye.20
        for <linux-mm@kvack.org>; Sat, 09 Feb 2008 07:26:42 -0800 (PST)
Message-ID: <2f11576a0802090726pa17d91crc1067554100f715f@mail.gmail.com>
Date: Sun, 10 Feb 2008 00:26:41 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 7/8][for -mm] mem_notify v6: ignore very small zone for prevent incorrect low mem notify
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: kosaki.motohiro@jp.fujitsu.com, Marcelo Tosatti <marcelo@kvack.org>, Daniel Spang <daniel.spang@gmail.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-fsdevel@vger.kernel.org, Pavel Machek <pavel@ucw.cz>, Al Boldi <a1426z@gawab.com>, Jon Masters <jonathan@jonmasters.org>, Zan Lynx <zlynx@acm.org>
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
