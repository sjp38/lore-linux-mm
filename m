Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id CB19B6B004D
	for <linux-mm@kvack.org>; Sat, 28 Jan 2012 06:23:49 -0500 (EST)
Received: by wibhj13 with SMTP id hj13so2621186wib.14
        for <linux-mm@kvack.org>; Sat, 28 Jan 2012 03:23:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1327705373-29395-3-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1327705373-29395-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<1327705373-29395-3-git-send-email-n-horiguchi@ah.jp.nec.com>
Date: Sat, 28 Jan 2012 19:23:47 +0800
Message-ID: <CAJd=RBCGeqqAMvNAF3wPKAVQCFO-hNk1c+7UwKod6tMWqQ1Gkw@mail.gmail.com>
Subject: Re: [PATCH 2/6] thp: optimize away unnecessary page table locking
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Hillf Danton <dhillf@gmail.com>

Hi Naoya

On Sat, Jan 28, 2012 at 7:02 AM, Naoya Horiguchi
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
> Changes since v3:
> =C2=A0- Fix likely/unlikely pattern in pmd_trans_huge_stable()
> =C2=A0- Change suffix from _stable to _lock
> =C2=A0- Introduce __pmd_trans_huge_lock() to avoid micro-regression
> =C2=A0- Return 1 when wait_split_huge_page path is taken
>
> Changes since v2:
> =C2=A0- Fix missing "return 0" in "thp under splitting" path
> =C2=A0- Remove unneeded comment
> =C2=A0- Change the name of check function to describe what it does
> =C2=A0- Add VM_BUG_ON(mmap_sem)
> ---
> =C2=A0fs/proc/task_mmu.c =C2=A0 =C2=A0 =C2=A0| =C2=A0 70 +++++++++-------=
-----------
> =C2=A0include/linux/huge_mm.h | =C2=A0 17 +++++++
> =C2=A0mm/huge_memory.c =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0120 +++++++++++=
+++++++++++-------------------------
> =C2=A03 files changed, 96 insertions(+), 111 deletions(-)
>
[...]

> @@ -1064,21 +1056,14 @@ int mincore_huge_pmd(struct vm_area_struct *vma, =
pmd_t *pmd,
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int ret =3D 0;
>
> - =C2=A0 =C2=A0 =C2=A0 spin_lock(&vma->vm_mm->page_table_lock);
> - =C2=A0 =C2=A0 =C2=A0 if (likely(pmd_trans_huge(*pmd))) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D !pmd_trans_spl=
itting(*pmd);

Here the value of ret is either false or true,

> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_unlock(&vma->vm_m=
m->page_table_lock);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (unlikely(!ret))
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 wait_split_huge_page(vma->anon_vma, pmd);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 else {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 /*
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0* All logical pages in the range are present
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0* if backed by a huge page.
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0*/
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 memset(vec, 1, (end - addr) >> PAGE_SHIFT);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
> - =C2=A0 =C2=A0 =C2=A0 } else
> + =C2=A0 =C2=A0 =C2=A0 if (__pmd_trans_huge_lock(pmd, vma) =3D=3D 1) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* All logical pa=
ges in the range are present
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* if backed by a=
 huge page.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock(&vma->=
vm_mm->page_table_lock);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 memset(vec, 1, (end - =
addr) >> PAGE_SHIFT);
> + =C2=A0 =C2=A0 =C2=A0 }
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return ret;

what is the returned value of this function? /Hillf

> =C2=A0}
> @@ -1108,20 +1093,10 @@ int move_huge_pmd(struct vm_area_struct *vma, str=
uct vm_area_struct *new_vma,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto out;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
