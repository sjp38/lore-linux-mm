Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 39EBA6B0038
	for <linux-mm@kvack.org>; Mon, 29 Dec 2014 09:50:03 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id g10so17380133pdj.34
        for <linux-mm@kvack.org>; Mon, 29 Dec 2014 06:50:03 -0800 (PST)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id wq3si47421pbc.91.2014.12.29.06.50.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 29 Dec 2014 06:50:01 -0800 (PST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NHC00INNMQ0K530@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 29 Dec 2014 14:54:00 +0000 (GMT)
From: Andrzej Hajda <a.hajda@samsung.com>
Subject: [RFC PATCH 0/4] kstrdup optimization
Date: Mon, 29 Dec 2014 15:48:26 +0100
Message-id: <1419864510-24834-1-git-send-email-a.hajda@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrzej Hajda <a.hajda@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org

Hi,

kstrdup if often used to duplicate strings where neither source neither
destination will be ever modified. In such case we can just reuse the source
instead of duplicating it. The problem is that we must be sure that
the source is non-modifiable and its life-time is long enough.

I suspect the good candidates for such strings are strings located in kernel
.rodata section, they cannot be modifed because the section is read-only and
their life-time is equal to kernel life-time.

This small patchset proposes alternative version of kstrdup - kstrdup_const,
which returns source string if it is located in .rodata otherwise it fallbacks
to kstrdup.
To verify if the source is in .rodata function checks if the address is between
sentinels __start_rodata, __end_rodata, I think it is OK, but maybe sombebody
with deeper knowledge can say if it is OK for all supported architectures and
configuration options.

The main patch is accompanied by three patches constifying kstrdup for cases
where situtation described above happens frequently.

The patchset is based on next-20141226.

As I have tested it on mobile platform (exynos4210-trats) it saves above 2600
string duplications. Below simple stats about the most frequent duplications:
Count String
  880 power
  874 subsystem
  130 device
  126 parameters
   61 iommu_group
   40 driver
   28 bdi
   28 none
   25 sclk_mpll
   23 sclk_usbphy0
   23 sclk_hdmi24m
   23 xusbxti
   22 sclk_vpll
   22 sclk_epll
   22 xxti
   20 sclk_hdmiphy
   11 aclk100

Regards
Andrzej


Andrzej Hajda (4):
  mm/util: add kstrdup_const
  kernfs: use kstrdup_const for node name allocation
  clk: use kstrdup_const for clock name allocations
  mm/slab: use kstrdup_const for allocating cache names

 drivers/clk/clk.c      | 12 ++++++------
 fs/kernfs/dir.c        | 12 ++++++------
 include/linux/string.h |  3 +++
 mm/slab_common.c       |  6 +++---
 mm/util.c              | 22 ++++++++++++++++++++++
 5 files changed, 40 insertions(+), 15 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
