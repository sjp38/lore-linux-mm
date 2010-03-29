Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1173C6B01EF
	for <linux-mm@kvack.org>; Mon, 29 Mar 2010 14:49:54 -0400 (EDT)
Received: from e35131.upc-e.chello.nl ([213.93.35.131] helo=dyad.programming.kicks-ass.net)
	by casper.infradead.org with esmtpsa (Exim 4.69 #1 (Red Hat Linux))
	id 1NwK23-0004Tz-9g
	for linux-mm@kvack.org; Mon, 29 Mar 2010 18:49:51 +0000
Subject: Re: [PATCH 36 of 41] remove PG_buddy
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <27d13ddf7c8f7ca03652.1269887869@v2.random>
References: <patchbomb.1269887833@v2.random>
	 <27d13ddf7c8f7ca03652.1269887869@v2.random>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 29 Mar 2010 20:49:44 +0200
Message-ID: <1269888584.12097.371.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Mon, 2010-03-29 at 20:37 +0200, Andrea Arcangeli wrote:
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> PG_buddy can be converted to page->_count == -1. So the PG_compound_lock can be
> added to page->flags without overflowing (because of the section bits
> increasing) with CONFIG_X86_PAE=y.

This seems to break the assumption that all free pages have a zero page
count relied upon by things like page_cache_get_speculative().

What if a page-cache pages gets freed and used as a head in the buddy
list while a concurrent lockless page-cache lookup tries to get a page
ref?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
