Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7B03D6B0088
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 06:15:29 -0500 (EST)
Subject: Re: [PATCH 09/13] writeback: reduce per-bdi dirty threshold ramp
 up time
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20101117042850.361893350@intel.com>
References: <20101117042720.033773013@intel.com>
	 <20101117042850.361893350@intel.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 24 Nov 2010 12:15:41 +0100
Message-ID: <1290597341.2072.456.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Richard Kennedy <richard@rsk.demon.co.uk>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2010-11-17 at 12:27 +0800, Wu Fengguang wrote:
> plain text document attachment
> (writeback-speedup-per-bdi-threshold-ramp-up.patch)
> Reduce the dampening for the control system, yielding faster
> convergence.
>=20
> Currently it converges at a snail's pace for slow devices (in order of
> minutes).  For really fast storage, the convergence speed should be fine.
>=20
> It makes sense to make it reasonably fast for typical desktops.
>=20
> After patch, it converges in ~10 seconds for 60MB/s writes and 4GB mem.
> So expect ~1s for a fast 600MB/s storage under 4GB mem, or ~4s under
> 16GB mem, which seems reasonable.
>=20
> $ while true; do grep BdiDirtyThresh /debug/bdi/8:0/stats; sleep 1; done
> BdiDirtyThresh:            0 kB
> BdiDirtyThresh:       118748 kB
> BdiDirtyThresh:       214280 kB
> BdiDirtyThresh:       303868 kB
> BdiDirtyThresh:       376528 kB
> BdiDirtyThresh:       411180 kB
> BdiDirtyThresh:       448636 kB
> BdiDirtyThresh:       472260 kB
> BdiDirtyThresh:       490924 kB
> BdiDirtyThresh:       499596 kB
> BdiDirtyThresh:       507068 kB
> ...
> DirtyThresh:          530392 kB
>=20
> CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
> CC: Richard Kennedy <richard@rsk.demon.co.uk>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  mm/page-writeback.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> --- linux-next.orig/mm/page-writeback.c	2010-11-15 13:08:16.000000000 +08=
00
> +++ linux-next/mm/page-writeback.c	2010-11-15 13:08:28.000000000 +0800
> @@ -125,7 +125,7 @@ static int calc_period_shift(void)
>  	else
>  		dirty_total =3D (vm_dirty_ratio * determine_dirtyable_memory()) /
>  				100;
> -	return 2 + ilog2(dirty_total - 1);
> +	return ilog2(dirty_total - 1) - 1;
>  }
> =20
>  /*

You could actually improve upon this now that you have per-bdi bandwidth
estimations, simply set the period to (seconds * bandwidth) to get
convergence in @seconds.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
