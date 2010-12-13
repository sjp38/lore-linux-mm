Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 58CB96B008A
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 16:01:49 -0500 (EST)
Subject: Re: [PATCH 31/35] nfs: dont change wbc->nr_to_write in
 write_inode()
From: Trond Myklebust <Trond.Myklebust@netapp.com>
In-Reply-To: <20101213150330.076517282@intel.com>
References: <20101213144646.341970461@intel.com>
	 <20101213150330.076517282@intel.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Mon, 13 Dec 2010 16:01:44 -0500
Message-ID: <1292274104.8795.23.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2010-12-13 at 22:47 +0800, Wu Fengguang wrote:
> plain text document attachment
> (writeback-nfs-commit-remove-nr_to_write.patch)
> It's introduced in commit 420e3646 ("NFS: Reduce the number of
> unnecessary COMMIT calls") and seems not necessary.
>=20
> CC: Trond Myklebust <Trond.Myklebust@netapp.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  fs/nfs/write.c |    9 +--------
>  1 file changed, 1 insertion(+), 8 deletions(-)
>=20
> --- linux-next.orig/fs/nfs/write.c	2010-12-13 21:46:21.000000000 +0800
> +++ linux-next/fs/nfs/write.c	2010-12-13 21:46:22.000000000 +0800
> @@ -1557,15 +1557,8 @@ static int nfs_commit_unstable_pages(str
>  	}
> =20
>  	ret =3D nfs_commit_inode(inode, flags);
> -	if (ret >=3D 0) {
> -		if (wbc->sync_mode =3D=3D WB_SYNC_NONE) {
> -			if (ret < wbc->nr_to_write)
> -				wbc->nr_to_write -=3D ret;
> -			else
> -				wbc->nr_to_write =3D 0;
> -		}
> +	if (ret >=3D 0)
>  		return 0;
> -	}
>  out_mark_dirty:
>  	__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
>  	return ret;

It is there in order to tell the VM that it has succeeded in freeing up
a certain number of pages. Otherwise, we end up cycling forever in
writeback_sb_inodes() & friends with the latter not realising that they
have made progress.

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
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
