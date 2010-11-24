Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 4F3B56B0071
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 07:50:39 -0500 (EST)
Subject: Re: [PATCH 06/13] writeback: bdi write bandwidth estimation
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20101124121046.GA8333@localhost>
References: <20101117042720.033773013@intel.com>
	 <20101117042850.002299964@intel.com> <1290596732.2072.450.camel@laptop>
	 <20101124121046.GA8333@localhost>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 24 Nov 2010 13:50:47 +0100
Message-ID: <1290603047.2072.465.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Li, Shaohua" <shaohua.li@intel.com>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2010-11-24 at 20:10 +0800, Wu Fengguang wrote:
> > > +       /*
> > > +        * When there lots of tasks throttled in balance_dirty_pages(=
), they
> > > +        * will each try to update the bandwidth for the same period,=
 making
> > > +        * the bandwidth drift much faster than the desired rate (as =
in the
> > > +        * single dirtier case). So do some rate limiting.
> > > +        */
> > > +       if (jiffies - bdi->write_bandwidth_update_time < elapsed)
> > > +               goto snapshot;
> >
> > Why this goto snapshot and not simply return? This is the second call
> > (bdi_update_bandwidth equivalent).
>=20
> Good question. The loop inside balance_dirty_pages() normally run only
> once, however wb_writeback() may loop over and over again. If we just
> return here, the condition
>=20
>         (jiffies - bdi->write_bandwidth_update_time < elapsed)
>=20
> cannot be reset, then future bdi_update_bandwidth() calls in the same
> wb_writeback() loop will never find it OK to update the bandwidth.

But the thing is, you don't want to reset that, it might loop so fast
you'll throttle all of them, if you keep the pre-throttle value you'll
eventually pass, no?

> It does assume no races between CPUs.. We may need some per-cpu based
> estimation.=20

But that multi-writer race is valid even for the balance_dirty_pages()
call, two or more could interleave on the bw_time and bw_written
variables.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
