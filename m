Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id 47AFC6B0005
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 16:22:31 -0400 (EDT)
Received: by mail-vs1-f72.google.com with SMTP id w20so5402141vsc.5
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 13:22:31 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a94-v6sor1357594uaa.66.2018.10.12.13.22.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Oct 2018 13:22:30 -0700 (PDT)
MIME-Version: 1.0
References: <153923113649.5546.9840926895953408273.stgit@magnolia> <153923117420.5546.13317703807467393934.stgit@magnolia>
In-Reply-To: <153923117420.5546.13317703807467393934.stgit@magnolia>
Reply-To: fdmanana@gmail.com
From: Filipe Manana <fdmanana@gmail.com>
Date: Fri, 12 Oct 2018 21:22:18 +0100
Message-ID: <CAL3q7H7mLvCGpyitJhQ=To-aDvG9k9rxSVi2jSpcALQVj3myzg@mail.gmail.com>
Subject: Re: [PATCH 05/25] vfs: avoid problematic remapping requests into
 partial EOF block
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Dave Chinner <david@fromorbit.com>, Eric Sandeen <sandeen@redhat.com>, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs <linux-btrfs@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, ocfs2-devel@oss.oracle.com

On Thu, Oct 11, 2018 at 5:13 AM Darrick J. Wong <darrick.wong@oracle.com> w=
rote:
>
> From: Darrick J. Wong <darrick.wong@oracle.com>
>
> A deduplication data corruption is exposed by fstests generic/505 on
> XFS.

(and btrfs)

Btw, the generic test I wrote was indeed numbered 505, however it was
never committed and there's now a generic/505 which has nothing to do
with deduplication.
So you should update the changelog to avoid confusion.

thanks

> It is caused by extending the block match range to include the
> partial EOF block, but then allowing unknown data beyond EOF to be
> considered a "match" to data in the destination file because the
> comparison is only made to the end of the source file. This corrupts the
> destination file when the source extent is shared with it.
>
> The VFS remapping prep functions  only support whole block dedupe, but
> we still need to appear to support whole file dedupe correctly.  Hence
> if the dedupe request includes the last block of the souce file, don't
> include it in the actual dedupe operation. If the rest of the range
> dedupes successfully, then reject the entire request.  A subsequent
> patch will enable us to shorten dedupe requests correctly.
>
> When reflinking sub-file ranges, a data corruption can occur when the
> source file range includes a partial EOF block. This shares the unknown
> data beyond EOF into the second file at a position inside EOF, exposing
> stale data in the second file.
>
> If the reflink request includes the last block of the souce file, only
> proceed with the reflink operation if it lands at or past the
> destination file's current EOF. If it lands within the destination file
> EOF, reject the entire request with -EINVAL and make the caller go the
> hard way.  A subsequent patch will enable us to shorten reflink requests
> correctly.
>
> Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> ---
>  fs/read_write.c |   22 ++++++++++++++++++++++
>  1 file changed, 22 insertions(+)
>
>
> diff --git a/fs/read_write.c b/fs/read_write.c
> index d6e8e242a15f..8498991e2f33 100644
> --- a/fs/read_write.c
> +++ b/fs/read_write.c
> @@ -1723,6 +1723,7 @@ int vfs_clone_file_prep(struct file *file_in, loff_=
t pos_in,
>  {
>         struct inode *inode_in =3D file_inode(file_in);
>         struct inode *inode_out =3D file_inode(file_out);
> +       u64 blkmask =3D i_blocksize(inode_in) - 1;
>         bool same_inode =3D (inode_in =3D=3D inode_out);
>         int ret;
>
> @@ -1785,6 +1786,27 @@ int vfs_clone_file_prep(struct file *file_in, loff=
_t pos_in,
>                         return -EBADE;
>         }
>
> +       /* Are we doing a partial EOF block remapping of some kind? */
> +       if (*len & blkmask) {
> +               /*
> +                * If the dedupe data matches, don't try to dedupe the pa=
rtial
> +                * EOF block.
> +                *
> +                * If the user is attempting to remap a partial EOF block=
 and
> +                * it's inside the destination EOF then reject it.
> +                *
> +                * We don't support shortening requests, so we can only r=
eject
> +                * them.
> +                */
> +               if (is_dedupe)
> +                       ret =3D -EBADE;
> +               else if (pos_out + *len < i_size_read(inode_out))
> +                       ret =3D -EINVAL;
> +
> +               if (ret)
> +                       return ret;
> +       }
> +
>         return 1;
>  }
>  EXPORT_SYMBOL(vfs_clone_file_prep);
>


--=20
Filipe David Manana,

=E2=80=9CWhether you think you can, or you think you can't =E2=80=94 you're=
 right.=E2=80=9D
