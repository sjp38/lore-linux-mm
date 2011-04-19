Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id D6795900087
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 23:29:11 -0400 (EDT)
Subject: Re: [PATCH 6/6] NFS: return -EAGAIN when skipped commit in
 nfs_commit_unstable_pages()
From: Trond Myklebust <Trond.Myklebust@netapp.com>
In-Reply-To: <20110419030532.902141228@intel.com>
References: <20110419030003.108796967@intel.com>
	 <20110419030532.902141228@intel.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Mon, 18 Apr 2011 23:29:07 -0400
Message-ID: <1303183747.5417.11.camel@lade.trondhjem.org>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mel Gorman <mel@linux.vnet.ibm.com>, Dave Chinner <david@fromorbit.com>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Minchan Kim <minchan.kim@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>

On Tue, 2011-04-19 at 11:00 +0800, Wu Fengguang wrote:
> plain text document attachment (nfs-fix-write_inode-retval.patch)
> It's probably not sane to return success while redirtying the inode at
> the same time in ->write_inode().
>=20
> CC: Trond Myklebust <Trond.Myklebust@netapp.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  fs/nfs/write.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> --- linux-next.orig/fs/nfs/write.c	2011-04-19 10:18:16.000000000 +0800
> +++ linux-next/fs/nfs/write.c	2011-04-19 10:18:32.000000000 +0800
> @@ -1519,7 +1519,7 @@ static int nfs_commit_unstable_pages(str
>  {
>  	struct nfs_inode *nfsi =3D NFS_I(inode);
>  	int flags =3D FLUSH_SYNC;
> -	int ret =3D 0;
> +	int ret =3D -EAGAIN;
> =20
>  	if (wbc->sync_mode =3D=3D WB_SYNC_NONE) {
>  		/* Don't commit yet if this is a non-blocking flush and there
>=20
>=20

Hi Fengguang,

I don't understand the purpose of this patch...

Currently, the value of 'ret' only affects the case where the commit
exits early due to this being a non-blocking flush where we have not yet
written back enough pages to make it worth our while to send a commit.

In essence, this really only matters for the cases where someone calls
'write_inode_now' (not used by anybody calling into the NFS client) and
'sync_inode', which is only called by nfs_wb_all (with sync_mode =3D
WB_SYNC_ALL).

So can you please elaborate on the possible use cases for this change?

Cheers
  Trond
--=20
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
