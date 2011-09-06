Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 513B56B00EE
	for <linux-mm@kvack.org>; Tue,  6 Sep 2011 10:52:20 -0400 (EDT)
Subject: Re: [PATCH 13/18] writeback: limit max dirty pause time
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Tue, 06 Sep 2011 16:52:06 +0200
In-Reply-To: <20110904020916.329482509@intel.com>
References: <20110904015305.367445271@intel.com>
	 <20110904020916.329482509@intel.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1315320726.14232.11.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sun, 2011-09-04 at 09:53 +0800, Wu Fengguang wrote:

> +static unsigned long bdi_max_pause(struct backing_dev_info *bdi,
> +				   unsigned long bdi_dirty)
> +{
> +	unsigned long hi =3D ilog2(bdi->write_bandwidth);
> +	unsigned long lo =3D ilog2(bdi->dirty_ratelimit);
> +	unsigned long t;
> +
> +	/* target for ~10ms pause on 1-dd case */
> +	t =3D HZ / 50;

1k/50 usually ends up being 20 something

> +	/*
> +	 * Scale up pause time for concurrent dirtiers in order to reduce CPU
> +	 * overheads.
> +	 *
> +	 * (N * 20ms) on 2^N concurrent tasks.
> +	 */
> +	if (hi > lo)
> +		t +=3D (hi - lo) * (20 * HZ) / 1024;
> +
> +	/*
> +	 * Limit pause time for small memory systems. If sleeping for too long
> +	 * time, a small pool of dirty/writeback pages may go empty and disk go
> +	 * idle.
> +	 *
> +	 * 1ms for every 1MB; may further consider bdi bandwidth.
> +	 */
> +	if (bdi_dirty)
> +		t =3D min(t, bdi_dirty >> (30 - PAGE_CACHE_SHIFT - ilog2(HZ)));

Yeah, I would add the bdi->avg_write_bandwidth term in there, 1g/s as an
avg bandwidth is just too wrong..


> +
> +	/*
> +	 * The pause time will be settled within range (max_pause/4, max_pause)=
.
> +	 * Apply a minimal value of 4 to get a non-zero max_pause/4.
> +	 */
> +	return clamp_val(t, 4, MAX_PAUSE);

So you limit to 50ms min? That still seems fairly large. Is that because
your min sleep granularity might be something like 10ms since you're
using jiffies?

> +}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
