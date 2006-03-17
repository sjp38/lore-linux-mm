Date: Fri, 17 Mar 2006 17:23:04 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [PATCH: 016/017]Memory hotplug for new nodes v.4.(get node id from acpi's handle)
Message-Id: <20060317163841.C657.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Andi Kleen <ak@suse.de>, "Luck, Tony" <tony.luck@intel.com>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, linux-mm <linux-mm@kvack.org>
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

 drivers/acpi/acpi_memhotplug.c |    5 +++--
 drivers/acpi/numa.c            |   15 +++++++++++++++
 include/linux/acpi.h           |    6 ++++++
 3 files changed, 24 insertions(+), 2 deletions(-)

Index: pgdat8/drivers/acpi/acpi_memhotplug.c
===================================================================
--- pgdat8.orig/drivers/acpi/acpi_memhotplug.c	2006-03-16 16:06:27.000000000 +0900
+++ pgdat8/drivers/acpi/acpi_memhotplug.c	2006-03-16 16:06:27.000000000 +0900
@@ -214,7 +214,7 @@ static int acpi_memory_check_device(stru
 
 static int acpi_memory_enable_device(struct acpi_memory_device *mem_device)
 {
-	int result, num_enabled = 0;
+	int result, num_enabled = 0, node;
 	struct acpi_memory_info *info;
 
 	ACPI_FUNCTION_TRACE("acpi_memory_enable_device");
@@ -227,6 +227,7 @@ static int acpi_memory_enable_device(str
 		return result;
 	}
 
+	node = acpi_get_node(mem_device->handle);
 	/*
 	 * Tell the VM there is more memory here...
 	 * Note: Assume that this function returns zero on success
@@ -244,7 +245,7 @@ static int acpi_memory_enable_device(str
 			continue;
 		}
 
-		result = add_memory(info->start_addr, info->length);
+		result = add_memory(node, info->start_addr, info->length);
 		if (result)
 			continue;
 		info->enabled = 1;
Index: pgdat8/drivers/acpi/numa.c
===================================================================
--- pgdat8.orig/drivers/acpi/numa.c	2006-03-16 16:04:55.000000000 +0900
+++ pgdat8/drivers/acpi/numa.c	2006-03-16 16:06:27.000000000 +0900
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
Index: pgdat8/include/linux/acpi.h
===================================================================
--- pgdat8.orig/include/linux/acpi.h	2006-03-16 16:04:55.000000000 +0900
+++ pgdat8/include/linux/acpi.h	2006-03-16 16:06:27.000000000 +0900
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
