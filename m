Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id A5C996B0072
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 16:04:36 -0400 (EDT)
Received: from /spool/local
	by e3.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Tue, 4 Sep 2012 16:04:07 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 981266E816F
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 16:03:31 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q84K3UdO113664
	for <linux-mm@kvack.org>; Tue, 4 Sep 2012 16:03:30 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q84K3ULW008049
	for <linux-mm@kvack.org>; Tue, 4 Sep 2012 16:03:30 -0400
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCH v2 1/3] zsmalloc: promote to mm/
Date: Tue,  4 Sep 2012 15:02:47 -0500
Message-Id: <1346788969-4100-2-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1346788969-4100-1-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1346788969-4100-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

This patch promotes the slab-based zsmalloc memory allocator
from the staging tree to mm/

zcache depends on this allocator for storing compressed RAM pages
in an efficient way under system wide memory pressure where
high-order (greater than 0) page allocation are very likely to
fail.

For more information on zsmalloc and its internals, read the
documentation at the top of the zsmalloc c file.

Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
 drivers/staging/Kconfig                            |    2 --
 drivers/staging/Makefile                           |    1 -
 drivers/staging/zcache/zcache-main.c               |    4 ++--
 drivers/staging/zram/zram_drv.h                    |    3 +--
 drivers/staging/zsmalloc/Kconfig                   |   10 ----------
 drivers/staging/zsmalloc/Makefile                  |    3 ---
 .../staging/zsmalloc => include/linux}/zsmalloc.h  |    0
 mm/Kconfig                                         |   18 ++++++++++++++++++
 mm/Makefile                                        |    1 +
 .../zsmalloc/zsmalloc-main.c => mm/zsmalloc.c      |    3 +--
 10 files changed, 23 insertions(+), 22 deletions(-)
 delete mode 100644 drivers/staging/zsmalloc/Kconfig
 delete mode 100644 drivers/staging/zsmalloc/Makefile
 rename {drivers/staging/zsmalloc => include/linux}/zsmalloc.h (100%)
 rename drivers/staging/zsmalloc/zsmalloc-main.c => mm/zsmalloc.c (99%)

diff --git a/drivers/staging/Kconfig b/drivers/staging/Kconfig
index e3402d5..b7f7bc7 100644
--- a/drivers/staging/Kconfig
+++ b/drivers/staging/Kconfig
@@ -78,8 +78,6 @@ source "drivers/staging/zram/Kconfig"
 
 source "drivers/staging/zcache/Kconfig"
 
-source "drivers/staging/zsmalloc/Kconfig"
-
 source "drivers/staging/wlags49_h2/Kconfig"
 
 source "drivers/staging/wlags49_h25/Kconfig"
diff --git a/drivers/staging/Makefile b/drivers/staging/Makefile
index 3be59d0..ad74bee 100644
--- a/drivers/staging/Makefile
+++ b/drivers/staging/Makefile
@@ -34,7 +34,6 @@ obj-$(CONFIG_DX_SEP)            += sep/
 obj-$(CONFIG_IIO)		+= iio/
 obj-$(CONFIG_ZRAM)		+= zram/
 obj-$(CONFIG_ZCACHE)		+= zcache/
-obj-$(CONFIG_ZSMALLOC)		+= zsmalloc/
 obj-$(CONFIG_WLAGS49_H2)	+= wlags49_h2/
 obj-$(CONFIG_WLAGS49_H25)	+= wlags49_h25/
 obj-$(CONFIG_FB_SM7XX)		+= sm7xxfb/
diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
index 52b43b7..34b2c5c 100644
--- a/drivers/staging/zcache/zcache-main.c
+++ b/drivers/staging/zcache/zcache-main.c
@@ -32,9 +32,9 @@
 #include <linux/crypto.h>
 #include <linux/string.h>
 #include <linux/idr.h>
-#include "tmem.h"
+#include <linux/zsmalloc.h>
 
-#include "../zsmalloc/zsmalloc.h"
+#include "tmem.h"
 
 #ifdef CONFIG_CLEANCACHE
 #include <linux/cleancache.h>
diff --git a/drivers/staging/zram/zram_drv.h b/drivers/staging/zram/zram_drv.h
index 572c0b1..f6d0925 100644
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
diff --git a/mm/Kconfig b/mm/Kconfig
index d5c8019..2586b66 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -411,3 +411,21 @@ config FRONTSWAP
 	  and swap data is stored as normal on the matching swap device.
 
 	  If unsure, say Y to enable frontswap.
+
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
diff --git a/mm/Makefile b/mm/Makefile
index 92753e2..8a3d7bea 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -57,3 +57,4 @@ obj-$(CONFIG_DEBUG_KMEMLEAK) += kmemleak.o
 obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) += kmemleak-test.o
 obj-$(CONFIG_CLEANCACHE) += cleancache.o
 obj-$(CONFIG_MEMORY_ISOLATION) += page_isolation.o
+obj-$(CONFIG_ZSMALLOC) += zsmalloc.o
diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/mm/zsmalloc.c
similarity index 99%
rename from drivers/staging/zsmalloc/zsmalloc-main.c
rename to mm/zsmalloc.c
index 09a9d35..6b20429 100644
--- a/drivers/staging/zsmalloc/zsmalloc-main.c
+++ b/mm/zsmalloc.c
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
