Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2DDDC6B0088
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 00:30:57 -0500 (EST)
Received: by iwn5 with SMTP id 5so636208iwn.14
        for <linux-mm@kvack.org>; Mon, 06 Dec 2010 21:30:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1012062005040.8572@tigran.mtv.corp.google.com>
References: <cover.1291568905.git.minchan.kim@gmail.com>
	<807118ceb3beeccdd69dda8228229e37b49d9803.1291568905.git.minchan.kim@gmail.com>
	<alpine.LSU.2.00.1012062005040.8572@tigran.mtv.corp.google.com>
Date: Tue, 7 Dec 2010 14:30:54 +0900
Message-ID: <AANLkTi=5CQ=c-NmwLoP3SJ6EMYwqf=Rvs5wzk2RdpO3g@mail.gmail.com>
Subject: Re: [PATCH v4 6/7] Remove zap_details NULL dependency
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

Hi Hugh,

On Tue, Dec 7, 2010 at 1:26 PM, Hugh Dickins <hughd@google.com> wrote:
> On Mon, 6 Dec 2010, Minchan Kim wrote:
>
>> Some functions used zap_details depends on assumption that
>> zap_details parameter should be NULLed if some fields are 0.
>>
>> This patch removes that dependency for next patch easy review/merge.
>> It should not chanage behavior.
>>
>> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>> Cc: Rik van Riel <riel@redhat.com>
>> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>> Cc: Nick Piggin <npiggin@kernel.dk>
>> Cc: Mel Gorman <mel@csn.ul.ie>
>> Cc: Wu Fengguang <fengguang.wu@intel.com>
>> Cc: Hugh Dickins <hughd@google.com>
>
> Sorry, while I do like that you're now using the details block,
> you seem to be adding overhead in various places without actually
> simplifying anything - you insist that everything passes down an
> initialized details block, and then in the end force the pointer
> to NULL again in all the common cases.
>
> Which seems odd. =A0I could understand if you were going to scrap
> the NULL details optimization altogether; but I think that (for
> the original optimization reasons) you're right to force it to NULL
> in the end, so then why initialize the block at all those call sites?
>
>> ---
>> =A0include/linux/mm.h | =A0 =A08 ++++++++
>> =A0mm/madvise.c =A0 =A0 =A0 | =A0 15 +++++++++------
>> =A0mm/memory.c =A0 =A0 =A0 =A0| =A0 14 ++++++++------
>> =A0mm/mmap.c =A0 =A0 =A0 =A0 =A0| =A0 =A06 ++++--
>> =A04 files changed, 29 insertions(+), 14 deletions(-)
>>
>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>> index e097df6..6522ae4 100644
>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -773,6 +773,14 @@ struct zap_details {
>> =A0 =A0 =A0 unsigned long truncate_count; =A0 =A0 =A0 =A0 =A0 /* Compare=
 vm_truncate_count */
>> =A0};
>>
>> +#define __ZAP_DETAILS_INITIALIZER(name) \
>> + =A0 =A0 =A0 =A0 =A0 =A0 { .nonlinear_vma =3D NULL \
>> + =A0 =A0 =A0 =A0 =A0 =A0 , .check_mapping =3D NULL \
>> + =A0 =A0 =A0 =A0 =A0 =A0 , .i_mmap_lock =3D NULL }
>> +
>> +#define DEFINE_ZAP_DETAILS(name) =A0 =A0 =A0 =A0 =A0 =A0 \
>> + =A0 =A0 struct zap_details name =3D __ZAP_DETAILS_INITIALIZER(name)
>
> Okay.
>
>> +
>> =A0struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long=
 addr,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 pte_t pte);
>>
>> diff --git a/mm/madvise.c b/mm/madvise.c
>> index 319528b..bfa17aa 100644
>> --- a/mm/madvise.c
>> +++ b/mm/madvise.c
>> @@ -162,18 +162,21 @@ static long madvise_dontneed(struct vm_area_struct=
 * vma,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct vm_area_st=
ruct ** prev,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long sta=
rt, unsigned long end)
>> =A0{
>> + =A0 =A0 DEFINE_ZAP_DETAILS(details);
>> +
>> =A0 =A0 =A0 *prev =3D vma;
>> =A0 =A0 =A0 if (vma->vm_flags & (VM_LOCKED|VM_HUGETLB|VM_PFNMAP))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
>>
>> =A0 =A0 =A0 if (unlikely(vma->vm_flags & VM_NONLINEAR)) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 struct zap_details details =3D {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 .nonlinear_vma =3D vma,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 .last_index =3D ULONG_MAX,
>> - =A0 =A0 =A0 =A0 =A0 =A0 };
>> + =A0 =A0 =A0 =A0 =A0 =A0 details.nonlinear_vma =3D vma;
>> + =A0 =A0 =A0 =A0 =A0 =A0 details.last_index =3D ULONG_MAX;
>> +
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 zap_page_range(vma, start, end - start, &det=
ails);
>> - =A0 =A0 } else
>> - =A0 =A0 =A0 =A0 =A0 =A0 zap_page_range(vma, start, end - start, NULL);
>> + =A0 =A0 } else {
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 zap_page_range(vma, start, end - start, &detai=
ls);
>> + =A0 =A0 }
>
> You end up with two identical zap_page_range() lines:
> better have one after the if {} without an else.
>

Okay. Will fix.

>> =A0 =A0 =A0 return 0;
>> =A0}
>>
>> diff --git a/mm/memory.c b/mm/memory.c
>> index ebfeedf..c0879bb 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -900,6 +900,9 @@ static unsigned long zap_pte_range(struct mmu_gather=
 *tlb,
>>
>> =A0 =A0 =A0 init_rss_vec(rss);
>>
>> + =A0 =A0 if (!details->check_mapping && !details->nonlinear_vma)
>> + =A0 =A0 =A0 =A0 =A0 =A0 details =3D NULL;
>> +
>
> Aside from its necessity in the next patch, I thoroughly approve of
> your moving this optimization here: it is confusing, and better that
> it be done near where the fields are used, than off at the higher level.

Thanks.

>
>> =A0 =A0 =A0 pte =3D pte_offset_map_lock(mm, pmd, addr, &ptl);
>> =A0 =A0 =A0 arch_enter_lazy_mmu_mode();
>> =A0 =A0 =A0 do {
>> @@ -1038,9 +1041,6 @@ static unsigned long unmap_page_range(struct mmu_g=
ather *tlb,
>> =A0 =A0 =A0 pgd_t *pgd;
>> =A0 =A0 =A0 unsigned long next;
>>
>> - =A0 =A0 if (details && !details->check_mapping && !details->nonlinear_=
vma)
>> - =A0 =A0 =A0 =A0 =A0 =A0 details =3D NULL;
>> -
>
> Yes, I put it there because that was the highest point at which
> it could then be done, so it was optimal from a do-it-fewest-times
> point of view; but not at all helpful in understanding what's going
> on, much better as you have it.
>
>> =A0 =A0 =A0 BUG_ON(addr >=3D end);
>> =A0 =A0 =A0 mem_cgroup_uncharge_start();
>> =A0 =A0 =A0 tlb_start_vma(tlb, vma);
>> @@ -1102,7 +1102,7 @@ unsigned long unmap_vmas(struct mmu_gather **tlbp,
>> =A0 =A0 =A0 unsigned long tlb_start =3D 0; =A0 =A0/* For tlb_finish_mmu =
*/
>> =A0 =A0 =A0 int tlb_start_valid =3D 0;
>> =A0 =A0 =A0 unsigned long start =3D start_addr;
>> - =A0 =A0 spinlock_t *i_mmap_lock =3D details? details->i_mmap_lock: NUL=
L;
>> + =A0 =A0 spinlock_t *i_mmap_lock =3D details->i_mmap_lock;
>
> This appears to be the sole improvement from insisting that everywhere
> sets up an initialized details block. =A0I don't think this is worth it.
>
>> =A0 =A0 =A0 int fullmm =3D (*tlbp)->fullmm;
>> =A0 =A0 =A0 struct mm_struct *mm =3D vma->vm_mm;
>>
>> @@ -1217,10 +1217,11 @@ unsigned long zap_page_range(struct vm_area_stru=
ct *vma, unsigned long address,
>> =A0int zap_vma_ptes(struct vm_area_struct *vma, unsigned long address,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long size)
>> =A0{
>> + =A0 =A0 DEFINE_ZAP_DETAILS(details);
>
> Overhead.
>
>> =A0 =A0 =A0 if (address < vma->vm_start || address + size > vma->vm_end =
||
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 !(vma->vm_flags & VM_PFNMAP)=
)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -1;
>> - =A0 =A0 zap_page_range(vma, address, size, NULL);
>> + =A0 =A0 zap_page_range(vma, address, size, &details);
>> =A0 =A0 =A0 return 0;
>> =A0}
>> =A0EXPORT_SYMBOL_GPL(zap_vma_ptes);
>> @@ -2577,7 +2578,8 @@ restart:
>> =A0void unmap_mapping_range(struct address_space *mapping,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 loff_t const holebegin, loff_t const holelen=
, int even_cows)
>> =A0{
>> - =A0 =A0 struct zap_details details;
>> + =A0 =A0 DEFINE_ZAP_DETAILS(details);
>> +
>> =A0 =A0 =A0 pgoff_t hba =3D holebegin >> PAGE_SHIFT;
>> =A0 =A0 =A0 pgoff_t hlen =3D (holelen + PAGE_SIZE - 1) >> PAGE_SHIFT;
>>
>> diff --git a/mm/mmap.c b/mm/mmap.c
>> index b179abb..31d2594 100644
>> --- a/mm/mmap.c
>> +++ b/mm/mmap.c
>> @@ -1900,11 +1900,12 @@ static void unmap_region(struct mm_struct *mm,
>> =A0 =A0 =A0 struct vm_area_struct *next =3D prev? prev->vm_next: mm->mma=
p;
>> =A0 =A0 =A0 struct mmu_gather *tlb;
>> =A0 =A0 =A0 unsigned long nr_accounted =3D 0;
>> + =A0 =A0 DEFINE_ZAP_DETAILS(details);
>
> Overhead.
>
>>
>> =A0 =A0 =A0 lru_add_drain();
>> =A0 =A0 =A0 tlb =3D tlb_gather_mmu(mm, 0);
>> =A0 =A0 =A0 update_hiwater_rss(mm);
>> - =A0 =A0 unmap_vmas(&tlb, vma, start, end, &nr_accounted, NULL);
>> + =A0 =A0 unmap_vmas(&tlb, vma, start, end, &nr_accounted, &details);
>> =A0 =A0 =A0 vm_unacct_memory(nr_accounted);
>> =A0 =A0 =A0 free_pgtables(tlb, vma, prev? prev->vm_end: FIRST_USER_ADDRE=
SS,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0next? nex=
t->vm_start: 0);
>> @@ -2254,6 +2255,7 @@ void exit_mmap(struct mm_struct *mm)
>> =A0 =A0 =A0 struct vm_area_struct *vma;
>> =A0 =A0 =A0 unsigned long nr_accounted =3D 0;
>> =A0 =A0 =A0 unsigned long end;
>> + =A0 =A0 DEFINE_ZAP_DETAILS(details);
>
> Overhead.
>
>>
>> =A0 =A0 =A0 /* mm's last user has gone, and its about to be pulled down =
*/
>> =A0 =A0 =A0 mmu_notifier_release(mm);
>> @@ -2278,7 +2280,7 @@ void exit_mmap(struct mm_struct *mm)
>> =A0 =A0 =A0 tlb =3D tlb_gather_mmu(mm, 1);
>> =A0 =A0 =A0 /* update_hiwater_rss(mm) here? but nobody should be looking=
 */
>> =A0 =A0 =A0 /* Use -1 here to ensure all VMAs in the mm are unmapped */
>> - =A0 =A0 end =3D unmap_vmas(&tlb, vma, 0, -1, &nr_accounted, NULL);
>> + =A0 =A0 end =3D unmap_vmas(&tlb, vma, 0, -1, &nr_accounted, &details);
>> =A0 =A0 =A0 vm_unacct_memory(nr_accounted);
>>
>> =A0 =A0 =A0 free_pgtables(tlb, vma, FIRST_USER_ADDRESS, 0);
>> --
>
> Am I being too fussy?

Never. It's a good comment.
I don't want add overhead unnecessary.

will fix and resend.

Thanks for the review, Hugh.

>
> Hugh
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
