Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 73B196B004D
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 08:25:34 -0500 (EST)
Received: by yenl12 with SMTP id l12so2768265yen.14
        for <linux-mm@kvack.org>; Tue, 29 Nov 2011 05:25:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111126173151.GF8397@redhat.com>
References: <CAJd=RBB2gSCaJSsFfJXBg2zmgzNjXPAn8OakAZACNG0mv2D7nQ@mail.gmail.com>
	<20111126173151.GF8397@redhat.com>
Date: Tue, 29 Nov 2011 21:25:32 +0800
Message-ID: <CAJd=RBD_JmPDx8tPjNXF=1gQTvzxtER6uQ4M9m5jhSFBLCOkGA@mail.gmail.com>
Subject: Re: [PATCH 3/3] MIPS: changes in VM core for adding THP
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Daney <ddaney.cavm@gmail.com>, Ralf Baechle <ralf@linux-mips.org>, linux-mips@linux-mips.org, linux-mm@kvack.org

On Sun, Nov 27, 2011 at 1:31 AM, Andrea Arcangeli <aarcange@redhat.com> wro=
te:
> On Sat, Nov 26, 2011 at 10:43:15PM +0800, Hillf Danton wrote:
>> In VM core, window is opened for MIPS to use THP.
>>
>> And two simple helper functions are added to easy MIPS a bit.
>>
>> Signed-off-by: Hillf Danton <dhillf@gmail.com>
>> ---
>>
>> --- a/mm/Kconfig =C2=A0 =C2=A0 =C2=A0Thu Nov 24 21:12:00 2011
>> +++ b/mm/Kconfig =C2=A0 =C2=A0 =C2=A0Sat Nov 26 22:12:56 2011
>> @@ -307,7 +307,7 @@ config NOMMU_INITIAL_TRIM_EXCESS
>>
>> =C2=A0config TRANSPARENT_HUGEPAGE
>> =C2=A0 =C2=A0 =C2=A0 bool "Transparent Hugepage Support"
>> - =C2=A0 =C2=A0 depends on X86 && MMU
>> + =C2=A0 =C2=A0 depends on MMU
>> =C2=A0 =C2=A0 =C2=A0 select COMPACTION
>> =C2=A0 =C2=A0 =C2=A0 help
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 Transparent Hugepages allows the kernel to u=
se huge pages and
>
> Then the build will break for all archs if they enable it, better to
> limit the option to those archs that supports it.
>
>> --- a/mm/huge_memory.c =C2=A0 =C2=A0 =C2=A0 =C2=A0Thu Nov 24 21:12:48 20=
11
>> +++ b/mm/huge_memory.c =C2=A0 =C2=A0 =C2=A0 =C2=A0Sat Nov 26 22:30:24 20=
11
>> @@ -17,6 +17,7 @@
>> =C2=A0#include <linux/khugepaged.h>
>> =C2=A0#include <linux/freezer.h>
>> =C2=A0#include <linux/mman.h>
>> +#include <linux/pagemap.h>
>> =C2=A0#include <asm/tlb.h>
>> =C2=A0#include <asm/pgalloc.h>
>> =C2=A0#include "internal.h"
>> @@ -135,6 +136,30 @@ static int set_recommended_min_free_kbyt
>> =C2=A0}
>> =C2=A0late_initcall(set_recommended_min_free_kbytes);
>>
>> +/* helper function for MIPS to call pmd_page() indirectly */
>> +static inline struct page *__pmd_page(pmd_t pmd)
>> +{
>> + =C2=A0 =C2=A0 struct page *page;
>> +
>> +#ifdef __HAVE_ARCH_THP_PMD_PAGE
>> + =C2=A0 =C2=A0 page =3D thp_pmd_page(pmd);
>> +#else
>> + =C2=A0 =C2=A0 page =3D pmd_page(pmd);
>> +#endif
>> + =C2=A0 =C2=A0 return page;
>> +}
>
> Why do you need this and also a branch in thp_pmd_page checking for
> pmd_trans_huge? If you fallback in pmd_page that would mean you're
> called by hugetlbfs. Doesn't make much sense to fallback in pmd_page
> if the hugepmd format for thp and hugetlbfs is different.
>
> Couldn't you set a different _PAGE_HUGE flag in the pmd in the thp
> case to avoid the above? Then you could have a pmd_page that works on
> both. Ok it'll be slower and require 1 more branch (but you already
> have a branch for something that doesn't seem needed).
>
> pmd_page is only called by hugetlbfs/thp, rest uses pte_offset* so I
> don't think a branch would be a big deal and you could hide the fact
> he format of the pmd between hugetlbfs and thp is different with a
> bitflag on the pmd (if any reserved is available to use to software).
>
>> +
>> +/* helper function for MIPS to call update_mmu_cache() indirectly */
>> +static inline void __update_mmu_cache(struct vm_area_struct *vma,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long addr,=
 pmd_t *pmdp)
>> +{
>> +#ifdef __HAVE_ARCH_UPDATE_MMU_THP
>> + =C2=A0 =C2=A0 update_mmu_thp(vma, addr, pmdp);
>> +#else
>> + =C2=A0 =C2=A0 update_mmu_cache(vma, addr, pmdp);
>> +#endif
>> +}
>
> Maybe here same, check pmd_trans_huge (and make it succeed only in the
> thp case and not the hugetlbfs case) and avoid it the __ and the ifdefs.
>

Got and thanks.

Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
