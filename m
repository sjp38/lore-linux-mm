From: Con Kolivas <kernel@kolivas.org>
Date: Mon, 20 Mar 2006 02:34:00 +1100
MIME-Version: 1.0
Content-Disposition: inline
Subject: [PATCH][3/3] mm: swsusp post resume aggressive swap prefetch
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <200603200234.01472.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux list <linux-kernel@vger.kernel.org>
Cc: ck list <ck@vds.kolivas.org>, Andrew Morton <akpm@osdl.org>, Rafael Wysocki <rjw@sisk.pl>, Pavel Machek <pavel@ucw.cz>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Swsusp reclaims a lot of memory during the suspend cycle and can benefit
from the aggressive_swap_prefetch mode immediately upon resuming.

Signed-off-by: Con Kolivas <kernel@kolivas.org>

---
 kernel/power/swsusp.c |    3 +++
 1 files changed, 3 insertions(+)

Index: linux-2.6.16-rc6-mm2/kernel/power/swsusp.c
===================================================================
--- linux-2.6.16-rc6-mm2.orig/kernel/power/swsusp.c	2006-03-20 02:15:47.000000000 +1100
+++ linux-2.6.16-rc6-mm2/kernel/power/swsusp.c	2006-03-20 02:20:35.000000000 +1100
@@ -49,6 +49,7 @@
 #include <linux/bootmem.h>
 #include <linux/syscalls.h>
 #include <linux/highmem.h>
+#include <linux/swap-prefetch.h>
 
 #include "power.h"
 
@@ -239,6 +240,8 @@ Restore_highmem:
 	device_power_up();
 Enable_irqs:
 	local_irq_enable();
+	if (!in_suspend)
+		aggressive_swap_prefetch();
 	return error;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
