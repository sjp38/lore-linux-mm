Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id CA9096B0036
	for <linux-mm@kvack.org>; Thu, 21 Mar 2013 05:18:42 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [RFC PATCH part2 0/4] Allow allocating pagetable on local node in movablemem_map.
Date: Thu, 21 Mar 2013 17:21:12 +0800
Message-Id: <1363857676-30694-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rob@landley.net, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, yinghai@kernel.org, akpm@linux-foundation.org, wency@cn.fujitsu.com, trenn@suse.de, liwanp@linux.vnet.ibm.com, mgorman@suse.de, walken@google.com, riel@redhat.com, khlebnikov@openvz.org, tj@kernel.org, minchan@kernel.org, m.szyprowski@samsung.com, mina86@mina86.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, linfeng@cn.fujitsu.com, jiang.liu@huawei.com, kosaki.motohiro@jp.fujitsu.com, guz.fnst@cn.fujitsu.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Yinghai, all,

This patch-set is based on Yinghai's tree:
git://git.kernel.org/pub/scm/linux/kernel/git/yinghai/linux-yinghai.git for-x86-mm

For main line, we need to apply Yinghai's
"x86, ACPI, numa: Parse numa info early" patch-set first.
Please refer to:
v1: https://lkml.org/lkml/2013/3/7/642
v2: https://lkml.org/lkml/2013/3/10/47


In this part2 patch-set, we didi the following things:
1) Introduce a "bool hotpluggable" member into struct numa_memblk so that we are
   able to know which memory ranges in numa_meminfo are hotpluggable.
   All the related apis have been changed.
2) Introduce a new global variable "numa_meminfo_all" to store all the memory ranges
   recorded in SRAT, because numa_cleanup_meminfo() will remove ranges higher than
   max_pfn.
   We need full numa memory info to limit zone_movable_pfn[].
3) Move movablemem_map sanitization after memory mapping is initialized so that
   pagetable allocation will not be limited by movablemem_map.


On the other hand, we may have another way to solve this problem:

Not only pagetable and vmemmap pages, but also all the data whose life cycle is the
same as a node, could be put on local node.

1) Introduce a flag into memblock, such as "LOCAL_NODE_DATA", to mark out which
   ranges have the same life cycle with node.
2) Only keep existing memory ranges in movablemem_map (no need to introduce
   numa_meminfo_all), and exclude these LOCAL_NODE_DATA ranges.
3) When hot-removing, we are able to find out these ranges, and free them first.
   This is very important.

Also, hot-add logic needs to be modified, too. As Yinghai mentioned before, I think
we can make memblock alive when memory is hot-added. And go with the same logic
as it is when booting.

How do you think?


Tang Chen (4):
  x86, mm, numa, acpi: Introduce numa_meminfo_all to store all the numa
    meminfo.
  x86, mm, numa, acpi: Introduce hotplug info into struct numa_meminfo.
  x86, mm, numa, acpi: Consider hotplug info when cleanup numa_meminfo.
  x86, mm, numa, acpi: Sanitize movablemem_map after memory mapping
    initialized.

 arch/x86/include/asm/numa.h     |    3 +-
 arch/x86/kernel/apic/numaq_32.c |    2 +-
 arch/x86/mm/amdtopology.c       |    3 +-
 arch/x86/mm/numa.c              |  161 +++++++++++++++++++++++++++++++++++++--
 arch/x86/mm/numa_internal.h     |    1 +
 arch/x86/mm/srat.c              |  141 +++++-----------------------------
 6 files changed, 178 insertions(+), 133 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
