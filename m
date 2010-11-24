Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D29806B0087
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 06:05:28 -0500 (EST)
Subject: Re: [PATCH 06/13] writeback: bdi write bandwidth estimation
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20101117042850.002299964@intel.com>
References: <20101117042720.033773013@intel.com>
	 <20101117042850.002299964@intel.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 24 Nov 2010 12:05:32 +0100
Message-ID: <1290596732.2072.450.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Li Shaohua <shaohua.li@intel.com>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2010-11-17 at 12:27 +0800, Wu Fengguang wrote:
> +void bdi_update_write_bandwidth(struct backing_dev_info *bdi,
> +                               unsigned long *bw_time,
> +                               s64 *bw_written)
> +{
> +       unsigned long written;
> +       unsigned long elapsed;
> +       unsigned long bw;
> +       unsigned long w;
> +
> +       if (*bw_written =3D=3D 0)
> +               goto snapshot;
> +
> +       elapsed =3D jiffies - *bw_time;
> +       if (elapsed < HZ/100)
> +               return;
> +
> +       /*
> +        * When there lots of tasks throttled in balance_dirty_pages(), t=
hey
> +        * will each try to update the bandwidth for the same period, mak=
ing
> +        * the bandwidth drift much faster than the desired rate (as in t=
he
> +        * single dirtier case). So do some rate limiting.
> +        */
> +       if (jiffies - bdi->write_bandwidth_update_time < elapsed)
> +               goto snapshot;

Why this goto snapshot and not simply return? This is the second call
(bdi_update_bandwidth equivalent).

If you were to leave the old bw_written/bw_time in place the next loop
around in wb_writeback() would see a larger delta..

I guess this funny loop in wb_writeback() is also the reason you've got
a single function and not the get/update like separation

> +       written =3D percpu_counter_read(&bdi->bdi_stat[BDI_WRITTEN]) - *b=
w_written;
> +       bw =3D (HZ * PAGE_CACHE_SIZE * written + elapsed/2) / elapsed;
> +       w =3D min(elapsed / (HZ/100), 128UL);
> +       bdi->write_bandwidth =3D (bdi->write_bandwidth * (1024-w) + bw * =
w) >> 10;
> +       bdi->write_bandwidth_update_time =3D jiffies;
> +snapshot:
> +       *bw_written =3D percpu_counter_read(&bdi->bdi_stat[BDI_WRITTEN]);
> +       *bw_time =3D jiffies;
> +}=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
