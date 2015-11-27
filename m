Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f175.google.com (mail-io0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id 6F0616B0038
	for <linux-mm@kvack.org>; Fri, 27 Nov 2015 01:01:20 -0500 (EST)
Received: by ioc74 with SMTP id 74so104020585ioc.2
        for <linux-mm@kvack.org>; Thu, 26 Nov 2015 22:01:20 -0800 (PST)
Received: from mgwkm04.jp.fujitsu.com (mgwkm04.jp.fujitsu.com. [202.219.69.171])
        by mx.google.com with ESMTPS id y4si8394002igl.99.2015.11.26.22.01.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Nov 2015 22:01:19 -0800 (PST)
Received: from m3051.s.css.fujitsu.com (m3051.s.css.fujitsu.com [10.134.21.209])
	by kw-mxoi1.gw.nic.fujitsu.com (Postfix) with ESMTP id 268C4AC0131
	for <linux-mm@kvack.org>; Fri, 27 Nov 2015 15:01:15 +0900 (JST)
From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH v2 0/2] mm: Introduce kernelcore=reliable option
Date: Sat, 28 Nov 2015 00:03:55 +0900
Message-Id: <1448636635-15946-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: tony.luck@intel.com, qiuxishi@huawei.com, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, akpm@linux-foundation.org, dave.hansen@intel.com, matt@codeblueprint.co.uk, Taku Izumi <izumi.taku@jp.fujitsu.com>

Xeon E7 v3 based systems supports Address Range Mirroring
and UEFI BIOS complied with UEFI spec 2.5 can notify which
ranges are reliable (mirrored) via EFI memory map.
Now Linux kernel utilize its information and allocates
boot time memory from reliable region.

My requirement is:
  - allocate kernel memory from reliable region
  - allocate user memory from non-reliable region

In order to meet my requirement, ZONE_MOVABLE is useful.
By arranging non-reliable range into ZONE_MOVABLE,
reliable memory is only used for kernel allocations.

My idea is to extend existing "kernelcore" option and
introduces kernelcore=reliable option. By specifying
"reliable" instead of specifying the amount of memory,
non-reliable region will be arranged into ZONE_MOVABLE.

Earlier discussions are at:
 https://lkml.org/lkml/2015/10/9/24
 https://lkml.org/lkml/2015/10/15/9

For example, suppose 2-nodes system with the following memory
 range:
  node 0 [mem 0x0000000000001000-0x000000109fffffff]
  node 1 [mem 0x00000010a0000000-0x000000209fffffff]

and the following ranges are marked as reliable:
  [0x0000000000000000-0x0000000100000000]
  [0x0000000100000000-0x0000000180000000]
  [0x0000000800000000-0x0000000880000000]
  [0x00000010a0000000-0x0000001120000000]
  [0x00000017a0000000-0x0000001820000000]

If you specify kernelcore=reliable, ZONE_NORMAL and ZONE_MOVABLE
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


Taku Izumi (2):
  mm: Calculate zone_start_pfn at zone_spanned_pages_in_node()
  mm: Introduce kernelcore=reliable option

 Documentation/kernel-parameters.txt |   9 ++-
 mm/page_alloc.c                     | 140 +++++++++++++++++++++++++++++++-----
 2 files changed, 131 insertions(+), 18 deletions(-)

-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
