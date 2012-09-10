Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id E36D96B006C
	for <linux-mm@kvack.org>; Mon, 10 Sep 2012 12:19:21 -0400 (EDT)
Subject: [PATCH 0/3 v2] mm: Batch page reclamation under shink_page_list
From: Tim Chen <tim.c.chen@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 10 Sep 2012 09:19:20 -0700
Message-ID: <1347293960.9977.70.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.cz>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Paul Gortmaker <paul.gortmaker@windriver.com>
Cc: Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Alex Shi <alex.shi@intel.com>, Fengguang Wu <fengguang.wu@intel.com>

This is the second version of the patch series. Thanks to Matthew Wilcox 
for many valuable suggestions on improving the patches.

To do page reclamation in shrink_page_list function, there are two
locks taken on a page by page basis.  One is the tree lock protecting
the radix tree of the page mapping and the other is the
mapping->i_mmap_mutex protecting the mapped
pages.  I try to batch the operations on pages sharing the same lock
to reduce lock contentions.  The first patch batch the operations protected by
tree lock while the second and third patch batch the operations protected by 
the i_mmap_mutex.

I managed to get 14% throughput improvement when with a workload putting
heavy pressure of page cache by reading many large mmaped files
simultaneously on a 8 socket Westmere server.

Tim

Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
---
Diffstat 

 include/linux/rmap.h |    8 +++-
 mm/rmap.c            |  110 ++++++++++++++++++++++++++++++++++---------------
 mm/vmscan.c          |  113 +++++++++++++++++++++++++++++++++++++++++++++-----
 3 files changed, 185 insertions(+), 46 deletions(-)
















--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
