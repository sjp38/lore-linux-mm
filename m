Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4C1746B016A
	for <linux-mm@kvack.org>; Mon,  8 Aug 2011 09:47:32 -0400 (EDT)
Subject: Re: [PATCH 4/5] writeback: per task dirty rate limit
From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 08 Aug 2011 15:47:14 +0200
In-Reply-To: <20110806094527.002914580@intel.com>
References: <20110806084447.388624428@intel.com>
	 <20110806094527.002914580@intel.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1312811234.10488.34.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sat, 2011-08-06 at 16:44 +0800, Wu Fengguang wrote:
> Add two fields to task_struct.
>=20
> 1) account dirtied pages in the individual tasks, for accuracy
> 2) per-task balance_dirty_pages() call intervals, for flexibility
>=20
> The balance_dirty_pages() call interval (ie. nr_dirtied_pause) will
> scale near-sqrt to the safety gap between dirty pages and threshold.
>=20
> XXX: The main problem of per-task nr_dirtied is, if 10k tasks start
> dirtying pages at exactly the same time, each task will be assigned a
> large initial nr_dirtied_pause, so that the dirty threshold will be
> exceeded long before each task reached its nr_dirtied_pause and hence
> call balance_dirty_pages().
>=20
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  include/linux/sched.h |    7 ++
>  mm/memory_hotplug.c   |    3 -
>  mm/page-writeback.c   |  106 +++++++++-------------------------------
>  3 files changed, 32 insertions(+), 84 deletions(-)=20

No fork() hooks? This way tasks inherit their parent's dirty count on
clone().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
