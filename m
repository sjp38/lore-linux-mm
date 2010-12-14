Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id C5F6D6B008C
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 20:21:21 -0500 (EST)
Received: by iwn40 with SMTP id 40so128799iwn.14
        for <linux-mm@kvack.org>; Mon, 13 Dec 2010 17:21:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101213150327.809762057@intel.com>
References: <20101213144646.341970461@intel.com>
	<20101213150327.809762057@intel.com>
Date: Tue, 14 Dec 2010 09:21:19 +0800
Message-ID: <AANLkTim_4v9D3uj9McRWo8nAJW=NT8dRPe4nbTiDbvn_@mail.gmail.com>
Subject: Re: [PATCH 12/35] writeback: scale down max throttle bandwidth on
 concurrent dirtiers
From: "Yan, Zheng" <zheng.z.yan@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Dec 13, 2010 at 10:46 PM, Wu Fengguang <fengguang.wu@intel.com> wro=
te:
> This will noticeably reduce the fluctuaions of pause time when there are
> 100+ concurrent dirtiers.
>
> The more parallel dirtiers (1 dirtier =3D> 4 dirtiers), the smaller
> bandwidth each dirtier will share (bdi_bandwidth =3D> bdi_bandwidth/4),
> the less gap to the dirty limit ((C-A) =3D> (C-B)), the less stable the
> pause time will be (given the same fluctuation of bdi_dirty).
>
> For example, if A drifts to A', its pause time may drift from 5ms to
> 6ms, while B to B' may drift from 50ms to 90ms. =A0It's much larger
> fluctuations in relative ratio as well as absolute time.
>
> Fig.1 before patch, gap (C-B) is too low to get smooth pause time
>
> throttle_bandwidth_A =3D bdi_bandwidth .........o
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0| o <=3D A'
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0| =A0 o
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0| =A0 =A0 o
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0| =A0 =A0 =A0 o
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0| =A0 =A0 =A0 =A0 o
> throttle_bandwidth_B =3D bdi_bandwidth / 4 .....|...........o
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0| =A0 =A0 =A0 =A0 =A0 | o <=3D B'
> ----------------------------------------------+-----------+---o
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0A =A0 =A0 =A0 =A0 =A0 B =A0 C
>
> The solution is to lower the slope of the throttle line accordingly,
> which makes B stabilize at some point more far away from C.
>
> Fig.2 after patch
>
> throttle_bandwidth_A =3D bdi_bandwidth .........o
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0| o <=3D A'
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0| =A0 o
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0| =A0 =A0 o
> =A0 =A0lowered max throttle bandwidth for B =3D=3D=3D> * =A0 =A0 =A0 o
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0| =A0 * =A0 =A0 o
> throttle_bandwidth_B =3D bdi_bandwidth / 4 .............* =A0 o
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0| =A0 =A0 =A0 | =A0 * o
> ----------------------------------------------+-------+-------o
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0A =A0 =A0 =A0 B =A0 =A0 =A0 C
>
> Note that C is actually different points for 1-dirty and 4-dirtiers
> cases, but for easy graphing, we move them together.
>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
> =A0mm/page-writeback.c | =A0 16 +++++++++++++---
> =A01 file changed, 13 insertions(+), 3 deletions(-)
>
> --- linux-next.orig/mm/page-writeback.c 2010-12-13 21:46:14.000000000 +08=
00
> +++ linux-next/mm/page-writeback.c =A0 =A0 =A02010-12-13 21:46:15.0000000=
00 +0800
> @@ -587,6 +587,7 @@ static void balance_dirty_pages(struct a
> =A0 =A0 =A0 =A0unsigned long background_thresh;
> =A0 =A0 =A0 =A0unsigned long dirty_thresh;
> =A0 =A0 =A0 =A0unsigned long bdi_thresh;
> + =A0 =A0 =A0 unsigned long task_thresh;
> =A0 =A0 =A0 =A0unsigned long long bw;
> =A0 =A0 =A0 =A0unsigned long period;
> =A0 =A0 =A0 =A0unsigned long pause =3D 0;
> @@ -616,7 +617,7 @@ static void balance_dirty_pages(struct a
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bdi_thresh =3D bdi_dirty_limit(bdi, dirty_=
thresh, nr_dirty);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 bdi_thresh =3D task_dirty_limit(current, bd=
i_thresh);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 task_thresh =3D task_dirty_limit(current, b=
di_thresh);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * In order to avoid the stacked BDI deadl=
ock we need
> @@ -638,14 +639,23 @@ static void balance_dirty_pages(struct a
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bdi_update_bandwidth(bdi, start_time, bdi_=
dirty, bdi_thresh);
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (bdi_dirty >=3D bdi_thresh || nr_dirty >=
 dirty_thresh) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (bdi_dirty >=3D task_thresh || nr_dirty =
> dirty_thresh) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pause =3D MAX_PAUSE;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto pause;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* When bdi_dirty grows closer to bdi_thr=
esh, it indicates more
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* concurrent dirtiers. Proportionally lo=
wer the max throttle
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* bandwidth. This will resist bdi_dirty =
from approaching to
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* close to task_thresh, and help reduce =
fluctuations of pause
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* time when there are lots of dirtiers.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bw =3D bdi->write_bandwidth;
> -
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bw =3D bw * (bdi_thresh - bdi_dirty);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 do_div(bw, bdi_thresh / BDI_SOFT_DIRTY_LIMI=
T + 1);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bw =3D bw * (task_thresh - bdi_dirty);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0do_div(bw, bdi_thresh / TASK_SOFT_DIRTY_LI=
MIT + 1);

Maybe changing this line to "do_div(bw, task_thresh /
TASK_SOFT_DIRTY_LIMIT + 1);"
is more consistent.

Thanks
Yan, Zheng

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
