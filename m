Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 467206B0005
	for <linux-mm@kvack.org>; Thu,  1 Nov 2018 03:13:37 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id g24-v6so12842295pfi.23
        for <linux-mm@kvack.org>; Thu, 01 Nov 2018 00:13:37 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id m10-v6si28609082plt.394.2018.11.01.00.13.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Nov 2018 00:13:35 -0700 (PDT)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.1 \(3445.101.1\))
Subject: Re: [PATCH] tmpfs: let lseek return ENXIO with a negative offset
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <1540434176-14349-1-git-send-email-yuyufen@huawei.com>
Date: Thu, 1 Nov 2018 01:13:25 -0600
Content-Transfer-Encoding: quoted-printable
Message-Id: <88ED1518-A829-4933-8E1B-0576C79491B3@oracle.com>
References: <1540434176-14349-1-git-send-email-yuyufen@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yufen Yu <yuyufen@huawei.com>
Cc: viro@zeniv.linux.org.uk, hughd@google.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-unionfs@vger.kernel.org



> On Oct 24, 2018, at 8:22 PM, Yufen Yu <yuyufen@huawei.com> wrote:
>=20
> For now, the others filesystems, such as ext4, f2fs, ubifs,
> all of them return ENXIO when lseek with a negative offset.
> It is better to let tmpfs return ENXIO too. After that, tmpfs
> can also pass generic/448.
>=20
> Signed-off-by: Yufen Yu <yuyufen@huawei.com>
> ---
> mm/shmem.c | 4 +---
> 1 file changed, 1 insertion(+), 3 deletions(-)
>=20
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 0376c124..f37bf06 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -2608,9 +2608,7 @@ static loff_t shmem_file_llseek(struct file =
*file, loff_t offset, int whence)
> 	inode_lock(inode);
> 	/* We're holding i_mutex so we can access i_size directly */
>=20
> -	if (offset < 0)
> -		offset =3D -EINVAL;
> -	else if (offset >=3D inode->i_size)
> +	if (offset < 0 || offset >=3D inode->i_size)
> 		offset =3D -ENXIO;
> 	else {
> 		start =3D offset >> PAGE_SHIFT;
> --

It's not at all clear what the proper thing to do is if a negative =
offset is passed.

The man page for lseek(2) states:

       SEEK_DATA
              Adjust the file offset to the next location in the file
              greater than or equal to offset containing data.  If =
offset
              points to data, then the file offset is set to offset.
      =20
       SEEK_HOLE
              Adjust the file offset to the next hole in the file =
greater
              than or equal to offset.  If offset points into the middle =
of
              a hole, then the file offset is set to offset.  If there =
is no
              hole past offset, then the file offset is adjusted to the =
end
              of the file (i.e., there is an implicit hole at the end of =
any
              file).

This seems to indicate that if passed a negative offset, a whence of =
either SEEK_DATA
or SEEK_HOLE should operate the same as if passed an offset of 0.

ENXIO just seems to be the wrong error code to return for a passed =
negative offset in
these cases (also from lseek(2)):

       ENXIO  whence is SEEK_DATA or SEEK_HOLE, and the file offset is
              beyond the end of the file.

but EINVAL isn't technically appropriate either:

       EINVAL whence is not valid.  Or: the resulting file offset would =
be
              negative, or beyond the end of a seekable device.

At the very least it seems the man page should be updated to reflect =
that ENXIO may be
returned if whence is SEEK_DATA or SEEK_HOLE and the passed offset is =
negative.

    William Kucharski
