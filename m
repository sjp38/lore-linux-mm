Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 34A636B00EE
	for <linux-mm@kvack.org>; Tue,  6 Sep 2011 11:51:35 -0400 (EDT)
Subject: Re: [PATCH 14/18] writeback: control dirty pause time
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Tue, 06 Sep 2011 17:51:25 +0200
In-Reply-To: <20110904020916.460538138@intel.com>
References: <20110904015305.367445271@intel.com>
	 <20110904020916.460538138@intel.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1315324285.14232.16.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sun, 2011-09-04 at 09:53 +0800, Wu Fengguang wrote:
> plain text document attachment (max-pause-adaption)
> The dirty pause time shall ultimately be controlled by adjusting
> nr_dirtied_pause, since there is relationship
>=20
> 	pause =3D pages_dirtied / task_ratelimit
>=20
> Assuming
>=20
> 	pages_dirtied ~=3D nr_dirtied_pause
> 	task_ratelimit ~=3D dirty_ratelimit
>=20
> We get
>=20
> 	nr_dirtied_pause ~=3D dirty_ratelimit * desired_pause
>=20
> Here dirty_ratelimit is preferred over task_ratelimit because it's
> more stable.
>=20
> It's also important to limit possible large transitional errors:
>=20
> - bw is changing quickly
> - pages_dirtied << nr_dirtied_pause on entering dirty exceeded area
> - pages_dirtied >> nr_dirtied_pause on btrfs (to be improved by a
>   separate fix, but still expect non-trivial errors)
>=20
> So we end up using the above formula inside clamp_val().
>=20
> The best test case for this code is to run 100 "dd bs=3D4M" tasks on
> btrfs and check its pause time distribution.



> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  mm/page-writeback.c |   15 ++++++++++++++-
>  1 file changed, 14 insertions(+), 1 deletion(-)
>=20
> --- linux-next.orig/mm/page-writeback.c	2011-08-29 19:08:43.000000000 +08=
00
> +++ linux-next/mm/page-writeback.c	2011-08-29 19:08:44.000000000 +0800
> @@ -1193,7 +1193,20 @@ pause:
>  	if (!dirty_exceeded && bdi->dirty_exceeded)
>  		bdi->dirty_exceeded =3D 0;
> =20
> -	current->nr_dirtied_pause =3D dirty_poll_interval(nr_dirty, dirty_thres=
h);
> +	if (pause =3D=3D 0)
> +		current->nr_dirtied_pause =3D
> +				dirty_poll_interval(nr_dirty, dirty_thresh);
> +	else if (period <=3D max_pause / 4 &&
> +		 pages_dirtied >=3D current->nr_dirtied_pause)
> +		current->nr_dirtied_pause =3D clamp_val(
> +					dirty_ratelimit * (max_pause / 2) / HZ,
> +					pages_dirtied + pages_dirtied / 8,
> +					pages_dirtied * 4);
> +	else if (pause >=3D max_pause)
> +		current->nr_dirtied_pause =3D 1 | clamp_val(
> +					dirty_ratelimit * (max_pause * 3/8)/HZ,
> +					pages_dirtied / 4,
> +					pages_dirtied * 7/8);
> =20

I very much prefer { } over multi line stmts, even if not strictly
needed.

I'm also not quite sure why pause=3D=3D0 is a special case, also, do the tw=
o
other line segments connect on the transition point?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
