Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A4E10900137
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 09:19:21 -0400 (EDT)
Date: Tue, 30 Aug 2011 14:19:15 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/7] Reduce filesystem writeback from page reclaim v3
Message-ID: <20110830131915.GB24629@csn.ul.ie>
References: <1312973240-32576-1-git-send-email-mgorman@suse.de>
 <20110818165420.0a7aabb5.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110818165420.0a7aabb5.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Johannes Weiner <jweiner@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>

On Thu, Aug 18, 2011 at 04:54:20PM -0700, Andrew Morton wrote:
> On Wed, 10 Aug 2011 11:47:13 +0100
> Mel Gorman <mgorman@suse.de> wrote:
> 
> > The new problem is that
> > reclaim has very little control over how long before a page in a
> > particular zone or container is cleaned which is discussed later.
> 
> Confused - where was this discussed?  Please tell us more about
> this problem and how it was addressed.
> 

This text really referred to V2 of the series where kswapd was not
writing back pages. This lead to problems on NUMA as described in
https://lkml.org/lkml/2011/7/21/242 . I should have updated the text to
read

"There is a potential new problem as reclaim has less control over
how long before a page in a particularly zone or container is cleaned
and direct reclaimers depend on kswapd or flusher threads to do
the necessary work. However, as filesystems sometimes ignore direct
reclaim requests already, it is not expected to be a serious issue"

> Another (and somewhat interrelated) potential problem I see with this
> work is that it throws a big dependency onto kswapd.  If kswapd gets
> stuck somewhere for extended periods, there's nothing there to perform
> direct writeback. 

In theory, this is true. In practice, btrfs and ext4 are already
ignoring requests from direct reclaim and have been for some
time. btrfs is particularly bad in that is also ignores requests
from kswapd leading me to believe that we are eventually going to
see stall-related bug reports on large NUMA machines with btrfs.

> This has happened in the past in weird situations
> such as kswpad getting blocked on ext3 journal commits which are
> themselves stuck for ages behind lots of writeout which itself is stuck
> behind lots of reads.  That's an advantage of direct reclaim: more
> threads available.

I do not know what these situations were but was it possible that it was
due to too many direct reclaimers starving kswapd of access to the
journal?

> How forcefully has this stuff been tested with multiple disks per
> kswapd? 

As heavily as I could on the machine I had available. This was 4 disks
for one kswapd instance. I did not spot major problems.

> Where one disk is overloaded-ext3-on-usb-stick?
> 

I tested with ext4 on a USB stick, not ext3. It completed faster and the
interactive performance felt roughly the same.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
