Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id B74586B0007
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 16:55:38 -0500 (EST)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 28 Jan 2013 14:55:37 -0700
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id BCE553E40044
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 14:55:26 -0700 (MST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0SLtXm0290268
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 14:55:33 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0SLtTgD004375
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 14:55:30 -0700
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCHv3 2/6] zsmalloc: promote to lib/
Date: Mon, 28 Jan 2013 15:49:23 -0600
Message-Id: <1359409767-30092-3-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1359409767-30092-1-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1359409767-30092-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

This patch promotes the slab-based zsmalloc memory allocator
from the staging tree to lib/

zswap depends on this allocator for storing compressed RAM pages
in an efficient way under system wide memory pressure where
high-order (greater than 0) page allocation are very likely to
fail.

For more information on zsmalloc and its internals, read the
documentation at the top of the zsmalloc.c file.

Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
--
This patch is similar to a patch Minchan has on out on the list
to promote for use in zram.
---
 drivers/staging/Kconfig                            |    2 --
 drivers/staging/Makefile                           |    1 -
 drivers/staging/zcache/zcache-main.c               |    3 +--
 drivers/staging/zram/zram_drv.h                    |    3 +--
 drivers/staging/zsmalloc/Kconfig                   |   10 ----------
 drivers/staging/zsmalloc/Makefile                  |    3 ---
 .../staging/zsmalloc => include/linux}/zsmalloc.h  |    0
 lib/Kconfig                                        |   18 ++++++++++++++++++
 lib/Makefile                                       |    1 +
 .../zsmalloc/zsmalloc-main.c => lib/zsmalloc.c     |    3 +--
 10 files changed, 22 insertions(+), 22 deletions(-)
 delete mode 100644 drivers/staging/zsmalloc/Kconfig
 delete mode 100644 drivers/staging/zsmalloc/Makefile
 rename {drivers/staging/zsmalloc => include/linux}/zsmalloc.h (100%)
 rename drivers/staging/zsmalloc/zsmalloc-main.c => lib/zsmalloc.c (99%)

diff --git a/drivers/staging/Kconfig b/drivers/staging/Kconfig
index 329bdb4..c0a7918 100644
--- a/drivers/staging/Kconfig
+++ b/drivers/staging/Kconfig
@@ -76,8 +76,6 @@ source "drivers/staging/zram/Kconfig"
 
 source "drivers/staging/zcache/Kconfig"
 
-source "drivers/staging/zsmalloc/Kconfig"
-
 source "drivers/staging/wlags49_h2/Kconfig"
 
 source "drivers/staging/wlags49_h25/Kconfig"
diff --git a/drivers/staging/Makefile b/drivers/staging/Makefile
index c7ec486..1572fe5 100644
--- a/drivers/staging/Makefile
+++ b/drivers/staging/Makefile
@@ -32,7 +32,6 @@ obj-$(CONFIG_DX_SEP)            += sep/
 obj-$(CONFIG_IIO)		+= iio/
 obj-$(CONFIG_ZRAM)		+= zram/
 obj-$(CONFIG_ZCACHE)		+= zcache/
-obj-$(CONFIG_ZSMALLOC)		+= zsmalloc/
 obj-$(CONFIG_WLAGS49_H2)	+= wlags49_h2/
 obj-$(CONFIG_WLAGS49_H25)	+= wlags49_h25/
 obj-$(CONFIG_FB_SM7XX)		+= sm7xxfb/
diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
index 52b43b7..75c08c5 100644
--- a/drivers/staging/zcache/zcache-main.c
+++ b/drivers/staging/zcache/zcache-main.c
@@ -32,10 +32,9 @@
 #include <linux/crypto.h>
 #include <linux/string.h>
 #include <linux/idr.h>
+#include <linux/zsmalloc.h>
 #include "tmem.h"
 
-#include "../zsmalloc/zsmalloc.h"
-
 #ifdef CONFIG_CLEANCACHE
 #include <linux/cleancache.h>
 #endif
diff --git a/drivers/staging/zram/zram_drv.h b/drivers/staging/zram/zram_drv.h
index df2eec4..1e72965 100644
--- a/drivers/staging/zram/zram_drv.h
+++ b/drivers/staging/zram/zram_drv.h
@@ -17,8 +17,7 @@
 
 #include <linux/spinlock.h>
 #include <linux/mutex.h>
-
-#include "../zsmalloc/zsmalloc.h"
+#include <linux/zsmalloc.h>
 
 /*
  * Some arbitrary value. This is just to catch
diff --git a/drivers/staging/zsmalloc/Kconfig b/drivers/staging/zsmalloc/Kconfig
deleted file mode 100644
index 9084565..0000000
--- a/drivers/staging/zsmalloc/Kconfig
+++ /dev/null
@@ -1,10 +0,0 @@
-config ZSMALLOC
-	tristate "Memory allocator for compressed pages"
-	default n
-	help
-	  zsmalloc is a slab-based memory allocator designed to store
-	  compressed RAM pages.  zsmalloc uses virtual memory mapping
-	  in order to reduce fragmentation.  However, this results in a
-	  non-standard allocator interface where a handle, not a pointer, is
-	  returned by an alloc().  This handle must be mapped in order to
-	  access the allocated space.
diff --git a/drivers/staging/zsmalloc/Makefile b/drivers/staging/zsmalloc/Makefile
deleted file mode 100644
index b134848..0000000
--- a/drivers/staging/zsmalloc/Makefile
+++ /dev/null
@@ -1,3 +0,0 @@
-zsmalloc-y 		:= zsmalloc-main.o
-
-obj-$(CONFIG_ZSMALLOC)	+= zsmalloc.o
diff --git a/drivers/staging/zsmalloc/zsmalloc.h b/include/linux/zsmalloc.h
similarity index 100%
rename from drivers/staging/zsmalloc/zsmalloc.h
rename to include/linux/zsmalloc.h
diff --git a/lib/Kconfig b/lib/Kconfig
index 75cdb77..fdab273 100644
--- a/lib/Kconfig
+++ b/lib/Kconfig
@@ -219,6 +219,24 @@ config DECOMPRESS_LZO
 config GENERIC_ALLOCATOR
 	boolean
 
+config ZSMALLOC
+	tristate "Memory allocator for compressed pages"
+	default n
+	help
+	  zsmalloc is a slab-based memory allocator designed to store
+	  compressed RAM pages.  zsmalloc uses a memory pool that combines
+	  single pages into higher order pages by linking them together
+	  using the fields of the struct page. Allocations are then
+	  mapped through copy buffers or VM mapping, in order to reduce
+	  memory pool fragmentation and increase allocation success rate under
+	  memory pressure.
+
+	  This results in a non-standard allocator interface where
+	  a handle, not a pointer, is returned by the allocation function.
+	  This handle must be mapped in order to access the allocated space.
+
+	  If unsure, say N.
+
 #
 # reed solomon support is select'ed if needed
 #
diff --git a/lib/Makefile b/lib/Makefile
index 02ed6c0..70b0892 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -65,6 +65,7 @@ obj-$(CONFIG_CRC7)	+= crc7.o
 obj-$(CONFIG_LIBCRC32C)	+= libcrc32c.o
 obj-$(CONFIG_CRC8)	+= crc8.o
 obj-$(CONFIG_GENERIC_ALLOCATOR) += genalloc.o
+obj-$(CONFIG_ZSMALLOC) += zsmalloc.o
 
 obj-$(CONFIG_ZLIB_INFLATE) += zlib_inflate/
 obj-$(CONFIG_ZLIB_DEFLATE) += zlib_deflate/
diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/lib/zsmalloc.c
similarity index 99%
rename from drivers/staging/zsmalloc/zsmalloc-main.c
rename to lib/zsmalloc.c
index 13018b7..d5146c7 100644
--- a/drivers/staging/zsmalloc/zsmalloc-main.c
+++ b/lib/zsmalloc.c
@@ -78,8 +78,7 @@
 #include <linux/hardirq.h>
 #include <linux/spinlock.h>
 #include <linux/types.h>
-
-#include "zsmalloc.h"
+#include <linux/zsmalloc.h>
 
 /*
  * This must be power of 2 and greater than of equal to sizeof(link_free).
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
