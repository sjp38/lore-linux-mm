Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3A816620122
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 10:46:50 -0400 (EDT)
Subject: Re: [PATCH 2/6] writeback: reduce calls to global_page_state in
 balance_dirty_pages()
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20100711021748.735126772@intel.com>
References: <20100711020656.340075560@intel.com>
	 <20100711021748.735126772@intel.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 03 Aug 2010 16:55:27 +0200
Message-ID: <1280847327.1923.589.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Jan Kara <jack@suse.cz>, Richard Kennedy <richard@rsk.demon.co.uk>, Dave Chinner <david@fromorbit.com>, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sun, 2010-07-11 at 10:06 +0800, Wu Fengguang wrote:
>=20
> CC: Jan Kara <jack@suse.cz>

I can more or less remember this patch, and the result looks good.

Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>


> Signed-off-by: Richard Kennedy <richard@rsk.demon.co.uk>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  mm/page-writeback.c |   95 ++++++++++++++----------------------------
>  1 file changed, 33 insertions(+), 62 deletions(-)
>=20
> --- linux-next.orig/mm/page-writeback.c 2010-07-11 08:42:14.000000000 +08=
00
> +++ linux-next/mm/page-writeback.c      2010-07-11 08:44:49.000000000 +08=
00
> @@ -253,32 +253,6 @@ static void bdi_writeout_fraction(struct
>         }
>  }
> =20
>  static inline void task_dirties_fraction(struct task_struct *tsk,
>                 long *numerator, long *denominator)
>  {
> @@ -469,7 +443,6 @@ get_dirty_limits(unsigned long *pbackgro
>                         bdi_dirty =3D dirty * bdi->max_ratio / 100;
> =20
>                 *pbdi_dirty =3D bdi_dirty;
>                 task_dirty_limit(current, pbdi_dirty);
>         }
>  }
> @@ -491,7 +464,7 @@ static void balance_dirty_pages(struct a
>         unsigned long bdi_thresh;
>         unsigned long pages_written =3D 0;
>         unsigned long pause =3D 1;
> +       int dirty_exceeded;
>         struct backing_dev_info *bdi =3D mapping->backing_dev_info;
> =20
>         for (;;) {
> @@ -510,10 +483,35 @@ static void balance_dirty_pages(struct a
>                 nr_writeback =3D global_page_state(NR_WRITEBACK) +
>                                global_page_state(NR_WRITEBACK_TEMP);
> =20
> +               /*
> +                * In order to avoid the stacked BDI deadlock we need
> +                * to ensure we accurately count the 'dirty' pages when
> +                * the threshold is low.
> +                *
> +                * Otherwise it would be possible to get thresh+n pages
> +                * reported dirty, even though there are thresh-m pages
> +                * actually dirty; with m+n sitting in the percpu
> +                * deltas.
> +                */
> +               if (bdi_thresh < 2*bdi_stat_error(bdi)) {
> +                       bdi_nr_reclaimable =3D bdi_stat_sum(bdi, BDI_RECL=
AIMABLE);
> +                       bdi_nr_writeback =3D bdi_stat_sum(bdi, BDI_WRITEB=
ACK);
> +               } else {
> +                       bdi_nr_reclaimable =3D bdi_stat(bdi, BDI_RECLAIMA=
BLE);
> +                       bdi_nr_writeback =3D bdi_stat(bdi, BDI_WRITEBACK)=
;
> +               }
> +
> +               /*
> +                * The bdi thresh is somehow "soft" limit derived from th=
e
> +                * global "hard" limit. The former helps to prevent heavy=
 IO
> +                * bdi or process from holding back light ones; The latte=
r is
> +                * the last resort safeguard.
> +                */
> +               dirty_exceeded =3D
> +                       (bdi_nr_reclaimable + bdi_nr_writeback >=3D bdi_t=
hresh)
> +                       || (nr_reclaimable + nr_writeback >=3D dirty_thre=
sh);
> =20
> +               if (!dirty_exceeded)
>                         break;
> =20
>                 /*
> @@ -541,34 +539,10 @@ static void balance_dirty_pages(struct a
>                 if (bdi_nr_reclaimable > bdi_thresh) {
>                         writeback_inodes_wb(&bdi->wb, &wbc);
>                         pages_written +=3D write_chunk - wbc.nr_to_write;
>                         trace_wbc_balance_dirty_written(&wbc, bdi);
> +                       if (pages_written >=3D write_chunk)
> +                               break;          /* We've done our duty */
>                 }
>                 trace_wbc_balance_dirty_wait(&wbc, bdi);
>                 __set_current_state(TASK_INTERRUPTIBLE);
>                 io_schedule_timeout(pause);
> @@ -582,8 +556,7 @@ static void balance_dirty_pages(struct a
>                         pause =3D HZ / 10;
>         }
> =20
> +       if (!dirty_exceeded && bdi->dirty_exceeded)
>                 bdi->dirty_exceeded =3D 0;
> =20
>         if (writeback_in_progress(bdi))
> @@ -598,9 +571,7 @@ static void balance_dirty_pages(struct a
>          * background_thresh, to keep the amount of dirty memory low.
>          */
>         if ((laptop_mode && pages_written) ||
> +           (!laptop_mode && (nr_reclaimable > background_thresh)))
>                 bdi_start_background_writeback(bdi);
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
