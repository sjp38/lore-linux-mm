Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id A79AA6B00F3
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 15:28:00 -0400 (EDT)
Date: Wed, 12 Sep 2012 12:27:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/3 v2] mm: Batch page reclamation under shink_page_list
Message-Id: <20120912122758.ad15e10f.akpm@linux-foundation.org>
In-Reply-To: <1347293960.9977.70.camel@schen9-DESK>
References: <1347293960.9977.70.camel@schen9-DESK>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.cz>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Paul Gortmaker <paul.gortmaker@windriver.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Alex Shi <alex.shi@intel.com>, Fengguang Wu <fengguang.wu@intel.com>

On Mon, 10 Sep 2012 09:19:20 -0700
Tim Chen <tim.c.chen@linux.intel.com> wrote:

> This is the second version of the patch series. Thanks to Matthew Wilcox 
> for many valuable suggestions on improving the patches.
> 
> To do page reclamation in shrink_page_list function, there are two
> locks taken on a page by page basis.  One is the tree lock protecting
> the radix tree of the page mapping and the other is the
> mapping->i_mmap_mutex protecting the mapped
> pages.  I try to batch the operations on pages sharing the same lock
> to reduce lock contentions.  The first patch batch the operations protected by
> tree lock while the second and third patch batch the operations protected by 
> the i_mmap_mutex.
> 
> I managed to get 14% throughput improvement when with a workload putting
> heavy pressure of page cache by reading many large mmaped files
> simultaneously on a 8 socket Westmere server.

That sounds good, although more details on the performance changes
would be appreciated - after all, that's the entire point of the
patchset.

And we shouldn't only test for improvements - we should also test for
degradation.  What workloads might be harmed by this change?  I'd suggest

- a single process which opens N files and reads one page from each
  one, then repeats.  So there are no contiguous LRU pages which share
  the same ->mapping.  Get some page reclaim happening, measure the
  impact.

- The batching means that we now do multiple passes over pageframes
  where we used to do things in a single pass.  Walking all those new
  page lists will be expensive if they are lengthy enough to cause L1
  cache evictions.

  What would be a test for this?  A simple, single-threaded walk
  through a file, I guess?

Mel's review comments were useful, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
