Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 88CC29000BD
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 11:09:59 -0400 (EDT)
Subject: Re: [PATCH 10/18] writeback: dirty position control - bdi reserve
 area
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 28 Sep 2011 16:50:35 +0200
In-Reply-To: <20110928140205.GA26617@localhost>
References: <20110904015305.367445271@intel.com>
	 <20110904020915.942753370@intel.com> <1315318179.14232.3.camel@twins>
	 <20110907123108.GB6862@localhost> <1315822779.26517.23.camel@twins>
	 <20110918141705.GB15366@localhost> <20110918143721.GA17240@localhost>
	 <20110918144751.GA18645@localhost> <20110928140205.GA26617@localhost>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1317221435.24040.39.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 2011-09-28 at 22:02 +0800, Wu Fengguang wrote:

/me attempts to swap back neurons related to writeback

> After lots of experiments, I end up with this bdi reserve point
>=20
> +       x_intercept =3D bdi_thresh / 2 + MIN_WRITEBACK_PAGES;
>=20
> together with this chunk to avoid a bdi stuck in bdi_thresh=3D0 state:
>=20
> @@ -590,6 +590,7 @@ static unsigned long bdi_position_ratio(
>          */
>         if (unlikely(bdi_thresh > thresh))
>                 bdi_thresh =3D thresh;
> +       bdi_thresh =3D max(bdi_thresh, (limit - dirty) / 8);
>         /*
>          * scale global setpoint to bdi's:
>          *      bdi_setpoint =3D setpoint * bdi_thresh / thresh

So you cap bdi_thresh at a minimum of (limit-dirty)/8 which can be
pretty close to 0 if we have a spike in dirty or a negative spike in
writeout bandwidth (sudden seeks or whatnot).


> The above changes are good enough to keep reasonable amount of bdi
> dirty pages, so the bdi underrun flag ("[PATCH 11/18] block: add bdi
> flag to indicate risk of io queue underrun") is dropped.

That sounds like goodness ;-)

> I also tried various bdi freerun patches, however the results are not
> satisfactory. Basically the bdi reserve area approach (this patch)
> yields noticeably more smooth/resilient behavior than the
> freerun/underrun approaches. I noticed that the bdi underrun flag
> could lead to sudden surge of dirty pages (especially if not
> safeguarded by the dirty_exceeded condition) in the very small
> window..=20

OK, so let me try and parse this magic:

+       x_intercept =3D bdi_thresh / 2 + MIN_WRITEBACK_PAGES;
+       if (bdi_dirty < x_intercept) {
+               if (bdi_dirty > x_intercept / 8) {
+                       pos_ratio *=3D x_intercept;
+                       do_div(pos_ratio, bdi_dirty);
+               } else
+                       pos_ratio *=3D 8;
+       }

So we set our target some place north of MIN_WRITEBACK_PAGES: if we're
short we add a factor of: x_intercept/bdi_dirty.=20

Now, since bdi_dirty < x_intercept, this is > 1 and thus we promote more
dirties.

Additionally we don't let the factor get larger than 8 to avoid silly
large fluctuations (8 already seems quite generous to me).


Now I guess the only problem is when nr_bdi * MIN_WRITEBACK_PAGES ~
limit, at which point things go pear shaped.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
