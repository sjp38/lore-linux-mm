Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8DE176B0038
	for <linux-mm@kvack.org>; Fri, 27 Jan 2017 16:26:26 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id 67so80976233ioh.1
        for <linux-mm@kvack.org>; Fri, 27 Jan 2017 13:26:26 -0800 (PST)
Received: from g9t5009.houston.hpe.com (g9t5009.houston.hpe.com. [15.241.48.73])
        by mx.google.com with ESMTPS id e41si5164194ioj.215.2017.01.27.13.26.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Jan 2017 13:26:25 -0800 (PST)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH v2 0/2] fix a kernel oops when reading sysfs valid_zones
Date: Fri, 27 Jan 2017 15:21:47 -0700
Message-Id: <20170127222149.30893-1-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, gregkh@linuxfoundation.org
Cc: linux-mm@kvack.org, zhenzhang.zhang@huawei.com, arbab@linux.vnet.ibm.com, dan.j.williams@intel.com, abanman@sgi.com, rientjes@google.com, linux-kernel@vger.kernel.org, stable@vger.kernel.org, toshi.kani@hpe.com

A sysfs memory file is created for each 2GiB memory block on x86-64
when the system has 64GiB or more memory. [1]  When the start address
of a memory block is not backed by struct page, i.e. a memory range is
not aligned by 2GiB, reading its 'valid_zones' attribute file leads to
a kernel oops.  This issue was observed on multiple x86-64 systems
with more than 64GiB of memory.  This patch-set fixes this issue.

Patch 1 first fixes an issue in test_pages_in_a_zone(), which does
not test the start section.

Patch 2 then fixes the kernel oops by extending test_pages_in_a_zone()
to return valid [start, end).

Note for stable kernels: The memory block size change was made by commit
bdee237c034, which was accepted to 3.9.  However, this patch-set depends
on (and fixes) the change to test_pages_in_a_zone() made by commit
5f0f2887f4, which was accepted to 4.4.  So, I recommend that we backport
it up to 4.4.

[1] 'Commit bdee237c0343 ("x86: mm: Use 2GB memory block size on
    large-memory x86-64 systems")'

v2:
 - Rebase to the -mm tree. (Andrew Morton)
 - Add more descriptions about the issue. (Andrew Morton)
 - Add cc to stable kernels. (Greg Kroah-Hartman, Andrew Morton)

---
Toshi Kani (2):
 1/2 mm/memory_hotplug.c: check start_pfn in test_pages_in_a_zone() 
 2/2 base/memory, hotplug: fix a kernel oops in show_valid_zones()

---
 drivers/base/memory.c          | 12 ++++++------
 include/linux/memory_hotplug.h |  3 ++-
 mm/memory_hotplug.c            | 28 +++++++++++++++++++++-------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
