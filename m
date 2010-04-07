Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id AFB876B01EE
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 06:46:54 -0400 (EDT)
Date: Wed, 7 Apr 2010 11:46:32 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 06/14] Export fragmentation index via
	/proc/extfrag_index
Message-ID: <20100407104632.GP17882@csn.ul.ie>
References: <1270224168-14775-1-git-send-email-mel@csn.ul.ie> <1270224168-14775-7-git-send-email-mel@csn.ul.ie> <20100406170542.fe9b9f33.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100406170542.fe9b9f33.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 06, 2010 at 05:05:42PM -0700, Andrew Morton wrote:
> On Fri,  2 Apr 2010 17:02:40 +0100
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > Fragmentation index is a value that makes sense when an allocation of a
> > given size would fail. The index indicates whether an allocation failure is
> > due to a lack of memory (values towards 0) or due to external fragmentation
> > (value towards 1).  For the most part, the huge page size will be the size
> > of interest but not necessarily so it is exported on a per-order and per-zone
> > basis via /proc/extfrag_index
> 
> (/proc/sys/vm?)
> 

It can move.

> Like unusable_index, this seems awfully specialised. 

Except in this case, the fragmentation index is used by the kernel when
deciding in advance whether compaction will do the job or if lumpy
reclaim is required.

I could avoid exposing this to userspace but it would make it harder to
decide what needs to happen with extfrag_threshold later. i.e. does the
threshold need a different value (proc would help gather the data) or
is a new heuristic needed.

> Perhaps we could
> hide it under CONFIG_MEL, or even put it in debugfs with the intention
> of removing it in 6 or 12 months time.  Either way, it's hard to
> justify permanently adding this stuff to every kernel in the world?
> 

Moving it to debugfs would satisfy the requirement of tuning extfrag_threshold
without adding it to every kernel but it could also be just removed.

> 
> I have a suspicion that all the info in unusable_index and
> extfrag_index could be computed from userspace using /proc/kpageflags

It can be computed from buddyinfo. I used a perl script to calculate it
in the past. I exposed the information from in-kernel in these patches so
people would be guaranteed to have the same information as me.

> (and perhaps a bit of dmesg-diddling to find the zones). 

Can be figured out from buddyinfo too.

> If that can't
> be done today, I bet it'd be pretty easy to arrange for it.
> 

It is. Will I just remove the proc files, keep the internal calculation
for fragmentation_index and kick that perl script into shape to produce
the same information from buddyinfo?

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
