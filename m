Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
        by fgwmail6.fujitsu.co.jp (Fujitsu Gateway)
        with ESMTP id k28DgvKt015407 for <linux-mm@kvack.org>; Wed, 8 Mar 2006 22:42:57 +0900
        (envelope-from y-goto@jp.fujitsu.com)
Received: from s12.gw.fujitsu.co.jp by m5.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id k28Dgv5o026573 for <linux-mm@kvack.org>; Wed, 8 Mar 2006 22:42:57 +0900
	(envelope-from y-goto@jp.fujitsu.com)
Received: from s12.gw.fujitsu.co.jp (s12 [127.0.0.1])
	by s12.gw.fujitsu.co.jp (Postfix) with ESMTP id 201791CC125
	for <linux-mm@kvack.org>; Wed,  8 Mar 2006 22:42:57 +0900 (JST)
Received: from ml8.s.css.fujitsu.com (ml8.s.css.fujitsu.com [10.23.4.198])
	by s12.gw.fujitsu.co.jp (Postfix) with ESMTP id 9AB531CC00E
	for <linux-mm@kvack.org>; Wed,  8 Mar 2006 22:42:56 +0900 (JST)
Date: Wed, 08 Mar 2006 22:42:56 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [PATCH: 014/017](RFC) Memory hotplug for new nodes v.3.(add start function acpi_memhotplug)
Message-Id: <20060308213548.003E.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <ak@suse.de>, Joel Schopp <jschopp@austin.ibm.com>, Dave Hansen <haveblue@us.ibm.com>
Cc: linux-ia64@vger.kernel.org, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

This is a patch to call add_memroy() when notify reaches for 
new node's add event.

When new node is added, notify of ACPI reaches container device
which means the node.
Container device driver calls acpi_bus_scan() to find and add
belonging devices (which means cpu, memory and so on).
Its function calls add and start function of belonging 
devices's driver.

Howevever, current memory hotplug driver just register add function to
create sysfs file for its memory. But, acpi_memory_enable_device()
is not called because it is considered just the case that notify reaches
memory device directly. So, if notify reaches container device 
nothing can call add_memory().

This is a patch to create start function which calls add_memory().
add_memory() can be called by this when notify reaches container device.


Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

Index: pgdat6/drivers/acpi/acpi_memhotplug.c
===================================================================
--- pgdat6.orig/drivers/acpi/acpi_memhotplug.c	2006-03-06 18:38:18.000000000 +0900
+++ pgdat6/drivers/acpi/acpi_memhotplug.c	2006-03-06 19:06:54.000000000 +0900
@@ -57,6 +57,7 @@ MODULE_LICENSE("GPL");
 
 static int acpi_memory_device_add(struct acpi_device *device);
 static int acpi_memory_device_remove(struct acpi_device *device, int type);
+static int acpi_memory_device_start (struct acpi_device *device);
 
 static struct acpi_driver acpi_memory_device_driver = {
 	.name = ACPI_MEMORY_DEVICE_DRIVER_NAME,
@@ -65,6 +66,7 @@ static struct acpi_driver acpi_memory_de
 	.ops = {
 		.add = acpi_memory_device_add,
 		.remove = acpi_memory_device_remove,
+		.start = acpi_memory_device_start,
 		},
 };
 
@@ -382,6 +384,26 @@ static int acpi_memory_device_remove(str
 	return_VALUE(0);
 }
 
+static int
+acpi_memory_device_start (struct acpi_device *device)
+{
+	struct acpi_memory_device *mem_device = NULL;
+	int result = 0;
+
+	ACPI_FUNCTION_TRACE("acpi_memory_device_start");
+
+	mem_device = (struct acpi_memory_device *) acpi_driver_data(device);
+
+	if (!acpi_memory_check_device(mem_device)){
+		/* call add_memory func */
+		result = acpi_memory_enable_device(mem_device);
+		if (result)
+			ACPI_DEBUG_PRINT((ACPI_DB_ERROR,
+			"Error in acpi_memory_enable_device\n"));
+	}
+	return_VALUE(result);
+}
+
 /*
  * Helper function to check for memory device
  */

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
