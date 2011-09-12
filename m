Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E5A7F6B024A
	for <linux-mm@kvack.org>; Mon, 12 Sep 2011 06:20:14 -0400 (EDT)
Subject: Re: [PATCH 10/18] writeback: dirty position control - bdi reserve
 area
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Mon, 12 Sep 2011 12:19:38 +0200
In-Reply-To: <20110907123108.GB6862@localhost>
References: <20110904015305.367445271@intel.com>
	 <20110904020915.942753370@intel.com> <1315318179.14232.3.camel@twins>
	 <20110907123108.GB6862@localhost>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1315822779.26517.23.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 2011-09-07 at 20:31 +0800, Wu Fengguang wrote:
> > > +   x_intercept =3D min(write_bw, freerun);
> > > +   if (bdi_dirty < x_intercept) {
> >=20
> > So the point of the freerun point is that we never throttle before it,
> > so basically all the below shouldn't be needed at all, right?=20
>=20
> Yes!
>=20
> > > +           if (bdi_dirty > x_intercept / 8) {
> > > +                   pos_ratio *=3D x_intercept;
> > > +                   do_div(pos_ratio, bdi_dirty);
> > > +           } else
> > > +                   pos_ratio *=3D 8;
> > > +   }
> > > +
> > >     return pos_ratio;
> > >  }

Does that mean we can remove this whole block?

> >=20
> > So why not add:
> >=20
> >       if (likely(dirty < freerun))
> >               return 2;
> >=20
> > at the start of this function and leave it at that?
>=20
> Because we already has
>=20
>         if (nr_dirty < freerun)
>                 break;
>=20
> in the main balance_dirty_pages() loop ;)

Bah! I keep missing that ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
