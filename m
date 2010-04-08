Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 85C94600337
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 11:33:09 -0400 (EDT)
Date: Thu, 8 Apr 2010 10:32:11 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 00 of 67] Transparent Hugepage Support #18
In-Reply-To: <20100408152302.GA5749@random.random>
Message-ID: <alpine.DEB.2.00.1004081030440.6321@router.home>
References: <patchbomb.1270691443@v2.random> <4BBDA43F.5030309@redhat.com> <4BBDC181.5040205@redhat.com> <20100408152302.GA5749@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Avi Kivity <avi@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 8 Apr 2010, Andrea Arcangeli wrote:

> Hopefully memory compaction or migration will be fixed soon enough.

Here are my earlier comments on this issue:


On Thu, 8 Apr 2010, Andrea Arcangeli wrote:

> Since I merged memory compaction things become very unstable.
>
> This is one debug info I collected. It crashes in
> migration_entry_to_page() here:
>
> BUG_ON(!PageLocked(p));
>
> because p == ffffea06ac000000 and segfaults in reading p->flags inside
> Pagelocked.

This means that migration_entry_to_page was passed an invalid pointer.
Note that remove_migration_ptes walks the page table. There is no current
code that deals with 2M pages in the walker.

> Please help to fix this, this is by far the highest priority at the
> moment and it has nothing to do with transparent hugepages, it's
> either a memory compaction or migration proper bug.

If the page table contains proper values then this should not occur unless
there is a now a 2M special case added.

The entry that is passed to migration_entry_to_page() is obtained from the
page table pte via pte_to_swp_entry().

> Apr  8 08:02:57 v2 kernel: [<ffffffff810dc5a0>] ? remove_migration_pte+0x0/0x240
> Apr  8 08:02:57 v2 kernel: [<ffffffff810ca155>] ? rmap_walk+0x135/0x180
> Apr  8 08:02:57 v2 kernel: [<ffffffff810dcbe9>] ? migrate_page_copy+0xe9/0x190

Stack dump messed up? migrate_page_copy should not call any pte functions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
