Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 2DDED6B004A
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 09:40:11 -0500 (EST)
Received: by vbbey12 with SMTP id ey12so3276760vbb.14
        for <linux-mm@kvack.org>; Wed, 29 Feb 2012 06:40:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120229092859.a0411859.kamezawa.hiroyu@jp.fujitsu.com>
References: <1330463552-18473-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<20120229092859.a0411859.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 29 Feb 2012 22:40:09 +0800
Message-ID: <CAJd=RBAVaWud3f6AUSr1PDWS_VvBgiSMobRdLyokwx3bcHqCKQ@mail.gmail.com>
Subject: Re: [RFC][PATCH] memcg: avoid THP split in task migration
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Wed, Feb 29, 2012 at 8:28 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 28 Feb 2012 16:12:32 -0500
> Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
>
>> Currently we can't do task migration among memory cgroups without THP sp=
lit,
>> which means processes heavily using THP experience large overhead in tas=
k
>> migration. This patch introduce the code for moving charge of THP and ma=
kes
>> THP more valuable.
>>
>> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>> Cc: Hillf Danton <dhillf@gmail.com>
>
>
> Thank you!

   ++hd;

>
> A comment below.
>
>> ---
>> =C2=A0mm/memcontrol.c | =C2=A0 76 ++++++++++++++++++++++++++++++++++++++=
++++++++++++----
>> =C2=A01 files changed, 70 insertions(+), 6 deletions(-)
>>
>> diff --git linux-next-20120228.orig/mm/memcontrol.c linux-next-20120228/=
mm/memcontrol.c
>> index c83aeb5..e97c041 100644
>> --- linux-next-20120228.orig/mm/memcontrol.c
>> +++ linux-next-20120228/mm/memcontrol.c
>> @@ -5211,6 +5211,42 @@ static int is_target_pte_for_mc(struct vm_area_st=
ruct *vma,
>> =C2=A0 =C2=A0 =C2=A0 return ret;
>> =C2=A0}
>>
>> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
>> +/*
>> + * We don't consider swapping or file mapped pages because THP does not
>> + * support them for now.
>> + */
>> +static int is_target_huge_pmd_for_mc(struct vm_area_struct *vma,

static int is_target_thp_for_mc(struct vm_area_struct *vma,
or
static int is_target_pmd_for_mc(struct vm_area_struct *vma,
sounds better?

>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long addr, pmd_t pm=
d, union mc_target *target)
>> +{
>> + =C2=A0 =C2=A0 struct page *page =3D NULL;
>> + =C2=A0 =C2=A0 struct page_cgroup *pc;
>> + =C2=A0 =C2=A0 int ret =3D 0;
>> +
>> + =C2=A0 =C2=A0 if (pmd_present(pmd))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 page =3D pmd_page(pmd);
>> + =C2=A0 =C2=A0 if (!page)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 0;
>> + =C2=A0 =C2=A0 VM_BUG_ON(!PageHead(page));

With a huge and stable pmd, the above operations on page could be
compacted into one line?

	page =3D pmd_page(pmd);

>> + =C2=A0 =C2=A0 get_page(page);
>> + =C2=A0 =C2=A0 pc =3D lookup_page_cgroup(page);
>> + =C2=A0 =C2=A0 if (PageCgroupUsed(pc) && pc->mem_cgroup =3D=3D mc.from)=
 {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D MC_TARGET_PAGE;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (target)

After checking target, looks only get_page() needed?

>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
target->page =3D page;
>> + =C2=A0 =C2=A0 }
>> + =C2=A0 =C2=A0 if (!ret || !target)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 put_page(page);
>> + =C2=A0 =C2=A0 return ret;
>> +}
>> +#else
>> +static inline int is_target_huge_pmd_for_mc(struct vm_area_struct *vma,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long addr, pmd_t pm=
d, union mc_target *target)
>> +{
>> + =C2=A0 =C2=A0 return 0;
>> +}
>> +#endif
>> +
>> =C2=A0static int mem_cgroup_count_precharge_pte_range(pmd_t *pmd,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned lon=
g addr, unsigned long end,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct mm_wa=
lk *walk)
>> @@ -5219,7 +5255,13 @@ static int mem_cgroup_count_precharge_pte_range(p=
md_t *pmd,
>> =C2=A0 =C2=A0 =C2=A0 pte_t *pte;
>> =C2=A0 =C2=A0 =C2=A0 spinlock_t *ptl;
>>
>> - =C2=A0 =C2=A0 split_huge_page_pmd(walk->mm, pmd);
>> + =C2=A0 =C2=A0 if (pmd_trans_huge_lock(pmd, vma) =3D=3D 1) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (is_target_huge_pmd_for_m=
c(vma, addr, *pmd, NULL))

		if (is_target_huge_pmd_for_mc(vma, addr, *pmd, NULL) =3D=3D MC_TARGET_PAG=
E)
looks clearer

>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
mc.precharge +=3D HPAGE_PMD_NR;

As HPAGE_PMD_NR is directly used, compiler beeps if THP disabled, I guess.

If yes, please cleanup huge_mm.h with s/BUG()/BUILD_BUG()/ and with
both HPAGE_PMD_ORDER and HPAGE_PMD_NR also defined,
to easy others a bit.

>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_unlock(&walk->mm->page_=
table_lock);

		spin_unlock(&vma->mm->page_table_lock);
looks clearer
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 cond_resched();
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 0;
>> + =C2=A0 =C2=A0 }
>>
>> =C2=A0 =C2=A0 =C2=A0 pte =3D pte_offset_map_lock(vma->vm_mm, pmd, addr, =
&ptl);
>> =C2=A0 =C2=A0 =C2=A0 for (; addr !=3D end; pte++, addr +=3D PAGE_SIZE)
>> @@ -5378,16 +5420,38 @@ static int mem_cgroup_move_charge_pte_range(pmd_=
t *pmd,
>> =C2=A0 =C2=A0 =C2=A0 struct vm_area_struct *vma =3D walk->private;
>> =C2=A0 =C2=A0 =C2=A0 pte_t *pte;
>> =C2=A0 =C2=A0 =C2=A0 spinlock_t *ptl;
>> + =C2=A0 =C2=A0 int type;
>> + =C2=A0 =C2=A0 union mc_target target;
>> + =C2=A0 =C2=A0 struct page *page;
>> + =C2=A0 =C2=A0 struct page_cgroup *pc;
>> +
>> + =C2=A0 =C2=A0 if (pmd_trans_huge_lock(pmd, vma) =3D=3D 1) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!mc.precharge)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
return 0;

Bang, return without page table lock released.

>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 type =3D is_target_huge_pmd_=
for_mc(vma, addr, *pmd, &target);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (type =3D=3D MC_TARGET_PA=
GE) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
page =3D target.page;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
if (!isolate_lru_page(page)) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 pc =3D lookup_page_cgroup(page);
>
> Here is a diffuclut point. Please see mem_cgroup_split_huge_fixup(). It s=
plits

Hard and hard point IMO.

> updates memcg's status of splitted pages under lru_lock and compound_lock
> but not under mm->page_table_lock.
>
> Looking into split_huge_page()
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0split_huge_page() =C2=A0# take anon_vma lock
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__split_huge_page(=
)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0__split_huge_page_refcount() # take lru_lock, compound_lock.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mem_cgroup_split_huge_fixup()
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0__split_huge_page_map() # take page table lock.
>
[copied from Naoya-san's reply]

> I'm afraid this callchain is not correct.

s/correct/complete/

> Page table lock seems to be taken before we enter the main split work.
>
> =C2=A0 =C2=A0split_huge_page
> =C2=A0 =C2=A0 =C2=A0 =C2=A0take anon_vma lock
> =C2=A0 =C2=A0 =C2=A0 =C2=A0__split_huge_page
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__split_huge_page_splitting
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0lock page_table_lo=
ck =C2=A0 =C2=A0 <--- *1
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0page_check_address=
_pmd
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unlock page_table_=
lock

Yeah, splitters are blocked.
Plus from the *ugly* documented lock function(another
cleanup needed), the embedded mmap_sem also blocks splitters.

That said, could we simply wait and see results of test cases?

-hd

/* mmap_sem must be held on entry */
static inline int pmd_trans_huge_lock(pmd_t *pmd,
				      struct vm_area_struct *vma)
{
	VM_BUG_ON(!rwsem_is_locked(&vma->vm_mm->mmap_sem));
	if (pmd_trans_huge(*pmd))
		return __pmd_trans_huge_lock(pmd, vma);
	else
		return 0;
}

> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__split_huge_page_refcount
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0lock lru_lock
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0compound_lock
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mem_cgroup_split_h=
uge_fixup
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0compound_unlock
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unlock lru_lock
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__split_huge_page_map
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0lock page_table_lo=
ck
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0... some work
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unlock page_table_=
lock
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unlock anon_vma lock
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
