Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 63A146B0169
	for <linux-mm@kvack.org>; Mon, 22 Aug 2011 11:38:25 -0400 (EDT)
Subject: Re: [PATCH 2/5] writeback: dirty position control
From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 22 Aug 2011 17:38:07 +0200
In-Reply-To: <20110812142020.GB17781@localhost>
References: <20110806084447.388624428@intel.com>
	 <20110806094526.733282037@intel.com> <1312811193.10488.33.camel@twins>
	 <20110808141128.GA22080@localhost> <1312814501.10488.41.camel@twins>
	 <20110808230535.GC7176@localhost> <1313154259.6576.42.camel@twins>
	 <20110812142020.GB17781@localhost>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1314027488.24275.74.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, 2011-08-12 at 22:20 +0800, Wu Fengguang wrote:
> On Fri, Aug 12, 2011 at 09:04:19PM +0800, Peter Zijlstra wrote:
> > On Tue, 2011-08-09 at 19:20 +0200, Peter Zijlstra wrote:
>=20
> To start with,
>=20
>                                                 write_bw
>         ref_bw =3D task_ratelimit_in_past_200ms * --------
>                                                 dirty_bw
>=20
> where
>         task_ratelimit_in_past_200ms ~=3D dirty_ratelimit * pos_ratio
>=20
> > > Now all of the above would seem to suggest:
> > >=20
> > >   dirty_ratelimit :=3D ref_bw
>=20
> Right, ideally ref_bw is the balanced dirty ratelimit. I actually
> started with exactly the above equation when I got choked by pure
> pos_bw based feedback control (as mentioned in the reply to Jan's
> email) and introduced the ref_bw estimation as the way out.
>=20
> But there are some imperfections in ref_bw, too. Which makes it not
> suitable for direct use:
>=20
> 1) large fluctuations

OK, understood.

> 2) due to truncates and fs redirties, the (write_bw <=3D> dirty_bw)
> becomes unbalanced match, which leads to large systematical errors
> in ref_bw. The truncates, due to its possibly bumpy nature, can hardly
> be compensated smoothly.

OK.

> 3) since we ultimately want to
>=20
> - keep the dirty pages around the setpoint as long time as possible
> - keep the fluctuations of task ratelimit as small as possible

Fair enough ;-)

> the update policy used for (2) also serves the above goals nicely:
> if for some reason the dirty pages are high (pos_bw < dirty_ratelimit),
> and dirty_ratelimit is low (dirty_ratelimit < ref_bw), there is no
> point to bring up dirty_ratelimit in a hurry and to hurt both the
> above two goals.

Right, so still I feel somewhat befuddled, so we have:

	dirty_ratelimit - rate at which we throttle dirtiers as
			  estimated upto 200ms ago.

	pos_ratio	- ratio adjusting the dirty_ratelimit
			  for variance in dirty pages around its target

	bw_ratio	- ratio adjusting the dirty_ratelimit
			  for variance in input/output bandwidth

and we need to basically do:

	dirty_ratelimit *=3D pos_ratio * bw_ratio

to update the dirty_ratelimit to reflect the current state. However per
1) and 2) bw_ratio is crappy and hard to fix.

So you propose to update dirty_ratelimit only if both pos_ratio and
bw_ratio point in the same direction, however that would result in:

  if (pos_ratio < UNIT && bw_ratio < UNIT ||
      pos_ratio > UNIT && bw_ratio > UNIT) {
	dirty_ratelimit =3D (dirty_ratelimit * pos_ratio) / UNIT;
	dirty_ratelimit =3D (dirty_ratelimit * bw_ratio) / UNIT;
  }

> > > However for that you use:
> > >=20
> > >   if (pos_bw < dirty_ratelimit && ref_bw < dirty_ratelimit)
> > >         dirty_ratelimit =3D max(ref_bw, pos_bw);
> > >=20
> > >   if (pos_bw > dirty_ratelimit && ref_bw > dirty_ratelimit)
> > >         dirty_ratelimit =3D min(ref_bw, pos_bw);
>=20
> The above are merely constraints to the dirty_ratelimit update.
> It serves to
>=20
> 1) stop adjusting the rate when it's against the position control
>    target (the adjusted rate will slow down the progress of dirty
>    pages going back to setpoint).

Not strictly speaking, suppose pos_ratio =3D 0.5 and bw_ratio =3D 1.1, then
they point in different directions however:

 0.5 < 1 &&  0.5 * 1.1 < 1

so your code will in fact update the dirty_ratelimit, even though the
two factors point in opposite directions.

> 2) limit the step size. pos_bw is changing values step by step,
>    leaving a consistent trace comparing to the randomly jumping
>    ref_bw. pos_bw also has smaller errors in stable state and normally
>    have larger errors when there are big errors in rate. So it's a
>    pretty good limiting factor for the step size of dirty_ratelimit.

OK, so that's the min/max stuff, however it only works because you use
pos_bw and ref_bw instead of the fully separated factors.

> Hope the above elaboration helps :)

A little..=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
