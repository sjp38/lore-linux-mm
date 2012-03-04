Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 8336B6B004D
	for <linux-mm@kvack.org>; Sat,  3 Mar 2012 22:50:37 -0500 (EST)
Received: by vbbey12 with SMTP id ey12so3350491vbb.14
        for <linux-mm@kvack.org>; Sat, 03 Mar 2012 19:50:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1330657121-18692-1-git-send-email-steven.truelove@utoronto.ca>
References: <1330657121-18692-1-git-send-email-steven.truelove@utoronto.ca>
Date: Sun, 4 Mar 2012 11:50:36 +0800
Message-ID: <CAJd=RBBXExVfnHnqWL8Q2zAU5qPCc-qZFKpXPLc+47ey5g_Ukw@mail.gmail.com>
Subject: Re: [PATCH] Correct alignment of huge page requests.
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Truelove <steven.truelove@utoronto.ca>
Cc: wli@holomorphy.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Mar 2, 2012 at 10:58 AM, Steven Truelove
<steven.truelove@utoronto.ca> wrote:
> When calling shmget() with SHM_HUGETLB, shmget aligns the request size to=
 PAGE_SIZE, but this is not sufficient. =C2=A0Modified hugetlb_file_setup()=
 to align requests to the huge page size, and to accept an address argument=
 so that all alignment checks can be performed in hugetlb_file_setup(), rat=
her than in its callers. =C2=A0Changed newseg and mmap_pgoff to match new p=
rototype and eliminated a now redundant alignment check.
>
> Signed-off-by: Steven Truelove <steven.truelove@utoronto.ca>

Acked-by: Hillf Danton <dhillf@gmail.com>

> ---
> =C2=A0fs/hugetlbfs/inode.c =C2=A0 =C2=A0| =C2=A0 12 ++++++++----
> =C2=A0include/linux/hugetlb.h | =C2=A0 =C2=A03 ++-
> =C2=A0ipc/shm.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0=
 =C2=A02 +-
> =C2=A0mm/mmap.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0=
 =C2=A06 +++---
> =C2=A04 files changed, 14 insertions(+), 9 deletions(-)
>
> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index 1e85a7a..a97b7cc 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -928,7 +928,7 @@ static int can_do_hugetlb_shm(void)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return capable(CAP_IPC_LOCK) || in_group_p(sys=
ctl_hugetlb_shm_group);
> =C2=A0}
>
> -struct file *hugetlb_file_setup(const char *name, size_t size,
> +struct file *hugetlb_file_setup(const char *name, unsigned long addr, si=
ze_t size,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0vm_flags_t acctflag,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct user_struct **user, int creat_=
flags)
> =C2=A0{
> @@ -938,6 +938,8 @@ struct file *hugetlb_file_setup(const char *name, siz=
e_t size,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct path path;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct dentry *root;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct qstr quick_string;
> + =C2=A0 =C2=A0 =C2=A0 struct hstate *hstate;
> + =C2=A0 =C2=A0 =C2=A0 int num_pages;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0*user =3D NULL;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!hugetlbfs_vfsmount)
> @@ -967,10 +969,12 @@ struct file *hugetlb_file_setup(const char *name, s=
ize_t size,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!inode)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto out_dentry;
>
> + =C2=A0 =C2=A0 =C2=A0 hstate =3D hstate_inode(inode);
> + =C2=A0 =C2=A0 =C2=A0 size +=3D addr & ~huge_page_mask(hstate);
> + =C2=A0 =C2=A0 =C2=A0 num_pages =3D ALIGN(size, huge_page_size(hstate)) =
>>
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 huge_page_shift(hstate);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0error =3D -ENOMEM;
> - =C2=A0 =C2=A0 =C2=A0 if (hugetlb_reserve_pages(inode, 0,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 size >> huge_page_shift(hstate_inode(inode)), NULL,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 acctflag))
> + =C2=A0 =C2=A0 =C2=A0 if (hugetlb_reserve_pages(inode, 0, num_pages, NUL=
L, acctflag))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto out_inode;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0d_instantiate(path.dentry, inode);
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index d9d6c86..4b9e59d 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -164,7 +164,8 @@ static inline struct hugetlbfs_sb_info *HUGETLBFS_SB(=
struct super_block *sb)
>
> =C2=A0extern const struct file_operations hugetlbfs_file_operations;
> =C2=A0extern const struct vm_operations_struct hugetlb_vm_ops;
> -struct file *hugetlb_file_setup(const char *name, size_t size, vm_flags_=
t acct,
> +struct file *hugetlb_file_setup(const char *name, unsigned long addr,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 size_t size, vm_flags_t acct,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct user_struct **user, int creat_=
flags);
> =C2=A0int hugetlb_get_quota(struct address_space *mapping, long delta);
> =C2=A0void hugetlb_put_quota(struct address_space *mapping, long delta);
> diff --git a/ipc/shm.c b/ipc/shm.c
> index b76be5b..406c5b2 100644
> --- a/ipc/shm.c
> +++ b/ipc/shm.c
> @@ -482,7 +482,7 @@ static int newseg(struct ipc_namespace *ns, struct ip=
c_params *params)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* hugetlb_file_se=
tup applies strict accounting */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (shmflg & SHM_N=
ORESERVE)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0acctflag =3D VM_NORESERVE;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 file =3D hugetlb_file_=
setup(name, size, acctflag,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 file =3D hugetlb_file_=
setup(name, 0, size, acctflag,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0&shp->mlo=
ck_user, HUGETLB_SHMFS_INODE);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0} else {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 3f758c7..4bf211a 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -1099,9 +1099,9 @@ SYSCALL_DEFINE6(mmap_pgoff, unsigned long, addr, un=
signed long, len,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * A dummy user va=
lue is used because we are not locking
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * memory so no ac=
counting is necessary
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 len =3D ALIGN(len, hug=
e_page_size(&default_hstate));
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 file =3D hugetlb_file_=
setup(HUGETLB_ANON_FILE, len, VM_NORESERVE,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 &user, HUGETLB_ANONHUGE_INODE);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 file =3D hugetlb_file_=
setup(HUGETLB_ANON_FILE, addr, len,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 VM_NORESERVE, &user,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 HUGETLB_ANONHUGE_INODE);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (IS_ERR(file))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0return PTR_ERR(file);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> --
> 1.7.3.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" i=
n
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =C2=A0http://www.tux.org/lkml/
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
