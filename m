Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 847F86B004A
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 15:28:36 -0400 (EDT)
Date: Wed, 20 Jul 2011 14:28:32 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/2] mm: page allocator: Initialise ZLC for first zone
 eligible for zone_reclaim
In-Reply-To: <20110720191858.GO5349@suse.de>
Message-ID: <alpine.DEB.2.00.1107201425200.1472@router.home>
References: <1310742540-22780-1-git-send-email-mgorman@suse.de> <1310742540-22780-2-git-send-email-mgorman@suse.de> <alpine.DEB.2.00.1107180951390.30392@router.home> <20110718160552.GB5349@suse.de> <alpine.DEB.2.00.1107181208050.31576@router.home>
 <20110718211325.GC5349@suse.de> <alpine.DEB.2.00.1107181651000.31576@router.home> <alpine.DEB.2.00.1107190901120.1199@router.home> <alpine.DEB.2.00.1107201307530.1472@router.home> <20110720191858.GO5349@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 20 Jul 2011, Mel Gorman wrote:

> On Wed, Jul 20, 2011 at 01:08:46PM -0500, Christoph Lameter wrote:
> > Hmmm... Looking at get_page_from_freelist and considering speeding that up
> > in general: Could we move the whole watermark logic into the slow path?
> > Only check when we refill the per cpu queues?
>
> Each CPU list can hold 186 pages (on my currently running
> kernel at least) which is 744K. As I'm running with THP enabled,
> the min watermark is 25852K so with 34 of more CPUs, there is a
> risk that a zone would be fully depleted due to lack of watermark
> checking. Bit unlikely that 34 CPUs would be on one node but the risk
> is there. Without THP, the min watermark would have been something like
> 32K where it would be much easier to accidentally consume all memory.
>
> Yes, moving the watermark checks to the slow path would be faster
> but under some conditions, the system will lock up.

Well the fastpath would simply grab a page if its on the list. If the list
is empty then we would be checking the watermarks and extract pages from
the buddylists. The pages in the per cpu lists would not be accounted for
for reclaim. Counters would reflect the buddy allocator pages available.
Reclaim  flushes the per cpu pages so the buddy allocator pages would be
replenished.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
