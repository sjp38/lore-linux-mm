Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 45F336B0005
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 19:12:46 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id f143so8917111qke.12
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 16:12:46 -0800 (PST)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id r34si3518706qtd.411.2018.03.02.16.12.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Mar 2018 16:12:45 -0800 (PST)
From: Daniel Vacek <neelx@redhat.com>
Subject: [PATCH v3 0/2] mm/page_alloc: fix kernel BUG at mm/page_alloc.c:1913! crash in move_freepages()
Date: Sat,  3 Mar 2018 01:12:24 +0100
Message-Id: <cover.1520011944.git.neelx@redhat.com>
In-Reply-To: <1519908465-12328-1-git-send-email-neelx@redhat.com>
References: <1519908465-12328-1-git-send-email-neelx@redhat.com>
In-Reply-To: <1519908465-12328-1-git-send-email-neelx@redhat.com>
References: <1519908465-12328-1-git-send-email-neelx@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Pavel Tatashin <pasha.tatashin@oracle.com>, Paul Burton <paul.burton@imgtec.com>, Daniel Vacek <neelx@redhat.com>, stable@vger.kernel.org

Kernel can crash on failed VM_BUG_ON assertion in function move_freepages()
on some rare physical memory mappings (with huge range(s) of memory
reserved by BIOS followed by usable memory not aligned to pageblock).

crash> page_init_bug -v | grep resource | sed '/RAM .3/,/RAM .4/!d'
<struct resource 0xffff88067fffd480>      4bfac000 -     646b1fff	System RAM (391.02 MiB = 400408.00 KiB)
<struct resource 0xffff88067fffd4b8>      646b2000 -     793fefff	reserved (333.30 MiB = 341300.00 KiB)
<struct resource 0xffff88067fffd4f0>      793ff000 -     7b3fefff	ACPI Non-volatile Storage ( 32.00 MiB)
<struct resource 0xffff88067fffd528>      7b3ff000 -     7b787fff	ACPI Tables (  3.54 MiB = 3620.00 KiB)
<struct resource 0xffff88067fffd560>      7b788000 -     7b7fffff	System RAM (480.00 KiB)

More details in second patch.

v2: Use -1 constant for max_pfn and remove the parameter. That's
    mostly just a cosmetics.
v3: Split to two patches series to make clear what is the actual fix
    and what is just a clean up. No code changes compared to v2 and
    second patch is identical to original v1.

Cc: stable@vger.kernel.org

Daniel Vacek (2):
  mm/memblock: hardcode the max_pfn being -1
  mm/page_alloc: fix memmap_init_zone pageblock alignment

 mm/memblock.c   | 13 ++++++-------
 mm/page_alloc.c |  9 +++++++--
 2 files changed, 13 insertions(+), 9 deletions(-)

-- 
2.16.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
