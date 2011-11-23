Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C94F56B00CE
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 14:59:24 -0500 (EST)
Received: by ggnq1 with SMTP id q1so2380428ggn.14
        for <linux-mm@kvack.org>; Wed, 23 Nov 2011 11:59:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1322038412-29013-1-git-send-email-amwang@redhat.com>
References: <1322038412-29013-1-git-send-email-amwang@redhat.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Wed, 23 Nov 2011 14:59:01 -0500
Message-ID: <CAHGf_=rOYkEGHakyHpihopMg2VtVfDV7XvC_QGs_kj6HgDmBRA@mail.gmail.com>
Subject: Re: [V3 PATCH 1/2] tmpfs: add fallocate support
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cong Wang <amwang@redhat.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Pekka Enberg <penberg@kernel.org>, Christoph Hellwig <hch@lst.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Lennart Poettering <lennart@poettering.net>, Kay Sievers <kay.sievers@vrfy.org>, linux-mm@kvack.org

> Systemd needs tmpfs to support fallocate [1], to be able
> to safely use mmap(), regarding SIGBUS, on files on the
> /dev/shm filesystem. The glibc fallback loop for -ENOSYS
> on fallocate is just ugly.

for EOPNOTSUPP?

glibc/sysdeps/unix/sysv/linux/i386/posix_fallocate.c
----------------
int
posix_fallocate (int fd, __off_t offset, __off_t len)
{
#ifdef __NR_fallocate
# ifndef __ASSUME_FALLOCATE
  if (__builtin_expect (__have_fallocate >=3D 0, 1))
# endif
    {
      int res =3D __call_fallocate (fd, 0, offset, len);
      if (! res)
        return 0;

# ifndef __ASSUME_FALLOCATE
      if (__builtin_expect (res =3D=3D ENOSYS, 0))
        __have_fallocate =3D -1;
      else
# endif
        if (res !=3D EOPNOTSUPP)
          return res;
    }
#endif

  return internal_fallocate (fd, offset, len);
}
--------------------------


But, ok, I'm now convinced this is needed. people strongly dislike to
receive SIGBUS. yes.


> This patch adds fallocate support to tmpfs, and as we
> already have shmem_truncate_range(), it is also easy to
> add FALLOC_FL_PUNCH_HOLE support too.
>
> 1. http://lkml.org/lkml/2011/10/20/275
>
> V2->V3:
> a) Read i_size directly after holding i_mutex;
> b) Call page_cache_release() too after shmem_getpage();
> c) Undo previous changes when -ENOSPC.
>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Dave Hansen <dave@linux.vnet.ibm.com>
> Cc: Lennart Poettering <lennart@poettering.net>
> Cc: Kay Sievers <kay.sievers@vrfy.org>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: WANG Cong <amwang@redhat.com>
>
> ---
> =A0mm/shmem.c | =A0 65 ++++++++++++++++++++++++++++++++++++++++++++++++++=
++++++++++
> =A01 files changed, 65 insertions(+), 0 deletions(-)
>
> diff --git a/mm/shmem.c b/mm/shmem.c
> index d672250..65f7a27 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -30,6 +30,7 @@
> =A0#include <linux/mm.h>
> =A0#include <linux/export.h>
> =A0#include <linux/swap.h>
> +#include <linux/falloc.h>
>
> =A0static struct vfsmount *shm_mnt;
>
> @@ -1431,6 +1432,69 @@ static ssize_t shmem_file_splice_read(struct file =
*in, loff_t *ppos,
> =A0 =A0 =A0 =A0return error;
> =A0}
>
> +static void shmem_truncate_page(struct inode *inode, pgoff_t index)
> +{
> + =A0 =A0 =A0 loff_t start =3D index << PAGE_CACHE_SHIFT;
> + =A0 =A0 =A0 loff_t end =3D ((index + 1) << PAGE_CACHE_SHIFT) - 1;
> + =A0 =A0 =A0 shmem_truncate_range(inode, start, end);
> +}
> +
> +static long shmem_fallocate(struct file *file, int mode,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 loff_t offs=
et, loff_t len)
> +{
> + =A0 =A0 =A0 struct inode *inode =3D file->f_path.dentry->d_inode;
> + =A0 =A0 =A0 pgoff_t start =3D offset >> PAGE_CACHE_SHIFT;
> + =A0 =A0 =A0 pgoff_t end =3D DIV_ROUND_UP((offset + len), PAGE_CACHE_SIZ=
E);
> + =A0 =A0 =A0 pgoff_t index =3D start;
> + =A0 =A0 =A0 loff_t i_size;
> + =A0 =A0 =A0 struct page *page =3D NULL;
> + =A0 =A0 =A0 int ret =3D 0;

do_fallocate has following file type check.

        if (!S_ISREG(inode->i_mode) && !S_ISDIR(inode->i_mode))
                return -ENODEV;

However, this implementation don't support dir allocation and/or punch hole=
.
ext4's ext4_punch_hole() has following additional check. Maybe we need simi=
lar
check.

        if (!S_ISREG(inode->i_mode))
                return -ENOTSUPP;


> + =A0 =A0 =A0 mutex_lock(&inode->i_mutex);
> + =A0 =A0 =A0 i_size =3D inode->i_size;
> + =A0 =A0 =A0 if (mode & FALLOC_FL_PUNCH_HOLE) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!(offset > i_size || (end << PAGE_CACHE=
_SHIFT) > i_size))

Seems incorrect.
fallocate(PUNCH, 0, very_big_number) should punch to a range of [0, end).


> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 shmem_truncate_range(inode,=
 offset,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0(end << PAGE_CACHE_SHIFT) - 1);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto unlock;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (!(mode & FALLOC_FL_KEEP_SIZE)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D inode_newsize_ok(inode, (offset + l=
en));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ret)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto unlock;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 while (index < end) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D shmem_getpage(inode, index, &page, =
SGP_WRITE, NULL);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ret) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ret =3D=3D -ENOSPC)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto undo;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto unlock=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (page) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unlock_page(page);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 page_cache_release(page);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 index++;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 if (!(mode & FALLOC_FL_KEEP_SIZE) && (index << PAGE_CACHE_S=
HIFT) > i_size)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 i_size_write(inode, index << PAGE_CACHE_SHI=
FT);

Seems incorrect.
new i_size should be offset+len. our round-up is implementation detail
and don't have to expose
to userland.

> +
> + =A0 =A0 =A0 goto unlock;
> +
> +undo:
> + =A0 =A0 =A0 while (index > start) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 shmem_truncate_page(inode, index);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 index--;

Hmmm...
seems too aggressive truncate if the file has pages before starting falloca=
te.
but I have no idea to make better undo. ;)


> + =A0 =A0 =A0 }
> +
> +unlock:
> + =A0 =A0 =A0 mutex_unlock(&inode->i_mutex);
> + =A0 =A0 =A0 return ret;
> +}
> +
> =A0static int shmem_statfs(struct dentry *dentry, struct kstatfs *buf)
> =A0{
> =A0 =A0 =A0 =A0struct shmem_sb_info *sbinfo =3D SHMEM_SB(dentry->d_sb);
> @@ -2286,6 +2350,7 @@ static const struct file_operations shmem_file_oper=
ations =3D {
> =A0 =A0 =A0 =A0.fsync =A0 =A0 =A0 =A0 =A0=3D noop_fsync,
> =A0 =A0 =A0 =A0.splice_read =A0 =A0=3D shmem_file_splice_read,
> =A0 =A0 =A0 =A0.splice_write =A0 =3D generic_file_splice_write,
> + =A0 =A0 =A0 .fallocate =A0 =A0 =A0=3D shmem_fallocate,
> =A0#endif
> =A0};

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
