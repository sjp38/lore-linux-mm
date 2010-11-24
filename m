Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id F2E806B0071
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 05:54:43 -0500 (EST)
Subject: Re: [PATCH 03/13] writeback: per-task rate limit on
 balance_dirty_pages()
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20101124104331.GA6096@localhost>
References: <20101117042720.033773013@intel.com>
	 <20101117042849.650810571@intel.com> <1290594187.2072.440.camel@laptop>
	 <20101124104331.GA6096@localhost>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 24 Nov 2010 11:49:28 +0100
Message-ID: <1290595768.2072.443.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2010-11-24 at 18:43 +0800, Wu Fengguang wrote:
> On Wed, Nov 24, 2010 at 06:23:07PM +0800, Peter Zijlstra wrote:
> > On Wed, 2010-11-17 at 12:27 +0800, Wu Fengguang wrote:
> > > +       if (unlikely(current->nr_dirtied >=3D current->nr_dirtied_pau=
se ||
> > > +                    bdi->dirty_exceeded)) {
> > > +               balance_dirty_pages(mapping, current->nr_dirtied);
> > > +               current->nr_dirtied =3D 0;
> > >         }=20
> >=20
> > Was it a conscious choice to use
> >   current->nr_dirtied =3D 0
> > over=20
> >   current->nr_dirtied -=3D current->nr_dirtied_pause
> > ?
> >=20
> > The former will cause a drift in pause times due to truncation of the
> > excess.
>=20
> It should be fine in either way, as long as the "truncated" number is
> passed to balance_dirty_pages():
>=20
> +               balance_dirty_pages(mapping, current->nr_dirtied);
> +               current->nr_dirtied =3D 0;
>=20
> or
>=20
> +               balance_dirty_pages(mapping, current->nr_dirtied_pause);
> +               current->nr_dirtied -=3D current->nr_dirtied_pause;

ok, just wanted to make sure you'd considered it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
