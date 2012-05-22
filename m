Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 2ACAC6B004D
	for <linux-mm@kvack.org>; Mon, 21 May 2012 20:08:33 -0400 (EDT)
Received: by wibhj6 with SMTP id hj6so2465179wib.8
        for <linux-mm@kvack.org>; Mon, 21 May 2012 17:08:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1205120505560.28861@eggly.anvils>
References: <alpine.LSU.2.00.1205120447380.28861@eggly.anvils>
	<alpine.LSU.2.00.1205120505560.28861@eggly.anvils>
Date: Mon, 21 May 2012 17:08:29 -0700
Message-ID: <CANcMJZByO1Ovog_BhrnXzk-1L_Oues4cFLMMib901o_Pa=xy5w@mail.gmail.com>
Subject: Re: [PATCH 5/10] mm/fs: route MADV_REMOVE to FALLOC_FL_PUNCH_HOLE
From: john stultz <johnstul@us.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, =?ISO-8859-1?Q?Arve_Hj=F8nnev=E5g?= <arve@android.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Cong Wang <amwang@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Colin Cross <ccross@android.com>, John Stulz <john.stulz@linaro.org>, Greg Kroah-Hartman <gregkh@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger@dilger.ca>, Mark Fasheh <mfasheh@suse.de>, Joel Becker <jlbec@evilplan.org>, Dave Chinner <david@fromorbit.com>, Ben Myers <bpm@sgi.com>, Michael Kerrisk <mtk.manpages@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Sat, May 12, 2012 at 5:13 AM, Hugh Dickins <hughd@google.com> wrote:
> Now tmpfs supports hole-punching via fallocate(), switch madvise_remove()
> to use do_fallocate() instead of vmtruncate_range(): which extends
> madvise(,,MADV_REMOVE) support from tmpfs to ext4, ocfs2 and xfs.
>
> There is one more user of vmtruncate_range() in our tree, staging/android=
's
> ashmem_shrink(): convert it to use do_fallocate() too (but if its unpinne=
d
> areas are already unmapped - I don't know - then it would do better to us=
e
> shmem_truncate_range() directly).

I suspect shmem_truncate_range directly would be the right approach,
but am not totally sure.
Arve: Any thoughts?

Hugh: Do you have a git tree with this set available somewhere?  I was
working on my own tmpfs support for FALLOC_FL_PUNCH_HOLE, along with
my volatile range work, so I'd like to rebase on top of your work
here.

thanks
-john


>
> Based-on-patch-by: Cong Wang <amwang@redhat.com>
> Signed-off-by: Hugh Dickins <hughd@google.com>
> ---
> =A0drivers/staging/android/ashmem.c | =A0 =A08 +++++---
> =A0mm/madvise.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 15 +++++++-=
-------
> =A02 files changed, 12 insertions(+), 11 deletions(-)
>
> --- 3045N.orig/drivers/staging/android/ashmem.c 2012-05-05 10:42:33.56405=
6626 -0700
> +++ 3045N/drivers/staging/android/ashmem.c =A0 =A0 =A02012-05-05 10:46:25=
.692062478 -0700
> @@ -19,6 +19,7 @@
> =A0#include <linux/module.h>
> =A0#include <linux/file.h>
> =A0#include <linux/fs.h>
> +#include <linux/falloc.h>
> =A0#include <linux/miscdevice.h>
> =A0#include <linux/security.h>
> =A0#include <linux/mm.h>
> @@ -363,11 +364,12 @@ static int ashmem_shrink(struct shrinker
>
> =A0 =A0 =A0 =A0mutex_lock(&ashmem_mutex);
> =A0 =A0 =A0 =A0list_for_each_entry_safe(range, next, &ashmem_lru_list, lr=
u) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct inode *inode =3D range->asma->file->=
f_dentry->d_inode;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0loff_t start =3D range->pgstart * PAGE_SIZ=
E;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 loff_t end =3D (range->pgend + 1) * PAGE_SI=
ZE - 1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 loff_t end =3D (range->pgend + 1) * PAGE_SI=
ZE;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 vmtruncate_range(inode, start, end);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 do_fallocate(range->asma->file,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 FALLOC_FL_P=
UNCH_HOLE | FALLOC_FL_KEEP_SIZE,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 start, end =
- start);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0range->purged =3D ASHMEM_WAS_PURGED;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0lru_del(range);
>
> --- 3045N.orig/mm/madvise.c =A0 =A0 2012-05-05 10:42:33.572056784 -0700
> +++ 3045N/mm/madvise.c =A02012-05-05 10:46:25.692062478 -0700
> @@ -11,8 +11,10 @@
> =A0#include <linux/mempolicy.h>
> =A0#include <linux/page-isolation.h>
> =A0#include <linux/hugetlb.h>
> +#include <linux/falloc.h>
> =A0#include <linux/sched.h>
> =A0#include <linux/ksm.h>
> +#include <linux/fs.h>
>
> =A0/*
> =A0* Any behaviour which results in changes to the vma->vm_flags needs to
> @@ -200,8 +202,7 @@ static long madvise_remove(struct vm_are
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct vm_=
area_struct **prev,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned l=
ong start, unsigned long end)
> =A0{
> - =A0 =A0 =A0 struct address_space *mapping;
> - =A0 =A0 =A0 loff_t offset, endoff;
> + =A0 =A0 =A0 loff_t offset;
> =A0 =A0 =A0 =A0int error;
>
> =A0 =A0 =A0 =A0*prev =3D NULL; =A0 /* tell sys_madvise we drop mmap_sem *=
/
> @@ -217,16 +218,14 @@ static long madvise_remove(struct vm_are
> =A0 =A0 =A0 =A0if ((vma->vm_flags & (VM_SHARED|VM_WRITE)) !=3D (VM_SHARED=
|VM_WRITE))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EACCES;
>
> - =A0 =A0 =A0 mapping =3D vma->vm_file->f_mapping;
> -
> =A0 =A0 =A0 =A0offset =3D (loff_t)(start - vma->vm_start)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0+ ((loff_t)vma->vm_pgoff <=
< PAGE_SHIFT);
> - =A0 =A0 =A0 endoff =3D (loff_t)(end - vma->vm_start - 1)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 + ((loff_t)vma->vm_pgoff <<=
 PAGE_SHIFT);
>
> - =A0 =A0 =A0 /* vmtruncate_range needs to take i_mutex */
> + =A0 =A0 =A0 /* filesystem's fallocate may need to take i_mutex */
> =A0 =A0 =A0 =A0up_read(&current->mm->mmap_sem);
> - =A0 =A0 =A0 error =3D vmtruncate_range(mapping->host, offset, endoff);
> + =A0 =A0 =A0 error =3D do_fallocate(vma->vm_file,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 FALLOC_FL_P=
UNCH_HOLE | FALLOC_FL_KEEP_SIZE,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 offset, end=
 - start);
> =A0 =A0 =A0 =A0down_read(&current->mm->mmap_sem);
> =A0 =A0 =A0 =A0return error;
> =A0}
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" i=
n
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
