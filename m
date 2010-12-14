Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 637526B0093
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 09:51:46 -0500 (EST)
Subject: Re: [PATCH 04/35] writeback: reduce per-bdi dirty threshold ramp
 up time
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20101214143902.GA24827@localhost>
References: <20101213144646.341970461@intel.com>
	 <20101213150326.856922289@intel.com> <1292333854.2019.16.camel@castor.rsk>
	 <20101214135910.GA21401@localhost> <20101214143325.GA22764@localhost>
	 <20101214143902.GA24827@localhost>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 14 Dec 2010 15:50:55 +0100
Message-ID: <1292338255.6803.1769.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Richard Kennedy <richard@rsk.demon.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2010-12-14 at 22:39 +0800, Wu Fengguang wrote:
> On Tue, Dec 14, 2010 at 10:33:25PM +0800, Wu Fengguang wrote:
> > On Tue, Dec 14, 2010 at 09:59:10PM +0800, Wu Fengguang wrote:
> > > On Tue, Dec 14, 2010 at 09:37:34PM +0800, Richard Kennedy wrote:
> >=20
> > > > As to the ramp up time, when writing to 2 disks at the same time I =
see
> > > > the per_bdi_threshold taking up to 20 seconds to converge on a stea=
dy
> > > > value after one of the write stops. So I think this could be speede=
d up
> > > > even more, at least on my setup.
> > >=20
> > > I have the roughly same ramp up time on the 1-disk 3GB mem test:
> > >=20
> > > http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/3G/=
ext4-1dd-1M-8p-2952M-2.6.37-rc5+-2010-12-09-00-37/dirty-pages.png
> > > =20
> >=20
> > Interestingly, the above graph shows that after about 10s fast ramp
> > up, there is another 20s slow ramp down. It's obviously due the
> > decline of global limit:
> >=20
> > http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/3G/ex=
t4-1dd-1M-8p-2952M-2.6.37-rc5+-2010-12-09-00-37/vmstat-dirty.png
> >=20
> > But why is the global limit declining?  The following log shows that
> > nr_file_pages keeps growing and goes stable after 75 seconds (so long
> > time!). In the same period nr_free_pages goes slowly down to its
> > stable value. Given that the global limit is mainly derived from
> > nr_free_pages+nr_file_pages (I disabled swap), something must be
> > slowly eating memory until 75 ms. Maybe the tracing ring buffers?
> >=20
> >          free     file      reclaimable pages
> > 50s      369324 + 318760 =3D> 688084
> > 60s      235989 + 448096 =3D> 684085
> >=20
> > http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/3G/ex=
t4-1dd-1M-8p-2952M-2.6.37-rc5+-2010-12-09-00-37/vmstat
>=20
> The log shows that ~64MB reclaimable memory is stoled. But the trace
> data only takes 1.8MB. Hmm..

Also, trace buffers are fully pre-allocated.

Inodes perhaps?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
