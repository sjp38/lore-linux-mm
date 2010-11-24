Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 53F976B0087
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 06:13:43 -0500 (EST)
Subject: Re: [PATCH 08/13] writeback: quit throttling when bdi dirty pages
 dropped low
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20101117042850.245782303@intel.com>
References: <20101117042720.033773013@intel.com>
	 <20101117042850.245782303@intel.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 24 Nov 2010 12:13:53 +0100
Message-ID: <1290597233.2072.454.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2010-11-17 at 12:27 +0800, Wu Fengguang wrote:

> @@ -578,6 +579,25 @@ static void balance_dirty_pages(struct a
>  				    bdi_stat(bdi, BDI_WRITEBACK);
>  		}
> =20
> +		/*
> +		 * bdi_thresh takes time to ramp up from the initial 0,
> +		 * especially for slow devices.
> +		 *
> +		 * It's possible that at the moment dirty throttling starts,
> +		 * 	bdi_dirty =3D nr_dirty
> +		 * 		  =3D (background_thresh + dirty_thresh) / 2
> +		 * 		  >> bdi_thresh
> +		 * Then the task could be blocked for a dozen second to flush
> +		 * all the exceeded (bdi_dirty - bdi_thresh) pages. So offer a
> +		 * complementary way to break out of the loop when 250ms worth
> +		 * of dirty pages have been cleaned during our pause time.
> +		 */
> +		if (nr_dirty < dirty_thresh &&
> +		    bdi_prev_dirty - bdi_dirty >
> +		    bdi->write_bandwidth >> (PAGE_CACHE_SHIFT + 2))
> +			break;
> +		bdi_prev_dirty =3D bdi_dirty;
> +
>  		if (bdi_dirty >=3D bdi_thresh) {
>  			pause =3D HZ/10;
>  			goto pause;


So we're testing to see if during our pause time (<=3D100ms) we've written
out 250ms worth of pages (given our current bandwidth estimation),
right?=20

(1/4th of bandwidth in bytes/s is bytes per 0.25s)=20

(and in your recent patches you've changed the bw to pages/s so I take
it the PAGE_CACHE_SIZE will be gone from all these sites).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
