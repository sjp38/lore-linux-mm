Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9BF506B0275
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 06:13:46 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id x63so4753592wmf.2
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 03:13:46 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id c7si4771217edl.136.2017.11.23.03.13.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Nov 2017 03:13:45 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vANB8xe1007068
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 06:13:44 -0500
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2edtdcnb8e-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 06:13:43 -0500
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ar@linux.vnet.ibm.com>;
	Thu, 23 Nov 2017 11:13:41 -0000
Date: Thu, 23 Nov 2017 11:13:35 +0000
From: Andrea Reale <ar@linux.vnet.ibm.com>
Subject: [PATCH v2 0/5] Memory hotplug support for arm64 - complete patchset
 v2
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Message-Id: <cover.1511433386.git.ar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, m.bielski@virtualopensystems.com, arunks@qti.qualcomm.com, mark.rutland@arm.com, scott.branden@broadcom.com, will.deacon@arm.com, qiuxishi@huawei.com, catalin.marinas@arm.com, mhocko@suse.com, realean2@ie.ibm.com

Hi all,

this is a second round of patches to introduce memory hotplug and
hotremove support for arm64. It builds on the work previously published at
[1] and it implements the feedback received in the first round of reviews.

The patchset applies and has been tested on commit bebc6082da0a ("Linux
4.14"). 

Due to a small regression introduced with commit 8135d8926c08
("mm: memory_hotplug: memory hotremove supports thp migration"), you
will need to appy patch [2] first, until the fix is not upstreamed.

Comments and feedback are gold.

[1] https://lkml.org/lkml/2017/4/11/536
[2] https://lkml.org/lkml/2017/11/20/902

Changes v1->v2:
- swapper pgtable updated in place on hot add, avoiding unnecessary copy
- stop_machine used to updated swapper on hot add, avoiding races
- introduced check on offlining state before hot remove
- new memblock flag used to mark partially unused vmemmap pages, avoiding
  the nasty 0xFD hack used in the prev rev (and in x86 hot remove code)
- proper cleaning sequence for p[um]ds,ptes and related TLB management
- Removed macros that changed hot remove behavior based on number
  of pgtable levels. Now this is hidden in the pgtable traversal macros.
- Check on the corner case where P[UM]Ds would have to be split during
  hot remove: now this is forbidden.
- Minor fixes and refactoring.

Andrea Reale (4):
  mm: memory_hotplug: Remove assumption on memory state before hotremove
  mm: memory_hotplug: memblock to track partially removed vmemmap mem
  mm: memory_hotplug: Add memory hotremove probe device
  mm: memory-hotplug: Add memory hot remove support for arm64

Maciej Bielski (1):
  mm: memory_hotplug: Memory hotplug (add) support for arm64

 arch/arm64/Kconfig             |  15 +
 arch/arm64/configs/defconfig   |   2 +
 arch/arm64/include/asm/mmu.h   |   7 +
 arch/arm64/mm/init.c           | 116 ++++++++
 arch/arm64/mm/mmu.c            | 609 ++++++++++++++++++++++++++++++++++++++++-
 drivers/acpi/acpi_memhotplug.c |   2 +-
 drivers/base/memory.c          |  34 ++-
 include/linux/memblock.h       |  12 +
 include/linux/memory_hotplug.h |   9 +-
 mm/memblock.c                  |  32 +++
 mm/memory_hotplug.c            |  13 +-
 11 files changed, 835 insertions(+), 16 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
