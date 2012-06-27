Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 67BB36B005A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 01:39:59 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 3F1AF3EE0C8
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 14:39:57 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 213D645DE60
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 14:39:57 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 044F445DE59
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 14:39:57 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id ECF241DB8043
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 14:39:56 +0900 (JST)
Received: from g01jpexchkw04.g01.fujitsu.local (g01jpexchkw04.g01.fujitsu.local [10.0.194.43])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 980F61DB804D
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 14:39:56 +0900 (JST)
Message-ID: <4FEA9C88.1070800@jp.fujitsu.com>
Date: Wed, 27 Jun 2012 14:39:20 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC PATCH 0/12] memory-hotplug : hot-remove physical memory
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org
Cc: len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, wency@cn.fujitsu.com

This patch series aims to support physical memory hot-remove.

  [RFC PATCH 1/12] memory-hotplug : rename remove_memory to offline_memory
  [RFC PATCH 2/12] memory-hogplug : check memory offline in offline_pages
  [RFC PATCH 3/12] memory-hotplug : add physical memory hotplug code to acpi_memory_device_remove
  [RFC PATCH 4/12] memory-hotplug : remove /sys/firmware/memmap/X sysfs
  [RFC PATCH 5/12] memory hotplug : does not release memory region in PAGES_PER_SECTION chunks
  [RFC PATCH 6/12] memory-hotplug : remove_memory calls __remove_pages
  [RFC PATCH 7/12] memory-hotplug : check page type in get_page_bootmem
  [RFC PATCH 8/12] memory-hotplug : move register_page_bootmem_info_node and put_page_bootmem for
sparse-vmemmap
  [RFC PATCH 9/12] memory-hotplug : implement register_page_bootmem_info_section of sparse-vmemmap
  [RFC PATCH 10/12] memory-hotplug : free memmap of sparse-vmemmap
  [RFC PATCH 11/12] memory-hotplug : add node_device_release
  [RFC PATCH 12/12] memory-hotplug : remove sysfs file of node

Even if you apply these patches, you cannot remove the physical memory
completely since these patches are still under development. I want you to
cooperate to improve the physical memory hot-remove. So please review these
patches and give your comment/idea.

The patches can free/remove following things:

  - acpi_memory_info                          : [RFC PATCH 3/12]
  - /sys/firmware/memmap/X/{end, start, type} : [RFC PATCH 4/12]
  - iomem_resource                            : [RFC PATCH 5/12]
  - mem_section and related sysfs files       : [RFC PATCH 6-10/12]
  - node and related sysfs files              : [RFC PATCH 11-12/12]

The patches cannot do following things yet:

  - page table of removed memory

If you find lack of function for physical memory hot-remove, please let me
know.

---

 arch/powerpc/platforms/pseries/hotplug-memory.c |   16 +-
 arch/x86/mm/init_64.c                           |  142 ++++++++++++++++++++++++
 drivers/acpi/acpi_memhotplug.c                  |   25 +++-
 drivers/base/memory.c                           |   24 +++-
 drivers/base/node.c                             |    7 +
 drivers/firmware/memmap.c                       |   71 ++++++++++++
 include/linux/firmware-map.h                    |    6 +
 include/linux/memory.h                          |    1
 include/linux/memory_hotplug.h                  |   17 --
 include/linux/mm.h                              |    5
 mm/memory_hotplug.c                             |  101 +++++++++++++----
 mm/sparse.c                                     |    5
 12 files changed, 374 insertions(+), 46 deletions(-)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
