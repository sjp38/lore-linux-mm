Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 6AF296B00EE
	for <linux-mm@kvack.org>; Tue,  6 Sep 2011 08:40:34 -0400 (EDT)
Subject: Re: [PATCH 2/5] writeback: dirty position control
From: Peter Zijlstra <peterz@infradead.org>
Date: Tue, 06 Sep 2011 14:40:19 +0200
References: <1313154259.6576.42.camel@twins>
	 <20110812142020.GB17781@localhost> <1314027488.24275.74.camel@twins>
	 <20110823034042.GC7332@localhost> <1314093660.8002.24.camel@twins>
	 <20110823141504.GA15949@localhost> <20110823174757.GC15820@redhat.com>
	 <20110824001257.GA6349@localhost> <20110824180058.GC22434@redhat.com>
	 <1314623527.2816.28.camel@twins> <20110829133729.GA27871@localhost>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1315312819.12533.5.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Vivek Goyal <vgoyal@redhat.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, 2011-09-02 at 14:16 +0200, Peter Zijlstra wrote:
> On Mon, 2011-08-29 at 21:37 +0800, Wu Fengguang wrote:
> > >=20
> > > Ok so this argument makes sense, is there some formalism to describe
> > > such systems where such things are more evident?
> >=20
> > I find the most easy and clean way to describe it is,
> >=20
> > (1) the below formula
> >                                                           write_bw =20
> >     bdi->dirty_ratelimit_(i+1) =3D bdi->dirty_ratelimit_i * --------- *=
 pos_ratio
> >                                                           dirty_bw
> > is able to yield
> >=20
> >     dirty_ratelimit_(i) ~=3D (write_bw / N)
> >=20
> > as long as
> >=20
> > - write_bw, dirty_bw and pos_ratio are not changing rapidly
> > - dirty pages are not around @freerun or @limit
> >=20
> > Otherwise there will be larger estimation errors.
> >=20
> > (2) based on (1), we get
> >=20
> >     task_ratelimit ~=3D (write_bw / N) * pos_ratio
> >=20
> > So the pos_ratio feedback is able to drive dirty count to the
> > setpoint, where pos_ratio =3D 1.
> >=20
> > That interpretation based on _real values_ can neatly decouple the two
> > feedback loops :) It makes full utilization of the fact "the
> > dirty_ratelimit _value_ is independent on pos_ratio except for
> > possible impacts on estimation errors".=20
>=20
> OK, so the 'problem' I have with this is that the whole control thing
> really doesn't care about N. All it does is measure:
>=20
>  - dirty rate
>  - writeback rate
>=20
> observe:
>=20
>  - dirty count; with the independent input of its setpoint
>=20
> control:
>=20
>  - ratelimit
>=20
> so I was looking for a way to describe the interaction between the two
> feedback loops without involving the exact details of what they're
> controlling, but that might just end up being an oxymoron.


Hmm, so per Vivek's argument the system without pos_ratio in the
feedback term isn't convergent. Therefore we should be able to argue
from convergent/stability grounds that this term is indeed needed.

Does the stability proof of a control system need the model of what its
controlling? I guess I ought to go get a book on this or so.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
