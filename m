Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id CFAB86B0034
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 14:39:37 -0400 (EDT)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nfont@linux.vnet.ibm.com>;
	Thu, 25 Jul 2013 04:29:09 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id F27D32BB004F
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 04:39:32 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6OINxb13015028
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 04:23:59 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6OIdW3i008104
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 04:39:32 +1000
Message-ID: <51F01F61.6010609@linux.vnet.ibm.com>
Date: Wed, 24 Jul 2013 13:39:29 -0500
From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 4/8] Create a sysfs release file for hot removing memory
References: <51F01E06.6090800@linux.vnet.ibm.com>
In-Reply-To: <51F01E06.6090800@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linuxppc-dev@lists.ozlabs.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, isimatu.yasuaki@jp.fujitsu.com

Provide a sysfs interface to hot remove memory.

This patch updates the sysfs interface for hot add of memory to also
provide a sysfs interface to hot remove memory. The use of this interface
is controlled with the ARCH_MEMORY_PROBE config option, currently used
by x86 and powerpc. This patch also updates the name of this option to
CONFIG_ARCH_MEMORY_PROBE_RELEASE to indicate that it controls the probe
and release sysfs interfaces.

Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
---
 Documentation/memory-hotplug.txt |   34 ++++++++++++----
 arch/powerpc/Kconfig             |    2 
 arch/x86/Kconfig                 |    2 
 drivers/base/memory.c            |   81 ++++++++++++++++++++++++++++++++++-----
 4 files changed, 100 insertions(+), 19 deletions(-)

Index: linux/drivers/base/memory.c
===================================================================
--- linux.orig/drivers/base/memory.c
+++ linux/drivers/base/memory.c
@@ -129,22 +129,30 @@ static ssize_t show_mem_end_phys_index(s
 	return sprintf(buf, "%08lx\n", phys_index);
 }
 
+static int is_memblock_removable(unsigned long start_section_nr)
+{
+	unsigned long pfn;
+	int i, ret = 1;
+
+	for (i = 0; i < sections_per_block; i++) {
+		pfn = section_nr_to_pfn(start_section_nr + i);
+		ret &= is_mem_section_removable(pfn, PAGES_PER_SECTION);
+	}
+
+	return ret;
+}
+
 /*
  * Show whether the section of memory is likely to be hot-removable
  */
 static ssize_t show_mem_removable(struct device *dev,
 			struct device_attribute *attr, char *buf)
 {
-	unsigned long i, pfn;
-	int ret = 1;
+	int ret;
 	struct memory_block *mem =
 		container_of(dev, struct memory_block, dev);
 
-	for (i = 0; i < sections_per_block; i++) {
-		pfn = section_nr_to_pfn(mem->start_section_nr + i);
-		ret &= is_mem_section_removable(pfn, PAGES_PER_SECTION);
-	}
-
+	ret = is_memblock_removable(mem->start_section_nr);
 	return sprintf(buf, "%d\n", ret);
 }
 
@@ -421,7 +429,7 @@ static DEVICE_ATTR(block_size_bytes, 044
  * as well as ppc64 will do all of their discovery in userspace
  * and will require this interface.
  */
-#ifdef CONFIG_ARCH_MEMORY_PROBE
+#ifdef CONFIG_ARCH_MEMORY_PROBE_RELEASE
 static ssize_t
 memory_probe_store(struct device *dev, struct device_attribute *attr,
 		   const char *buf, size_t count)
@@ -444,6 +452,60 @@ memory_probe_store(struct device *dev, s
 }
 
 static DEVICE_ATTR(probe, S_IWUSR, NULL, memory_probe_store);
+
+static int is_memblock_offline(struct memory_block *mem, void *arg)
+{
+	if (mem->state == MEM_ONLINE)
+		return 1;
+
+	return 0;
+}
+
+static ssize_t
+memory_release_store(struct device *dev, struct device_attribute *attr,
+		     const char *buf, size_t count)
+{
+	u64 phys_addr;
+	int nid, ret = 0;
+	unsigned long block_size, pfn;
+	unsigned long pages_per_block = PAGES_PER_SECTION * sections_per_block;
+
+	lock_device_hotplug();
+
+	ret = kstrtoull(buf, 0, &phys_addr);
+	if (ret)
+		goto out;
+
+	if (phys_addr & ((pages_per_block << PAGE_SHIFT) - 1)) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	block_size = get_memory_block_size();
+	nid = memory_add_physaddr_to_nid(phys_addr);
+
+	/* Ensure memory is offline and removable before removing it. */
+	ret = walk_memory_range(PFN_DOWN(phys_addr),
+				PFN_UP(phys_addr + block_size - 1), NULL,
+				is_memblock_offline);
+	if (!ret) {
+		pfn = phys_addr >> PAGE_SHIFT;
+		ret = !is_memblock_removable(pfn_to_section_nr(pfn));
+	}
+
+	if (ret) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	remove_memory(nid, phys_addr, block_size);
+
+out:
+	unlock_device_hotplug();
+	return ret ? ret : count;
+}
+
+static DEVICE_ATTR(release, S_IWUSR, NULL, memory_release_store);
 #endif
 
 #ifdef CONFIG_MEMORY_FAILURE
@@ -694,8 +756,9 @@ bool is_memblock_offlined(struct memory_
 }
 
 static struct attribute *memory_root_attrs[] = {
-#ifdef CONFIG_ARCH_MEMORY_PROBE
+#ifdef CONFIG_ARCH_MEMORY_PROBE_RELEASE
 	&dev_attr_probe.attr,
+	&dev_attr_release.attr,
 #endif
 
 #ifdef CONFIG_MEMORY_FAILURE
Index: linux/arch/powerpc/Kconfig
===================================================================
--- linux.orig/arch/powerpc/Kconfig
+++ linux/arch/powerpc/Kconfig
@@ -438,7 +438,7 @@ config SYS_SUPPORTS_HUGETLBFS
 
 source "mm/Kconfig"
 
-config ARCH_MEMORY_PROBE
+config ARCH_MEMORY_PROBE_RELEASE
 	def_bool y
 	depends on MEMORY_HOTPLUG
 
Index: linux/arch/x86/Kconfig
===================================================================
--- linux.orig/arch/x86/Kconfig
+++ linux/arch/x86/Kconfig
@@ -1343,7 +1343,7 @@ config ARCH_SELECT_MEMORY_MODEL
 	def_bool y
 	depends on ARCH_SPARSEMEM_ENABLE
 
-config ARCH_MEMORY_PROBE
+config ARCH_MEMORY_PROBE_RELEASE
 	def_bool y
 	depends on X86_64 && MEMORY_HOTPLUG
 
Index: linux/Documentation/memory-hotplug.txt
===================================================================
--- linux.orig/Documentation/memory-hotplug.txt
+++ linux/Documentation/memory-hotplug.txt
@@ -17,7 +17,9 @@ be changed often.
 3. sysfs files for memory hotplug
 4. Physical memory hot-add phase
   4.1 Hardware(Firmware) Support
-  4.2 Notify memory hot-add event by hand
+  4.2 Notify memory hot-addand hot-remove event by hand
+     4.2.1 Probe interface
+     4.2.2 Release interface
 5. Logical Memory hot-add phase
   5.1. State of memory
   5.2. How to online memory
@@ -69,7 +71,7 @@ management tables, and makes sysfs files
 
 If firmware supports notification of connection of new memory to OS,
 this phase is triggered automatically. ACPI can notify this event. If not,
-"probe" operation by system administration is used instead.
+"probe" and "release" operations by system administration is used instead.
 (see Section 4.).
 
 Logical Memory Hotplug phase is to change memory state into
@@ -208,20 +210,23 @@ calls hotplug code for all of objects wh
 If memory device is found, memory hotplug code will be called.
 
 
-4.2 Notify memory hot-add event by hand
+4.2 Notify memory hot-add and hot-remove event by hand
 ------------
 In some environments, especially virtualized environment, firmware will not
 notify memory hotplug event to the kernel. For such environment, "probe"
-interface is supported. This interface depends on CONFIG_ARCH_MEMORY_PROBE.
+and "release" interfaces are supported. This interface depends on
+CONFIG_ARCH_MEMORY_PROBE_RELEASE.
 
-Now, CONFIG_ARCH_MEMORY_PROBE is supported only by powerpc but it does not
-contain highly architecture codes. Please add config if you need "probe"
-interface.
+Now, CONFIG_ARCH_MEMORY_PROBE_RELEASE is supported only by powerpc but it does
+not contain highly architecture codes. Please add config if you need "probe"
+and "release" interfaces.
 
+4.2.1 "probe" interface
+------------
 Probe interface is located at
 /sys/devices/system/memory/probe
 
-You can tell the physical address of new memory to the kernel by
+You can tell the physical address of new memory to hot-add to the kernel by
 
 % echo start_address_of_new_memory > /sys/devices/system/memory/probe
 
@@ -230,6 +235,19 @@ memory range is hot-added. In this case,
 current implementation). You'll have to online memory by yourself.
 Please see "How to online memory" in this text.
 
+4.2.2 "release" interface
+------------
+Release interface is located at
+/sys/devices/system/memory/release
+
+You can tell the physical address of memory to hot-remove from the kernel by
+
+% echo start_address_of_memory > /sys/devices/system/memory/release
+
+Then, [start_address_of_memory, start_address_of_memory + section_size)
+memory range is hot-removed. You will need to ensure all of the memory in
+this range has been offlined prior to using this interface, please see
+"How to offline memory" in this text.
 
 
 ------------------------------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
