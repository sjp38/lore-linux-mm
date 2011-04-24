Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D44ED8D003B
	for <linux-mm@kvack.org>; Sat, 23 Apr 2011 23:15:35 -0400 (EDT)
Date: Sun, 24 Apr 2011 11:15:31 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 5/6] writeback: sync expired inodes first in background
 writeback
Message-ID: <20110424031531.GA11220@localhost>
References: <20110420080336.441157866@intel.com>
 <20110420080918.383880412@intel.com>
 <20110420164005.e3925965.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110420164005.e3925965.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Mel Gorman <mel@linux.vnet.ibm.com>, Dave Chinner <david@fromorbit.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Minchan Kim <minchan.kim@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

> One of the many requirements for writeback is that if userspace is
> continually dirtying pages in a particular file, that shouldn't cause
> the kupdate function to concentrate on that file's newly-dirtied pages,
> neglecting pages from other files which were less-recently dirtied. 
> (and dirty nodes, etc).

Sadly I do find the old pages that the flusher never get a chance to
catch and write them out.

In the below case, if the task dirties pages fast enough at the end of
file, writeback_index will never get a chance to wrap back. There may
be various variations of this case.

file head
[          ***                        ==>***************]==>
           old pages          writeback_index            fresh dirties

Ironically the current kernel relies on pageout() to catch these
old pages, which is not only inefficient, but also not reliable.
If a full LRU walk takes an hour, the old pages may stay dirtied
for an hour.

We may have to do (conditional) tagged ->writepages to safeguard users
from losing data he'd expect to be written hours ago.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
