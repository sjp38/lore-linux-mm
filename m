Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 94D056B004F
	for <linux-mm@kvack.org>; Sat, 16 May 2009 21:36:11 -0400 (EDT)
Received: by gxk20 with SMTP id 20so5218459gxk.14
        for <linux-mm@kvack.org>; Sat, 16 May 2009 18:36:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090516090448.249602749@intel.com>
References: <20090516090005.916779788@intel.com>
	 <20090516090448.249602749@intel.com>
Date: Sun, 17 May 2009 10:36:44 +0900
Message-ID: <28c262360905161836u332f9e9aj6fa3f3b65da95592@mail.gmail.com>
Subject: Re: [PATCH 1/3] vmscan: report vm_flags in page_referenced()
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "riel@redhat.com" <riel@redhat.com>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Sat, May 16, 2009 at 6:00 PM, Wu Fengguang <fengguang.wu@intel.com> wrot=
e:
> Collect vma->vm_flags of the VMAs that actually referenced the page.
>
> This is preparing for more informed reclaim heuristics,
> eg. to protect executable file pages more aggressively.
> For now only the VM_EXEC bit will be used by the caller.
>
> CC: Minchan Kim <minchan.kim@gmail.com>
> CC: Johannes Weiner <hannes@cmpxchg.org>
> CC: Peter Zijlstra <peterz@infradead.org>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
> =C2=A0include/linux/rmap.h | =C2=A0 =C2=A05 +++--
> =C2=A0mm/rmap.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 37 ++++=
++++++++++++++++++++++-----------
> =C2=A0mm/vmscan.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A07 ++++=
+--
> =C2=A03 files changed, 34 insertions(+), 15 deletions(-)
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
> @@ -333,7 +333,9 @@ static int page_mapped_in_vma(struct pag
> =C2=A0* repeatedly from either page_referenced_anon or page_referenced_fi=
le.
> =C2=A0*/
> =C2=A0static int page_referenced_one(struct page *page,
> - =C2=A0 =C2=A0 =C2=A0 struct vm_area_struct *vma, unsigned int *mapcount=
)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct vm_area_struct *vma,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned int *mapcount,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long *vm_flags)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct mm_struct *mm =3D vma->vm_mm;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long address;
> @@ -381,11 +383,14 @@ out_unmap:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0(*mapcount)--;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pte_unmap_unlock(pte, ptl);
> =C2=A0out:
> + =C2=A0 =C2=A0 =C2=A0 if (referenced)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 *vm_flags |=3D vma->vm=
_flags;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return referenced;
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
> @@ -405,7 +410,8 @@ static int page_referenced_anon(struct p
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (mem_cont && !m=
m_match_cgroup(vma->vm_mm, mem_cont))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0continue;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 referenced +=3D page_r=
eferenced_one(page, vma, &mapcount);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 referenced +=3D page_r=
eferenced_one(page, vma,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 &mapcount, vm_flags);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!mapcount)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0break;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> @@ -418,6 +424,7 @@ static int page_referenced_anon(struct p
> =C2=A0* page_referenced_file - referenced check for object-based rmap
> =C2=A0* @page: the page we're checking references on.
> =C2=A0* @mem_cont: target memory controller
> + * @vm_flags: collect encountered vma->vm_flags

I missed this.
To clarify, how about ?
collect encountered vma->vm_flags among vma which referenced the page

--=20
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
