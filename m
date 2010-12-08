Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 10DA16B008C
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 02:55:12 -0500 (EST)
Received: by iwn1 with SMTP id 1so1280993iwn.37
        for <linux-mm@kvack.org>; Tue, 07 Dec 2010 23:55:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1012072258420.5260@sister.anvils>
References: <cover.1291568905.git.minchan.kim@gmail.com>
	<ca25c4e33beceeb3a96e8437671e5e0a188602fa.1291568905.git.minchan.kim@gmail.com>
	<alpine.LSU.2.00.1012062027100.8572@tigran.mtv.corp.google.com>
	<AANLkTindkfPJxxjR-nVy+Tmu6Q=fs2c=KOmdOQyfXaCP@mail.gmail.com>
	<alpine.LSU.2.00.1012072258420.5260@sister.anvils>
Date: Wed, 8 Dec 2010 16:55:11 +0900
Message-ID: <AANLkTinx6wBUxQKWeCfcLbqB60qvTFWd8EHS0cGTj-Ma@mail.gmail.com>
Subject: Re: [PATCH v4 7/7] Prevent activation of page in madvise_dontneed
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 8, 2010 at 4:26 PM, Hugh Dickins <hughd@google.com> wrote:
> On Tue, 7 Dec 2010, Minchan Kim wrote:
>>
>> How about this? Although it doesn't remove null dependency, it meet my
>> goal without big overhead.
>> It's just quick patch.
>
> Roughly, yes; by "just quick patch" I take you to mean that I should
> not waste time on all the minor carelessnesses scattered through it.
>
>> If you agree, I will resend this version as formal patch.
>> (If you suffered from seeing below word-wrapped source, see the
>> attachment. I asked to google two time to support text-plain mode in
>> gmail web but I can't receive any response until now. ;(. Lots of
>> kernel developer in google. Please support this mode for us who can't
>> use SMTP although it's a very small VOC)
>
> Tiresome. =A0Seems not to be high on gmail's priorities.
> It's sad to see even Linus attaching patches these days.

That encourages me(But I don't mean I will use attachment again. :)).

>
>>
>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>> index e097df6..14ae918 100644
>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -771,6 +771,7 @@ struct zap_details {
>> =A0 =A0 =A0 =A0 pgoff_t last_index; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 /* Highest page->index
>> to unmap */
>> =A0 =A0 =A0 =A0 spinlock_t *i_mmap_lock; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
/* For unmap_mapping_range: */
>> =A0 =A0 =A0 =A0 unsigned long truncate_count; =A0 =A0 =A0 =A0 =A0 /* Com=
pare vm_truncate_count */
>> + =A0 =A0 =A0 int ignore_reference;
>> =A0};
>>
>> =A0struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long=
 addr,
>> diff --git a/mm/madvise.c b/mm/madvise.c
>> index 319528b..fdb0253 100644
>> --- a/mm/madvise.c
>> +++ b/mm/madvise.c
>> @@ -162,18 +162,22 @@ static long madvise_dontneed(struct vm_area_struct=
 * vma,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct vm_are=
a_struct ** prev,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long=
 start, unsigned long end)
>> =A0{
>> + =A0 =A0 =A0 struct zap_details details ;
>> +
>> =A0 =A0 =A0 =A0 *prev =3D vma;
>> =A0 =A0 =A0 =A0 if (vma->vm_flags & (VM_LOCKED|VM_HUGETLB|VM_PFNMAP))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
>>
>> =A0 =A0 =A0 =A0 if (unlikely(vma->vm_flags & VM_NONLINEAR)) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct zap_details details =3D {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 .nonlinear_vma =3D vma,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 .last_index =3D ULONG_MAX,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 };
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 zap_page_range(vma, start, end - start, &d=
etails);
>> - =A0 =A0 =A0 } else
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 zap_page_range(vma, start, end - start, NU=
LL);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 details.nonlinear_vma =3D vma;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 details.last_index =3D ULONG_MAX;
>> + =A0 =A0 =A0 } else {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 details.nonlinear_vma =3D NULL;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 details.last_index =3D NULL;
>> + =A0 =A0 =A0 }
>> +
>> + =A0 =A0 =A0 details.ignore_references =3D true;
>> + =A0 =A0 =A0 zap_page_range(vma, start, end - start, &details);
>> =A0 =A0 =A0 =A0 return 0;
>> =A0}
>>
>> diff --git a/mm/memory.c b/mm/memory.c
>> index ebfeedf..d46ac42 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -897,9 +897,15 @@ static unsigned long zap_pte_range(struct mmu_gathe=
r *tlb,
>> =A0 =A0 =A0 =A0 pte_t *pte;
>> =A0 =A0 =A0 =A0 spinlock_t *ptl;
>> =A0 =A0 =A0 =A0 int rss[NR_MM_COUNTERS];
>> -
>> + =A0 =A0 =A0 bool ignore_reference =3D false;
>> =A0 =A0 =A0 =A0 init_rss_vec(rss);
>>
>> + =A0 =A0 =A0 if (details && ((!details->check_mapping && !details->nonl=
inear_vma)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0|| !details->ignore_reference))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 details =3D NULL;
>> +
>
> =A0 =A0 =A0 =A0bool mark_accessed =3D true;
>
> =A0 =A0 =A0 =A0if (VM_SequentialReadHint(vma) ||
> =A0 =A0 =A0 =A0 =A0 =A0(details && details->ignore_reference))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mark_accessed =3D false;
> =A0 =A0 =A0 =A0if (details && !details->check_mapping && !details->nonlin=
ear_vma)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0details =3D NULL;
>
>
>> =A0 =A0 =A0 =A0 pte =3D pte_offset_map_lock(mm, pmd, addr, &ptl);
>> =A0 =A0 =A0 =A0 arch_enter_lazy_mmu_mode();
>> =A0 =A0 =A0 =A0 do {
>> @@ -949,7 +955,8 @@ static unsigned long zap_pte_range(struct mmu_gather=
 *tlb,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (pte_=
dirty(ptent))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 set_page_dirty(page);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (pte_=
young(ptent) &&
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 li=
kely(!VM_SequentialReadHint(vma)))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 li=
kely(!VM_SequentialReadHint(vma)) &&
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 li=
kely(!ignore_reference))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 mark_page_accessed(page);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (pte_yo=
ung(ptent) && mark_accessed)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0mark_page_accessed(page);
>
>

Much clean.

>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rss[MM_F=
ILEPAGES]--;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> @@ -1038,8 +1045,6 @@ static unsigned long unmap_page_range(struct
>> mmu_gather *tlb,
>> =A0 =A0 =A0 =A0 pgd_t *pgd;
>> =A0 =A0 =A0 =A0 unsigned long next;
>>
>> - =A0 =A0 =A0 if (details && !details->check_mapping && !details->nonlin=
ear_vma)
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 details =3D NULL;
>>
>> =A0 =A0 =A0 =A0 BUG_ON(addr >=3D end);
>> =A0 =A0 =A0 =A0 mem_cgroup_uncharge_start();
>> @@ -1102,7 +1107,8 @@ unsigned long unmap_vmas(struct mmu_gather **tlbp,
>> =A0 =A0 =A0 =A0 unsigned long tlb_start =3D 0; =A0 =A0/* For tlb_finish_=
mmu */
>> =A0 =A0 =A0 =A0 int tlb_start_valid =3D 0;
>> =A0 =A0 =A0 =A0 unsigned long start =3D start_addr;
>> - =A0 =A0 =A0 spinlock_t *i_mmap_lock =3D details? details->i_mmap_lock:=
 NULL;
>> + =A0 =A0 =A0 spinlock_t *i_mmap_lock =3D details ?
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 (detais->check_mapping ? details->i_mmap_l=
ock: NULL) : NULL;
>
> Why that change?

It has done very careless. Sorry for that. I thought i_mmap_lock
always is used with check_mapping. Clear wrong!
My concern is that if we don't have such routine, caller use only
ingore_reference should initialize i_mmap_lock with NULL.
It's bad.

Hmm...

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
