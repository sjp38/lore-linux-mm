Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id 94ACC6B0035
	for <linux-mm@kvack.org>; Wed, 13 Aug 2014 08:14:07 -0400 (EDT)
Received: by mail-we0-f174.google.com with SMTP id x48so11288648wes.33
        for <linux-mm@kvack.org>; Wed, 13 Aug 2014 05:14:07 -0700 (PDT)
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
        by mx.google.com with ESMTPS id nd8si2323926wic.57.2014.08.13.05.14.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 13 Aug 2014 05:14:06 -0700 (PDT)
Received: by mail-wg0-f43.google.com with SMTP id l18so11011739wgh.26
        for <linux-mm@kvack.org>; Wed, 13 Aug 2014 05:14:05 -0700 (PDT)
Message-ID: <53EB568B.2060006@plexistor.com>
Date: Wed, 13 Aug 2014 15:14:03 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: [RFC 4/9] SQUASHME: prd: Fixs to getgeo
References: <53EB5536.8020702@gmail.com>
In-Reply-To: <53EB5536.8020702@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Matthew Wilcox <willy@linux.intel.com>, Sagi Manole <sagi@plexistor.com>, Yigal Korman <yigal@plexistor.com>

From: Boaz Harrosh <boaz@plexistor.com>

With current values fdisk does the wrong thing.

Setting all values to 1, will make everything nice and easy.

Note that current code had a BUG with anything bigger than
64G because hd_geometry->cylinders is ushort and it would
overflow at this value. Any way capacity is not calculated
through getgeo so it does not matter what you put here.

Signed-off-by: Boaz Harrosh <boaz@plexistor.com>
---
 drivers/block/prd.c | 16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/block/prd.c b/drivers/block/prd.c
index cc0aabf..62af81e 100644
--- a/drivers/block/prd.c
+++ b/drivers/block/prd.c
@@ -55,10 +55,18 @@ struct prd_device {
 
 static int prd_getgeo(struct block_device *bd, struct hd_geometry *geo)
 {
-	/* some standard values */
-	geo->heads = 1 << 6;
-	geo->sectors = 1 << 5;
-	geo->cylinders = get_capacity(bd->bd_disk) >> 11;
+	/* Just tell fdisk to get out of the way. The math here is so
+	 * convoluted and does not make any sense at all. With all 1s
+	 * The math just gets out of the way.
+	 * NOTE: I was trying to get some values that will make fdisk
+	 * Want to align first sector on 4K (like 8, 16, 20, ... sectors) but
+	 * nothing worked, I searched the net the math is not your regular
+	 * simple multiplication at all. If you managed to get these please
+	 * fix here. For now we use 4k physical sectors for this
+	 */
+	geo->heads = 1;
+	geo->sectors = 1;
+	geo->cylinders = 1;
 	return 0;
 }
 
-- 
1.9.3


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
