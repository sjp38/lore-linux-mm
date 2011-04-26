Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6C3689000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 08:17:57 -0400 (EDT)
Date: Tue, 26 Apr 2011 14:17:51 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 5/6] writeback: sync expired inodes first in background
 writeback
Message-ID: <20110426121751.GB5114@quack.suse.cz>
References: <20110420080336.441157866@intel.com>
 <20110420080918.383880412@intel.com>
 <20110420164005.e3925965.akpm@linux-foundation.org>
 <20110424031531.GA11220@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110424031531.GA11220@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mel Gorman <mel@linux.vnet.ibm.com>, Dave Chinner <david@fromorbit.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Minchan Kim <minchan.kim@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Sun 24-04-11 11:15:31, Wu Fengguang wrote:
> > One of the many requirements for writeback is that if userspace is
> > continually dirtying pages in a particular file, that shouldn't cause
> > the kupdate function to concentrate on that file's newly-dirtied pages,
> > neglecting pages from other files which were less-recently dirtied. 
> > (and dirty nodes, etc).
> 
> Sadly I do find the old pages that the flusher never get a chance to
> catch and write them out.
  What kind of load do you use?

> In the below case, if the task dirties pages fast enough at the end of
> file, writeback_index will never get a chance to wrap back. There may
> be various variations of this case.
> 
> file head
> [          ***                        ==>***************]==>
>            old pages          writeback_index            fresh dirties
> 
> Ironically the current kernel relies on pageout() to catch these
> old pages, which is not only inefficient, but also not reliable.
> If a full LRU walk takes an hour, the old pages may stay dirtied
> for an hour.
  Well, the kupdate behavior has always been just a best-effort thing. We
always tried to handle well common cases but didn't try to solve all of
them. Unless we want to track dirty-age of every page (which we don't
want because it's too expensive), there is really no way to make syncing
of old pages 100% working for all the cases unless we do data-integrity
type of writeback for the whole inode - but that could create new problems
with stalling other files for too long I suspect.

> We may have to do (conditional) tagged ->writepages to safeguard users
> from losing data he'd expect to be written hours ago.
  Well, if the file is continuously written (and in your case it must be
even continuosly grown) I'd be content if we handle well the common case of
linear append (that happens for log files etc.). If we can do well for more
cases, even better but I'd be cautious not to disrupt some other more
common cases.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
