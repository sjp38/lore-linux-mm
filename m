Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id BD3A36B0069
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 10:34:43 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id u16so2675381pfh.7
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 07:34:43 -0800 (PST)
Received: from mailout3.samsung.com (mailout3.samsung.com. [203.254.224.33])
        by mx.google.com with ESMTPS id p1si1413967pgr.812.2017.11.29.07.34.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Nov 2017 07:34:42 -0800 (PST)
Received: from epcas5p4.samsung.com (unknown [182.195.41.42])
	by mailout3.samsung.com (KnoxPortal) with ESMTP id 20171129153440epoutp033e0fff5b1e18258d0dc750343128d1ed~7mGnKszLc0111301113epoutp03f
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 15:34:40 +0000 (GMT)
Mime-Version: 1.0
Subject: [PATCH] zswap: Update with same-value filled page feature
Reply-To: srividya.dr@samsung.com
From: Srividya Desireddy <srividya.dr@samsung.com>
In-Reply-To: <CALZtONA1R8HyODqUP8Z-0yxvRAsV=Zo8OD2PQT3HwWWmqE6Hig@mail.gmail.com>
Message-ID: <20171129153437epcms5p64b04efa370cc42bb0f9e5677e298704e@epcms5p6>
Date: Wed, 29 Nov 2017 15:34:37 +0000
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset="utf-8"
References: <CALZtONA1R8HyODqUP8Z-0yxvRAsV=Zo8OD2PQT3HwWWmqE6Hig@mail.gmail.com>
	<20171018104832epcms5p1b2232e2236258de3d03d1344dde9fce0@epcms5p1>
	<20171120154648.6c2f96804c4c1668bd8d572a@linux-foundation.org>
	<CGME20171018104832epcms5p1b2232e2236258de3d03d1344dde9fce0@epcms5p6>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>, "sjenning@redhat.com" <sjenning@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: Dinakar Reddy Pathireddy <dinakar.p@samsung.com>, RAJIB BASU <rajib.basu@samsung.com>, Srikanth Mandalapu <srikanth.m@samsung.com>, SHARAN ALLUR <sharan.allur@samsung.com>, JUHUN KIM <juhunkim@samsung.com>, Srividya Desireddy <srividya.dr@samsung.com>, "srividya.desireddy@gmail.com" <srividya.desireddy@gmail.com>

From: Srividya Desireddy <srividya.dr@samsung.com>
Date: Wed, 29 Nov 2017 20:23:15 +0530
Subject: [PATCH] zswap: Update with same-value filled page feature

Updated zswap document with details on same-value filled
pages identification feature.
The usage of zswap.same_filled_pages_enabled module parameter
is explained.

Signed-off-by: Srividya Desireddy <srividya.dr@samsung.com>
---
 Documentation/vm/zswap.txt | 22 +++++++++++++++++++++-
 1 file changed, 21 insertions(+), 1 deletion(-)

diff --git a/Documentation/vm/zswap.txt b/Documentation/vm/zswap.txt
index 89fff7d..cc015b5 100644
--- a/Documentation/vm/zswap.txt
+++ b/Documentation/vm/zswap.txt
@@ -98,5 +98,25 @@ request is made for a page in an old zpool, it is uncompressed using its
 original compressor.  Once all pages are removed from an old zpool, the zpool
 and its compressor are freed.
 
+Some of the pages in zswap are same-value filled pages (i.e. contents of the
+page have same value or repetitive pattern). These pages include zero-filled
+pages and they are handled differently. During store operation, a page is
+checked if it is a same-value filled page before compressing it. If true, the
+compressed length of the page is set to zero and the pattern or same-filled
+value is stored.
+
+Same-value filled pages identification feature is enabled by default and can be
+disabled at boot time by setting the "same_filled_pages_enabled" attribute to 0,
+e.g. zswap.same_filled_pages_enabled=0. It can also be enabled and disabled at
+runtime using the sysfs "same_filled_pages_enabled" attribute, e.g.
+
+echo 1 > /sys/module/zswap/parameters/same_filled_pages_enabled
+
+When zswap same-filled page identification is disabled at runtime, it will stop
+checking for the same-value filled pages during store operation. However, the
+existing pages which are marked as same-value filled pages will be loaded or
+invalidated.
+
 A debugfs interface is provided for various statistic about pool size, number
-of pages stored, and various counters for the reasons pages are rejected.
+of pages stored, same-value filled pages and various counters for the reasons
+pages are rejected.
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
