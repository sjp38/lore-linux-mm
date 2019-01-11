Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 29E838E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 00:13:19 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id t10so7591230plo.13
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 21:13:19 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c8sor1649554plr.70.2019.01.10.21.13.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 Jan 2019 21:13:17 -0800 (PST)
From: Pingfan Liu <kernelfans@gmail.com>
Subject: [PATCHv2 0/7] x86_64/mm: remove bottom-up allocation style by pushing forward the parsing of mem hotplug info 
Date: Fri, 11 Jan 2019 13:12:50 +0800
Message-Id: <1547183577-20309-1-git-send-email-kernelfans@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Pingfan Liu <kernelfans@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, Chao Fan <fanc.fnst@cn.fujitsu.com>, Baoquan He <bhe@redhat.com>, Juergen Gross <jgross@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, x86@kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org

Background
When kaslr kernel can be guaranteed to sit inside unmovable node
after [1]. But if kaslr kernel is located near the end of the movable node,
then bottom-up allocator may create pagetable which crosses the boundary
between unmovable node and movable node.  It is a probability issue,
two factors include -1. how big the gap between kernel end and
unmovable node's end.  -2. how many memory does the system own.
Alternative way to fix this issue is by increasing the gap by
boot/compressed/kaslr*. But taking the scenario of PB level memory,
the pagetable will take server MB even if using 1GB page, different page
attr and fragment will make things worse. So it is hard to decide how much
should the gap increase.
The following figure show the defection of current bottom-up style:
  [startA, endA][startB, "kaslr kernel verly close to" endB][startC, endC]

If nodeA,B is unmovable, while nodeC is movable, then init_mem_mapping()
can generate pgtable on nodeC, which stain movable node.

This patch makes it certainty instead of a probablity problem. It achieves
this by pushing forward the parsing of mem hotplug info ahead of init_mem_mapping().

Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Len Brown <lenb@kernel.org>
Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Chao Fan <fanc.fnst@cn.fujitsu.com>
Cc: Baoquan He <bhe@redhat.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@suse.com>
Cc: x86@kernel.org
Cc: linux-acpi@vger.kernel.org
Cc: linux-mm@kvack.org
Pingfan Liu (7):
  x86/mm: concentrate the code to memblock allocator enabled
  acpi: change the topo of acpi_table_upgrade()
  mm/memblock: introduce allocation boundary for tracing purpose
  x86/setup: parse acpi to get hotplug info before init_mem_mapping()
  x86/mm: set allowed range for memblock allocator
  x86/mm: remove bottom-up allocation style for x86_64
  x86/mm: isolate the bottom-up style to init_32.c

 arch/arm/mm/init.c              |   3 +-
 arch/arm/mm/mmu.c               |   4 +-
 arch/arm/mm/nommu.c             |   2 +-
 arch/arm64/kernel/setup.c       |   2 +-
 arch/csky/kernel/setup.c        |   2 +-
 arch/microblaze/mm/init.c       |   2 +-
 arch/mips/kernel/setup.c        |   2 +-
 arch/powerpc/mm/40x_mmu.c       |   6 +-
 arch/powerpc/mm/44x_mmu.c       |   2 +-
 arch/powerpc/mm/8xx_mmu.c       |   2 +-
 arch/powerpc/mm/fsl_booke_mmu.c |   5 +-
 arch/powerpc/mm/hash_utils_64.c |   4 +-
 arch/powerpc/mm/init_32.c       |   2 +-
 arch/powerpc/mm/pgtable-radix.c |   2 +-
 arch/powerpc/mm/ppc_mmu_32.c    |   8 +-
 arch/powerpc/mm/tlb_nohash.c    |   6 +-
 arch/unicore32/mm/mmu.c         |   2 +-
 arch/x86/kernel/setup.c         |  93 ++++++++++++++---------
 arch/x86/mm/init.c              | 163 +++++-----------------------------------
 arch/x86/mm/init_32.c           | 147 ++++++++++++++++++++++++++++++++++++
 arch/x86/mm/mm_internal.h       |   8 +-
 arch/xtensa/mm/init.c           |   2 +-
 drivers/acpi/tables.c           |   4 +-
 include/linux/acpi.h            |   5 +-
 include/linux/memblock.h        |  10 ++-
 mm/memblock.c                   |  23 ++++--
 26 files changed, 290 insertions(+), 221 deletions(-)

-- 
2.7.4
