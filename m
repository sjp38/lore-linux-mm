Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 1F0FF6B0044
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 09:30:45 -0500 (EST)
Date: Fri, 18 Dec 2009 15:30:25 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 02 of 28] alter compound get_page/put_page
Message-ID: <20091218143025.GJ29790@random.random>
References: <patchbomb.1261076403@v2.random>
 <1bc7617980f2f148888e.1261076405@v2.random>
 <alpine.DEB.2.00.0912171349220.4640@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0912171349220.4640@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 17, 2009 at 01:50:10PM -0600, Christoph Lameter wrote:
> 
> Additional cachelines are dirtied in performance critical VM primitives
> now. Increases cache footprint etc.

Only slowdown added is to put_page called on compound _tail_
pages. Everything runs as fast as always on regular pages, hugetlbfs
head pages, and transparent head hugepages too the same way. The only
thing that ever calls a put_page on a compound tail page is O_DIRECT
I/O completion handler which is all but performance critical given it
is I/O dominated.

The ones that aren't I/O dominated and that don't deal with I/O DMA
(like KVM minor fault and GRU tlb miss handler), must start using mmu
notifier and stop calling gup with FOLL_GET and not ever need to call
put_page at all, so they will run faster with or without 2/28 (and
they won't screw with KSM merging [ksm can't merge if there are pins
on the pages to avoids screwing in-flight dma], and they will be
pageable).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
