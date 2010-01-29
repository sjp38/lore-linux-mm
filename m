Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 4ABB16B0083
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 19:02:28 -0500 (EST)
Date: Fri, 29 Jan 2010 01:00:04 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 25 of 31] transparent hugepage core
Message-ID: <20100129000004.GR1217@random.random>
References: <patchbomb.1264689194@v2.random>
 <ac9bbf9e2c95840eb237.1264689219@v2.random>
 <20100128175753.GF7139@csn.ul.ie>
 <20100128223653.GL1217@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100128223653.GL1217@random.random>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <hch@infradead.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 28, 2010 at 11:36:53PM +0100, Andrea Arcangeli wrote:
> able to split it anyway. Maybe we can chance it so that a hugepage is
> always guaranteed to have PageLRU set, but split_huge_page has to take

The most important benefit of not having enforced that guarantee, is
that young bits will be checked on isolated pages (so with pagelru not
set), when they are still mapped by pmd_trans_huge pmd. This way qemu
pte side, and kvm spte side will both always keep using hugetlb and
pmd_trans_huge in pmd/spmd (as long as at least one between the pmds
and spmds has the young bit set).

Like said to Robin in a different thread, it may not be necessary to
call pmdp_flush_splitting_notify, pmdp_flush_splitting may be enough
if the mmu notifier users learn that if they map a spmd with PSE set
they may also get an invalidate at a later time when the page has no
pagehead/tail/compound set anymore. Current way is conceptually
simpler and less risky because by the time we clear pagetail/compound
in split_huge_page_refcount the secondary mapping is gone just after
the primary mapping (ksm minor fault will wait for splitting bit to go
away like any other regular page fault from other threads).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
