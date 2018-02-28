Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3B5E56B0003
	for <linux-mm@kvack.org>; Tue, 27 Feb 2018 22:03:22 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id d18so1284243iob.23
        for <linux-mm@kvack.org>; Tue, 27 Feb 2018 19:03:22 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id b62si627770iti.5.2018.02.27.19.03.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Feb 2018 19:03:20 -0800 (PST)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [v5 0/6] optimize memory hotplug
Date: Tue, 27 Feb 2018 22:03:02 -0500
Message-Id: <20180228030308.1116-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, akpm@linux-foundation.org, mgorman@techsingularity.net, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, vbabka@suse.cz, bharata@linux.vnet.ibm.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, bhe@redhat.com

Changelog:
	v5 - v4
	- Addressed more comments from Ingo Molnar and Michal Hocko.
	- In the patch "optimize memory hotplug" we are now using
	  struct memory_block to hold node id as suggested by Michal.
	- In the patch "don't read nid from struct page during hotplug"
	  renamed register_new_memory() to hotplug_memory_register() as
	  suggested by Ingo. Also, in this patch replaced the
	  description with the one provided by Michal.
	- Fixed other spelling issues found by Ingo.

	v3 - v4
	Addressed comments from Ingo Molnar and from Michal Hocko
	Split 4th patch into three patches
	Instead of using section table to save node ids, saving node id in
	the first page of every section.

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

The following experiments were performed on Xeon(R)
CPU E7-8895 v3 @ 2.60GHz with 1T RAM:

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

Pavel Tatashin (6):
  mm/memory_hotplug: enforce block size aligned range check
  x86/mm/memory_hotplug: determine block size based on the end of boot
    memory
  mm: add uninitialized struct page poisoning sanity checking
  mm/memory_hotplug: optimize probe routine
  mm/memory_hotplug: don't read nid from struct page during hotplug
  mm/memory_hotplug: optimize memory hotplug

 arch/x86/mm/init_64.c      | 33 +++++++++++++++++++++++++++++----
 drivers/base/memory.c      | 40 ++++++++++++++++++++++------------------
 drivers/base/node.c        | 24 +++++++++++++++++-------
 include/linux/memory.h     |  3 ++-
 include/linux/mm.h         |  4 +++-
 include/linux/node.h       |  4 ++--
 include/linux/page-flags.h | 22 +++++++++++++++++-----
 mm/memblock.c              |  2 +-
 mm/memory_hotplug.c        | 44 +++++++++++++++++---------------------------
 mm/page_alloc.c            | 28 ++++++++++------------------
 mm/sparse.c                |  8 +++++++-
 11 files changed, 127 insertions(+), 85 deletions(-)

-- 
2.16.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
