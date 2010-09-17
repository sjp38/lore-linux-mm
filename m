Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 46C336B0078
	for <linux-mm@kvack.org>; Fri, 17 Sep 2010 01:52:44 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8H5qeNU005174
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 17 Sep 2010 14:52:40 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 41F6E45DE51
	for <linux-mm@kvack.org>; Fri, 17 Sep 2010 14:52:40 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1D01C45DE4F
	for <linux-mm@kvack.org>; Fri, 17 Sep 2010 14:52:40 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 05C8CE18001
	for <linux-mm@kvack.org>; Fri, 17 Sep 2010 14:52:40 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id B50E8E08001
	for <linux-mm@kvack.org>; Fri, 17 Sep 2010 14:52:39 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC]pagealloc: compensate a task for direct page reclaim
In-Reply-To: <1284636396.1726.5.camel@shli-laptop>
References: <1284636396.1726.5.camel@shli-laptop>
Message-Id: <20100917145224.3BDB.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Fri, 17 Sep 2010 14:52:39 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

> A task enters into direct page reclaim, free some memory. But sometimes
> the task can't get a free page after direct page reclaim because
> other tasks take them (this is quite common in a multi-task workload
> in my test). This behavior will bring extra latency to the task and is
> unfair. Since the task already gets penalty, we'd better give it a compensation.
> If a task frees some pages from direct page reclaim, we cache one freed page,
> and the task will get it soon. We only consider order 0 allocation, because
> it's hard to cache order > 0 page.
> 
> Below is a trace output when a task frees some pages in try_to_free_pages(), but
> get_page_from_freelist() can't get a page in direct page reclaim.
> 
> <...>-809   [004]   730.218991: __alloc_pages_nodemask: progress 147, order 0, pid 809, comm mmap_test
> <...>-806   [001]   730.237969: __alloc_pages_nodemask: progress 147, order 0, pid 806, comm mmap_test
> <...>-810   [005]   730.237971: __alloc_pages_nodemask: progress 147, order 0, pid 810, comm mmap_test
> <...>-809   [004]   730.237972: __alloc_pages_nodemask: progress 147, order 0, pid 809, comm mmap_test
> <...>-811   [006]   730.241409: __alloc_pages_nodemask: progress 147, order 0, pid 811, comm mmap_test
> <...>-809   [004]   730.241412: __alloc_pages_nodemask: progress 147, order 0, pid 809, comm mmap_test
> <...>-812   [007]   730.241435: __alloc_pages_nodemask: progress 147, order 0, pid 812, comm mmap_test
> <...>-809   [004]   730.245036: __alloc_pages_nodemask: progress 147, order 0, pid 809, comm mmap_test
> <...>-809   [004]   730.260360: __alloc_pages_nodemask: progress 147, order 0, pid 809, comm mmap_test
> <...>-805   [000]   730.260362: __alloc_pages_nodemask: progress 147, order 0, pid 805, comm mmap_test
> <...>-811   [006]   730.263877: __alloc_pages_nodemask: progress 147, order 0, pid 811, comm mmap_test

As far as I remembered, two years ago, similar patches was posted. but 
minchan found it makes performance regression when kernbench run.

http://archives.free.net.ph/message/20080905.101958.0f84e87d.ja.html



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
