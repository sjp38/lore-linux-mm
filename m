Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 3FC516B0012
	for <linux-mm@kvack.org>; Wed, 18 May 2011 19:17:15 -0400 (EDT)
Received: by qyk30 with SMTP id 30so1550289qyk.14
        for <linux-mm@kvack.org>; Wed, 18 May 2011 16:17:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1105171120220.29593@sister.anvils>
References: <alpine.LSU.2.00.1105171120220.29593@sister.anvils>
Date: Thu, 19 May 2011 08:17:13 +0900
Message-ID: <BANLkTi=4YY6aJk+ZLiiF7UX73LZD=7+W2Q@mail.gmail.com>
Subject: Re: [PATCH mmotm] add the pagefault count into memcg stats: shmem fix
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org

Hi Hugh,

On Wed, May 18, 2011 at 3:24 AM, Hugh Dickins <hughd@google.com> wrote:
> mem_cgroup_count_vm_event() should update the PGMAJFAULT count for the
> target mm, not for current mm (but of course they're usually the same).
>
> We don't know the target mm in shmem_getpage(), so do it at the outer
> level in shmem_fault(); and it's easier to follow if we move the
> count_vm_event(PGMAJFAULT) there too.
>
> Hah, it was using __count_vm_event() before, sneaking that update into
> the unpreemptible section under info->lock: well, it comes to the same
> on x86 at least, and I still think it's best to keep these together.
>
> Signed-off-by: Hugh Dickins <hughd@google.com>

It's good to me but I have a nitpick.

You are changing behavior a bit.
Old behavior is to account FAULT although the operation got failed.
But new one is to not account it.
I think we have to account it regardless of whether it is successful or not=
.
That's because it is fact fault happens.

> ---
>
> =C2=A0mm/shmem.c | =C2=A0 13 ++++++-------
> =C2=A01 file changed, 6 insertions(+), 7 deletions(-)
>
> --- mmotm/mm/shmem.c =C2=A0 =C2=A02011-05-13 14:57:45.367884578 -0700
> +++ linux/mm/shmem.c =C2=A0 =C2=A02011-05-17 10:27:19.901934756 -0700
> @@ -1293,14 +1293,10 @@ repeat:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0swappage =3D looku=
p_swap_cache(swap);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!swappage) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0shmem_swp_unmap(entry);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 spin_unlock(&info->lock);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0/* here we actually do the io */
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 if (type && !(*type & VM_FAULT_MAJOR)) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __count_vm_event(PGMAJFAULT);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mem_cgroup_count_vm_event(current->mm,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 PGMAJFAULT);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 if (type)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*type |=3D VM_FAULT_MAJOR;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 }
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 spin_unlock(&info->lock);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0swappage =3D shmem_swapin(swap, gfp, info, idx);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0if (!swappage) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock(&info->lock);
> @@ -1539,7 +1535,10 @@ static int shmem_fault(struct vm_area_st
> =C2=A0 =C2=A0 =C2=A0 =C2=A0error =3D shmem_getpage(inode, vmf->pgoff, &vm=
f->page, SGP_CACHE, &ret);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (error)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return ((error =3D=
=3D -ENOMEM) ? VM_FAULT_OOM : VM_FAULT_SIGBUS);
> -
> + =C2=A0 =C2=A0 =C2=A0 if (ret & VM_FAULT_MAJOR) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 count_vm_event(PGMAJFA=
ULT);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mem_cgroup_count_vm_ev=
ent(vma->vm_mm, PGMAJFAULT);
> + =C2=A0 =C2=A0 =C2=A0 }
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return ret | VM_FAULT_LOCKED;
> =C2=A0}
>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
