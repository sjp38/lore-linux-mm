Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id EE10F6B0275
	for <linux-mm@kvack.org>; Fri, 30 Mar 2018 04:17:30 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id t2so1255730pgb.19
        for <linux-mm@kvack.org>; Fri, 30 Mar 2018 01:17:30 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y3sor1847955pgp.95.2018.03.30.01.17.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 30 Mar 2018 01:17:29 -0700 (PDT)
From: Jia He <hejianet@gmail.com>
Subject: [PATCH v4 5/5] mm: page_alloc: reduce unnecessary binary search in early_pfn_valid()
Date: Fri, 30 Mar 2018 01:15:55 -0700
Message-Id: <1522397755-33393-6-git-send-email-hejianet@gmail.com>
In-Reply-To: <1522397755-33393-1-git-send-email-hejianet@gmail.com>
References: <1522397755-33393-1-git-send-email-hejianet@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King <linux@armlinux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Catalin Marinas <catalin.marinas@arm.com>, Mel Gorman <mgorman@suse.de>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Gioh Kim <gi-oh.kim@profitbricks.com>, Steven Sistare <steven.sistare@oracle.com>, Daniel Vacek <neelx@redhat.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, James Morse <james.morse@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Steve Capper <steve.capper@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, richard.weiyang@gmail.com, Jia He <hejianet@gmail.com>, Jia He <jia.he@hxt-semitech.com>

Commit b92df1de5d28 ("mm: page_alloc: skip over regions of invalid pfns
where possible") optimized the loop in memmap_init_zone(). But there is
still some room for improvement. E.g. in early_pfn_valid(), if pfn and
pfn+1 are in the same memblock region, we can record the last returned
memblock region index and check check pfn++ is still in the same region.

Currently it only improve the performance on arm64 and will have no
impact on other arches.

Signed-off-by: Jia He <jia.he@hxt-semitech.com>
---
 include/linux/mmzone.h | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index d797716..b68d22c 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1267,9 +1267,14 @@ static inline int pfn_present(unsigned long pfn)
 })
 #else
 #define pfn_to_nid(pfn)		(0)
-#endif
+#endif /*CONFIG_NUMA*/
 
+#ifdef CONFIG_HAVE_ARCH_PFN_VALID
+#define early_pfn_valid(pfn) pfn_valid_region(pfn, &early_region_idx)
+#else
 #define early_pfn_valid(pfn)	pfn_valid(pfn)
+#endif /*CONFIG_HAVE_ARCH_PFN_VALID*/
+
 void sparse_init(void);
 #else
 #define sparse_init()	do {} while (0)
-- 
2.7.4
