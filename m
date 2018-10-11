Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 35C956B000C
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 01:15:56 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id f66-v6so4374865ywa.0
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 22:15:56 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j6-v6sor3807306ywc.199.2018.10.10.22.15.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Oct 2018 22:15:55 -0700 (PDT)
MIME-Version: 1.0
References: <153923113649.5546.9840926895953408273.stgit@magnolia> <153923126628.5546.3484461137192547927.stgit@magnolia>
In-Reply-To: <153923126628.5546.3484461137192547927.stgit@magnolia>
From: Amir Goldstein <amir73il@gmail.com>
Date: Thu, 11 Oct 2018 08:15:42 +0300
Message-ID: <CAOQ4uxgbTf0Po3stK4YZWqYPWTmwfqsSLGwV4p4be6gBrdLP+g@mail.gmail.com>
Subject: Re: [PATCH 17/25] vfs: enable remap callers that can handle short operations
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Dave Chinner <david@fromorbit.com>, Eric Sandeen <sandeen@redhat.com>, Linux NFS Mailing List <linux-nfs@vger.kernel.org>, linux-cifs@vger.kernel.org, overlayfs <linux-unionfs@vger.kernel.org>, linux-xfs <linux-xfs@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Btrfs <linux-btrfs@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, ocfs2-devel@oss.oracle.com

On Thu, Oct 11, 2018 at 7:14 AM Darrick J. Wong <darrick.wong@oracle.com> wrote:
>
> From: Darrick J. Wong <darrick.wong@oracle.com>
>
> Plumb in a remap flag that enables the filesystem remap handler to
> shorten remapping requests for callers that can handle it.  Now
> copy_file_range can report partial success (in case we run up against
> alignment problems, resource limits, etc.).
>
> Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> Reviewed-by: Amir Goldstein <amir73il@gmail.com>
> ---
>  fs/read_write.c    |   15 +++++++++------
>  include/linux/fs.h |    7 +++++--
>  mm/filemap.c       |   16 ++++++++++++----
>  3 files changed, 26 insertions(+), 12 deletions(-)
>
>
> diff --git a/fs/read_write.c b/fs/read_write.c
> index 6ec908f9a69b..3713893b7e38 100644
> --- a/fs/read_write.c
> +++ b/fs/read_write.c
> @@ -1593,7 +1593,8 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
>
>                 cloned = file_in->f_op->remap_file_range(file_in, pos_in,
>                                 file_out, pos_out,
> -                               min_t(loff_t, MAX_RW_COUNT, len), 0);
> +                               min_t(loff_t, MAX_RW_COUNT, len),
> +                               RFR_CAN_SHORTEN);
>                 if (cloned > 0) {
>                         ret = cloned;
>                         goto done;
> @@ -1804,16 +1805,18 @@ int generic_remap_file_range_prep(struct file *file_in, loff_t pos_in,
>                  * If the user is attempting to remap a partial EOF block and
>                  * it's inside the destination EOF then reject it.
>                  *
> -                * We don't support shortening requests, so we can only reject
> -                * them.
> +                * If possible, shorten the request instead of rejecting it.
>                  */
>                 if (is_dedupe)
>                         ret = -EBADE;
>                 else if (pos_out + *len < i_size_read(inode_out))
>                         ret = -EINVAL;
>
> -               if (ret)
> -                       return ret;
> +               if (ret) {
> +                       if (!(remap_flags & RFR_CAN_SHORTEN))
> +                               return ret;
> +                       *len &= ~blkmask;
> +               }
>         }
>
>         return 1;
> @@ -2112,7 +2115,7 @@ int vfs_dedupe_file_range(struct file *file, struct file_dedupe_range *same)
>
>                 deduped = vfs_dedupe_file_range_one(file, off, dst_file,
>                                                     info->dest_offset, len,
> -                                                   0);
> +                                                   RFR_CAN_SHORTEN);

You did not update WARN_ON_ONCE in vfs_dedupe_file_range_one()
to allow this flag and did not mention dedupe in commit message.
Was that change intentional in this patch?

After RFR_SHORT_DEDUPE patch the end result in fine.

Thanks,
Amir.
