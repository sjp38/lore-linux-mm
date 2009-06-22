Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id BD58D6B004D
	for <linux-mm@kvack.org>; Mon, 22 Jun 2009 03:42:04 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5M7hLN9008566
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 22 Jun 2009 16:43:22 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4ABCF45DE51
	for <linux-mm@kvack.org>; Mon, 22 Jun 2009 16:43:21 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1AB0245DE4F
	for <linux-mm@kvack.org>; Mon, 22 Jun 2009 16:43:21 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E0D4EE08002
	for <linux-mm@kvack.org>; Mon, 22 Jun 2009 16:43:20 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 85F521DB803E
	for <linux-mm@kvack.org>; Mon, 22 Jun 2009 16:43:20 +0900 (JST)
Date: Mon, 22 Jun 2009 16:41:47 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Performance degradation seen after using one list for hot/cold
 pages.
Message-Id: <20090622164147.720683f8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <70875432E21A4185AD2E007941B6A792@sisodomain.com>
References: <70875432E21A4185AD2E007941B6A792@sisodomain.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Narayanan Gopalakrishnan <narayanan.g@samsung.com>
Cc: linux-mm@kvack.org, mel@csn.ul.ie, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 22 Jun 2009 11:20:14 +0530
Narayanan Gopalakrishnan <narayanan.g@samsung.com> wrote:

> Hi,
> 
> We are facing a performance degradation of 2 MBps in kernels 2.6.25 and
> above.
> We were able to zero on the fact that the exact patch that has affected us
> is this
> (http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdi
> ff;h=3dfa5721f12c3d5a441448086bee156887daa961), that changes to have one
> list for hot/cold pages. 
> 
> We see the at the block driver the pages we get are not contiguous hence the
> number of LLD requests we are making have increased which is the cause of
> this problem.
> 
> The page allocation in our case is called from aio_read and hence it always
> calls page_cache_alloc_cold(mapping) from readahead.
> 
> We have found a hack for this that is, removing the __GFP_COLD macro when
> __page_cache_alloc()is called helps us to regain the performance as we see
> contiguous pages in block driver.
> 
> Has anyone faced this problem or can give a possible solution for this?
> 
> Our target is OMAP2430 custom board with 128MB RAM.
> 
Added some CCs.

My understanding is this: 

Assume A,B,C,D are pfn of continuous pages. (B=A+1, C=A+2, D=A+3)

1) When there are 2 lists for hot and cold pages, pcp list is constracted in
   following order after rmqueue_bulk().

   pcp_list[cold] (next) <-> A <-> B <-> C <-> D <-(prev) pcp_list[cold]

   The pages are drained from "next" and pages were given in sequence of
   A, B, C, D...

2) Now, pcp list is constracted as following after  rmqueue_bulk()

	pcp_list (next) <-> A <-> B <-> C <-> D <-> (prev) pcp_list

   When __GFP_COLD, the page is drained via "prev" and sequence of given pages
   is D,C,B,A...

   Then, removing __GFP_COLD allows you to allocate pages in sequence of
   A, B, C, D.

Looking into page_alloc.c::rmqueue_bulk(),
 871     /*
 872      * Split buddy pages returned by expand() are received here
 873      * in physical page order. The page is added to the callers and
 874      * list and the list head then moves forward. From the callers
 875      * perspective, the linked list is ordered by page number in
 876      * some conditions. This is useful for IO devices that can
 877      * merge IO requests if the physical pages are ordered
 878      * properly.
 879      */

Order of pfn is taken into account but doesn't work well for __GFP_COLD
allocation. (works well for not __GFP_COLD allocation.)
Using 2 lists again or modify current behavior ?

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
