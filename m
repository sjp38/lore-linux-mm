Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 448AB6B0255
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 22:01:45 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id ho8so22801228pac.2
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 19:01:45 -0800 (PST)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id n88si6096785pfb.139.2016.02.17.19.01.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Feb 2016 19:01:44 -0800 (PST)
Received: by mail-pa0-x22b.google.com with SMTP id yy13so22163497pab.3
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 19:01:44 -0800 (PST)
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: [RFC PATCH 3/3] mm/zsmalloc: change ZS_MAX_PAGES_PER_ZSPAGE
Date: Thu, 18 Feb 2016 12:02:36 +0900
Message-Id: <1455764556-13979-4-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1455764556-13979-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1455764556-13979-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

ZS_MAX_PAGES_PER_ZSPAGE does not have to be order or 2. The existing
limit of 4 pages per zspage sets a tight limit on ->huge classes, which
results in increased memory wastage and consumption.

For example, on x86_64, PAGE_SHIFT 12, ->huge class_size range is

ZS_MAX_PAGES_PER_ZSPAGE		->huge classes size range
4					3280-4096
5					3424-4096
6					3520-4096

With bigger ZS_MAX_PAGES_PER_ZSPAGE we have less ->huge classes, because
some of the previously known as ->huge classes now have better chances to
form zspages that will waste less memory. This increases the density and
improves memory efficiency.

Example,

class_size 3328 with ZS_MAX_PAGES_PER_ZSPAGE=5 has pages_per_zspage 5
and max_objects 6, while with ZS_MAX_PAGES_PER_ZSPAGE=1 it had
pages_per_zspage 1 and max_objects 1. So now every 6th 3328-bytes object
stored by zram will not consume a new zspage (and order-0 page), but will
share an already allocated one.

TEST
====

Create a text file and do rounds of dd (one process). The amount of
copied data, its content and order are stable.

test script:

rm /tmp/test-file
for i in {1..200}; do
	cat /media/dev/linux-mmots/mm/zsmalloc.c >> /tmp/test-file;
done

for i in {1..5}; do
        umount /zram
        rmmod zram

        # create a 4G zram device, LZ0, multi stream, ext4 fs
        ./create-zram 4g

        for k in {1..3}; do
                j=1;
                while [ $j -lt $((1024*1024)) ]; do
                        dd if=/tmp/test-file of=/zram/file-$k-$j bs=$j count=1 \
                                oflag=sync > /dev/null 2>&1
                        let j=$j+512
                done
        done

        sync
        cat /sys/block/zram0/mm_stat >> /tmp/zram-stat
        umount /zram
        rmmod zram
done

RESULTS
=======
cat /sys/block/zram0/mm_stat column 3 is zs_get_total_pages() << PAGE_SHIFT

BASE
3371106304 1714719722 1842778112        0 1842778112       16        0        1
3371098112 1714667024 1842831360        0 1842831360       16        0        1
3371110400 1714767329 1842716672        0 1842716672       16        0        1
3371110400 1714717615 1842601984        0 1842601984       16        0        1
3371106304 1714744207 1842135040        0 1842135040       16        0        1

ZS_MAX_PAGES_PER_ZSPAGE=5
3371094016 1714584459 1804095488        0 1804095488       16        0        1
3371102208 1714619140 1804660736        0 1804660736       16        0        1
3371114496 1714755452 1804316672        0 1804316672       16        0        1
3371081728 1714606179 1804800000        0 1804800000       16        0        1
3371122688 1714871507 1804361728        0 1804361728       16        0        1

ZS_MAX_PAGES_PER_ZSPAGE=6
3371114496 1714704275 1789206528        0 1789206528       16        0        1
3371102208 1714740225 1789259776        0 1789259776       16        0        1
3371102208 1714717465 1789071360        0 1789071360       16        0        1
3371110400 1714704079 1789194240        0 1789194240       16        0        1
3371085824 1714792954 1789308928        0 1789308928       16        0        1

So that's
 around 36MB of saved space between BASE and ZS_MAX_PAGES_PER_ZSPAGE=5
and
 around 51MB of saved space between BASE and ZS_MAX_PAGES_PER_ZSPAGE=6.

Set ZS_MAX_PAGES_PER_ZSPAGE to 6 for now.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 mm/zsmalloc.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 61b1b35..0c9f117 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -74,11 +74,10 @@
 #define ZS_ALIGN		8
 
 /*
- * A single 'zspage' is composed of up to 2^N discontiguous 0-order (single)
- * pages. ZS_MAX_ZSPAGE_ORDER defines upper limit on N.
+ * A single 'zspage' is composed of up ZS_MAX_PAGES_PER_ZSPAGE discontiguous
+ * 0-order (single) pages.
  */
-#define ZS_MAX_ZSPAGE_ORDER 2
-#define ZS_MAX_PAGES_PER_ZSPAGE (_AC(1, UL) << ZS_MAX_ZSPAGE_ORDER)
+#define ZS_MAX_PAGES_PER_ZSPAGE	6
 
 #define ZS_HANDLE_SIZE (sizeof(unsigned long))
 
-- 
2.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
