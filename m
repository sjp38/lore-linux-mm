Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 476186B0044
	for <linux-mm@kvack.org>; Sat, 19 Dec 2009 10:21:14 -0500 (EST)
Date: Sat, 19 Dec 2009 16:20:30 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00 of 28] Transparent Hugepage support #2
Message-ID: <20091219152030.GX29790@random.random>
References: <patchbomb.1261076403@v2.random>
 <1261162049.27372.1649.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1261162049.27372.1649.camel@nimitz>
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Dec 18, 2009 at 10:47:29AM -0800, Dave Hansen wrote:
> For what it's worth, I went trying to do some of this a few months ago
> to see how feasible it was.  I ended up doing a bunch of the same stuff
> like having the preallocated pte_page() hanging off the mm.  I think I
> tied directly into the pte_offset_*() functions instead of introducing
> new ones, but the concept was the same: as much as possible *don't*
> teach the VM about huge pages, split them.

Obviously I agree ;). At the same time I also agree with Christoph
about the long term: in the future we want more and more code paths to
be hugepage aware, and even swap in 2M chunks but I think those things
should happen incrementally over time, just like the kernel didn't
become multithreaded overnight. And if one uses "echo madvise
>enabled" one can already make sure 99% to never run into
split_huge_page (actually 100% sure after swapoff -a), so this greatly
simplified approach already provides 100% of the benefit for example
to KVM hypervisor, where NTP/EPT definitely require hugepages. On host
hugepages are a significant but not so mandatory improvement and in
turn only very few apps get through the pain of using hugetlbfs API or
libhugetlbfs, but NPT/EPT explodes the benefit and makes it a
requirement to use _always_ and to make sure all guest physical pages
are mapped with NPT/EPT pmds.

> I ended up getting hung up on some of the PMD locking, and I think using
> the PMD bit like that is a fine solution.  The way these are split up
> also looks good to me.

Yep, please review if it's ok the page remains mapped in userland
during the split (see __split_huge_page_splitting). In previous
patchset I cleared the present bit in the pmd (which provided the same
information as no pmd could ever be not present and not null
before). But that stopped userland accesses as well during the split,
which Avi said is not required and I agreed.

> Except for some of the stuff in put_compound_page(), these look pretty
> sane to me in general.  I'll go through them in more detail after the
> holidays.

Thanks a lot!!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
