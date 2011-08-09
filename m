Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 9946E6B0169
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 10:58:05 -0400 (EDT)
Subject: Re: [PATCH 3/5] writeback: dirty rate control
From: Peter Zijlstra <peterz@infradead.org>
Date: Tue, 09 Aug 2011 16:57:32 +0200
In-Reply-To: <20110806094526.878435971@intel.com>
References: <20110806084447.388624428@intel.com>
	 <20110806094526.878435971@intel.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1312901852.1083.26.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sat, 2011-08-06 at 16:44 +0800, Wu Fengguang wrote:
>=20
> Estimation of balanced bdi->dirty_ratelimit
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>=20
> When started N dd, throttle each dd at
>=20
>          task_ratelimit =3D pos_bw (any non-zero initial value is OK)

This is (0), since it makes (1). But it fails to explain what the
difference is between task_ratelimit and pos_bw (and why positional
bandwidth is a good name).

> After 200ms, we got
>=20
>          dirty_bw =3D # of pages dirtied by app / 200ms
>          write_bw =3D # of pages written to disk / 200ms

Right, so that I get. And our premise for the whole work is to delay
applications so that we match the dirty_bw to the write_bw, right?

> For aggressive dirtiers, the equality holds
>=20
>          dirty_bw =3D=3D N * task_ratelimit
>                   =3D=3D N * pos_bw                         (1)

So dirty_bw is in pages/s, so task_ratelimit should also be in pages/s,
since N is a unit-less number.

What does task_ratelimit in pages/s mean? Since we make the tasks sleep
the only thing we can make from this is a measure of pages. So I expect
(in a later patch) we compute the sleep time on the amount of pages we
want written out, using this ratelimit measure, right?

> The balanced throttle bandwidth can be estimated by
>=20
>          ref_bw =3D pos_bw * write_bw / dirty_bw          (2)

Here you introduce reference bandwidth, what does it mean and what is
its relation to positional bandwidth. Going by the equation, we got
(pages/s * pages/s) / (pages/s) so we indeed have a bandwidth unit.

write_bw/dirty_bw is the ration between output and input of dirty pages,
but what is pos_bw and what does that make ref_bw?

> >From (1) and (2), we get equality
>=20
>          ref_bw =3D=3D write_bw / N                         (3)

Somehow this seems like the primary postulate, yet you present it like a
derivation. The whole purpose of your control system is to provide this
fairness between processes, therefore I would expect you start out with
this postulate and reason therefrom.

> If the N dd's are all throttled at ref_bw, the dirty/writeback rates
> will match. So ref_bw is the balanced dirty rate.

Which does lead to the question why its not called that instead ;-)

> In practice, the ref_bw calculated by (2) may fluctuate and have
> estimation errors. So the bdi->dirty_ratelimit update policy is to
> follow it only when both pos_bw and ref_bw point to the same direction
> (indicating not only the dirty position has deviated from the global/bdi
> setpoints, but also it's still departing away).

Which is where you introduce the need for pos_bw, yet you have not yet
explained its meaning. In this explanation you allude to it being the
speed (first time derivative) of the deviation from the setpoint.

The set point's measure is in pages, so the measure of its first time
derivative would indeed be pages/s, just like bandwidth, but calling it
a bandwidth seems highly confusing indeed.

I would also like a few more words on your update condition, why did you
pick those, and what are the full ramifications of them.

Also missing in this story is your pos_ratio thing, it is used in the
code, but there is no explanation on how it ties in with the above
things.


You seem very skilled in control systems (your earlier read-ahead work
was also a very complex system), but the explanations of your systems
are highly confusing. Can you go back to the roots and explain how you
constructed your model and why you did so? (without using graphs please)


PS. I'm not criticizing your work, the results are impressive (as
always), but I find it very hard to understand.=20

PPS. If it would help, feel free to refer me to educational material on
control system theory, either online or in books.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
