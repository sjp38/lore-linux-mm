Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6B2316B02A4
	for <linux-mm@kvack.org>; Fri, 30 Jul 2010 12:50:14 -0400 (EDT)
Date: Fri, 30 Jul 2010 17:49:57 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: compaction: why depends on HUGETLB_PAGE
Message-ID: <20100730164957.GH3571@csn.ul.ie>
References: <20100730164414.88965.qmail@web4208.mail.ogk.yahoo.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100730164414.88965.qmail@web4208.mail.ogk.yahoo.co.jp>
Sender: owner-linux-mm@kvack.org
To: Round Robinjp <roundrobinjp@yahoo.co.jp>
Cc: linux-mm@kvack.org, iram.shahzad@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Sat, Jul 31, 2010 at 01:44:09AM +0900, Round Robinjp wrote:
> > > Please could you elaborate a little more why depending on
> > > compaction to satisfy other high-order allocation is not good.
> > >
> > 
> > At the very least, it's not a situation that has been tested heavily and
> > because other high-order allocations are typically not movable. In the
> > worst case, if they are both frequent and long-lived they *may* eventually
> > encounter fragmentation-related problems. This uncertainity is why it's
> > not good. It gets worse if there is no swap as eventually all movable pages
> > will be compacted as much as possible but there still might not be enough
> > contiguous memory for a high-order page because other pages are pinned.
> 
> I am interested in this topic too.
> 
> How about using compaction for infrequent short-lived
> high-order allocations?

Depend on MIGRATE_RESERVE instead within fragmentation avoidance. It's
objective is to keep certain blocks of pages free unless there is no other
choice. How many blocks of MIGRATE_RESERVE there are depends on the value
of min_free_kbytes (which can be tuned to a recommended value with hugeadm)
MIGRATE_RESERVE is known to be important for short-lived high-order allocations
- particularly atomic ones.

> Is there any problem in that case?
> (apart from the point that it is not tested for that purpose)
> 

It's racy, you are depending on compaction to happen at the right time
and with enough vigour to prevent allocation failures.

> Also how about using compaction as a preparation
> for partial refresh?
> 

Hacky, but you could do it from userspace by periodically writing to
/proc/sys/vm/compact_memory. In the event allocation failures are
common, it would still be best to figure out how long-lived those
allocations are and why MIGRATE_RESERVE was insufficient.

I'm not saying pre-emptively compacting won't work, it probably will for
a large number of cases but there will be failure scenarios in the
field.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
