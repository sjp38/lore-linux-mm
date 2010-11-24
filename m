Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6E76C6B0071
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 05:58:10 -0500 (EST)
Subject: Re: [PATCH 06/13] writeback: bdi write bandwidth estimation
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20101117042850.002299964@intel.com>
References: <20101117042720.033773013@intel.com>
	 <20101117042850.002299964@intel.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 24 Nov 2010 11:58:22 +0100
Message-ID: <1290596302.2072.445.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Li Shaohua <shaohua.li@intel.com>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2010-11-17 at 12:27 +0800, Wu Fengguang wrote:

> @@ -555,8 +592,10 @@ static void balance_dirty_pages(struct a
>  		pause =3D clamp_val(pause, 1, HZ/10);
> =20
>  pause:
> +		bdi_update_write_bandwidth(bdi, &bw_time, &bw_written);
>  		__set_current_state(TASK_INTERRUPTIBLE);
>  		io_schedule_timeout(pause);
> +		bdi_update_write_bandwidth(bdi, &bw_time, &bw_written);
> =20
>  		/*
>  		 * The bdi thresh is somehow "soft" limit derived from the

So its really a two part bandwidth calculation, the first call is:

  bdi_get_bandwidth()

and the second call is:

  bdi_update_bandwidth()

Would it make sense to actually implement it with two functions instead
of overloading the functionality of the one function?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
