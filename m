Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 45F776B0047
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 13:44:48 -0500 (EST)
Date: Wed, 27 Jan 2010 19:43:44 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 22 of 31] split_huge_page paging
Message-ID: <20100127184344.GG12736@random.random>
References: <patchbomb.1264513915@v2.random>
 <3e6e5d853907eafd664a.1264513937@v2.random>
 <4B5F2E52.2080608@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4B5F2E52.2080608@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <chellwig@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 26, 2010 at 01:02:58PM -0500, Rik van Riel wrote:
> Shouldn't we split up these pages in vmscan.c, before calling
> add_to_swap() ?

In theory it would work, but for khugepaged to be safe, I'm relying on
either mmap_sem write mode, or PG_lock taken, so split_huge_page has
to run either with mmap_sem read/write mode or PG_lock taken. Calling
it from isolate_lru_page would make locking more complicated, in
addition to that split_huge_page would deadlock if called by
__isolate_lru_page because it has to take the lru lock to add the tail
pages to the lru and I didn't want to risk with a __split_huge_page
variant that works while holding lru_lock.

I'll add the above to patch comment.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
