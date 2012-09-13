Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 099606B015B
	for <linux-mm@kvack.org>; Thu, 13 Sep 2012 12:06:11 -0400 (EDT)
Subject: Re: [PATCH 1/3 v2] mm: Batch unmapping of file mapped pages in
 shrink_page_list
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <20120911110535.GO11157@csn.ul.ie>
References: <1347293965.9977.71.camel@schen9-DESK>
	 <20120911110535.GO11157@csn.ul.ie>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 13 Sep 2012 09:06:10 -0700
Message-ID: <1347552370.9977.99.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.cz>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Paul Gortmaker <paul.gortmaker@windriver.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Alex Shi <alex.shi@intel.com>, Matthew Wilcox <willy@linux.intel.com>, Fengguang Wu <fengguang.wu@intel.com>

On Tue, 2012-09-11 at 12:05 +0100, Mel Gorman wrote:

> 
> One *massive* change here that is not called out in the changelog is that
> the reclaim path now holds the page lock on multiple pages at the same
> time waiting for them to be batch unlocked in __remove_mapping_batch.
> This is suspicious for two reasons.
> 
> The first suspicion is that it is expected that there are filesystems
> that lock multiple pages in page->index order and page reclaim tries to
> lock pages in a random order.  You are "ok" because you trylock the pages
> but there should be a comment explaining the situation and why you're
> ok.
> 
> My *far* greater concern is that the hold time for a locked page is
> now potentially much longer. You could lock a bunch of filesystem pages
> and then call pageout() on an swapcache page that takes a long time to
> write. This potentially causes a filesystem (or flusher threads etc)
> to stall on lock_page and that could cause all sorts of latency trouble.
> It will be hard to hit this bug and diagnose it but I believe it's
> there.
> 
> That second risk *really* must be commented upon and ideally reviewed by
> the filesystem people. However, I very strongly suspect that the outcome
> of such a review will be a suggestion to unlock the pages and reacquire
> the lock in __remove_mapping_batch(). Bear in mind that if you take this
> approach that you *must* use trylock when reacquiring the page lock and
> handle being unable to lock the page.
> 

Mel,

Thanks for your detailed comments and analysis.  If I unlock the pages,
will flusher threads be the only things that will touch them?  Or do I
have to worry about potentially other things done to the pages that will
make it invalid for me to unmap the pages later and put them on free
list?

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
