Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f179.google.com (mail-io0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id C0E436B0256
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 03:35:44 -0500 (EST)
Received: by mail-io0-f179.google.com with SMTP id g73so81902161ioe.3
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 00:35:44 -0800 (PST)
Received: from mgwkm03.jp.fujitsu.com (mgwkm03.jp.fujitsu.com. [202.219.69.170])
        by mx.google.com with ESMTPS id n67si7741750ioi.144.2016.01.08.00.35.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jan 2016 00:35:44 -0800 (PST)
Received: from m3051.s.css.fujitsu.com (m3051.s.css.fujitsu.com [10.134.21.209])
	by kw-mxq.gw.nic.fujitsu.com (Postfix) with ESMTP id 550FFAC0488
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 17:35:36 +0900 (JST)
From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH v4 0/2] mm: Introduce kernelcore=mirror option
Date: Fri,  8 Jan 2016 17:26:19 +0900
Message-Id: <1452241579-19601-1-git-send-email-izumi.taku@jp.fujitsu.com>
In-Reply-To: <1452241523-19559-1-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1452241523-19559-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
Cc: tony.luck@intel.com, qiuxishi@huawei.com, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, dave.hansen@intel.com, matt@codeblueprint.co.uk, arnd@arndb.de, steve.capper@linaro.org, sudeep.holla@arm.com, Taku Izumi <izumi.taku@jp.fujitsu.com>

Xeon E7 v3 based systems supports Address Range Mirroring
and UEFI BIOS complied with UEFI spec 2.5 can notify which
ranges are mirrored (reliable) via EFI memory map.
Now Linux kernel utilize its information and allocates 
boot time memory from reliable region.

My requirement is:
  - allocate kernel memory from mirrored region 
  - allocate user memory from non-mirrored region

In order to meet my requirement, ZONE_MOVABLE is useful.
By arranging non-mirrored range into ZONE_MOVABLE, 
mirrored memory is used for kernel allocations.

My idea is to extend existing "kernelcore" option and 
introduces kernelcore=mirror option. By specifying
"mirror" instead of specifying the amount of memory,
non-mirrored region will be arranged into ZONE_MOVABLE.

Earlier discussions are at: 
 https://lkml.org/lkml/2015/10/9/24
 https://lkml.org/lkml/2015/10/15/9
 https://lkml.org/lkml/2015/11/27/18
 https://lkml.org/lkml/2015/12/8/836

For example, suppose 2-nodes system with the following memory
 range: 
  node 0 [mem 0x0000000000001000-0x000000109fffffff] 
  node 1 [mem 0x00000010a0000000-0x000000209fffffff]
and the following ranges are marked as reliable (mirrored):
  [0x0000000000000000-0x0000000100000000] 
  [0x0000000100000000-0x0000000180000000] 
  [0x0000000800000000-0x0000000880000000] 
  [0x00000010a0000000-0x0000001120000000]
  [0x00000017a0000000-0x0000001820000000] 

If you specify kernelcore=mirror, ZONE_NORMAL and ZONE_MOVABLE
are arranged like bellow:

 - node 0:
  ZONE_NORMAL : [0x0000000100000000-0x00000010a0000000]
  ZONE_MOVABLE: [0x0000000180000000-0x00000010a0000000]
 - node 1: 
  ZONE_NORMAL : [0x00000010a0000000-0x00000020a0000000]
  ZONE_MOVABLE: [0x0000001120000000-0x00000020a0000000]
 
In overlapped range, pages to be ZONE_MOVABLE in ZONE_NORMAL
are treated as absent pages, and vice versa.

This patchset is created against "akpm" branch of linux-next


v1 -> v2:
 - Refine so that the above example case also can be
 handled properly:
v2 -> v3:
 - Change the option name from kernelcore=reliable
 into kernelcore=mirror and some documentation fix
 according to Andrew Morton's point
v3 -> v4:
 - Fix up the case of CONFIG_HAVE_MEMBLOCK_NODE_MAP=n
   (Fix boot failed of ARM machines)
 - No functional change in case of CONFIG_HAVE_MEMBLOCK_NODE_MAP=y


Taku Izumi (2):
  mm/page_alloc.c: calculate zone_start_pfn at
    zone_spanned_pages_in_node()
  mm/page_alloc.c: introduce kernelcore=mirror option

 Documentation/kernel-parameters.txt |  12 ++-
 mm/page_alloc.c                     | 154 ++++++++++++++++++++++++++++++++----
 2 files changed, 148 insertions(+), 18 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
