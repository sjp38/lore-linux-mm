Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id CAEFF6B004F
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 07:04:57 -0500 (EST)
Received: by wicr5 with SMTP id r5so403347wic.14
        for <linux-mm@kvack.org>; Fri, 13 Jan 2012 04:04:56 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1326396898-5579-3-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1326396898-5579-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<1326396898-5579-3-git-send-email-n-horiguchi@ah.jp.nec.com>
Date: Fri, 13 Jan 2012 20:04:56 +0800
Message-ID: <CAJd=RBB6azf9nin5tjqTtHakxy896rCxr6ErK4p2KDrke_goEA@mail.gmail.com>
Subject: Re: [PATCH 2/6] thp: optimize away unnecessary page table locking
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jan 13, 2012 at 3:34 AM, Naoya Horiguchi
<n-horiguchi@ah.jp.nec.com> wrote:
> Currently when we check if we can handle thp as it is or we need to
> split it into regular sized pages, we hold page table lock prior to
> check whether a given pmd is mapping thp or not. Because of this,
> when it's not "huge pmd" we suffer from unnecessary lock/unlock overhead.
> To remove it, this patch introduces a optimized check function and
> replace several similar logics with it.
>
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: David Rientjes <rientjes@google.com>
>
> Changes since v2:
> =C2=A0- Fix missing "return 0" in "thp under splitting" path
> =C2=A0- Remove unneeded comment
> =C2=A0- Change the name of check function to describe what it does
> =C2=A0- Add VM_BUG_ON(mmap_sem)
> ---
> =C2=A0fs/proc/task_mmu.c =C2=A0 =C2=A0 =C2=A0| =C2=A0 73 +++++++++-------=
-----------
> =C2=A0include/linux/huge_mm.h | =C2=A0 =C2=A07 +++
> =C2=A0mm/huge_memory.c =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0127 +++++++++++=
++++++++++++------------------------
> =C2=A0mm/mremap.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=
=A03 +-
> =C2=A04 files changed, 95 insertions(+), 115 deletions(-)
>
[...]
> +/*
> + * Returns 1 if a given pmd is mapping a thp and stable (not under split=
ting.)
> + * Returns 0 otherwise. Note that if it returns 1, this routine returns =
without
> + * unlocking page table locks. So callers must unlock them.
> + */
> +int pmd_trans_huge_stable(pmd_t *pmd, struct vm_area_struct *vma)
> +{
> + =C2=A0 =C2=A0 =C2=A0 VM_BUG_ON(!rwsem_is_locked(&vma->vm_mm->mmap_sem))=
;
> +
> + =C2=A0 =C2=A0 =C2=A0 if (!pmd_trans_huge(*pmd))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 0;
> +
> + =C2=A0 =C2=A0 =C2=A0 spin_lock(&vma->vm_mm->page_table_lock);
> + =C2=A0 =C2=A0 =C2=A0 if (likely(pmd_trans_huge(*pmd))) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (pmd_trans_splittin=
g(*pmd)) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 spin_unlock(&vma->vm_mm->page_table_lock);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 wait_split_huge_page(vma->anon_vma, pmd);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 return 0;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 } else {

    =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0   spin_unlock(&vma->vm_mm->page_table_lock);     yes?

> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 /* Thp mapped by 'pmd' is stable, so we can
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0* handle it as it is. */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 return 1;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 spin_unlock(&vma->vm_mm->page_table_lock);
> + =C2=A0 =C2=A0 =C2=A0 return 0;
> +}
> +

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
