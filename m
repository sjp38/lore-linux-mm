Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id A8AC96B0006
	for <linux-mm@kvack.org>; Tue, 13 Feb 2018 14:32:15 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id z6so18121046iob.3
        for <linux-mm@kvack.org>; Tue, 13 Feb 2018 11:32:15 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id h101si1770629ioi.229.2018.02.13.11.32.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Feb 2018 11:32:14 -0800 (PST)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH v3 0/4] optimize memory hotplug
Date: Tue, 13 Feb 2018 14:31:55 -0500
Message-Id: <20180213193159.14606-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, akpm@linux-foundation.org, mgorman@techsingularity.net, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, vbabka@suse.cz, bharata@linux.vnet.ibm.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, bhe@redhat.com

Changelog:
	v2 - v3
	Fixed two issues found during testing
	Addressed Kbuild warning reports

	v1 - v2
	Added struct page poisoning checking in order to verify that
	struct pages are never accessed until initialized during memory
	hotplug

This patchset:
- Improves hotplug performance by eliminating a number of
struct page traverses during memory hotplug.

- Fixes some issues with hotplugging, where boundaries
were not properly checked. And on x86 block size was not properly aligned
with end of memory

- Also, potentially improves boot performance by eliminating condition from
  __init_single_page().

- Adds robustness by verifying that that struct pages are correctly
  poisoned when flags are accessed.

The following experiments were performed on Xeon(R) CPU E7-8895 v3 @ 2.60GHz
with 1T RAM:

booting in qemu with 960G of memory, time to initialize struct pages:

no-kvm:
	TRY1		TRY2
BEFORE:	39.433668	39.39705
AFTER:	36.903781	36.989329

with-kvm:
BEFORE:	10.977447	11.103164
AFTER:	10.929072	10.751885

Hotplug 896G memory:
no-kvm:
	TRY1		TRY2
BEFORE: 848.740000	846.910000
AFTER:  783.070000	786.560000

with-kvm:
	TRY1		TRY2
BEFORE: 34.410000	33.57
AFTER:	29.810000	29.580000

Pavel Tatashin (4):
  mm/memory_hotplug: enforce block size aligned range check
  x86/mm/memory_hotplug: determine block size based on the end of boot
    memory
  mm: uninitialized struct page poisoning sanity checking
  mm/memory_hotplug: optimize memory hotplug

 arch/x86/mm/init_64.c          | 33 +++++++++++++++++++++++++++++----
 drivers/base/memory.c          | 38 +++++++++++++++++++++-----------------
 drivers/base/node.c            | 17 ++++++++++-------
 include/linux/memory_hotplug.h |  2 ++
 include/linux/mm.h             |  4 +++-
 include/linux/node.h           |  4 ++--
 include/linux/page-flags.h     | 22 +++++++++++++++++-----
 mm/memblock.c                  |  2 +-
 mm/memory_hotplug.c            | 36 ++++++++++--------------------------
 mm/page_alloc.c                | 28 ++++++++++------------------
 mm/sparse.c                    | 29 ++++++++++++++++++++++++++---
 11 files changed, 131 insertions(+), 84 deletions(-)

-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
