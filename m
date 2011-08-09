Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 47F596B0169
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 14:35:31 -0400 (EDT)
Subject: Re: [PATCH 4/5] writeback: per task dirty rate limit
From: Peter Zijlstra <peterz@infradead.org>
Date: Tue, 09 Aug 2011 20:35:06 +0200
In-Reply-To: <20110806094527.002914580@intel.com>
References: <20110806084447.388624428@intel.com>
	 <20110806094527.002914580@intel.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1312914906.1083.71.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sat, 2011-08-06 at 16:44 +0800, Wu Fengguang wrote:
>=20
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
> call balance_dirty_pages().=20

Right, so why remove the per-cpu threshold? you can keep that as a bound
on the number of out-standing dirty pages.

Loosing that bound is actually a bad thing (TM), since you could have
configured a tight dirty limit and lock up your machine this way.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
