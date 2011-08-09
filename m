Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 8BD966B0169
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 13:02:26 -0400 (EDT)
Subject: Re: [PATCH 3/5] writeback: dirty rate control
From: Peter Zijlstra <peterz@infradead.org>
Date: Tue, 09 Aug 2011 19:02:02 +0200
In-Reply-To: <20110806094526.878435971@intel.com>
References: <20110806084447.388624428@intel.com>
	 <20110806094526.878435971@intel.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1312909322.1083.52.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sat, 2011-08-06 at 16:44 +0800, Wu Fengguang wrote:

> +       pos_bw =3D bw * pos_ratio >> BANDWIDTH_CALC_SHIFT;
> +       pos_bw++;  /* this avoids bdi->dirty_ratelimit get stuck in 0 */
> +

> +       pos_ratio *=3D bdi->avg_write_bandwidth;
> +       do_div(pos_ratio, dirty_bw | 1);
> +       ref_bw =3D bw * pos_ratio >> BANDWIDTH_CALC_SHIFT;=20

when written out that results in:

           bw * pos_ratio * bdi->avg_write_bandwidth
  ref_bw =3D -----------------------------------------
                         dirty_bw

which would suggest you write it like:

  ref_bw =3D div_u64((u64)pos_bw * bdi->avg_write_bandwidth, dirty_bw | 1);

since pos_bw is already bw * pos_ratio per the above.

Or am I missing something?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
