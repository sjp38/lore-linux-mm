Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 654C36B005A
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 06:02:08 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 73B6D3EE0C7
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 19:02:06 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5651B45DE5B
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 19:02:06 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 37F8245DE55
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 19:02:06 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 261101DB8053
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 19:02:06 +0900 (JST)
Received: from g01jpexchyt07.g01.fujitsu.local (g01jpexchyt07.g01.fujitsu.local [10.128.194.46])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C96B11DB804E
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 19:02:05 +0900 (JST)
Message-ID: <50068974.1070409@jp.fujitsu.com>
Date: Wed, 18 Jul 2012 19:01:24 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC PATCH v4 0/13] memory-hotplug : hot-remove physical memory
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org
Cc: rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, wency@cn.fujitsu.com

This patch series aims to support physical memory hot-remove.

  [RFC PATCH v4 1/13] memory-hotplug : rename remove_memory to offline_memory
  [RFC PATCH v4 2/13] memory-hotplug : add physical memory hotplug code to acpi_memory_device_remove
  [RFC PATCH v4 3/13] memory-hotplug : check whether memory is present or not
  [RFC PATCH v4 4/13] memory-hotplug : remove /sys/firmware/memmap/X sysfs
  [RFC PATCH v4 5/13] memory-hotplug : does not release memory region in PAGES_PER_SECTION chunks
  [RFC PATCH v4 6/13] memory-hotplug : add memory_block_release
  [RFC PATCH v4 7/13] memory-hotplug : remove_memory calls __remove_pages
  [RFC PATCH v4 8/13] memory-hotplug : check page type in get_page_bootmem
  [RFC PATCH v4 9/13] memory-hotplug : move register_page_bootmem_info_node and put_page_bootmem for
sparse-vmemmap4
  [RFC PATCH v4 10/13] memory-hotplug : implement register_page_bootmem_info_section of sparse-vmemmap
  [RFC PATCH v4 11/13] memory-hotplug : free memmap of sparse-vmemmap
  [RFC PATCH v4 12/13] memory-hotplug : add node_device_release
  [RFC PATCH v4 13/13] memory-hotplug : remove sysfs file of node

Even if you apply these patches, you cannot remove the physical memory
completely since these patches are still under development. But other
components can be removed. I want you to cooperate to improve the
physical memory hot-remove. So please review these patches and give
your comment/idea.

The patches can free/remove following things:

  - acpi_memory_info                          : [RFC PATCH 2/13]
  - /sys/firmware/memmap/X/{end, start, type} : [RFC PATCH 4/13]
  - iomem_resource                            : [RFC PATCH 5/13]
  - mem_section and related sysfs files       : [RFC PATCH 6-11/13]
  - node and related sysfs files              : [RFC PATCH 12-13/13]

The patches cannot do following things yet:

  - page table of removed memory

If you find lack of function for physical memory hot-remove, please let me
know.

change log of v4:
 * remove "memory-hotplug : unify argument of firmware_map_add_early/hotplug"
   from the patch series, since the patch is a bugfix. It is being disccussed
   on other thread. But for testing the patch series, the patch is needed.
   So I added the patch as [PATCH 0/13].

 [RFC PATCH v4 2/13]
   * check memory is online or not at remove_memory()
   * add memory_add_physaddr_to_nid() to acpi_memory_device_remove() for
     getting node id
 
 [RFC PATCH v4 3/13]
   * create new patch : check memory is online or not at online_pages()

 [RFC PATCH v4 4/13]
   * add __ref section to remove_memory()
   * call firmware_map_remove_entry() before remove_sysfs_fw_map_entry()

 [RFC PATCH v4 11/13]
   * rewrite register_page_bootmem_memmap() for removing page used as PT/PMD

change log of v3:
 * rebase to 3.5.0-rc6

 [RFC PATCH v2 2/13]
   * remove extra kobject_put()

   * The patch was commented by Wen. Wen's comment is
     "acpi_memory_device_remove() should ignore a return value of
     remove_memory() since caller does not care the return value".
     But I did not change it since I think caller should care the
     return value. And I am trying to fix it as follow:

     https://lkml.org/lkml/2012/7/5/624

 [RFC PATCH v2 4/13]
   * remove a firmware_memmap_entry allocated by kzmalloc()

change log of v2:
 [RFC PATCH v2 2/13]
   * check whether memory block is offline or not before calling offline_memory()
   * check whether section is valid or not in is_memblk_offline()
   * call kobject_put() for each memory_block in is_memblk_offline()

 [RFC PATCH v2 3/13]
   * unify the end argument of firmware_map_add_early/hotplug

 [RFC PATCH v2 4/13]
   * add release_firmware_map_entry() for freeing firmware_map_entry

 [RFC PATCH v2 6/13]
  * add release_memory_block() for freeing memory_block

 [RFC PATCH v2 11/13]
  * fix wrong arguments of free_pages()

---
 arch/powerpc/platforms/pseries/hotplug-memory.c |   16 +-
 arch/x86/mm/init_64.c                           |  144 ++++++++++++++++++++++++
 drivers/acpi/acpi_memhotplug.c                  |   28 ++++
 drivers/base/memory.c                           |   54 ++++++++-
 drivers/base/node.c                             |    7 +
 drivers/firmware/memmap.c                       |   78 ++++++++++++-
 include/linux/firmware-map.h                    |    6 +
 include/linux/memory.h                          |    5 
 include/linux/memory_hotplug.h                  |   17 --
 include/linux/mm.h                              |    5 
 mm/memory_hotplug.c                             |   98 ++++++++++++----
 mm/sparse.c                                     |    5 
 12 files changed, 414 insertions(+), 49 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
