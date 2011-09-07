Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4B0E66B016A
	for <linux-mm@kvack.org>; Wed,  7 Sep 2011 15:15:08 -0400 (EDT)
Subject: Re: [PATCH 00/18] IO-less dirty throttling v11
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Wed, 07 Sep 2011 15:14:46 -0400
In-Reply-To: <20110907133211.GA28442@localhost>
References: <20110904015305.367445271@intel.com>
	 <20110907133211.GA28442@localhost>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1315422886.4160.11.camel@lade.trondhjem.org>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 2011-09-07 at 21:32 +0800, Wu Fengguang wrote:=20
> > Finally, the complete IO-less balance_dirty_pages(). NFS is observed to=
 perform
> > better or worse depending on the memory size. Otherwise the added patch=
es can
> > address all known regressions.
>=20
> I find that the NFS performance regressions on large memory system can
> be fixed by this patch. It tries to make the progress more smooth by
> reasonably reducing the commit size.
>=20
> Thanks,
> Fengguang
> ---
> Subject: nfs: limit the commit size to reduce fluctuations
> Date: Thu Dec 16 13:22:43 CST 2010
>=20
> Limit the commit size to half the dirty control scope, so that the
> arrival of one commit will not knock the overall dirty pages off the
> scope.
>=20
> Also limit the commit size to one second worth of data. This will
> obviously help make the pipeline run more smoothly.
>=20
> Also change "<=3D" to "<": if an inode has only one dirty page in the end=
,
> it should be committed. I wonder why the "<=3D" didn't cause a bug...
>=20
> CC: Trond Myklebust <Trond.Myklebust@netapp.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  fs/nfs/write.c |    8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
>=20
> After patch, there are still drop offs from the control scope,
>=20
> http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttl=
ing-v6/NFS/nfs-1dd-1M-8p-2945M-20%25-2.6.38-rc6-dt6+-2011-02-22-21-09/balan=
ce_dirty_pages-pages.png
>=20
> due to bursty arrival of commits:
>=20
> http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttl=
ing-v6/NFS/nfs-1dd-1M-8p-2945M-20%25-2.6.38-rc6-dt6+-2011-02-22-21-09/nfs-c=
ommit.png
>=20
> --- linux-next.orig/fs/nfs/write.c	2011-09-07 21:29:15.000000000 +0800
> +++ linux-next/fs/nfs/write.c	2011-09-07 21:29:32.000000000 +0800
> @@ -1543,10 +1543,14 @@ static int nfs_commit_unstable_pages(str
>  	int ret =3D 0;
> =20
>  	if (wbc->sync_mode =3D=3D WB_SYNC_NONE) {
> +		unsigned long bw =3D MIN_WRITEBACK_PAGES +
> +			NFS_SERVER(inode)->backing_dev_info.avg_write_bandwidth;
> +
>  		/* Don't commit yet if this is a non-blocking flush and there
> -		 * are a lot of outstanding writes for this mapping.
> +		 * are a lot of outstanding writes for this mapping, until
> +		 * collected enough pages to commit.
>  		 */
> -		if (nfsi->ncommit <=3D (nfsi->npages >> 1))
> +		if (nfsi->ncommit < min(nfsi->npages / DIRTY_SCOPE, bw))
>  			goto out_mark_dirty;
> =20
>  		/* don't wait for the COMMIT response */

So what goes into the 'avg_write_bandwidth' variable that makes it a
good measure above (why 1 second of data instead of 10 seconds or
1ms, ...)? What is the 'DIRTY_SCOPE' value?

IOW: what new black magic are we introducing above and why is it so
obviously better than what we have (yes, I see you have graphs, but that
is just measuring _one_ NFS setup and workload).

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
