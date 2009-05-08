Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 8F3566B003D
	for <linux-mm@kvack.org>; Fri,  8 May 2009 08:09:17 -0400 (EDT)
Received: by yw-out-1718.google.com with SMTP id 5so702007ywm.26
        for <linux-mm@kvack.org>; Fri, 08 May 2009 05:09:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090508041700.GC8892@localhost>
References: <20090430181340.6f07421d.akpm@linux-foundation.org>
	 <20090430195439.e02edc26.akpm@linux-foundation.org>
	 <49FB01C1.6050204@redhat.com>
	 <20090501123541.7983a8ae.akpm@linux-foundation.org>
	 <20090503031539.GC5702@localhost> <1241432635.7620.4732.camel@twins>
	 <20090507121101.GB20934@localhost> <20090507151039.GA2413@cmpxchg.org>
	 <1241709466.11251.164.camel@twins> <20090508041700.GC8892@localhost>
Date: Fri, 8 May 2009 21:09:24 +0900
Message-ID: <28c262360905080509q333ec8acv2d2be69d99e1dfa3@mail.gmail.com>
Subject: Re: [RFC][PATCH] vmscan: report vm_flags in page_referenced()
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, May 8, 2009 at 1:17 PM, Wu Fengguang <fengguang.wu@intel.com> wrote=
:
> On Thu, May 07, 2009 at 11:17:46PM +0800, Peter Zijlstra wrote:
>> On Thu, 2009-05-07 at 17:10 +0200, Johannes Weiner wrote:
>>
>> > > @@ -1269,8 +1270,15 @@ static void shrink_active_list(unsigned
>> > >
>> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* page_referenced clears PageRef=
erenced */
>> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (page_mapping_inuse(page) &&
>> > > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 page_referenced(page, 0,=
 sc->mem_cgroup))
>> > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 page_referenced(page, 0,=
 sc->mem_cgroup)) {
>> > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct add=
ress_space *mapping =3D page_mapping(page);
>> > > +
>> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pgmov=
ed++;
>> > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (mappin=
g && test_bit(AS_EXEC, &mapping->flags)) {
>> > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 list_add(&page->lru, &l_active);
>> > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 continue;
>> > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> >
>> > Since we walk the VMAs in page_referenced anyway, wouldn't it be
>> > better to check if one of them is executable? =C2=A0This would even wo=
rk
>> > for executable anon pages. =C2=A0After all, there are applications tha=
t cow
>> > executable mappings (sbcl and other language environments that use an
>> > executable, run-time modified core image come to mind).
>>
>> Hmm, like provide a vm_flags mask along to page_referenced() to only
>> account matching vmas... seems like a sensible idea.
>
> Here is a quick patch for your opinions. Compile tested.
>
> With the added vm_flags reporting, the mlock=3D>unevictable logic can
> possibly be made more straightforward.
>
> Thanks,
> Fengguang
> ---
> vmscan: report vm_flags in page_referenced()
>
> This enables more informed reclaim heuristics, eg. to protect executable
> file pages more aggressively.
>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
> =C2=A0include/linux/rmap.h | =C2=A0 =C2=A05 +++--
> =C2=A0mm/rmap.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 30 ++++=
+++++++++++++++++---------
> =C2=A0mm/vmscan.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A07 ++++=
+--
> =C2=A03 files changed, 29 insertions(+), 13 deletions(-)
>
> --- linux.orig/include/linux/rmap.h
> +++ linux/include/linux/rmap.h
> @@ -83,7 +83,8 @@ static inline void page_dup_rmap(struct
> =C2=A0/*
> =C2=A0* Called from mm/vmscan.c to handle paging out
> =C2=A0*/
> -int page_referenced(struct page *, int is_locked, struct mem_cgroup *cnt=
);
> +int page_referenced(struct page *, int is_locked,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 struct mem_cgroup *cnt, unsigned long *vm_flags);
> =C2=A0int try_to_unmap(struct page *, int ignore_refs);
>
> =C2=A0/*
> @@ -128,7 +129,7 @@ int page_wrprotect(struct page *page, in
> =C2=A0#define anon_vma_prepare(vma) =C2=A0(0)
> =C2=A0#define anon_vma_link(vma) =C2=A0 =C2=A0 do {} while (0)
>
> -#define page_referenced(page,l,cnt) TestClearPageReferenced(page)
> +#define page_referenced(page, locked, cnt, flags) TestClearPageReference=
d(page)
> =C2=A0#define try_to_unmap(page, refs) SWAP_FAIL
>
> =C2=A0static inline int page_mkclean(struct page *page)
> --- linux.orig/mm/rmap.c
> +++ linux/mm/rmap.c
> @@ -333,7 +333,8 @@ static int page_mapped_in_vma(struct pag
> =C2=A0* repeatedly from either page_referenced_anon or page_referenced_fi=
le.
> =C2=A0*/
> =C2=A0static int page_referenced_one(struct page *page,
> - =C2=A0 =C2=A0 =C2=A0 struct vm_area_struct *vma, unsigned int *mapcount=
)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct vm_area_struct *vma,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned int *mapcount)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct mm_struct *mm =3D vma->vm_mm;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long address;
> @@ -385,7 +386,8 @@ out:
> =C2=A0}
>
> =C2=A0static int page_referenced_anon(struct page *page,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct mem_cgroup *mem_cont)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct mem_cgroup *mem_cont,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long *vm_flags)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned int mapcount;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct anon_vma *anon_vma;
> @@ -406,6 +408,7 @@ static int page_referenced_anon(struct p
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (mem_cont && !m=
m_match_cgroup(vma->vm_mm, mem_cont))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0continue;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0referenced +=3D pa=
ge_referenced_one(page, vma, &mapcount);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 *vm_flags |=3D vma->vm=
_flags;

Sometime this vma don't contain the anon page.
That's why we need page_check_address.
For such a case, wrong *vm_flag cause be harmful to reclaim.
It can be happen in your first class citizen patch, I think.



--=20
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
