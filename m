Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id E83FC6B0257
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 22:15:57 -0500 (EST)
Received: by igcsu19 with SMTP id su19so1640565igc.0
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 19:15:57 -0800 (PST)
Received: from mgwym01.jp.fujitsu.com (mgwym01.jp.fujitsu.com. [211.128.242.40])
        by mx.google.com with ESMTPS id f11si9554883ioj.131.2015.12.08.19.15.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Dec 2015 19:15:57 -0800 (PST)
Received: from m3050.s.css.fujitsu.com (msm.b.css.fujitsu.com [10.134.21.208])
	by yt-mxoi1.gw.nic.fujitsu.com (Postfix) with ESMTP id 06FC2AC027B
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 12:15:51 +0900 (JST)
From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH v3 0/2] mm: Introduce kernelcore=mirror option
Date: Wed,  9 Dec 2015 12:18:29 +0900
Message-Id: <1449631109-14756-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
Cc: tony.luck@intel.com, qiuxishi@huawei.com, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, dave.hansen@intel.com, matt@codeblueprint.co.uk, Taku Izumi <izumi.taku@jp.fujitsu.com>

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

v1 -> v2:
 Refine so that the above example case also can be
 handled properly:
v2 -> v3:
 Change the option name from kernelcore=reliable
 into kernelcore=mirror and some documentation fix
 according to Andrew Morton's point

 
Taku Izumi (2):
  mm: Calculate zone_start_pfn at zone_spanned_pages_in_node()
  mm: Introduce kernelcore=mirror option

 Documentation/kernel-parameters.txt |  11 ++-
 mm/page_alloc.c                     | 140 +++++++++++++++++++++++++++++++-----
 2 files changed, 133 insertions(+), 18 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
