Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 04D676B0255
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 22:21:52 -0500 (EST)
Received: by pfv76 with SMTP id 76so5866005pfv.2
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 19:21:51 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id qi3si300843pac.30.2015.12.10.19.21.51
        for <linux-mm@kvack.org>;
        Thu, 10 Dec 2015 19:21:51 -0800 (PST)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH 0/6] mm, x86/vdso: Special IO mapping improvements
Date: Thu, 10 Dec 2015 19:21:41 -0800
Message-Id: <cover.1449803537.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>

This applies on top of the earlier vdso pvclock series I sent out.
Once that lands in -tip, this will apply to -tip.

This series cleans up the hack that is our vvar mapping.  We currently
initialize the vvar mapping as a special mapping vma backed by nothing
whatsoever and then we abuse remap_pfn_range to populate it.

This cheats the mm core, probably breaks under various evil madvise
workloads, and prevents handling faults in more interesting ways.

To clean it up, this series:

 - Adds a special mapping .fault operation
 - Adds a vm_insert_pfn_prot helper
 - Uses the new .fault infrastructure in x86's vdso and vvar mappings
 - Hardens the HPET mapping, mitigating an HW attack surface that bothers me

I'd appreciate some review from the mm folks.  Also, akpm, if you're
okay with this whole series going in through -tip, that would be
great -- it will avoid splitting it across two releases.

Andy Lutomirski (6):
  mm: Add a vm_special_mapping .fault method
  mm: Add vm_insert_pfn_prot
  x86/vdso: Track each mm's loaded vdso image as well as its base
  x86,vdso: Use .fault for the vdso text mapping
  x86,vdso: Use .fault instead of remap_pfn_range for the vvar mapping
  x86/vdso: Disallow vvar access to vclock IO for never-used vclocks

 arch/x86/entry/vdso/vdso2c.h            |   7 --
 arch/x86/entry/vdso/vma.c               | 124 ++++++++++++++++++++------------
 arch/x86/entry/vsyscall/vsyscall_gtod.c |   9 ++-
 arch/x86/include/asm/clocksource.h      |   9 +--
 arch/x86/include/asm/mmu.h              |   3 +-
 arch/x86/include/asm/vdso.h             |   3 -
 arch/x86/include/asm/vgtod.h            |   6 ++
 include/linux/mm.h                      |   2 +
 include/linux/mm_types.h                |  19 ++++-
 mm/memory.c                             |  25 ++++++-
 mm/mmap.c                               |  13 ++--
 11 files changed, 150 insertions(+), 70 deletions(-)

-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
