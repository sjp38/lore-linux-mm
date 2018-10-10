Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 60FAD6B0003
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 01:23:40 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id n143-v6so2252259ywd.6
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 22:23:40 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t5-v6sor9895914ybq.86.2018.10.09.22.23.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Oct 2018 22:23:39 -0700 (PDT)
MIME-Version: 1.0
References: <153913023835.32295.13962696655740190941.stgit@magnolia> <153913028015.32295.15993665528948323051.stgit@magnolia>
In-Reply-To: <153913028015.32295.15993665528948323051.stgit@magnolia>
From: Amir Goldstein <amir73il@gmail.com>
Date: Wed, 10 Oct 2018 08:23:27 +0300
Message-ID: <CAOQ4uxjZ1JuT3Ga1kTDF9boeYF5pafDmsnzWxVNPWcTpESchgw@mail.gmail.com>
Subject: Re: [PATCH 06/25] vfs: strengthen checking of file range inputs to generic_remap_checks
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Dave Chinner <david@fromorbit.com>, Eric Sandeen <sandeen@redhat.com>, Linux NFS Mailing List <linux-nfs@vger.kernel.org>, linux-cifs@vger.kernel.org, overlayfs <linux-unionfs@vger.kernel.org>, linux-xfs <linux-xfs@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Btrfs <linux-btrfs@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, ocfs2-devel@oss.oracle.com

On Wed, Oct 10, 2018 at 3:11 AM Darrick J. Wong <darrick.wong@oracle.com> wrote:
>
> From: Darrick J. Wong <darrick.wong@oracle.com>
>
> File range remapping, if allowed to run past the destination file's EOF,
> is an optimization on a regular file write.  Regular file writes that
> extend the file length are subject to various constraints which are not
> checked by range cloning.
>
> This is a correctness problem because we're never allowed to touch
> ranges that the page cache can't support (s_maxbytes); we're not
> supposed to deal with large offsets (MAX_NON_LFS) if O_LARGEFILE isn't
> set; and we must obey resource limits (RLIMIT_FSIZE).
>
> Therefore, add these checks to the new generic_remap_checks function so
> that we curtail unexpected behavior.
>
> Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> ---
>  mm/filemap.c |   39 +++++++++++++++++++++++++++++++++++++++
>  1 file changed, 39 insertions(+)
>
>
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 14041a8468ba..59056bd9c58a 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -2974,6 +2974,27 @@ inline ssize_t generic_write_checks(struct kiocb *iocb, struct iov_iter *from)
>  }
>  EXPORT_SYMBOL(generic_write_checks);
>
> +static int
> +generic_remap_check_limits(struct file *file, loff_t pos, uint64_t *count)
> +{
> +       struct inode *inode = file->f_mapping->host;
> +
> +       /* Don't exceed the LFS limits. */
> +       if (unlikely(pos + *count > MAX_NON_LFS &&
> +                               !(file->f_flags & O_LARGEFILE))) {
> +               if (pos >= MAX_NON_LFS)
> +                       return -EFBIG;
> +               *count = min(*count, MAX_NON_LFS - (uint64_t)pos);
> +       }
> +
> +       /* Don't operate on ranges the page cache doesn't support. */
> +       if (unlikely(pos >= inode->i_sb->s_maxbytes))
> +               return -EFBIG;
> +
> +       *count = min(*count, inode->i_sb->s_maxbytes - (uint64_t)pos);
> +       return 0;
> +}
> +

Sorry. I haven't explained myself properly last time.
What I meant is that it hurts my eyes to see generic_write_checks() and
generic_remap_check_limits() which from the line of (limit != RLIM_INFINITY)
are exactly the same thing. Yes, generic_remap_check_limits() uses
iov_iter_truncate(), but that's a minor semantic change - it can be easily
resolved by creating a dummy iter in generic_remap_checks() instead of
passing int *count.

You could say that this is nit picking, but the very reason this patch
set exists
it because clone/dedup implementation did not use the same range checks
of write to begin with, so it just seems wrong to diverge them at this point.

So to be clear, I suggest that generic_write_checks() should use your
generic_remap_check_limits() helper.
If you disagree and others can live with this minor duplication, fine by me.

Thanks,
Amir.
