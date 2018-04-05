Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id B2C5A6B0009
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 04:05:38 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id f3-v6so18086451plf.1
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 01:05:38 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 188sor1374832pgd.215.2018.04.05.01.05.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 05 Apr 2018 01:05:37 -0700 (PDT)
From: Jia He <hejianet@gmail.com>
Subject: [PATCH v7 3/5] mm/memblock: introduce memblock_search_pfn_regions()
Date: Thu,  5 Apr 2018 01:04:36 -0700
Message-Id: <1522915478-5044-4-git-send-email-hejianet@gmail.com>
In-Reply-To: <1522915478-5044-1-git-send-email-hejianet@gmail.com>
References: <1522915478-5044-1-git-send-email-hejianet@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, Kees Cook <keescook@chromium.org>, Laura Abbott <labbott@redhat.com>, Vladimir Murzin <vladimir.murzin@arm.com>, Philip Derrin <philip@cog.systems>, AKASHI Takahiro <takahiro.akashi@linaro.org>, James Morse <james.morse@arm.com>, Steve Capper <steve.capper@arm.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Daniel Vacek <neelx@redhat.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Jia He <hejianet@gmail.com>, Jia He <jia.he@hxt-semitech.com>

This api is to find the memory region index of input pfn. With this
helper, we can improve the loop in early_pfn_valid by recording last
region index. If current pfn and last pfn are in the same memory
region, we needn't do the unnecessary binary searches because the
result of memblock_is_nomap is the same for whole memory region.

Signed-off-by: Jia He <jia.he@hxt-semitech.com>
---
 include/linux/memblock.h | 2 ++
 mm/memblock.c            | 9 +++++++++
 2 files changed, 11 insertions(+)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 0257aee..a0127b3 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -203,6 +203,8 @@ void __next_mem_pfn_range(int *idx, int nid, unsigned long *out_start_pfn,
 	     i >= 0; __next_mem_pfn_range(&i, nid, p_start, p_end, p_nid))
 #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
 
+int memblock_search_pfn_regions(unsigned long pfn);
+
 /**
  * for_each_free_mem_range - iterate through free memblock areas
  * @i: u64 used as loop variable
diff --git a/mm/memblock.c b/mm/memblock.c
index ba7c878..0f4004c 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1617,6 +1617,15 @@ static int __init_memblock memblock_search(struct memblock_type *type, phys_addr
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
