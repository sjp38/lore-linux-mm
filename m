Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C8ADA6B008A
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 10:58:03 -0500 (EST)
Subject: Re: [PATCH 29/35] nfs: in-commit pages accounting and wait queue
From: Trond Myklebust <Trond.Myklebust@netapp.com>
In-Reply-To: <20101214154026.GA8959@localhost>
References: <20101213144646.341970461@intel.com>
	 <20101213150329.831955132@intel.com>
	 <1292274951.8795.28.camel@heimdal.trondhjem.org>
	 <20101214154026.GA8959@localhost>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 14 Dec 2010 10:57:25 -0500
Message-ID: <1292342245.2976.13.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2010-12-14 at 23:40 +0800, Wu Fengguang wrote:
> On Tue, Dec 14, 2010 at 05:15:51AM +0800, Trond Myklebust wrote:
> > On Mon, 2010-12-13 at 22:47 +0800, Wu Fengguang wrote:
> > > plain text document attachment (writeback-nfs-in-commit.patch)
> > > When doing 10+ concurrent dd's, I observed very bumpy commits submiss=
ion
> > > (partly because the dd's are started at the same time, and hence reac=
hed
> > > 4MB to-commit pages at the same time). Basically we rely on the serve=
r
> > > to complete and return write/commit requests, and want both to progre=
ss
> > > smoothly and not consume too many pages. The write request wait queue=
 is
> > > not enough as it's mainly network bounded. So add another commit requ=
est
> > > wait queue. Only async writes need to sleep on this queue.
> > >=20
> >=20
> > I'm not understanding the above reasoning. Why should we serialise
> > commits at the per-filesystem level (and only for non-blocking flushes
> > at that)?
>=20
> I did the commit wait queue after seeing this graph, where there is
> very bursty pattern of commit submission and hence completion:
>=20
> http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/3G/nfs-=
100dd-1M-8p-2953M-2.6.37-rc3+-2010-12-03-01/nfs-commit-1000.png
>=20
> leading to big fluctuations, eg. the almost straight up/straight down
> lines below
> http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/3G/nfs-=
100dd-1M-8p-2953M-2.6.37-rc3+-2010-12-03-01/vmstat-dirty-300.png
> http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/3G/nfs-=
100dd-1M-8p-2953M-2.6.37-rc3+-2010-12-03-01/dirty-pages.png
> http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/3G/nfs-=
100dd-1M-8p-2953M-2.6.37-rc3+-2010-12-03-01/dirty-pages-200.png
>=20
> A commit wait queue will help wipe out the "peaks". The "fixed" graph
> is
> http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/3G/nfs-=
100dd-1M-8p-2952M-2.6.37-rc5+-2010-12-09-03-23/vmstat-dirty-300.png
> http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/3G/nfs-=
100dd-1M-8p-2952M-2.6.37-rc5+-2010-12-09-03-23/dirty-pages.png
>=20
> Blocking flushes don't need to wait on this queue because they already
> throttle themselves by waiting on the inode commit lock before/after
> the commit.  They actually should not wait on this queue, to prevent
> sync requests being unnecessarily blocked by async ones.

OK, but isn't it better then to just abort the commit, and have the
relevant async process retry it later?

This is a code path which is followed by kswapd, for instance. It seems
dangerous to be throttling that instead of allowing it to proceed (and
perhaps being able to free up memory on some other partition in the mean
time).

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
