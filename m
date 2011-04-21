Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 534838D0041
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 21:22:04 -0400 (EDT)
Date: Thu, 21 Apr 2011 09:21:56 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 5/6] writeback: sync expired inodes first in background
 writeback
Message-ID: <20110421012156.GA11120@localhost>
References: <20110420080336.441157866@intel.com>
 <20110420080918.383880412@intel.com>
 <20110420164005.e3925965.akpm@linux-foundation.org>
 <20110421011431.GA7828@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110421011431.GA7828@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Mel Gorman <mel@linux.vnet.ibm.com>, Dave Chinner <david@fromorbit.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Minchan Kim <minchan.kim@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

> > Are you testing for this failure scenario?  If so, can you briefly
> > describe the testing?
> 
> Not yet.. But one possible scheme is to record the dirty time of each
> page in a debug kernel and expose them to user space. Then we can run
> any kind of workloads, and in the mean while run a background scanner
> to collect and report the distribution of dirty page ages.
> 
> Does it sound too heavy weight? Or we may start by reporting the dirty
> inode age first. To maintain a mapping->writeback_index_wrapped_when and
> a mapping->pages_dirtied_when to follow it (or just reuse/reset
> mapping->dirtied_when?). The former will be reset to jiffies on each
> full scan of the pages. range_whole=1 scan can maintain its start time
> in a local variable. Then we get an estimation "what's the max
> possible dirty page age this inode has?". There will sure be redirtied
> pages though..

Hmm the lighter scheme will fail the common "active sequential write
to large file" case, because the full scan will never manage to come
to an end..

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
