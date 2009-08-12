Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 615646B004F
	for <linux-mm@kvack.org>; Wed, 12 Aug 2009 01:45:06 -0400 (EDT)
Received: by bwz24 with SMTP id 24so3762499bwz.38
        for <linux-mm@kvack.org>; Tue, 11 Aug 2009 22:45:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <a45eb555ca7d9e23e5eb051e27f757ae70a6b0c5.1249999949.git.ebmunson@us.ibm.com>
References: <cover.1249999949.git.ebmunson@us.ibm.com>
	 <2154e5ac91c7acd5505c5fc6c55665980cbc1bf8.1249999949.git.ebmunson@us.ibm.com>
	 <a45eb555ca7d9e23e5eb051e27f757ae70a6b0c5.1249999949.git.ebmunson@us.ibm.com>
Date: Wed, 12 Aug 2009 08:45:09 +0300
Message-ID: <84144f020908112245g139564erbe56bac668a68bef@mail.gmail.com>
Subject: Re: [PATCH 2/3] Add MAP_LARGEPAGE for mmaping pseudo-anonymous huge
	page regions
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Eric B Munson <ebmunson@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org, mtk.manpages@gmail.com, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi Eric,

On Wed, Aug 12, 2009 at 1:13 AM, Eric B Munson<ebmunson@us.ibm.com> wrote:
> This patch adds a flag for mmap that will be used to request a huge
> page region that will look like anonymous memory to user space. =A0This
> is accomplished by using a file on the internal vfsmount. =A0MAP_LARGEPAG=
E
> is a modifier of MAP_ANONYMOUS and so must be specified with it. =A0The
> region will behave the same as a MAP_ANONYMOUS region using small pages.
>
> Signed-off-by: Eric B Munson <ebmunson@us.ibm.com>

I would love to see something like this in the kernel. Huge pages are
useful for garbage collection and JIT text in the userspace but
unfortunately obtaining them is a real PITA at the moment.

Is there any way to drop the
CAP_IPC_LOCK/in_group_p(hugetlbfs_shm_group) requirement, btw? That
would make huge pages even more accessible to user-space virtual
machines.

                        Pekka

> ---
> =A0include/asm-generic/mman-common.h | =A0 =A01 +
> =A0include/linux/hugetlb.h =A0 =A0 =A0 =A0 =A0 | =A0 =A07 +++++++
> =A0mm/mmap.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 16 +++=
+++++++++++++
> =A03 files changed, 24 insertions(+), 0 deletions(-)
>
> diff --git a/include/asm-generic/mman-common.h b/include/asm-generic/mman=
-common.h
> index 3b69ad3..60b6be7 100644
> --- a/include/asm-generic/mman-common.h
> +++ b/include/asm-generic/mman-common.h
> @@ -19,6 +19,7 @@
> =A0#define MAP_TYPE =A0 =A0 =A0 0x0f =A0 =A0 =A0 =A0 =A0 =A0/* Mask for t=
ype of mapping */
> =A0#define MAP_FIXED =A0 =A0 =A00x10 =A0 =A0 =A0 =A0 =A0 =A0/* Interpret =
addr exactly */
> =A0#define MAP_ANONYMOUS =A00x20 =A0 =A0 =A0 =A0 =A0 =A0/* don't use a fi=
le */
> +#define MAP_LARGEPAGE =A00x40 =A0 =A0 =A0 =A0 =A0 =A0/* create a large p=
age mapping */
>
> =A0#define MS_ASYNC =A0 =A0 =A0 1 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* sync mem=
ory asynchronously */
> =A0#define MS_INVALIDATE =A02 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* invalidate t=
he caches */
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 78b6ddf..b84361c 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -109,12 +109,19 @@ static inline void hugetlb_report_meminfo(struct se=
q_file *m)
>
> =A0#endif /* !CONFIG_HUGETLB_PAGE */
>
> +#define HUGETLB_ANON_FILE "anon_hugepage"
> +
> =A0enum {
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * The file will be used as an shm file so shmfs accountin=
g rules
> =A0 =A0 =A0 =A0 * apply
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0HUGETLB_SHMFS_INODE =A0 =A0 =3D 0x01,
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* The file is being created on the internal vfs mount an=
d shmfs
> + =A0 =A0 =A0 =A0* accounting rules do not apply
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 HUGETLB_ANONHUGE_INODE =A0=3D 0x02,
> =A0};
>
> =A0#ifdef CONFIG_HUGETLBFS
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 34579b2..c2c729a 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -29,6 +29,7 @@
> =A0#include <linux/rmap.h>
> =A0#include <linux/mmu_notifier.h>
> =A0#include <linux/perf_counter.h>
> +#include <linux/hugetlb.h>
>
> =A0#include <asm/uaccess.h>
> =A0#include <asm/cacheflush.h>
> @@ -954,6 +955,21 @@ unsigned long do_mmap_pgoff(struct file *file, unsig=
ned long addr,
> =A0 =A0 =A0 =A0if (mm->map_count > sysctl_max_map_count)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENOMEM;
>
> + =A0 =A0 =A0 if (flags & MAP_LARGEPAGE) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (file)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* VM_NORESERVE is used because the reser=
vations will be
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* taken when vm_ops->mmap() is called
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 len =3D ALIGN(len, huge_page_size(&default_=
hstate));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 file =3D hugetlb_file_setup(HUGETLB_ANON_FI=
LE, len, VM_NORESERVE,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 HUGETLB_ANONHUGE_INODE);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (IS_ERR(file))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> + =A0 =A0 =A0 }
> +
> =A0 =A0 =A0 =A0/* Obtain the address to map to. we verify (or select) it =
and ensure
> =A0 =A0 =A0 =A0 * that it represents a valid section of the address space=
.
> =A0 =A0 =A0 =A0 */
> --
> 1.6.3.2
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
