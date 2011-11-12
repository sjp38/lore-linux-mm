Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D768B6B002D
	for <linux-mm@kvack.org>; Sat, 12 Nov 2011 00:44:36 -0500 (EST)
Received: by vws16 with SMTP id 16so5369467vws.14
        for <linux-mm@kvack.org>; Fri, 11 Nov 2011 21:44:34 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110904020914.848566742@intel.com>
References: <20110904015305.367445271@intel.com>
	<20110904020914.848566742@intel.com>
Date: Sat, 12 Nov 2011 13:44:34 +0800
Message-ID: <CAPQyPG5JS+C-zHyXFW1EXMfRyRS=4oM2mijPL9dOn7=0ubD4Eg@mail.gmail.com>
Subject: Re: [PATCH 02/18] writeback: dirty position control
From: Nai Xia <nai.xia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: linux-fsdevel@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hello Fengguang,

Is this the similar idea&algo behind TCP congestion control
since 2.6.19 ?

Same situation: Multiple tcp connections contending for network
bandwidth V.S. multiple process contending for BDI bandwidth.

Same solution: Per connection(v.s. process) speed control with cubic
algorithm controlled balancing.

:-)

Then the validness and efficiency in essence has been verified
in real world for years in another similar situation. Good to see we
are going to have it in write-back too!


Thanks,
Nai


On Sun, Sep 4, 2011 at 9:53 AM, Wu Fengguang <fengguang.wu@intel.com> wrote=
:
> bdi_position_ratio() provides a scale factor to bdi->dirty_ratelimit, so
> that the resulted task rate limit can drive the dirty pages back to the
> global/bdi setpoints.
>
> Old scheme is,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0|
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 free run area =A0| =
=A0throttle area
> =A0----------------------------------------+---------------------------->
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0th=
resh^ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dirty pages
>
> New scheme is,
>
> =A0^ task rate limit
> =A0|
> =A0| =A0 =A0 =A0 =A0 =A0 =A0*
> =A0| =A0 =A0 =A0 =A0 =A0 =A0 *
> =A0| =A0 =A0 =A0 =A0 =A0 =A0 =A0*
> =A0|[free run] =A0 =A0 =A0* =A0 =A0 =A0[smooth throttled]
> =A0| =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*
> =A0| =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *
> =A0| =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *
> =A0..bdi->dirty_ratelimit..........*
> =A0| =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 . =A0 =
=A0 *
> =A0| =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 . =A0 =
=A0 =A0 =A0 =A0*
> =A0| =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 . =A0 =
=A0 =A0 =A0 =A0 =A0 =A0*
> =A0| =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 . =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 *
> =A0| =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 . =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*
> =A0+-------------------------------.-----------------------*------------>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0setpoint^ =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0limit^ =A0dirty pages
>
> The slope of the bdi control line should be
>
> 1) large enough to pull the dirty pages to setpoint reasonably fast
>
> 2) small enough to avoid big fluctuations in the resulted pos_ratio and
> =A0 hence task ratelimit
>
> Since the fluctuation range of the bdi dirty pages is typically observed
> to be within 1-second worth of data, the bdi control line's slope is
> selected to be a linear function of bdi write bandwidth, so that it can
> adapt to slow/fast storage devices well.
>
> Assume the bdi control line
>
> =A0 =A0 =A0 =A0pos_ratio =3D 1.0 + k * (dirty - bdi_setpoint)
>
> where k is the negative slope.
>
> If targeting for 12.5% fluctuation range in pos_ratio when dirty pages
> are fluctuating in range
>
> =A0 =A0 =A0 =A0[bdi_setpoint - write_bw/2, bdi_setpoint + write_bw/2],
>
> we get slope
>
> =A0 =A0 =A0 =A0k =3D - 1 / (8 * write_bw)
>
> Let pos_ratio(x_intercept) =3D 0, we get the parameter used in code:
>
> =A0 =A0 =A0 =A0x_intercept =3D bdi_setpoint + 8 * write_bw
>
> The global/bdi slopes are nicely complementing each other when the
> system has only one major bdi (indicated by bdi_thresh ~=3D thresh):
>
> 1) slope of global control line =A0 =A0=3D> scaling to the control scope =
size
> 2) slope of main bdi control line =A0=3D> scaling to the writeout bandwid=
th
>
> so that
>
> - in memory tight systems, (1) becomes strong enough to squeeze dirty
> =A0pages inside the control scope
>
> - in large memory systems where the "gravity" of (1) for pulling the
> =A0dirty pages to setpoint is too weak, (2) can back (1) up and drive
> =A0dirty pages to bdi_setpoint ~=3D setpoint reasonably fast.
>
> Unfortunately in JBOD setups, the fluctuation range of bdi threshold
> is related to memory size due to the interferences between disks. =A0In
> this case, the bdi slope will be weighted sum of write_bw and bdi_thresh.
>
> Given equations
>
> =A0 =A0 =A0 =A0span =3D x_intercept - bdi_setpoint
> =A0 =A0 =A0 =A0k =3D df/dx =3D - 1 / span
>
> and the extremum values
>
> =A0 =A0 =A0 =A0span =3D bdi_thresh
> =A0 =A0 =A0 =A0dx =3D bdi_thresh
>
> we get
>
> =A0 =A0 =A0 =A0df =3D - dx / span =3D - 1.0
>
> That means, when bdi_dirty deviates bdi_thresh up, pos_ratio and hence
> task ratelimit will fluctuate by -100%.
>
> peter: use 3rd order polynomial for the global control line
>
> CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Acked-by: Jan Kara <jack@suse.cz>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
> =A0fs/fs-writeback.c =A0 =A0 =A0 =A0 | =A0 =A02
> =A0include/linux/writeback.h | =A0 =A01
> =A0mm/page-writeback.c =A0 =A0 =A0 | =A0213 +++++++++++++++++++++++++++++=
++++++-
> =A03 files changed, 210 insertions(+), 6 deletions(-)
>
> --- linux-next.orig/mm/page-writeback.c 2011-08-26 15:57:18.000000000 +08=
00
> +++ linux-next/mm/page-writeback.c =A0 =A0 =A02011-08-26 15:57:34.0000000=
00 +0800
> @@ -46,6 +46,8 @@
> =A0*/
> =A0#define BANDWIDTH_INTERVAL =A0 =A0 max(HZ/5, 1)
>
> +#define RATELIMIT_CALC_SHIFT =A0 10
> +
> =A0/*
> =A0* After a CPU has dirtied this many pages, balance_dirty_pages_ratelim=
ited
> =A0* will look to see if it needs to force writeback or throttling.
> @@ -409,6 +411,12 @@ int bdi_set_max_ratio(struct backing_dev
> =A0}
> =A0EXPORT_SYMBOL(bdi_set_max_ratio);
>
> +static unsigned long dirty_freerun_ceiling(unsigned long thresh,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0unsigned long bg_thresh)
> +{
> + =A0 =A0 =A0 return (thresh + bg_thresh) / 2;
> +}
> +
> =A0static unsigned long hard_dirty_limit(unsigned long thresh)
> =A0{
> =A0 =A0 =A0 =A0return max(thresh, global_dirty_limit);
> @@ -493,6 +501,197 @@ unsigned long bdi_dirty_limit(struct bac
> =A0 =A0 =A0 =A0return bdi_dirty;
> =A0}
>
> +/*
> + * Dirty position control.
> + *
> + * (o) global/bdi setpoints
> + *
> + * We want the dirty pages be balanced around the global/bdi setpoints.
> + * When the number of dirty pages is higher/lower than the setpoint, the
> + * dirty position control ratio (and hence task dirty ratelimit) will be
> + * decreased/increased to bring the dirty pages back to the setpoint.
> + *
> + * =A0 =A0 pos_ratio =3D 1 << RATELIMIT_CALC_SHIFT
> + *
> + * =A0 =A0 if (dirty < setpoint) scale up =A0 pos_ratio
> + * =A0 =A0 if (dirty > setpoint) scale down pos_ratio
> + *
> + * =A0 =A0 if (bdi_dirty < bdi_setpoint) scale up =A0 pos_ratio
> + * =A0 =A0 if (bdi_dirty > bdi_setpoint) scale down pos_ratio
> + *
> + * =A0 =A0 task_ratelimit =3D dirty_ratelimit * pos_ratio >> RATELIMIT_C=
ALC_SHIFT
> + *
> + * (o) global control line
> + *
> + * =A0 =A0 ^ pos_ratio
> + * =A0 =A0 |
> + * =A0 =A0 | =A0 =A0 =A0 =A0 =A0 =A0|<=3D=3D=3D=3D=3D global dirty contr=
ol scope =3D=3D=3D=3D=3D=3D>|
> + * 2.0 .............*
> + * =A0 =A0 | =A0 =A0 =A0 =A0 =A0 =A0.*
> + * =A0 =A0 | =A0 =A0 =A0 =A0 =A0 =A0. *
> + * =A0 =A0 | =A0 =A0 =A0 =A0 =A0 =A0. =A0 *
> + * =A0 =A0 | =A0 =A0 =A0 =A0 =A0 =A0. =A0 =A0 *
> + * =A0 =A0 | =A0 =A0 =A0 =A0 =A0 =A0. =A0 =A0 =A0 =A0*
> + * =A0 =A0 | =A0 =A0 =A0 =A0 =A0 =A0. =A0 =A0 =A0 =A0 =A0 =A0*
> + * 1.0 ................................*
> + * =A0 =A0 | =A0 =A0 =A0 =A0 =A0 =A0. =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0. =A0 =A0 *
> + * =A0 =A0 | =A0 =A0 =A0 =A0 =A0 =A0. =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0. =A0 =A0 =A0 =A0 =A0*
> + * =A0 =A0 | =A0 =A0 =A0 =A0 =A0 =A0. =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0. =A0 =A0 =A0 =A0 =A0 =A0 =A0*
> + * =A0 =A0 | =A0 =A0 =A0 =A0 =A0 =A0. =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0. =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *
> + * =A0 =A0 | =A0 =A0 =A0 =A0 =A0 =A0. =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0. =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*
> + * =A0 0 +------------.------------------.----------------------*-------=
------>
> + * =A0 =A0 =A0 =A0 =A0 freerun^ =A0 =A0 =A0 =A0 =A0setpoint^ =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 limit^ =A0 dirty pages
> + *
> + * (o) bdi control lines
> + *
> + * The control lines for the global/bdi setpoints both stretch up to @li=
mit.
> + * The below figure illustrates the main bdi control line with an auxili=
ary
> + * line extending it to @limit.
> + *
> + * =A0 o
> + * =A0 =A0 o
> + * =A0 =A0 =A0 o =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0[o] main control line
> + * =A0 =A0 =A0 =A0 o =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0[*] auxiliary control line
> + * =A0 =A0 =A0 =A0 =A0 o
> + * =A0 =A0 =A0 =A0 =A0 =A0 o
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 o
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 o
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 o
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 o
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 o--------------------- ba=
lance point, rate scale =3D 1
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | o
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 o
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A0 o
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A0 =A0 o
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A0 =A0 =A0 o
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A0 =A0 =A0 =A0 o
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A0 =A0 =A0 =A0 =A0=
 o------- connect point, rate scale =3D 1/2
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 .*
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 . =A0 *
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 . =A0 =A0 =A0*
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 . =A0 =A0 =A0 =A0 *
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 . =A0 =A0 =A0 =A0 =A0 *
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 . =A0 =A0 =A0 =A0 =A0 =A0 =A0*
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 . =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *
> + * =A0[--------------------+-----------------------------.--------------=
------*]
> + * =A00 =A0 =A0 =A0 =A0 =A0 =A0 =A0bdi_setpoint =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0x_intercept =A0 =A0 =A0 =A0 =A0 limit
> + *
> + * The auxiliary control line allows smoothly throttling bdi_dirty down =
to
> + * normal if it starts high in situations like
> + * - start writing to a slow SD card and a fast disk at the same time. T=
he SD
> + * =A0 card's bdi_dirty may rush to many times higher than bdi_setpoint.
> + * - the bdi dirty thresh drops quickly due to change of JBOD workload
> + */
> +static unsigned long bdi_position_ratio(struct backing_dev_info *bdi,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 unsigned long thresh,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 unsigned long bg_thresh,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 unsigned long dirty,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 unsigned long bdi_thresh,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 unsigned long bdi_dirty)
> +{
> + =A0 =A0 =A0 unsigned long write_bw =3D bdi->avg_write_bandwidth;
> + =A0 =A0 =A0 unsigned long freerun =3D dirty_freerun_ceiling(thresh, bg_=
thresh);
> + =A0 =A0 =A0 unsigned long limit =3D hard_dirty_limit(thresh);
> + =A0 =A0 =A0 unsigned long x_intercept;
> + =A0 =A0 =A0 unsigned long setpoint; =A0 =A0 =A0 =A0 /* dirty pages' tar=
get balance point */
> + =A0 =A0 =A0 unsigned long bdi_setpoint;
> + =A0 =A0 =A0 unsigned long span;
> + =A0 =A0 =A0 long long pos_ratio; =A0 =A0 =A0 =A0 =A0 =A0/* for scaling =
up/down the rate limit */
> + =A0 =A0 =A0 long x;
> +
> + =A0 =A0 =A0 if (unlikely(dirty >=3D limit))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* global setpoint
> + =A0 =A0 =A0 =A0*
> + =A0 =A0 =A0 =A0* =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 se=
tpoint - dirty 3
> + =A0 =A0 =A0 =A0* =A0 =A0 =A0 =A0f(dirty) :=3D 1.0 + (----------------)
> + =A0 =A0 =A0 =A0* =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 li=
mit - setpoint
> + =A0 =A0 =A0 =A0*
> + =A0 =A0 =A0 =A0* it's a 3rd order polynomial that subjects to
> + =A0 =A0 =A0 =A0*
> + =A0 =A0 =A0 =A0* (1) f(freerun) =A0=3D 2.0 =3D> rampup dirty_ratelimit =
reasonably fast
> + =A0 =A0 =A0 =A0* (2) f(setpoint) =3D 1.0 =3D> the balance point
> + =A0 =A0 =A0 =A0* (3) f(limit) =A0 =A0=3D 0 =A0 =3D> the hard limit
> + =A0 =A0 =A0 =A0* (4) df/dx =A0 =A0 =A0<=3D 0 =A0 =3D> negative feedback=
 control
> + =A0 =A0 =A0 =A0* (5) the closer to setpoint, the smaller |df/dx| (and t=
he reverse)
> + =A0 =A0 =A0 =A0* =A0 =A0 =3D> fast response on large errors; small osci=
llation near setpoint
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 setpoint =3D (freerun + limit) / 2;
> + =A0 =A0 =A0 x =3D div_s64((setpoint - dirty) << RATELIMIT_CALC_SHIFT,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 limit - setpoint + 1);
> + =A0 =A0 =A0 pos_ratio =3D x;
> + =A0 =A0 =A0 pos_ratio =3D pos_ratio * x >> RATELIMIT_CALC_SHIFT;
> + =A0 =A0 =A0 pos_ratio =3D pos_ratio * x >> RATELIMIT_CALC_SHIFT;
> + =A0 =A0 =A0 pos_ratio +=3D 1 << RATELIMIT_CALC_SHIFT;
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* We have computed basic pos_ratio above based on global=
 situation. If
> + =A0 =A0 =A0 =A0* the bdi is over/under its share of dirty pages, we wan=
t to scale
> + =A0 =A0 =A0 =A0* pos_ratio further down/up. That is done by the followi=
ng mechanism.
> + =A0 =A0 =A0 =A0*/
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* bdi setpoint
> + =A0 =A0 =A0 =A0*
> + =A0 =A0 =A0 =A0* =A0 =A0 =A0 =A0f(bdi_dirty) :=3D 1.0 + k * (bdi_dirty =
- bdi_setpoint)
> + =A0 =A0 =A0 =A0*
> + =A0 =A0 =A0 =A0* =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0x_inter=
cept - bdi_dirty
> + =A0 =A0 =A0 =A0* =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 :=3D ---------=
-----------------
> + =A0 =A0 =A0 =A0* =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0x_inter=
cept - bdi_setpoint
> + =A0 =A0 =A0 =A0*
> + =A0 =A0 =A0 =A0* The main bdi control line is a linear function that su=
bjects to
> + =A0 =A0 =A0 =A0*
> + =A0 =A0 =A0 =A0* (1) f(bdi_setpoint) =3D 1.0
> + =A0 =A0 =A0 =A0* (2) k =3D - 1 / (8 * write_bw) =A0(in single bdi case)
> + =A0 =A0 =A0 =A0* =A0 =A0 or equally: x_intercept =3D bdi_setpoint + 8 *=
 write_bw
> + =A0 =A0 =A0 =A0*
> + =A0 =A0 =A0 =A0* For single bdi case, the dirty pages are observed to f=
luctuate
> + =A0 =A0 =A0 =A0* regularly within range
> + =A0 =A0 =A0 =A0* =A0 =A0 =A0 =A0[bdi_setpoint - write_bw/2, bdi_setpoin=
t + write_bw/2]
> + =A0 =A0 =A0 =A0* for various filesystems, where (2) can yield in a reas=
onable 12.5%
> + =A0 =A0 =A0 =A0* fluctuation range for pos_ratio.
> + =A0 =A0 =A0 =A0*
> + =A0 =A0 =A0 =A0* For JBOD case, bdi_thresh (not bdi_dirty!) could fluct=
uate up to its
> + =A0 =A0 =A0 =A0* own size, so move the slope over accordingly and choos=
e a slope that
> + =A0 =A0 =A0 =A0* yields 100% pos_ratio fluctuation on suddenly doubled =
bdi_thresh.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (unlikely(bdi_thresh > thresh))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bdi_thresh =3D thresh;
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* scale global setpoint to bdi's:
> + =A0 =A0 =A0 =A0* =A0 =A0 =A0bdi_setpoint =3D setpoint * bdi_thresh / th=
resh
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 x =3D div_u64((u64)bdi_thresh << 16, thresh + 1);
> + =A0 =A0 =A0 bdi_setpoint =3D setpoint * (u64)x >> 16;
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Use span=3D(8*write_bw) in single bdi case as indicate=
d by
> + =A0 =A0 =A0 =A0* (thresh - bdi_thresh ~=3D 0) and transit to bdi_thresh=
 in JBOD case.
> + =A0 =A0 =A0 =A0*
> + =A0 =A0 =A0 =A0* =A0 =A0 =A0 =A0bdi_thresh =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0thresh - bdi_thresh
> + =A0 =A0 =A0 =A0* span =3D ---------- * (8 * write_bw) + ---------------=
---- * bdi_thresh
> + =A0 =A0 =A0 =A0* =A0 =A0 =A0 =A0 =A0thresh =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0thresh
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 span =3D (thresh - bdi_thresh + 8 * write_bw) * (u64)x >> 1=
6;
> + =A0 =A0 =A0 x_intercept =3D bdi_setpoint + span;
> +
> + =A0 =A0 =A0 span >>=3D 1;
> + =A0 =A0 =A0 if (unlikely(bdi_dirty > bdi_setpoint + span)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(bdi_dirty > limit))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (x_intercept < limit) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 x_intercept =3D limit; =A0 =
=A0/* auxiliary control line */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bdi_setpoint +=3D span;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pos_ratio >>=3D 1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 pos_ratio *=3D x_intercept - bdi_dirty;
> + =A0 =A0 =A0 do_div(pos_ratio, x_intercept - bdi_setpoint + 1);
> +
> + =A0 =A0 =A0 return pos_ratio;
> +}
> +
> =A0static void bdi_update_write_bandwidth(struct backing_dev_info *bdi,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 unsigned long elapsed,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 unsigned long written)
> @@ -591,6 +790,7 @@ static void global_update_bandwidth(unsi
>
> =A0void __bdi_update_bandwidth(struct backing_dev_info *bdi,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long thre=
sh,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long bg_th=
resh,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long dirt=
y,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long bdi_=
thresh,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long bdi_=
dirty,
> @@ -627,6 +827,7 @@ snapshot:
>
> =A0static void bdi_update_bandwidth(struct backing_dev_info *bdi,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned =
long thresh,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned=
 long bg_thresh,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned =
long dirty,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned =
long bdi_thresh,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned =
long bdi_dirty,
> @@ -635,8 +836,8 @@ static void bdi_update_bandwidth(struct
> =A0 =A0 =A0 =A0if (time_is_after_eq_jiffies(bdi->bw_time_stamp + BANDWIDT=
H_INTERVAL))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
> =A0 =A0 =A0 =A0spin_lock(&bdi->wb.list_lock);
> - =A0 =A0 =A0 __bdi_update_bandwidth(bdi, thresh, dirty, bdi_thresh, bdi_=
dirty,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0start_time);
> + =A0 =A0 =A0 __bdi_update_bandwidth(bdi, thresh, bg_thresh, dirty,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bdi_thresh, =
bdi_dirty, start_time);
> =A0 =A0 =A0 =A0spin_unlock(&bdi->wb.list_lock);
> =A0}
>
> @@ -677,7 +878,8 @@ static void balance_dirty_pages(struct a
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * catch-up. This avoids (excessively) sma=
ll writeouts
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * when the bdi limits are ramping up.
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (nr_dirty <=3D (background_thresh + dirt=
y_thresh) / 2)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (nr_dirty <=3D dirty_freerun_ceiling(dir=
ty_thresh,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 background_thresh))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bdi_thresh =3D bdi_dirty_limit(bdi, dirty_=
thresh);
> @@ -721,8 +923,9 @@ static void balance_dirty_pages(struct a
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!bdi->dirty_exceeded)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bdi->dirty_exceeded =3D 1;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 bdi_update_bandwidth(bdi, dirty_thresh, nr_=
dirty,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
bdi_thresh, bdi_dirty, start_time);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bdi_update_bandwidth(bdi, dirty_thresh, bac=
kground_thresh,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
nr_dirty, bdi_thresh, bdi_dirty,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
start_time);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Note: nr_reclaimable denotes nr_dirty +=
 nr_unstable.
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * Unstable writes are a feature of certai=
n networked
> --- linux-next.orig/fs/fs-writeback.c =A0 2011-08-26 15:57:18.000000000 +=
0800
> +++ linux-next/fs/fs-writeback.c =A0 =A0 =A0 =A02011-08-26 15:57:20.00000=
0000 +0800
> @@ -675,7 +675,7 @@ static inline bool over_bground_thresh(v
> =A0static void wb_update_bandwidth(struct bdi_writeback *wb,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned l=
ong start_time)
> =A0{
> - =A0 =A0 =A0 __bdi_update_bandwidth(wb->bdi, 0, 0, 0, 0, start_time);
> + =A0 =A0 =A0 __bdi_update_bandwidth(wb->bdi, 0, 0, 0, 0, 0, start_time);
> =A0}
>
> =A0/*
> --- linux-next.orig/include/linux/writeback.h =A0 2011-08-26 15:57:18.000=
000000 +0800
> +++ linux-next/include/linux/writeback.h =A0 =A0 =A0 =A02011-08-26 15:57:=
20.000000000 +0800
> @@ -141,6 +141,7 @@ unsigned long bdi_dirty_limit(struct bac
>
> =A0void __bdi_update_bandwidth(struct backing_dev_info *bdi,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long thre=
sh,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long bg_th=
resh,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long dirt=
y,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long bdi_=
thresh,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long bdi_=
dirty,
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
