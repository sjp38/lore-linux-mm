Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 51AE36B0033
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 15:48:52 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id v96so50190133ioi.5
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 12:48:52 -0800 (PST)
Received: from g2t2353.austin.hpe.com (g2t2353.austin.hpe.com. [15.233.44.26])
        by mx.google.com with ESMTPS id 7si174167itk.88.2017.01.26.12.48.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jan 2017 12:48:51 -0800 (PST)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH 0/2] fix a kernel oops in reading sysfs valid_zones
Date: Thu, 26 Jan 2017 14:44:13 -0700
Message-Id: <20170126214415.4509-1-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, gregkh@linuxfoundation.org
Cc: linux-mm@kvack.org, zhenzhang.zhang@huawei.com, arbab@linux.vnet.ibm.com, dan.j.williams@intel.com, abanman@sgi.com, rientjes@google.com, linux-kernel@vger.kernel.org

A sysfs memory file is created for each 128MiB or 2GiB of a memory
block on x86. [1]  When the start address of a memory block is not
backed by struct page, i.e. memory range is not aligned by the memory
block size, reading its valid_zones attribute file leads to a kernel
oops.  This patch-set fixes this issue.

Patch 1 first fixes an issue in test_pages_in_a_zone() that it does
not test the start section.

Patch 2 then fixes the kernel oops by extending test_pages_in_a_zone()
to return valid [start, end).

[1] 2GB when the system has 64GB or larger memory.

---
Toshi Kani (2):
 1/2 mm/memory_hotplug.c: check start_pfn in test_pages_in_a_zone() 
 2/2 base/memory, hotplug: fix a kernel oops in show_valid_zones()

---
 drivers/base/memory.c          | 12 ++++++------
 include/linux/memory_hotplug.h |  3 ++-
 mm/memory_hotplug.c            | 28 +++++++++++++++++++++-------
 3 files changed, 29 insertions(+), 14 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
