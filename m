Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 21F006B016B
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 04:56:34 -0400 (EDT)
Subject: Re: [PATCH 2/5] writeback: dirty position control
From: Peter Zijlstra <peterz@infradead.org>
Date: Fri, 26 Aug 2011 10:56:11 +0200
In-Reply-To: <20110826015610.GA10320@localhost>
References: <20110812142020.GB17781@localhost>
	 <1314027488.24275.74.camel@twins> <20110823034042.GC7332@localhost>
	 <1314093660.8002.24.camel@twins> <20110823141504.GA15949@localhost>
	 <20110823174757.GC15820@redhat.com> <20110824001257.GA6349@localhost>
	 <20110824180058.GC22434@redhat.com> <20110825031934.GA9764@localhost>
	 <20110825222001.GG27162@redhat.com> <20110826015610.GA10320@localhost>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1314348971.26922.20.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Vivek Goyal <vgoyal@redhat.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, 2011-08-26 at 09:56 +0800, Wu Fengguang wrote:
>         /*
>          * A linear estimation of the "balanced" throttle rate. The theor=
y is,
>          * if there are N dd tasks, each throttled at task_ratelimit, the=
 bdi's
>          * dirty_rate will be measured to be (N * task_ratelimit). So the=
 below
>          * formula will yield the balanced rate limit (write_bw / N).
>          *
>          * Note that the expanded form is not a pure rate feedback:
>          *      rate_(i+1) =3D rate_(i) * (write_bw / dirty_rate)        =
      (1)
>          * but also takes pos_ratio into account:
>          *      rate_(i+1) =3D rate_(i) * (write_bw / dirty_rate) * pos_r=
atio  (2)
>          *
>          * (1) is not realistic because pos_ratio also takes part in bala=
ncing
>          * the dirty rate.  Consider the state
>          *      pos_ratio =3D 0.5                                        =
      (3)
>          *      rate =3D 2 * (write_bw / N)                              =
      (4)
>          * If (1) is used, it will stuck in that state! Because each dd w=
ill be
>          * throttled at
>          *      task_ratelimit =3D pos_ratio * rate =3D (write_bw / N)   =
        (5)
>          * yielding
>          *      dirty_rate =3D N * task_ratelimit =3D write_bw           =
        (6)
>          * put (6) into (1) we get
>          *      rate_(i+1) =3D rate_(i)                                  =
      (7)
>          *
>          * So we end up using (2) to always keep
>          *      rate_(i+1) ~=3D (write_bw / N)                           =
      (8)
>          * regardless of the value of pos_ratio. As long as (8) is satisf=
ied,
>          * pos_ratio is able to drive itself to 1.0, which is not only wh=
ere
>          * the dirty count meet the setpoint, but also where the slope of
>          * pos_ratio is most flat and hence task_ratelimit is least fluct=
uated.
>          */=20

I'm still not buying this, it has the massive assumption N is a
constant, without that assumption you get the same kind of thing you get
from not adding pos_ratio to the feedback term.

Also, I've yet to see what harm it does if you leave it out, all
feedback loops should stabilize just fine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
