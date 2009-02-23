Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 7016B6B007E
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 04:37:45 -0500 (EST)
Date: Mon, 23 Feb 2009 01:37:23 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 20/20] Get rid of the concept of hot/cold page freeing
Message-Id: <20090223013723.1d8f11c1.akpm@linux-foundation.org>
In-Reply-To: <1235344649-18265-21-git-send-email-mel@csn.ul.ie>
References: <1235344649-18265-1-git-send-email-mel@csn.ul.ie>
	<1235344649-18265-21-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Sun, 22 Feb 2009 23:17:29 +0000 Mel Gorman <mel@csn.ul.ie> wrote:

> Currently an effort is made to determine if a page is hot or cold when
> it is being freed so that cache hot pages can be allocated to callers if
> possible. However, the reasoning used whether to mark something hot or
> cold is a bit spurious. A profile run of kernbench showed that "cold"
> pages were never freed so it either doesn't happen generally or is so
> rare, it's barely measurable.
> 
> It's dubious as to whether pages are being correctly marked hot and cold
> anyway. Things like page cache and pages being truncated are are considered
> "hot" but there is no guarantee that these pages have been recently used
> and are cache hot. Pages being reclaimed from the LRU are considered
> cold which is logical because they cannot have been referenced recently
> but if the system is reclaiming pages, then we have entered allocator
> slowpaths and are not going to notice any potential performance boost
> because a "hot" page was freed.
> 
> This patch just deletes the concept of freeing hot or cold pages and
> just frees them all as hot.
> 

Well yes.  We waffled for months over whether to merge that code originally.

What tipped the balance was a dopey microbenchmark which I wrote which
sat in a loop extending (via write()) and then truncating the same file
by 32 kbytes (or thereabouts).  Its performance was increased by a lot
(2x or more, iirc) and no actual regressions were demonstrable, so we
merged it.

Could you check that please?  I'd suggest trying various values of 32k,
too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
