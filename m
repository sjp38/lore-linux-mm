Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 39A8F6B0030
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 05:38:41 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id k16so1132529pfi.7
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 02:38:41 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v5-v6sor1530388plg.116.2018.03.28.02.38.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 28 Mar 2018 02:38:40 -0700 (PDT)
Date: Wed, 28 Mar 2018 17:38:30 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH v3 4/5] arm64: introduce pfn_valid_region()
Message-ID: <20180328093830.GB98648@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <1522033340-6575-1-git-send-email-hejianet@gmail.com>
 <1522033340-6575-5-git-send-email-hejianet@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1522033340-6575-5-git-send-email-hejianet@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia He <hejianet@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Catalin Marinas <catalin.marinas@arm.com>, Mel Gorman <mgorman@suse.de>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Gioh Kim <gi-oh.kim@profitbricks.com>, Steven Sistare <steven.sistare@oracle.com>, Daniel Vacek <neelx@redhat.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, James Morse <james.morse@arm.com>, Steve Capper <steve.capper@arm.com>, x86@kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Jia He <jia.he@hxt-semitech.com>

On Sun, Mar 25, 2018 at 08:02:18PM -0700, Jia He wrote:
>This is the preparation for further optimizing in early_pfn_valid
>on arm64.
>
>Signed-off-by: Jia He <jia.he@hxt-semitech.com>
>---
> arch/arm64/include/asm/page.h |  3 ++-
> arch/arm64/mm/init.c          | 25 ++++++++++++++++++++++++-
> 2 files changed, 26 insertions(+), 2 deletions(-)
>
>diff --git a/arch/arm64/include/asm/page.h b/arch/arm64/include/asm/page.h
>index 60d02c8..da2cba3 100644
>--- a/arch/arm64/include/asm/page.h
>+++ b/arch/arm64/include/asm/page.h
>@@ -38,7 +38,8 @@ extern void clear_page(void *to);
> typedef struct page *pgtable_t;
> 
> #ifdef CONFIG_HAVE_ARCH_PFN_VALID
>-extern int pfn_valid(unsigned long);
>+extern int pfn_valid(unsigned long pfn);
>+extern int pfn_valid_region(unsigned long pfn, int *last_idx);
> #endif
> 
> #include <asm/memory.h>
>diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
>index 00e7b90..06433d5 100644
>--- a/arch/arm64/mm/init.c
>+++ b/arch/arm64/mm/init.c
>@@ -290,7 +290,30 @@ int pfn_valid(unsigned long pfn)
> 	return memblock_is_map_memory(pfn << PAGE_SHIFT);
> }
> EXPORT_SYMBOL(pfn_valid);
>-#endif
>+
>+int pfn_valid_region(unsigned long pfn, int *last_idx)
>+{
>+	unsigned long start_pfn, end_pfn;
>+	struct memblock_type *type = &memblock.memory;
>+
>+	if (*last_idx != -1) {
>+		start_pfn = PFN_DOWN(type->regions[*last_idx].base);

PFN_UP() should be used.

>+		end_pfn= PFN_DOWN(type->regions[*last_idx].base +
>+					type->regions[*last_idx].size);
>+
>+		if (pfn >= start_pfn && pfn < end_pfn)
>+			return !memblock_is_nomap(
>+				&memblock.memory.regions[*last_idx]);

Could use type->regions directly.

>+	}
>+
>+	*last_idx = memblock_search_pfn_regions(pfn);
>+	if (*last_idx == -1)
>+		return false;
>+
>+	return !memblock_is_nomap(&memblock.memory.regions[*last_idx]);

Could use type->regions directly.

Well, since your check memblock.memory.regions, how about use a variable
equals memblock.memory.regions directly instead of type->regions?

For example:

struct memblock_region *regions = memblock.memory.regions;

>+}
>+EXPORT_SYMBOL(pfn_valid_region);
>+#endif /*CONFIG_HAVE_ARCH_PFN_VALID*/
> 
> #ifndef CONFIG_SPARSEMEM
> static void __init arm64_memory_present(void)
>-- 
>2.7.4

-- 
Wei Yang
Help you, Help me
