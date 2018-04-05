Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 900036B0010
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 04:06:03 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id d6-v6so15919065plo.2
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 01:06:03 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i85sor1836084pfd.88.2018.04.05.01.06.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 05 Apr 2018 01:06:02 -0700 (PDT)
From: Jia He <hejianet@gmail.com>
Subject: [PATCH v7 5/5] mm: page_alloc: reduce unnecessary binary search in early_pfn_valid()
Date: Thu,  5 Apr 2018 01:04:38 -0700
Message-Id: <1522915478-5044-6-git-send-email-hejianet@gmail.com>
In-Reply-To: <1522915478-5044-1-git-send-email-hejianet@gmail.com>
References: <1522915478-5044-1-git-send-email-hejianet@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, Kees Cook <keescook@chromium.org>, Laura Abbott <labbott@redhat.com>, Vladimir Murzin <vladimir.murzin@arm.com>, Philip Derrin <philip@cog.systems>, AKASHI Takahiro <takahiro.akashi@linaro.org>, James Morse <james.morse@arm.com>, Steve Capper <steve.capper@arm.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Daniel Vacek <neelx@redhat.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Jia He <hejianet@gmail.com>, Jia He <jia.he@hxt-semitech.com>

Commit b92df1de5d28 ("mm: page_alloc: skip over regions of invalid pfns
where possible") optimized the loop in memmap_init_zone(). But there is
still some room for improvement. E.g. in early_pfn_valid(), if pfn and
pfn+1 are in the same memblock region, we can record the last returned
memblock region index and check whether pfn++ is still in the same
region.

Currently it only improve the performance on arm/arm64 and will have no
impact on other arches.

For the performance improvement, after this set, I can see the time
overhead of memmap_init() is reduced from 41313 us to 24345 us in my
armv8a server(QDF2400 with 96G memory).

Signed-off-by: Jia He <jia.he@hxt-semitech.com>
---
 include/linux/mmzone.h | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index eb56071..ab01bd3 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1271,11 +1271,16 @@ static inline int pfn_present(unsigned long pfn)
 #define pfn_to_nid(pfn)		(0)
 #endif
 
-#define early_pfn_valid(pfn)	pfn_valid(pfn)
 #ifdef CONFIG_HAVE_ARCH_PFN_VALID
 extern ulong memblock_next_valid_pfn(ulong pfn);
 #define next_valid_pfn(pfn)	memblock_next_valid_pfn(pfn)
-#endif
+
+extern int pfn_valid_region(ulong pfn);
+#define early_pfn_valid(pfn)	pfn_valid_region(pfn)
+#else
+#define early_pfn_valid(pfn)    pfn_valid(pfn)
+#endif /*CONFIG_HAVE_ARCH_PFN_VALID*/
+
 void sparse_init(void);
 #else
 #define sparse_init()	do {} while (0)
-- 
2.7.4
