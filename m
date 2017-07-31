Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 240066B04AE
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 13:50:08 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id w187so128953622pgb.10
        for <linux-mm@kvack.org>; Mon, 31 Jul 2017 10:50:08 -0700 (PDT)
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com. [209.85.192.170])
        by mx.google.com with ESMTPS id x4si17536274plm.263.2017.07.31.10.50.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Jul 2017 10:50:07 -0700 (PDT)
Received: by mail-pf0-f170.google.com with SMTP id z129so84324709pfb.3
        for <linux-mm@kvack.org>; Mon, 31 Jul 2017 10:50:06 -0700 (PDT)
From: Matthias Kaehlcke <mka@chromium.org>
Subject: [PATCH] mm/zsmalloc: Change stat type parameter to int
Date: Mon, 31 Jul 2017 10:50:00 -0700
Message-Id: <20170731175000.56538-1-mka@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Doug Anderson <dianders@chromium.org>, Matthias Kaehlcke <mka@chromium.org>

zs_stat_inc/dec/get() uses enum zs_stat_type for the stat type, however
some callers pass an enum fullness_group value. Change the type to int
to reflect the actual use of the functions and get rid of
'enum-conversion' warnings

Signed-off-by: Matthias Kaehlcke <mka@chromium.org>
---
 mm/zsmalloc.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 013eea76685e..8daf56b73024 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -551,20 +551,23 @@ static int get_size_class_index(int size)
 	return min_t(int, ZS_SIZE_CLASSES - 1, idx);
 }
 
+/* type can be of enum type zs_stat_type or fullness_group */
 static inline void zs_stat_inc(struct size_class *class,
-				enum zs_stat_type type, unsigned long cnt)
+				int type, unsigned long cnt)
 {
 	class->stats.objs[type] += cnt;
 }
 
+/* type can be of enum type zs_stat_type or fullness_group */
 static inline void zs_stat_dec(struct size_class *class,
-				enum zs_stat_type type, unsigned long cnt)
+				int type, unsigned long cnt)
 {
 	class->stats.objs[type] -= cnt;
 }
 
+/* type can be of enum type zs_stat_type or fullness_group */
 static inline unsigned long zs_stat_get(struct size_class *class,
-				enum zs_stat_type type)
+				int type)
 {
 	return class->stats.objs[type];
 }
-- 
2.14.0.rc0.400.g1c36432dff-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
