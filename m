Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8A79B6B0003
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 01:54:57 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id i79-v6so2235232ywc.23
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 22:54:57 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h12-v6sor9746170ybm.163.2018.10.09.22.54.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Oct 2018 22:54:56 -0700 (PDT)
MIME-Version: 1.0
References: <153913023835.32295.13962696655740190941.stgit@magnolia> <153913029885.32295.7399525233513945673.stgit@magnolia>
In-Reply-To: <153913029885.32295.7399525233513945673.stgit@magnolia>
From: Amir Goldstein <amir73il@gmail.com>
Date: Wed, 10 Oct 2018 08:54:44 +0300
Message-ID: <CAOQ4uxj_wftoGvub9n_6X3Qc64LKxs+8TB-opUiq59sGQ=YoKw@mail.gmail.com>
Subject: Re: [PATCH 08/25] vfs: combine the clone and dedupe into a single remap_file_range
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Dave Chinner <david@fromorbit.com>, Eric Sandeen <sandeen@redhat.com>, Linux NFS Mailing List <linux-nfs@vger.kernel.org>, linux-cifs@vger.kernel.org, overlayfs <linux-unionfs@vger.kernel.org>, linux-xfs <linux-xfs@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Btrfs <linux-btrfs@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, ocfs2-devel@oss.oracle.com

On Wed, Oct 10, 2018 at 3:12 AM Darrick J. Wong <darrick.wong@oracle.com> wrote:
>
> From: Darrick J. Wong <darrick.wong@oracle.com>
>
> Combine the clone_file_range and dedupe_file_range operations into a
> single remap_file_range file operation dispatch since they're
> fundamentally the same operation.  The differences between the two can
> be made in the prep functions.
>
> Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> ---

I like this. Nits below.

[...]

> diff --git a/fs/btrfs/ioctl.c b/fs/btrfs/ioctl.c
> index d60b6caf09e8..e22b294fa25b 100644
> --- a/fs/btrfs/ioctl.c
> +++ b/fs/btrfs/ioctl.c
> @@ -3627,26 +3627,6 @@ static int btrfs_extent_same(struct inode *src, u64 loff, u64 olen,
>         return ret;
>  }
>
> -int btrfs_dedupe_file_range(struct file *src_file, loff_t src_loff,
> -                           struct file *dst_file, loff_t dst_loff,
> -                           u64 olen)
> -{
> -       struct inode *src = file_inode(src_file);
> -       struct inode *dst = file_inode(dst_file);
> -       u64 bs = BTRFS_I(src)->root->fs_info->sb->s_blocksize;
> -
> -       if (WARN_ON_ONCE(bs < PAGE_SIZE)) {
> -               /*
> -                * Btrfs does not support blocksize < page_size. As a
> -                * result, btrfs_cmp_data() won't correctly handle
> -                * this situation without an update.
> -                */
> -               return -EINVAL;
> -       }
> -
> -       return btrfs_extent_same(src, src_loff, olen, dst, dst_loff);
> -}
> -
>  static int clone_finish_inode_update(struct btrfs_trans_handle *trans,
>                                      struct inode *inode,
>                                      u64 endoff,
> @@ -4348,9 +4328,27 @@ static noinline int btrfs_clone_files(struct file *file, struct file *file_src,
>         return ret;
>  }
>
> -int btrfs_clone_file_range(struct file *src_file, loff_t off,
> -               struct file *dst_file, loff_t destoff, u64 len)
> +int btrfs_remap_file_range(struct file *src_file, loff_t off,
> +               struct file *dst_file, loff_t destoff, u64 len,
> +               unsigned int flags)
>  {
> +       if (flags & RFR_IDENTICAL_DATA) {
> +               struct inode *src = file_inode(src_file);
> +               struct inode *dst = file_inode(dst_file);
> +               u64 bs = BTRFS_I(src)->root->fs_info->sb->s_blocksize;
> +
> +               if (WARN_ON_ONCE(bs < PAGE_SIZE)) {
> +                       /*
> +                        * Btrfs does not support blocksize < page_size. As a
> +                        * result, btrfs_cmp_data() won't correctly handle
> +                        * this situation without an update.
> +                        */
> +                       return -EINVAL;
> +               }
> +
> +               return btrfs_extent_same(src, off, len, dst, destoff);
> +       }
> +

Seems weird that you would do that instead of:

+    if (flags & ~RFR_IDENTICAL_DATA)
+        return -EINVAL;
+    if (flags & RFR_IDENTICAL_DATA)
+        return btrfs_dedupe_file_range(src, off, dst, destoff, len);

>         return btrfs_clone_files(dst_file, src_file, off, len, destoff);
>  }
>
> diff --git a/fs/cifs/cifsfs.c b/fs/cifs/cifsfs.c
> index 7065426b3280..bf971fd7cab2 100644
> --- a/fs/cifs/cifsfs.c
> +++ b/fs/cifs/cifsfs.c
> @@ -975,8 +975,9 @@ const struct inode_operations cifs_symlink_inode_ops = {
>         .listxattr = cifs_listxattr,
>  };
>
> -static int cifs_clone_file_range(struct file *src_file, loff_t off,
> -               struct file *dst_file, loff_t destoff, u64 len)
> +static int cifs_remap_file_range(struct file *src_file, loff_t off,
> +               struct file *dst_file, loff_t destoff, u64 len,
> +               unsigned int flags)
>  {
>         struct inode *src_inode = file_inode(src_file);
>         struct inode *target_inode = file_inode(dst_file);
> @@ -986,6 +987,9 @@ static int cifs_clone_file_range(struct file *src_file, loff_t off,
>         unsigned int xid;
>         int rc;
>
> +       if (flags & RFR_IDENTICAL_DATA)
> +               return -EOPNOTSUPP;
> +

I think everyone would be better off with:
+       if (flags)
+               return -EINVAL;

This way you won't need to change all filesystem implementations
every time that you add a new RFR flag.
Lucky for us, dedup already return -EINVAL if (!f_op->dedupe_file_range)
(and not -EOPNOTSUPP).

[...]
> diff --git a/fs/overlayfs/file.c b/fs/overlayfs/file.c
> index 986313da0c88..693bd0620a81 100644
> --- a/fs/overlayfs/file.c
> +++ b/fs/overlayfs/file.c
> @@ -489,26 +489,28 @@ static ssize_t ovl_copy_file_range(struct file *file_in, loff_t pos_in,
>                             OVL_COPY);
>  }
>
> -static int ovl_clone_file_range(struct file *file_in, loff_t pos_in,
> -                               struct file *file_out, loff_t pos_out, u64 len)
> +static int ovl_remap_file_range(struct file *file_in, loff_t pos_in,
> +                               struct file *file_out, loff_t pos_out,
> +                               u64 len, unsigned int flags)
>  {
> -       return ovl_copyfile(file_in, pos_in, file_out, pos_out, len, 0,
> -                           OVL_CLONE);
> -}
> +       enum ovl_copyop op;
> +
> +       if (flags & RFR_IDENTICAL_DATA)
> +               op = OVL_DEDUPE;
> +       else
> +               op = OVL_CLONE;
>
> -static int ovl_dedupe_file_range(struct file *file_in, loff_t pos_in,
> -                                struct file *file_out, loff_t pos_out, u64 len)
> -{
>         /*
>          * Don't copy up because of a dedupe request, this wouldn't make sense
>          * most of the time (data would be duplicated instead of deduplicated).
>          */
> -       if (!ovl_inode_upper(file_inode(file_in)) ||
> -           !ovl_inode_upper(file_inode(file_out)))
> +       if (op == OVL_DEDUPE &&
> +           (!ovl_inode_upper(file_inode(file_in)) ||
> +            !ovl_inode_upper(file_inode(file_out))))
>                 return -EPERM;
>
>         return ovl_copyfile(file_in, pos_in, file_out, pos_out, len, 0,
> -                           OVL_DEDUPE);
> +                           op);
>  }
>

Apart from the generic check invalid flags comment - ACK on ovl part.

Thanks,
Amir.
