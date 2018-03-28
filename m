Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 97A426B0029
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 05:18:09 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id u1-v6so1356422pls.16
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 02:18:09 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f20-v6sor1526904plj.18.2018.03.28.02.18.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 28 Mar 2018 02:18:08 -0700 (PDT)
Date: Wed, 28 Mar 2018 17:18:00 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH v3 1/5] mm: page_alloc: remain memblock_next_valid_pfn()
 when CONFIG_HAVE_ARCH_PFN_VALID is enable
Message-ID: <20180328091800.GB97260@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <1522033340-6575-1-git-send-email-hejianet@gmail.com>
 <1522033340-6575-2-git-send-email-hejianet@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1522033340-6575-2-git-send-email-hejianet@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia He <hejianet@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Catalin Marinas <catalin.marinas@arm.com>, Mel Gorman <mgorman@suse.de>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Gioh Kim <gi-oh.kim@profitbricks.com>, Steven Sistare <steven.sistare@oracle.com>, Daniel Vacek <neelx@redhat.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, James Morse <james.morse@arm.com>, Steve Capper <steve.capper@arm.com>, x86@kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Jia He <jia.he@hxt-semitech.com>

Oops, I should reply this thread. Forget about the reply on another thread.

On Sun, Mar 25, 2018 at 08:02:15PM -0700, Jia He wrote:
>Commit b92df1de5d28 ("mm: page_alloc: skip over regions of invalid pfns
>where possible") optimized the loop in memmap_init_zone(). But it causes
>possible panic bug. So Daniel Vacek reverted it later.
>

Why this has a bug? Do you have some link about it?

If the audience could know the potential risk, it would be helpful to review
the code and decide whether to take it back.

>But memblock_next_valid_pfn is valid when CONFIG_HAVE_ARCH_PFN_VALID is
>enable. And as verified by Eugeniu Rosca, arm can benifit from this
>commit. So remain the memblock_next_valid_pfn.
>
>Signed-off-by: Jia He <jia.he@hxt-semitech.com>
>---
> include/linux/memblock.h |  4 ++++
> mm/memblock.c            | 29 +++++++++++++++++++++++++++++
> mm/page_alloc.c          | 11 ++++++++++-
> 3 files changed, 43 insertions(+), 1 deletion(-)
>
>diff --git a/include/linux/memblock.h b/include/linux/memblock.h
>index 0257aee..efbbe4b 100644
>--- a/include/linux/memblock.h
>+++ b/include/linux/memblock.h
>@@ -203,6 +203,10 @@ void __next_mem_pfn_range(int *idx, int nid, unsigned long *out_start_pfn,
> 	     i >= 0; __next_mem_pfn_range(&i, nid, p_start, p_end, p_nid))
> #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
> 
>+#ifdef CONFIG_HAVE_ARCH_PFN_VALID
>+unsigned long memblock_next_valid_pfn(unsigned long pfn);
>+#endif
>+
> /**
>  * for_each_free_mem_range - iterate through free memblock areas
>  * @i: u64 used as loop variable
>diff --git a/mm/memblock.c b/mm/memblock.c
>index ba7c878..bea5a9c 100644
>--- a/mm/memblock.c
>+++ b/mm/memblock.c
>@@ -1102,6 +1102,35 @@ void __init_memblock __next_mem_pfn_range(int *idx, int nid,
> 		*out_nid = r->nid;
> }
> 
>+#ifdef CONFIG_HAVE_ARCH_PFN_VALID
>+unsigned long __init_memblock memblock_next_valid_pfn(unsigned long pfn)
>+{
>+	struct memblock_type *type = &memblock.memory;
>+	unsigned int right = type->cnt;
>+	unsigned int mid, left = 0;
>+	phys_addr_t addr = PFN_PHYS(++pfn);
>+
>+	do {
>+		mid = (right + left) / 2;
>+
>+		if (addr < type->regions[mid].base)
>+			right = mid;
>+		else if (addr >= (type->regions[mid].base +
>+				  type->regions[mid].size))
>+			left = mid + 1;
>+		else {
>+			/* addr is within the region, so pfn is valid */
>+			return pfn;
>+		}
>+	} while (left < right);
>+
>+	if (right == type->cnt)
>+		return -1UL;
>+	else
>+		return PHYS_PFN(type->regions[right].base);
>+}
>+#endif /*CONFIG_HAVE_ARCH_PFN_VALID*/
>+
> /**
>  * memblock_set_node - set node ID on memblock regions
>  * @base: base of area to set node ID for
>diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>index c19f5ac..2a967f7 100644
>--- a/mm/page_alloc.c
>+++ b/mm/page_alloc.c
>@@ -5483,8 +5483,17 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
> 		if (context != MEMMAP_EARLY)
> 			goto not_early;
> 
>-		if (!early_pfn_valid(pfn))
>+		if (!early_pfn_valid(pfn)) {
>+#if (defined CONFIG_HAVE_MEMBLOCK) && (defined CONFIG_HAVE_ARCH_PFN_VALID)

In commit b92df1de5d28, it use CONFIG_HAVE_MEMBLOCK_NODE_MAP.

Not get the point of your change.

>+			/*
>+			 * Skip to the pfn preceding the next valid one (or
>+			 * end_pfn), such that we hit a valid pfn (or end_pfn)
>+			 * on our next iteration of the loop.
>+			 */
>+			pfn = memblock_next_valid_pfn(pfn) - 1;
>+#endif
> 			continue;
>+		}
> 		if (!early_pfn_in_nid(pfn, nid))
> 			continue;
> 		if (!update_defer_init(pgdat, pfn, end_pfn, &nr_initialised))
>-- 
>2.7.4

-- 
Wei Yang
Help you, Help me
