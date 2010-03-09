Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B24166B0047
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 12:19:24 -0500 (EST)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.13.1/8.13.1) with ESMTP id o29HJKBY005949
	for <linux-mm@kvack.org>; Tue, 9 Mar 2010 17:19:20 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o29HJKK61528034
	for <linux-mm@kvack.org>; Tue, 9 Mar 2010 18:19:20 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o29HJKSh008702
	for <linux-mm@kvack.org>; Tue, 9 Mar 2010 18:19:20 +0100
Date: Tue, 9 Mar 2010 18:19:33 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: [PATCH 1/2] memory hotplug: allow to set phys_device
Message-ID: <20100309171933.GB2360@osiris.boeblingen.de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <haveblue@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Gerald Schaefer <gerald.schaefer@de.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

From: Heiko Carstens <heiko.carstens@de.ibm.com>

/sys/devices/system/memory/memoryX/phys_device is supposed to contain the
number of the physical device that the corresponding piece of memory
belongs to.
In case a physical device should be replaced or taken offline for whatever
reason it is necessary to set all corresponding memory pieces offline.
The current implementation always sets phys_device to '0' and there is
no way or hook to change that. Seems like there was a plan to implement
that but it wasn't finished for whatever reason.

So add a weak function which architectures can override to actually set
the phys_device from within add_memory_block().

Cc: Dave Hansen <haveblue@us.ibm.com>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by:  Heiko Carstens <heiko.carstens@de.ibm.com>
---
 drivers/base/memory.c  |   15 ++++++++++-----
 include/linux/memory.h |    2 ++
 2 files changed, 12 insertions(+), 5 deletions(-)

--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -429,12 +429,16 @@ static inline int memory_fail_init(void)
  * differentiation between which *physical* devices each
  * section belongs to...
  */
+int __weak arch_get_memory_phys_device(unsigned long start_pfn)
+{
+	return 0;
+}
 
 static int add_memory_block(int nid, struct mem_section *section,
-			unsigned long state, int phys_device,
-			enum mem_add_context context)
+			unsigned long state, enum mem_add_context context)
 {
 	struct memory_block *mem = kzalloc(sizeof(*mem), GFP_KERNEL);
+	unsigned long start_pfn;
 	int ret = 0;
 
 	if (!mem)
@@ -443,7 +447,8 @@ static int add_memory_block(int nid, str
 	mem->phys_index = __section_nr(section);
 	mem->state = state;
 	mutex_init(&mem->state_mutex);
-	mem->phys_device = phys_device;
+	start_pfn = section_nr_to_pfn(mem->phys_index);
+	mem->phys_device = arch_get_memory_phys_device(start_pfn);
 
 	ret = register_memory(mem, section);
 	if (!ret)
@@ -515,7 +520,7 @@ int remove_memory_block(unsigned long no
  */
 int register_new_memory(int nid, struct mem_section *section)
 {
-	return add_memory_block(nid, section, MEM_OFFLINE, 0, HOTPLUG);
+	return add_memory_block(nid, section, MEM_OFFLINE, HOTPLUG);
 }
 
 int unregister_memory_section(struct mem_section *section)
@@ -548,7 +553,7 @@ int __init memory_dev_init(void)
 		if (!present_section_nr(i))
 			continue;
 		err = add_memory_block(0, __nr_to_section(i), MEM_ONLINE,
-					0, BOOT);
+				       BOOT);
 		if (!ret)
 			ret = err;
 	}
--- a/include/linux/memory.h
+++ b/include/linux/memory.h
@@ -36,6 +36,8 @@ struct memory_block {
 	struct sys_device sysdev;
 };
 
+int arch_get_memory_phys_device(unsigned long start_pfn);
+
 /* These states are exposed to userspace as text strings in sysfs */
 #define	MEM_ONLINE		(1<<0) /* exposed to userspace */
 #define	MEM_GOING_OFFLINE	(1<<1) /* exposed to userspace */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
