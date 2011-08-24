Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E1F786B0169
	for <linux-mm@kvack.org>; Wed, 24 Aug 2011 11:58:03 -0400 (EDT)
Subject: Re: [PATCH 2/5] writeback: dirty position control
From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 24 Aug 2011 17:57:39 +0200
In-Reply-To: <20110823141504.GA15949@localhost>
References: <20110806094526.733282037@intel.com>
	 <1312811193.10488.33.camel@twins> <20110808141128.GA22080@localhost>
	 <1312814501.10488.41.camel@twins> <20110808230535.GC7176@localhost>
	 <1313154259.6576.42.camel@twins> <20110812142020.GB17781@localhost>
	 <1314027488.24275.74.camel@twins> <20110823034042.GC7332@localhost>
	 <1314093660.8002.24.camel@twins> <20110823141504.GA15949@localhost>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1314201460.6925.44.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 2011-08-23 at 22:15 +0800, Wu Fengguang wrote:
> On Tue, Aug 23, 2011 at 06:01:00PM +0800, Peter Zijlstra wrote:
> > On Tue, 2011-08-23 at 11:40 +0800, Wu Fengguang wrote:
> > > - not a factor at all for updating balanced_rate (whether or not we d=
o (2))
> > >   well, in this concept: the balanced_rate formula inherently does no=
t
> > >   derive the balanced_rate_(i+1) from balanced_rate_i. Rather it's
> > >   based on the ratelimit executed for the past 200ms:
> > >=20
> > >           balanced_rate_(i+1) =3D task_ratelimit_200ms * bw_ratio
> >=20
> > Ok, this is where it all goes funny..
> >=20
> > So if you want completely separated feedback loops I would expect
>=20
> If call it feedback loops, then it's a series of independent feedback
> loops of depth 1.  Because each balanced_rate is a fresh estimation
> dependent solely on
>=20
> - writeout bandwidth
> - N, the number of dd tasks
>=20
> in the past 200ms.
>=20
> As long as a CONSTANT ratelimit (whatever value it is) is executed in
> the past 200ms, we can get the same balanced_rate.
>=20
>         balanced_rate =3D CONSTANT_ratelimit * write_bw / dirty_rate
>=20
> The resulted balanced_rate is independent of how large the CONSTANT
> ratelimit is, because if we start with a doubled CONSTANT ratelimit,
> we'll see doubled dirty_rate and result in the same balanced_rate.=20
>=20
> In that manner, balance_rate_(i+1) is not really depending on the
> value of balance_rate_(i): whatever balance_rate_(i) is, we are going
> to get the same balance_rate_(i+1)=20

At best this argument says it doesn't matter what we use, making
balance_rate_i an equally valid choice. However I don't buy this, your
argument is broken, your CONSTANT_ratelimit breaks feedback but then you
rely on the iterative form of feedback to finish your argument.

Consider:

	r_(i+1) =3D r_i * ratio_i

you say, r_i :=3D C for all i, then by definition ratio_i must be 1 and
you've got nothing. The only way your conclusion can be right is by
allowing the proper iteration, otherwise we'll never reach the
equilibrium.

Now it is true you can introduce random perturbations in r_i at any
given point and still end up in equilibrium, such is the power of
iterative feedback, but that doesn't say you can do away with r_i.=20

> > something like:
> >=20
> > 	balance_rate_(i+1) =3D balance_rate_(i) * bw_ratio   ; every 200ms
> >=20
> > The former is a complete feedback loop, expressing the new value in the
> > old value (*) with bw_ratio as feedback parameter; if we throttled too
> > much, the dirty_rate will have dropped and the bw_ratio will be <1
> > causing the balance_rate to drop increasing the dirty_rate, and vice
> > versa.
>=20
> In principle, the bw_ratio works that way. However since
> balance_rate_(i) is not the exact _executed_ ratelimit in
> balance_dirty_pages().

This seems to be where your argument goes bad, the actually executed
ratelimit is not important, the variance introduced by pos_ratio is
purely for the benefit of the dirty page count.=20

It doesn't matter for the balance_rate. Without pos_ratio, the dirty
page count would stay stable (ignoring all these oscillations and other
fun things), and therefore it is the balance_rate we should be using for
the iterative feedback.

> > (*) which is the form I expected and why I thought your primary feedbac=
k
> > loop looked like: rate_(i+1) =3D rate_(i) * pos_ratio * bw_ratio
> =20
> Because the executed ratelimit was rate_(i) * pos_ratio.

No, because iterative feedback has the form:=20

	new =3D old $op $feedback-term


> > Then when you use the balance_rate to actually throttle tasks you apply
> > your secondary control steering the dirty page count, yielding:
> >=20
> > 	task_rate =3D balance_rate * pos_ratio
>=20
> Right. Note the above formula is not a derived one,=20

Agreed, its not a derived expression but the originator of the dirty
page count control.

> but an original
> one that later leads to pos_ratio showing up in the calculation of
> balanced_rate.

That's where I disagree :-)

> > >   and task_ratelimit_200ms happen to can be estimated from
> > >=20
> > >           task_ratelimit_200ms ~=3D balanced_rate_i * pos_ratio
> >=20
> > >   We may alternatively record every task_ratelimit executed in the
> > >   past 200ms and average them all to get task_ratelimit_200ms. In thi=
s
> > >   way we take the "superfluous" pos_ratio out of sight :)=20
> >=20
> > Right, so I'm not at all sure that makes sense, its not immediately
> > evident that <task_ratelimit> ~=3D balance_rate * pos_ratio. Nor is it
> > clear to me why your primary feedback loop uses task_ratelimit_200ms at
> > all.=20
>=20
> task_ratelimit is used and hence defined to be (balance_rate * pos_ratio)
> by balance_dirty_pages(). So this is an original formula:
>=20
>         task_ratelimit =3D balance_rate * pos_ratio
>=20
> task_ratelimit_200ms is also used as an original data source in
>=20
>         balanced_rate =3D task_ratelimit_200ms * write_bw / dirty_rate

But that's exactly where you conflate the positional feedback with the
throughput feedback, the effective ratelimit includes the positional
feedback so that the dirty page count can move around, but that is
completely orthogonal to the throughput feedback since the throughout
thing would leave the dirty count constant (ideal case again).

That is, yes the iterative feedback still works because you still got
your primary feedback in place, but the addition of pos_ratio in the
feedback loop is a pure perturbation and doesn't matter one whit.

> Then we try to estimate task_ratelimit_200ms by assuming all tasks
> have been executing the same CONSTANT ratelimit in
> balance_dirty_pages(). Hence we get
>=20
>         task_ratelimit_200ms ~=3D prev_balance_rate * pos_ratio

But this just cannot be true (and, as argued above, is completely
unnecessary).=20

Consider the case where the dirty count is way below the setpoint but
the base ratelimit is pretty accurate. In that case we would start out
by creating very low task ratelimits such that the dirty count can
increase. Once we match the setpoint we go back to the base ratelimit.
The average over those 200ms would be <1, but since we're right at the
setpoint when we do the base ratelimit feedback we pick exactly 1.=20

Anyway, its completely irrelevant.. :-)

> > >   There is fundamentally no dependency between balanced_rate_(i+1) an=
d
> > >   balanced_rate_i/task_ratelimit_200ms: the balanced_rate estimation
> > >   only asks for _whatever_ CONSTANT task ratelimit to be executed for
> > >   200ms, then it get the balanced rate from the dirty_rate feedback.
> >=20
> > How can there not be a relation between balance_rate_(i+1) and
> > balance_rate_(i) ?=20
>=20
> In this manner: even though balance_rate_(i) is somehow used for
> calculating balance_rate_(i+1), the latter will evaluate to the same
> value given whatever balance_rate_(i).

But only if you allow for the iterative feedback to work, you absolutely
need that balance_rate_(i), without that its completely broken.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
