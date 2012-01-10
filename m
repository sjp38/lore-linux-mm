Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id D03716B0068
	for <linux-mm@kvack.org>; Mon,  9 Jan 2012 21:34:33 -0500 (EST)
Date: Mon, 9 Jan 2012 21:31:56 -0500
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH -mm 0/2] kswapd vs compaction improvements
Message-ID: <20120109213156.0ff47ee5@annuminas.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, akpm@linux-foundation.org, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, hughd@google.com, aarcange@redhat.com

Running a kernel with compaction enabled with some memory pressure has
caused my system to run into all kinds of trouble.

One of the more obvious problems is that while kswapd does not try to 
free contiguous pages when CONFIG_COMPACTION is enabled, it does
continue reclaiming until enough contiguous pages have become available.
This can lead to enormous swap storms, where lots of memory is freed
and a fair amount of the working set can end up in swap.

A second problem is that memory compaction currently does nothing for
network allocations in the receive path, for eg. jumbo frames, because
those are done in interrupt context.  In the past we have tried to
have kswapd invoke memory compaction, but it used too much CPU time.
The second patch in this series has kswapd invoke compaction very
carefully, taking in account the desired page order, as well as
zone->compaction_deferred.

I have tested these patches on my system, and things seem to behave
well. Any tests and reviews would be appreciated.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
