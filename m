Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2EC7C8D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 02:59:51 -0400 (EDT)
Received: by iyh42 with SMTP id 42so1805262iyh.14
        for <linux-mm@kvack.org>; Wed, 20 Apr 2011 23:59:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110415101248.GB22688@suse.de>
References: <20110415101248.GB22688@suse.de>
Date: Thu, 21 Apr 2011 15:59:47 +0900
Message-ID: <BANLkTik7H+cmA8iToV4j1ncbQqeraCaeTg@mail.gmail.com>
Subject: Re: [PATCH] mm: Check if PTE is already allocated during page fault
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: akpm@linux-foundation.org, Andrea Arcangeli <aarcange@redhat.com>, raz ben yehuda <raziebe@gmail.com>, riel@redhat.com, kosaki.motohiro@jp.fujitsu.com, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, stable@kernel.org

Hi Mel,

On Fri, Apr 15, 2011 at 7:12 PM, Mel Gorman <mgorman@suse.de> wrote:
> With transparent hugepage support, handle_mm_fault() has to be careful
> that a normal PMD has been established before handling a PTE fault. To
> achieve this, it used __pte_alloc() directly instead of pte_alloc_map
> as pte_alloc_map is unsafe to run against a huge PMD. pte_offset_map()
> is called once it is known the PMD is safe.
>
> pte_alloc_map() is smart enough to check if a PTE is already present
> before calling __pte_alloc but this check was lost. As a consequence,
> PTEs may be allocated unnecessarily and the page table lock taken.
> Thi useless PTE does get cleaned up but it's a performance hit which
> is visible in page_test from aim9.
>
> This patch simply re-adds the check normally done by pte_alloc_map to
> check if the PTE needs to be allocated before taking the page table
> lock. The effect is noticable in page_test from aim9.
>
> AIM9
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A02.6.38-vanilla 2.6=
.38-checkptenone
> creat-clo =C2=A0 =C2=A0 =C2=A0446.10 ( 0.00%) =C2=A0 424.47 (-5.10%)
> page_test =C2=A0 =C2=A0 =C2=A0 38.10 ( 0.00%) =C2=A0 =C2=A042.04 ( 9.37%)
> brk_test =C2=A0 =C2=A0 =C2=A0 =C2=A052.45 ( 0.00%) =C2=A0 =C2=A051.57 (-1=
.71%)
> exec_test =C2=A0 =C2=A0 =C2=A0382.00 ( 0.00%) =C2=A0 456.90 (16.39%)
> fork_test =C2=A0 =C2=A0 =C2=A0 60.11 ( 0.00%) =C2=A0 =C2=A067.79 (11.34%)
> MMTests Statistics: duration
> Total Elapsed Time (seconds) =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0611.90 =C2=A0 =C2=A0612.22
>
> (While this affects 2.6.38, it is a performance rather than a
> functional bug and normally outside the rules -stable. While the big
> performance differences are to a microbench, the difference in fork
> and exec performance may be significant enough that -stable wants to
> consider the patch)
>
> Reported-by: Raz Ben Yehuda <raziebe@gmail.com>
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> --
> =C2=A0mm/memory.c | =C2=A0 =C2=A02 +-
> =C2=A01 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/memory.c b/mm/memory.c
> index 5823698..1659574 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3322,7 +3322,7 @@ int handle_mm_fault(struct mm_struct *mm, struct vm=
_area_struct *vma,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * run pte_offset_map on the pmd, if an huge p=
md could
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * materialize from under us from a different =
thread.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> - =C2=A0 =C2=A0 =C2=A0 if (unlikely(__pte_alloc(mm, vma, pmd, address)))
> + =C2=A0 =C2=A0 =C2=A0 if (unlikely(pmd_none(*pmd)) && __pte_alloc(mm, vm=
a, pmd, address))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return VM_FAULT_OO=
M;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* if an huge pmd materialized from under us j=
ust retry later */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (unlikely(pmd_trans_huge(*pmd)))
>

Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Sorry for jumping in too late. I have a just nitpick.

We have another place, do_huge_pmd_anonymous_page.
Although it isn't workload of page_test, is it valuable to expand your
patch to cover it?
If there is workload there are many thread and share one shared anon
vma in ALWAYS THP mode, same problem would happen.


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
