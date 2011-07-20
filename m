Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 7BCD46B004A
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 15:52:20 -0400 (EDT)
Date: Wed, 20 Jul 2011 14:52:15 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/2] mm: page allocator: Initialise ZLC for first zone
 eligible for zone_reclaim
In-Reply-To: <alpine.DEB.2.00.1107201425200.1472@router.home>
Message-ID: <alpine.DEB.2.00.1107201443400.1472@router.home>
References: <1310742540-22780-1-git-send-email-mgorman@suse.de> <1310742540-22780-2-git-send-email-mgorman@suse.de> <alpine.DEB.2.00.1107180951390.30392@router.home> <20110718160552.GB5349@suse.de> <alpine.DEB.2.00.1107181208050.31576@router.home>
 <20110718211325.GC5349@suse.de> <alpine.DEB.2.00.1107181651000.31576@router.home> <alpine.DEB.2.00.1107190901120.1199@router.home> <alpine.DEB.2.00.1107201307530.1472@router.home> <20110720191858.GO5349@suse.de>
 <alpine.DEB.2.00.1107201425200.1472@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The existing way of deciding if watermarks have been met looks broken to
me.

There are two pools of pages: One is the pages available from the buddy
lists and another the pages in the per cpu lists.

zone_watermark_ok() only checks those in the buddy lists
(NR_FREE_PAGES) is not updated when we get a page from the per cpu lists).

And we do check zone_watermark_ok() before even attempting to allocate
pages that may be available from the per cpu lists?

So the allocator may pass on a zone and/or go into reclaim despite of the
availability of pages on per cpu lists. The more pages one puts into the
per cpu lists the higher the chance of an OOM. ... Ok that is not true
since we flush the per cpu pages and get them back into the buddy lists
before that happens.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
