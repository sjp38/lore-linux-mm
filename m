Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 1E2E36B00EE
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 18:56:42 -0400 (EDT)
Subject: Re: [PATCH 2/5] writeback: dirty position control
From: Peter Zijlstra <peterz@infradead.org>
Date: Fri, 12 Aug 2011 00:56:06 +0200
References: <20110806084447.388624428@intel.com>
	 <20110806094526.733282037@intel.com> <1312811193.10488.33.camel@twins>
	 <20110808141128.GA22080@localhost> <1312814501.10488.41.camel@twins>
	 <20110808230535.GC7176@localhost>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1313103367.26866.39.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 2011-08-09 at 19:20 +0200, Peter Zijlstra wrote:
> So going by:
>=20
>                                          write_bw
>   ref_bw =3D dirty_ratelimit * pos_ratio * --------
>                                          dirty_bw
>=20
> pos_ratio seems to be the feedback on the deviation of the dirty pages
> around its setpoint. So we adjust the reference bw (or rather ratelimit)
> to take account of the shift in output vs input capacity as well as the
> shift in dirty pages around its setpoint.
>=20
> From that we derive the condition that:=20
>=20
>   pos_ratio(setpoint) :=3D 1
>=20
> Now in order to create a linear function we need one more condition. We
> get one from the fact that once we hit the limit we should hard throttle
> our writers. We get that by setting the ratelimit to 0, because, after
> all, pause =3D nr_dirtied / ratelimit would yield inf. in that case. Thus=
:
>=20
>   pos_ratio(limit) :=3D 0
>=20
> Using these two conditions we can solve the equations and get your:
>=20
>                         limit - dirty
>   pos_ratio(dirty) =3D  ----------------
>                       limit - setpoint
>=20
> Now, for some reason you chose not to use limit, but something like
> min(limit, 4*thresh) something to do with the slope affecting the rate
> of adjustment. This wants a comment someplace.=20

Ok, so I think that pos_ratio(limit) :=3D 0, is a stronger condition than
your negative slope (df/dx < 0), simply because it implies your
condition and because it expresses our hard stop at limit.

Also, while I know this is totally over the top, but..

I saw you added a ramp and brake area in future patches, so have you
considered using a third order polynomial instead?

The simple:

 f(x) =3D -x^3=20

has the 'right' shape, all we need is move it so that:

 f(s) =3D 1

and stretch it to put the single root at our limit. You'd get something
like:

               s - x 3
 f(x) :=3D  1 + (-----)
                 d

Which, as required, is 1 at our setpoint and the factor d stretches the
middle bit. Which has a single (real) root at:=20

  x =3D s + d,=20

by setting that to our limit, we get:

  d =3D l - s

Making our final function look like:

               s - x 3
 f(x) :=3D  1 + (-----)
               l - s

You can clamp it at [0,2] or so. The implementation wouldn't be too
horrid either, something like:

unsigned long bdi_pos_ratio(..)
{
	if (dirty > limit)
		return 0;

	if (dirty < 2*setpoint - limit)
		return 2 * SCALE;

	x =3D SCALE * (setpoint - dirty) / (limit - setpoint);
	xx =3D (x * x) / SCALE;
	xxx =3D (xx * x) / SCALE;

	return xxx;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
