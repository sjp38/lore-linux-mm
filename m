Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 1BD7D6B005A
	for <linux-mm@kvack.org>; Sun, 25 Oct 2009 14:54:14 -0400 (EDT)
From: Frans Pop <elendil@planet.nl>
Subject: Re: [Bug #14141] order 2 page allocation failures in iwlagn
Date: Sun, 25 Oct 2009 19:54:06 +0100
References: <3onW63eFtRF.A.xXH.oMTxKB@chimera> <20091019140151.GC9036@csn.ul.ie> <20091019161815.GA11487@think>
In-Reply-To: <20091019161815.GA11487@think>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Message-Id: <200910251954.11716.elendil@planet.nl>
Sender: owner-linux-mm@kvack.org
To: Chris Mason <chris.mason@oracle.com>
Cc: Mel Gorman <mel@csn.ul.ie>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Reinette Chatre <reinette.chatre@intel.com>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Mohamed Abbas <mohamed.abbas@intel.com>, Jens Axboe <jens.axboe@oracle.com>, "John W. Linville" <linville@tuxdriver.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Sorry for the delayed reply.

On Monday 19 October 2009, Chris Mason wrote:
> On Mon, Oct 19, 2009 at 03:01:52PM +0100, Mel Gorman wrote:
> > > During the 2nd phase I see the first SKB allocation errors with a
> > > music skip between reading commits 95.000 and 110.000.
> > > About commit 115.000 there is a very long pause during which the
> > > counter does not increase, music stops and the desktop freezes
> > > completely. The first 30 seconds of that freeze there is only very
> > > low disk activity (which seems strange);
> >
> > I'm just going to have to depend on Jens here. Jens, the
> > congestion_wait() is on BLK_RW_ASYNC after the commit. Reclaim usually
> > writes pages asynchronously but lumpy reclaim actually waits of pages
> > to write out synchronously so it's not always async.
>
> Waiting doesn't make it synchronous from the elevator point of view ;)
> If you're using WB_SYNC_NONE, it's a async write. =A0WB_SYNC_ALL makes it
> a sync write. =A0I only see WB_SYNC_NONE in vmscan.c, so we should be
> using the async congestion wait. =A0(the exception is xfs which always
> does async writes).
>
> But I'm honestly not 100% sure. =A0Looking back through the emails, the
> test case is doing IO on top of a whole lot of things on top of
> dm-crypt? =A0I just tried to figure out if dm-crypt is turning the async
> IO into sync IOs, but didn't quite make sense of it.
>
> Could you also please include which filesystems were being abused during
> the test and how? =A0Reading through the emails, I think you've got:
>
> gitk being run 3 times on some FS (NFS?)

gitk is run on an ext3 logical volume in a volume group that's on a LUKS=20
encrypted partition of the local hard disk.

So it's: SATA harddisk -> dm-crypt (dmsetup) -> LVM (lvm2) -> ext3

> streaming reads on NFS

Correct. My music share is a remote (nfs4) read-only mounted ext3=20
partition.

> swap on dm-crypt

Correct. Swap is another logical volume in the same volume group as=20
mentioned above.

So kcrypt gets to (de)encrypt both the gitk data *and* any swapping caused=
=20
by that [1].

> If other filesystems are being used, please correct me. =A0Also please
> include if they are on crypto or straight block device.

All my file systems are ext3. Nothing newfangled or exotic ;-)
There are some bind mounts involved, but I expect that's transparent.

Cheers,
=46JP

[1] I've plans to move some of my data outside the encrypted volume, but=20
currently everything except /boot is in the encrypted VG.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
