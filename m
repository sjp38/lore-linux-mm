Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
        by fgwmail7.fujitsu.co.jp (Fujitsu Gateway)
        with ESMTP id k28Dh8Em011789 for <linux-mm@kvack.org>; Wed, 8 Mar 2006 22:43:08 +0900
        (envelope-from y-goto@jp.fujitsu.com)
Received: from s7.gw.fujitsu.co.jp by m3.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id k28Dh70Y029183 for <linux-mm@kvack.org>; Wed, 8 Mar 2006 22:43:07 +0900
	(envelope-from y-goto@jp.fujitsu.com)
Received: from s7.gw.fujitsu.co.jp (s7 [127.0.0.1])
	by s7.gw.fujitsu.co.jp (Postfix) with ESMTP id 783B8208282
	for <linux-mm@kvack.org>; Wed,  8 Mar 2006 22:43:07 +0900 (JST)
Received: from ml6.s.css.fujitsu.com (ml6.s.css.fujitsu.com [10.23.4.196])
	by s7.gw.fujitsu.co.jp (Postfix) with ESMTP id 38C8A208287
	for <linux-mm@kvack.org>; Wed,  8 Mar 2006 22:43:07 +0900 (JST)
Date: Wed, 08 Mar 2006 22:43:07 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [PATCH: 016/017](RFC) Memory hotplug for new nodes v.3. (get node id from acpi's handle)
Message-Id: <20060308213726.0042.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <ak@suse.de>, Joel Schopp <jschopp@austin.ibm.com>, Dave Hansen <haveblue@us.ibm.com>
Cc: linux-ia64@vger.kernel.org, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

This is to find node id from acpi's handle of memory_device in DSDT.
_PXM for the new node can be found by acpi_get_pxm()
by using new memory's handle. 
So, node id can be found by pxm_to_nid_map[].

  This patch becomes simpler than v2. Because old add_memory()
  function doesn't have node id parameter. So, kernel must 
  find its handle by physical address via DSDT again.
  But, v3 just give node id to add_memory() now.

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

Index: pgdat6/drivers/acpi/acpi_memhotplug.c
===================================================================
--- pgdat6.orig/drivers/acpi/acpi_memhotplug.c	2006-03-06 18:26:30.000000000 +0900
+++ pgdat6/drivers/acpi/acpi_memhotplug.c	2006-03-06 18:26:31.000000000 +0900
@@ -182,7 +182,7 @@ static int acpi_memory_check_device(stru
 
 static int acpi_memory_enable_device(struct acpi_memory_device *mem_device)
 {
-	int result;
+	int result, node;
 
 	ACPI_FUNCTION_TRACE("acpi_memory_enable_device");
 
@@ -194,11 +194,12 @@ static int acpi_memory_enable_device(str
 		return result;
 	}
 
+	node = acpi_get_node(mem_device->handle);
 	/*
 	 * Tell the VM there is more memory here...
 	 * Note: Assume that this function returns zero on success
 	 */
-	result = add_memory(mem_device->start_addr, mem_device->length);
+	result = add_memory(node, mem_device->start_addr, mem_device->length);
 	switch(result) {
 	case 0:
 		break;
Index: pgdat6/drivers/acpi/numa.c
===================================================================
--- pgdat6.orig/drivers/acpi/numa.c	2006-03-06 18:25:32.000000000 +0900
+++ pgdat6/drivers/acpi/numa.c	2006-03-06 18:26:31.000000000 +0900
@@ -258,3 +258,18 @@ int acpi_get_pxm(acpi_handle h)
 }
 
 EXPORT_SYMBOL(acpi_get_pxm);
+
+int acpi_get_node(acpi_handle *handle)
+{
+	int pxm, node = -1;
+
+	ACPI_FUNCTION_TRACE("acpi_get_node");
+
+	pxm = acpi_get_pxm(handle);
+	if (pxm >= 0)
+		node = acpi_map_pxm_to_node(pxm);
+
+	return_VALUE(node);
+}
+
+EXPORT_SYMBOL(acpi_get_node);
Index: pgdat6/include/linux/acpi.h
===================================================================
--- pgdat6.orig/include/linux/acpi.h	2006-03-06 18:25:37.000000000 +0900
+++ pgdat6/include/linux/acpi.h	2006-03-06 18:26:31.000000000 +0900
@@ -529,12 +529,18 @@ static inline void acpi_set_cstate_limit
 
 #ifdef CONFIG_ACPI_NUMA
 int acpi_get_pxm(acpi_handle handle);
+int acpi_get_node(acpi_handle *handle);
 #else
 static inline int acpi_get_pxm(acpi_handle handle)
 {
 	return 0;
 }
+static inline int acpi_get_node(acpi_handle *handle)
+{
+	return 0;
+}
 #endif
+extern int acpi_paddr_to_node(u64 start_addr, u64 size);
 
 extern int pnpacpi_disabled;
 

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
