Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f169.google.com (mail-qk0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id 01A066B0038
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 13:33:34 -0400 (EDT)
Received: by qkfh127 with SMTP id h127so78139362qkf.1
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 10:33:33 -0700 (PDT)
Received: from mail-qg0-x22a.google.com (mail-qg0-x22a.google.com. [2607:f8b0:400d:c04::22a])
        by mx.google.com with ESMTPS id 192si1306763qhc.102.2015.08.24.10.33.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Aug 2015 10:33:33 -0700 (PDT)
Received: by qgeg42 with SMTP id g42so91367460qge.1
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 10:33:32 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCHv2] zswap: update docs for runtime-changeable attributes
Date: Mon, 24 Aug 2015 13:33:15 -0400
Message-Id: <1440437595-10518-1-git-send-email-ddstreet@ieee.org>
In-Reply-To: <CALZtONB9LaMhYZNk7_aHp3iGigHLAmZ1uQLSKEni94RNOAKUSg@mail.gmail.com>
References: <CALZtONB9LaMhYZNk7_aHp3iGigHLAmZ1uQLSKEni94RNOAKUSg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>, Seth Jennings <sjennings@variantweb.net>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>
Cc: linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Streetman <ddstreet@ieee.org>

Change the Documentation/vm/zswap.txt doc to indicate that the "zpool"
and "compressor" params are now changeable at runtime.

Cc: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Dan Streetman <ddstreet@ieee.org>
---
changes since v1:
  update doc on working of zbud per Vlastimil Babka's suggestion
  add explanation of how old pages are handled when changing zpool/compressor

 Documentation/vm/zswap.txt | 36 ++++++++++++++++++++++++++++--------
 1 file changed, 28 insertions(+), 8 deletions(-)

diff --git a/Documentation/vm/zswap.txt b/Documentation/vm/zswap.txt
index 8458c08..89fff7d 100644
--- a/Documentation/vm/zswap.txt
+++ b/Documentation/vm/zswap.txt
@@ -32,7 +32,7 @@ can also be enabled and disabled at runtime using the sysfs interface.
 An example command to enable zswap at runtime, assuming sysfs is mounted
 at /sys, is:
 
-echo 1 > /sys/modules/zswap/parameters/enabled
+echo 1 > /sys/module/zswap/parameters/enabled
 
 When zswap is disabled at runtime it will stop storing pages that are
 being swapped out.  However, it will _not_ immediately write out or fault
@@ -49,14 +49,26 @@ Zswap receives pages for compression through the Frontswap API and is able to
 evict pages from its own compressed pool on an LRU basis and write them back to
 the backing swap device in the case that the compressed pool is full.
 
-Zswap makes use of zbud for the managing the compressed memory pool.  Each
-allocation in zbud is not directly accessible by address.  Rather, a handle is
+Zswap makes use of zpool for the managing the compressed memory pool.  Each
+allocation in zpool is not directly accessible by address.  Rather, a handle is
 returned by the allocation routine and that handle must be mapped before being
 accessed.  The compressed memory pool grows on demand and shrinks as compressed
-pages are freed.  The pool is not preallocated.
+pages are freed.  The pool is not preallocated.  By default, a zpool of type
+zbud is created, but it can be selected at boot time by setting the "zpool"
+attribute, e.g. zswap.zpool=zbud.  It can also be changed at runtime using the
+sysfs "zpool" attribute, e.g.
+
+echo zbud > /sys/module/zswap/parameters/zpool
+
+The zbud type zpool allocates exactly 1 page to store 2 compressed pages, which
+means the compression ratio will always be 2:1 or worse (because of half-full
+zbud pages).  The zsmalloc type zpool has a more complex compressed page
+storage method, and it can achieve greater storage densities.  However,
+zsmalloc does not implement compressed page eviction, so once zswap fills it
+cannot evict the oldest page, it can only reject new pages.
 
 When a swap page is passed from frontswap to zswap, zswap maintains a mapping
-of the swap entry, a combination of the swap type and swap offset, to the zbud
+of the swap entry, a combination of the swap type and swap offset, to the zpool
 handle that references that compressed swap page.  This mapping is achieved
 with a red-black tree per swap type.  The swap offset is the search key for the
 tree nodes.
@@ -74,9 +86,17 @@ controlled policy:
 * max_pool_percent - The maximum percentage of memory that the compressed
     pool can occupy.
 
-Zswap allows the compressor to be selected at kernel boot time by setting the
-a??compressora?? attribute.  The default compressor is lzo.  e.g.
-zswap.compressor=deflate
+The default compressor is lzo, but it can be selected at boot time by setting
+the a??compressora?? attribute, e.g. zswap.compressor=lzo.  It can also be changed
+at runtime using the sysfs "compressor" attribute, e.g.
+
+echo lzo > /sys/module/zswap/parameters/compressor
+
+When the zpool and/or compressor parameter is changed at runtime, any existing
+compressed pages are not modified; they are left in their own zpool.  When a
+request is made for a page in an old zpool, it is uncompressed using its
+original compressor.  Once all pages are removed from an old zpool, the zpool
+and its compressor are freed.
 
 A debugfs interface is provided for various statistic about pool size, number
 of pages stored, and various counters for the reasons pages are rejected.
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
