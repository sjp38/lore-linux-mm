Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id E05B96B0005
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 04:42:59 -0500 (EST)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH 0/3] Support SRAT for movablemem_map boot option.
Date: Fri, 25 Jan 2013 17:42:06 +0800
Message-Id: <1359106929-3034-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, jiang.liu@huawei.com, wujianguo@huawei.com, hpa@zytor.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, linfeng@cn.fujitsu.com, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.com, rob@landley.net, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, guz.fnst@cn.fujitsu.com, rusty@rustcorp.com.au, lliubbo@gmail.com, jaegeuk.hanse@gmail.com, tony.luck@intel.com, glommer@parallels.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

Here, we do two things:
1) patch1 ~ patch2: Prevent memblock from allocating memory in memory
                    to be set as ZONE_MOVABLE.
2) patch3:          Provide movablemem_map=acpi option for users who
                    don't want to specify physical address in kernel
                    commandline. It will use SRAT info, and set all
                    the hotpluggable memory as ZONE_MOVABLE.

After applying these 3 patches, movablemem_map boot option will work like this:

        /*
         * For movablemem_map=acpi:
         *
         * SRAT:                |_____| |_____| |_________| |_________| ......
         * node id:                0       1         1           2
         * hotpluggable:           n       y         y           n
         * movablemem_map:              |_____| |_________|
         *
         *
         * For movablemem_map=nn[KMG]@ss[KMG]:
         *
         * SRAT:                |_____| |_____| |_________| |_________| ......
         * node id:                0       1         1           2
         * user specified:                |__|                 |___|
         * movablemem_map:                |___| |_________|    |______| ......
         *
         * Using movablemem_map, we can prevent memblock from allocating memory
         * on ZONE_MOVABLE at boot time.
         *
         * NOTE: In the second case, SRAT info will be ingored.
         */

NOTE: Using this boot option could cause NUMA performance down. For users who
      don't want to lose NUMA performance, just do not use it now.
      We will improve it all along.

For more info of movablemem_map, please refer to:
      https://lkml.org/lkml/2013/1/14/87


Tang Chen (3):
  acpi, memory-hotplug: Parse SRAT before memblock is ready.
  acpi, memory-hotplug: Extend movablemem_map ranges to the end of
    node.
  acpi, memory-hotplug: Support getting hotplug info from SRAT.

 Documentation/kernel-parameters.txt |   23 ++++++++--
 arch/x86/kernel/setup.c             |   13 ++++--
 arch/x86/mm/numa.c                  |    2 +-
 arch/x86/mm/srat.c                  |   81 +++++++++++++++++++++++++++++++++-
 drivers/acpi/numa.c                 |   23 ++++++----
 include/linux/acpi.h                |    1 +
 include/linux/mm.h                  |    6 +++
 mm/page_alloc.c                     |   56 +++++++++++++++++++++++-
 8 files changed, 179 insertions(+), 26 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
