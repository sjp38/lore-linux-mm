Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6892E6B00EE
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 12:18:23 -0400 (EDT)
Subject: Re: [PATCH 3/5] writeback: dirty rate control
From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 10 Aug 2011 18:17:55 +0200
In-Reply-To: <20110810110709.GA27604@localhost>
References: <20110806084447.388624428@intel.com>
	 <20110806094526.878435971@intel.com> <1312901852.1083.26.camel@twins>
	 <20110810110709.GA27604@localhost>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1312993075.23660.40.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

How about something like the below, it still needs some more work, but
its more or less complete in that is now explains both controls in one
story. The actual update bit is still missing.

---

balance_dirty_pages() needs to throttle tasks dirtying pages such that
the total amount of dirty pages stays below the specified dirty limit in
order to avoid memory deadlocks. Furthermore we desire fairness in that
tasks get throttled proportionally to the amount of pages they dirty.

IOW we want to throttle tasks such that we match the dirty rate to the
writeout bandwidth, this yields a stable amount of dirty pages:

	ratelimit =3D writeout_bandwidth

The fairness requirements gives us:

	task_ratelimit =3D write_bandwidth / N

> : When started N dd, we would like to throttle each dd at
> :=20
> :          balanced_rate =3D=3D write_bw / N                             =
     (1)
> :=20
> : We don't know N beforehand, but still can estimate balanced_rate
> : within 200ms.
> :=20
> : Start by throttling each dd task at rate
> :=20
> :         task_ratelimit =3D task_ratelimit_0                            =
   (2)
> :                          (any non-zero initial value is OK)
> :=20
> : After 200ms, we got
> :=20
> :         dirty_rate =3D # of pages dirtied by all dd's / 200ms
> :         write_bw   =3D # of pages written to the disk / 200ms
> :=20
> : For the aggressive dd dirtiers, the equality holds
> :=20
> :         dirty_rate =3D=3D N * task_rate
> :                    =3D=3D N * task_ratelimit
> :                    =3D=3D N * task_ratelimit_0                         =
     (3)
> : Or
> :         task_ratelimit_0 =3D dirty_rate / N                            =
   (4)
> :                          =20
> : So the balanced throttle bandwidth can be estimated by
> :                          =20
> :         balanced_rate =3D task_ratelimit_0 * (write_bw / dirty_rate)   =
   (5)
> :                          =20
> : Because with (4) and (5) we can get the desired equality (1):
> :                          =20
> :         balanced_rate =3D=3D (dirty_rate / N) * (write_bw / dirty_rate)
> :                       =3D=3D write_bw / N

Then using the balance_rate we can compute task pause times like:

	task_pause =3D task->nr_dirtied / task_ratelimit

[ however all that still misses the primary feedback of:

   task_ratelimit_(i+1) =3D task_ratelimit_i * (write_bw / dirty_rate)

  there's still some confusion in the above due to task_ratelimit and
  balanced_rate.
]

However, while the above gives us means of matching the dirty rate to
the writeout bandwidth, it at best provides us with a stable dirty page
count (assuming a static system). In order to control the dirty page
count such that it is high enough to provide performance, but does not
exceed the specified limit we need another control.

> So if the dirty pages are ABOVE the setpoints, we throttle each task
> a bit more HEAVY than balanced_rate, so that the dirty pages are
> created less fast than they are cleaned, thus DROP to the setpoints
> (and the reverse). With that positional adjustment, the formula is
> transformed from
>=20
>         task_ratelimit =3D balanced_rate
>=20
> to
>=20
>         task_ratelimit =3D balanced_rate * pos_ratio

> In terms of the negative feedback control theory, the
> bdi_position_ratio() function (control lines) can be expressed as
>=20
> 1) f(setpoint) =3D 1.0
> 2) df/dt < 0
>=20
> 3) optionally, abs(df/dt) should be large on large errors (=3D dirty -
>    setpoint) in order to cancel the errors fast, and be smaller when
>    dirty pages get closer to the setpoints in order to avoid overshooting=
.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
