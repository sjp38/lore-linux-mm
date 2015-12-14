Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 9B0186B0038
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 13:31:24 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so107574801pac.3
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 10:31:24 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id xr9si10411352pab.232.2015.12.14.10.31.23
        for <linux-mm@kvack.org>;
        Mon, 14 Dec 2015 10:31:23 -0800 (PST)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH v2 0/6] mm, x86/vdso: Special IO mapping improvements
Date: Mon, 14 Dec 2015 10:31:12 -0800
Message-Id: <cover.1450117783.git.luto@kernel.org>
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

akpm, can you ack patck 1?

Changes from v1:
 - Lots of changelog clarification requested by akpm
 - Minor tweaks to style and comments in the first two patches

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
 include/linux/mm_types.h                |  22 +++++-
 mm/memory.c                             |  25 ++++++-
 mm/mmap.c                               |  13 ++--
 11 files changed, 151 insertions(+), 72 deletions(-)

-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
