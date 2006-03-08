Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
        by fgwmail7.fujitsu.co.jp (Fujitsu Gateway)
        with ESMTP id k28Dh4Um011732 for <linux-mm@kvack.org>; Wed, 8 Mar 2006 22:43:04 +0900
        (envelope-from y-goto@jp.fujitsu.com)
Received: from s13.gw.fujitsu.co.jp by m6.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id k28Dh3Js028547 for <linux-mm@kvack.org>; Wed, 8 Mar 2006 22:43:03 +0900
	(envelope-from y-goto@jp.fujitsu.com)
Received: from s13.gw.fujitsu.co.jp (s13 [127.0.0.1])
	by s13.gw.fujitsu.co.jp (Postfix) with ESMTP id D7FA51CC105
	for <linux-mm@kvack.org>; Wed,  8 Mar 2006 22:43:02 +0900 (JST)
Received: from ml2.s.css.fujitsu.com (ml2.s.css.fujitsu.com [10.23.4.192])
	by s13.gw.fujitsu.co.jp (Postfix) with ESMTP id 346291CC100
	for <linux-mm@kvack.org>; Wed,  8 Mar 2006 22:43:02 +0900 (JST)
Date: Wed, 08 Mar 2006 22:43:01 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [PATCH: 015/017](RFC) Memory hotplug for new nodes v.3.(allow -EEXIST of add_memory)
Message-Id: <20060308213646.0040.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <ak@suse.de>, Joel Schopp <jschopp@austin.ibm.com>, Dave Hansen <haveblue@us.ibm.com>
Cc: linux-ia64@vger.kernel.org, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

When acpi_memory_device_init() is called at boottime to
register struct memory acpi_memory_device, 
acpi_bus_add() are called via acpi_driver_attach().

But it also calls ops->start() function.
It is called even if the memory blocks are initialized at
early boottime. In this case add_memory() return -EEXIST, and
the memory blocks becomes INVALID state even if it is normal.


This is patch for it.

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

Index: pgdat6/drivers/acpi/acpi_memhotplug.c
===================================================================
--- pgdat6.orig/drivers/acpi/acpi_memhotplug.c	2006-03-06 18:26:28.000000000 +0900
+++ pgdat6/drivers/acpi/acpi_memhotplug.c	2006-03-06 18:26:30.000000000 +0900
@@ -199,7 +199,16 @@ static int acpi_memory_enable_device(str
 	 * Note: Assume that this function returns zero on success
 	 */
 	result = add_memory(mem_device->start_addr, mem_device->length);
-	if (result) {
+	switch(result) {
+	case 0:
+		break;
+	case -EEXIST:
+		ACPI_DEBUG_PRINT((ACPI_DB_INFO,
+				  "\nmemory start=%lu size=%lu has already existed\n",
+				  mem_device->start_addr,
+				  mem_device->length));
+		return 0;
+	default:
 		ACPI_ERROR((AE_INFO, "add_memory failed"));
 		mem_device->state = MEMORY_INVALID_STATE;
 		return result;

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
