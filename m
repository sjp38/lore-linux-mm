Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id AA98B6B00EE
	for <linux-mm@kvack.org>; Mon,  5 Sep 2011 11:06:09 -0400 (EDT)
Subject: Re: [PATCH 02/18] writeback: dirty position control
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Mon, 05 Sep 2011 17:05:57 +0200
In-Reply-To: <20110904020914.848566742@intel.com>
References: <20110904015305.367445271@intel.com>
	 <20110904020914.848566742@intel.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1315235157.3191.6.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sun, 2011-09-04 at 09:53 +0800, Wu Fengguang wrote:
> @@ -591,6 +790,7 @@ static void global_update_bandwidth(unsi
> =20
>  void __bdi_update_bandwidth(struct backing_dev_info *bdi,
>                             unsigned long thresh,
> +                           unsigned long bg_thresh,
>                             unsigned long dirty,
>                             unsigned long bdi_thresh,
>                             unsigned long bdi_dirty,
> @@ -627,6 +827,7 @@ snapshot:
> =20
>  static void bdi_update_bandwidth(struct backing_dev_info *bdi,
>                                  unsigned long thresh,
> +                                unsigned long bg_thresh,
>                                  unsigned long dirty,
>                                  unsigned long bdi_thresh,
>                                  unsigned long bdi_dirty,
> @@ -635,8 +836,8 @@ static void bdi_update_bandwidth(struct=20
>         if (time_is_after_eq_jiffies(bdi->bw_time_stamp + BANDWIDTH_INTER=
VAL))
>                 return;
>         spin_lock(&bdi->wb.list_lock);
> -       __bdi_update_bandwidth(bdi, thresh, dirty, bdi_thresh, bdi_dirty,
> -                              start_time);
> +       __bdi_update_bandwidth(bdi, thresh, bg_thresh, dirty,
> +                              bdi_thresh, bdi_dirty, start_time);
>         spin_unlock(&bdi->wb.list_lock);
>  }
> =20
> @@ -677,7 +878,8 @@ static void balance_dirty_pages(struct a
>                  * catch-up. This avoids (excessively) small writeouts
>                  * when the bdi limits are ramping up.
>                  */
> -               if (nr_dirty <=3D (background_thresh + dirty_thresh) / 2)
> +               if (nr_dirty <=3D dirty_freerun_ceiling(dirty_thresh,
> +                                                     background_thresh))
>                         break;
> =20
>                 bdi_thresh =3D bdi_dirty_limit(bdi, dirty_thresh);
> @@ -721,8 +923,9 @@ static void balance_dirty_pages(struct a
>                 if (!bdi->dirty_exceeded)
>                         bdi->dirty_exceeded =3D 1;
> =20
> -               bdi_update_bandwidth(bdi, dirty_thresh, nr_dirty,
> -                                    bdi_thresh, bdi_dirty, start_time);
> +               bdi_update_bandwidth(bdi, dirty_thresh, background_thresh=
,
> +                                    nr_dirty, bdi_thresh, bdi_dirty,
> +                                    start_time);
> =20
>                 /* Note: nr_reclaimable denotes nr_dirty + nr_unstable.
>                  * Unstable writes are a feature of certain networked
> --- linux-next.orig/fs/fs-writeback.c   2011-08-26 15:57:18.000000000 +08=
00
> +++ linux-next/fs/fs-writeback.c        2011-08-26 15:57:20.000000000 +08=
00
> @@ -675,7 +675,7 @@ static inline bool over_bground_thresh(v
>  static void wb_update_bandwidth(struct bdi_writeback *wb,
>                                 unsigned long start_time)
>  {
> -       __bdi_update_bandwidth(wb->bdi, 0, 0, 0, 0, start_time);
> +       __bdi_update_bandwidth(wb->bdi, 0, 0, 0, 0, 0, start_time);
>  }
> =20
>  /*
> --- linux-next.orig/include/linux/writeback.h   2011-08-26 15:57:18.00000=
0000 +0800
> +++ linux-next/include/linux/writeback.h        2011-08-26 15:57:20.00000=
0000 +0800
> @@ -141,6 +141,7 @@ unsigned long bdi_dirty_limit(struct bac
> =20
>  void __bdi_update_bandwidth(struct backing_dev_info *bdi,
>                             unsigned long thresh,
> +                           unsigned long bg_thresh,
>                             unsigned long dirty,
>                             unsigned long bdi_thresh,
>                             unsigned long bdi_dirty,


All this function signature muck doesn't seem immediately relevant to
the introduction of bdi_position_ratio() since the new function isn't
actually used.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
