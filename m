Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 57D376B002E
	for <linux-mm@kvack.org>; Sun, 25 Mar 2018 23:03:26 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id z5-v6so3833628plo.21
        for <linux-mm@kvack.org>; Sun, 25 Mar 2018 20:03:26 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id ba12-v6sor6218028plb.46.2018.03.25.20.03.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 25 Mar 2018 20:03:25 -0700 (PDT)
From: Jia He <hejianet@gmail.com>
Subject: [PATCH v3 3/5] mm/memblock: introduce memblock_search_pfn_regions()
Date: Sun, 25 Mar 2018 20:02:17 -0700
Message-Id: <1522033340-6575-4-git-send-email-hejianet@gmail.com>
In-Reply-To: <1522033340-6575-1-git-send-email-hejianet@gmail.com>
References: <1522033340-6575-1-git-send-email-hejianet@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Catalin Marinas <catalin.marinas@arm.com>, Mel Gorman <mgorman@suse.de>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Gioh Kim <gi-oh.kim@profitbricks.com>, Steven Sistare <steven.sistare@oracle.com>, Daniel Vacek <neelx@redhat.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, James Morse <james.morse@arm.com>, Steve Capper <steve.capper@arm.com>, x86@kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Jia He <hejianet@gmail.com>, Jia He <jia.he@hxt-semitech.com>

This api is the preparation for further optimizing early_pfn_valid

Signed-off-by: Jia He <jia.he@hxt-semitech.com>
---
 include/linux/memblock.h | 2 ++
 mm/memblock.c            | 9 +++++++++
 2 files changed, 11 insertions(+)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index a8fb2ab..104bca6 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -207,6 +207,8 @@ void __next_mem_pfn_range(int *idx, int nid, unsigned long *out_start_pfn,
 unsigned long memblock_next_valid_pfn(unsigned long pfn, int *idx);
 #endif
 
+int memblock_search_pfn_regions(unsigned long pfn);
+
 /**
  * for_each_free_mem_range - iterate through free memblock areas
  * @i: u64 used as loop variable
diff --git a/mm/memblock.c b/mm/memblock.c
index 06c1a08..15fcde2 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1661,6 +1661,15 @@ static int __init_memblock memblock_search(struct memblock_type *type, phys_addr
 	return -1;
 }
 
+/* search memblock with the input pfn, return the region idx */
+int __init_memblock memblock_search_pfn_regions(unsigned long pfn)
+{
+	struct memblock_type *type = &memblock.memory;
+	int mid = memblock_search(type, PFN_PHYS(pfn));
+
+	return mid;
+}
+
 bool __init memblock_is_reserved(phys_addr_t addr)
 {
 	return memblock_search(&memblock.reserved, addr) != -1;
-- 
2.7.4
