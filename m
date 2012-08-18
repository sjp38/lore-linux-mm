Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id C556C6B0070
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 21:06:46 -0400 (EDT)
Subject: [RFC PATCH 0/2] mm: Batch page reclamation under shink_page_list
From: Tim Chen <tim.c.chen@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 17 Aug 2012 18:06:30 -0700
Message-ID: <1345251990.13492.233.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Alex Shi <alex.shi@intel.com>

To do page reclamation in shrink_page_list function, there are two
locks taken on a page by page basis.  One is the tree lock protecting
the radix tree of the page mapping and the other is the
mapping->i_mmap_mutex protecting the reverse mapping of file maped
pages.  I tried to batch the operations on pages sharing the same lock
to reduce lock contentions.  The first patch batch the operations under
tree lock while the second one batch the checking of file page
references under the i_mmap_mutex.

I managed to get 14% throughput improvement when with a workload putting
heavy pressure of page cache by reading many large mmaped files
simultaneously on a 8 socket Westmere server.

There are some ugly hacks in the patches to pass information about
whether the i_mmap_mutex is locked.  Any suggestions on a better
approach and reviews of the patches are appreciated.

Tim

Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
---
Diffstat

include/linux/rmap.h |    6 +-
mm/memory-failure.c  |    2 +-
mm/migrate.c         |    4 +-
mm/rmap.c            |   28 ++++++----
mm/vmscan.c          |  139 +++++++++++++++++++++++++++++++++++++++++++++-----
5 files changed, 147 insertions(+), 32 deletions(-)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
