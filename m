Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 8D2D46B00EE
	for <linux-mm@kvack.org>; Tue,  6 Sep 2011 10:23:27 -0400 (EDT)
Subject: Re: [PATCH 11/18] block: add bdi flag to indicate risk of io queue
 underrun
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Tue, 06 Sep 2011 16:22:48 +0200
In-Reply-To: <20110904020916.070059502@intel.com>
References: <20110904015305.367445271@intel.com>
	 <20110904020916.070059502@intel.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1315318968.14232.6.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: linux-fsdevel@vger.kernel.org, Tejun Heo <tj@kernel.org>, Jens Axboe <axboe@kernel.dk>, Li Shaohua <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sun, 2011-09-04 at 09:53 +0800, Wu Fengguang wrote:
> +++ linux-next/mm/page-writeback.c      2011-08-31 14:40:58.000000000 +08=
00
> @@ -1067,6 +1067,9 @@ static void balance_dirty_pages(struct a
>                                      nr_dirty, bdi_thresh, bdi_dirty,
>                                      start_time);
> =20
> +               if (unlikely(!dirty_exceeded && bdi_async_underrun(bdi)))
> +                       break;
> +
>                 dirty_ratelimit =3D bdi->dirty_ratelimit;
>                 pos_ratio =3D bdi_position_ratio(bdi, dirty_thresh,
>                                                background_thresh, nr_dirt=
y,

So dirty_exceeded looks like:


1109                 dirty_exceeded =3D (bdi_dirty > bdi_thresh) ||
1110                                   (nr_dirty > dirty_thresh);

Would it make sense to write it as:

	if (nr_dirty > dirty_thresh ||=20
	    (nr_dirty > freerun && bdi_dirty > bdi_thresh))
		dirty_exceeded =3D 1;

So that we don't actually throttle bdi thingies when we're still in the
freerun area?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
