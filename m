Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8486E6B0169
	for <linux-mm@kvack.org>; Wed, 24 Aug 2011 12:13:19 -0400 (EDT)
Subject: Re: [PATCH 2/5] writeback: dirty position control
From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 24 Aug 2011 18:12:58 +0200
In-Reply-To: <20110824001257.GA6349@localhost>
References: <20110808141128.GA22080@localhost>
	 <1312814501.10488.41.camel@twins> <20110808230535.GC7176@localhost>
	 <1313154259.6576.42.camel@twins> <20110812142020.GB17781@localhost>
	 <1314027488.24275.74.camel@twins> <20110823034042.GC7332@localhost>
	 <1314093660.8002.24.camel@twins> <20110823141504.GA15949@localhost>
	 <20110823174757.GC15820@redhat.com> <20110824001257.GA6349@localhost>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1314202378.6925.48.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Vivek Goyal <vgoyal@redhat.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 2011-08-24 at 08:12 +0800, Wu Fengguang wrote:
> > You somehow directly jump to =20
> >=20
> > 	balanced_rate =3D task_ratelimit_200ms * write_bw / dirty_rate
> >=20
> > without explaining why following will not work.
> >=20
> > 	balanced_rate_(i+1) =3D balance_rate(i) * write_bw / dirty_rate
>=20
> Thanks for asking that, it's probably the root of confusions, so let
> me answer it standalone.
>=20
> It's actually pretty simple to explain this equation:
>=20
>                                                write_bw
>         balanced_rate =3D task_ratelimit_200ms * ----------       (1)
>                                                dirty_rate
>=20
> If there are N dd tasks, each task is throttled at task_ratelimit_200ms
> for the past 200ms, we are going to measure the overall bdi dirty rate
>=20
>         dirty_rate =3D N * task_ratelimit_200ms                   (2)
>=20
> put (2) into (1) we get
>=20
>         balanced_rate =3D write_bw / N                            (3)
>=20
> So equation (1) is the right estimation to get the desired target (3).
>=20
>=20
> As for
>=20
>                                                   write_bw
>         balanced_rate_(i+1) =3D balanced_rate_(i) * ----------    (4)
>                                                   dirty_rate
>=20
> Let's compare it with the "expanded" form of (1):
>=20
>                                                               write_bw
>         balanced_rate_(i+1) =3D balanced_rate_(i) * pos_ratio * ---------=
-      (5)
>                                                               dirty_rate
>=20
> So the difference lies in pos_ratio.
>=20
> Believe it or not, it's exactly the seemingly use of pos_ratio that
> makes (5) independent(*) of the position control.
>=20
> Why? Look at (4), assume the system is in a state
>=20
> - dirty rate is already balanced, ie. balanced_rate_(i) =3D write_bw / N
> - dirty position is not balanced, for example pos_ratio =3D 0.5
>=20
> balance_dirty_pages() will be rate limiting each tasks at half the
> balanced dirty rate, yielding a measured
>=20
>         dirty_rate =3D write_bw / 2                               (6)
>=20
> Put (6) into (4), we get
>=20
>         balanced_rate_(i+1) =3D balanced_rate_(i) * 2
>                             =3D (write_bw / N) * 2
>=20
> That means, any position imbalance will lead to balanced_rate
> estimation errors if we follow (4). Whereas if (1)/(5) is used, we
> always get the right balanced dirty ratelimit value whether or not
> (pos_ratio =3D=3D 1.0), hence make the rate estimation independent(*) of
> dirty position control.
>=20
> (*) independent as in real values, not the seemingly relations in equatio=
n


The assumption here is that N is a constant.. in the above case
pos_ratio would eventually end up at 1 and things would be good again. I
see your argument about oscillations, but I think you can introduce
similar effects by varying N.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
