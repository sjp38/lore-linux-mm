Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C01746B0044
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 09:07:11 -0500 (EST)
Date: Fri, 18 Dec 2009 15:05:30 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00 of 28] Transparent Hugepage support #2
Message-ID: <20091218140530.GE29790@random.random>
References: <patchbomb.1261076403@v2.random>
 <alpine.DEB.2.00.0912171352330.4640@router.home>
 <4B2A8D83.30305@redhat.com>
 <alpine.DEB.2.00.0912171402550.4640@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0912171402550.4640@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 17, 2009 at 02:09:47PM -0600, Christoph Lameter wrote:
> Can we do this step by step? This splitting thing and its
> associated overhead causes me concerns.

The split_huge_page* functionality whole point is exactly to do things
step by step. Removing it would mean doing it all at once.

This is like the big kernel lock when SMP initially was
introduced. Surely kernel would have been a little faster if the big
kernel lock was never introduced but over time the split_huge_page can
be removed just like the big kernel lock has been removed. Then the
PG_compound_lock can go away too.

> Frankly I am not sure that there is a problem. The word swap is mostly
> synonymous with "problem". Huge pages are good. I dont think one
> needs to necessarily associate something good (huge page) with a known
> problem (swap) otherwise the whole may not improve.

Others already answered extensively on why it is needed. Also look at
Hugh's effort to make KSM pages swappable.

Plus locking the huge pages in ram wouldn't actually remove the need
of split_huge_page for all other places in the VM that aren't hugepage
aware yet and where there is no urgency to make them swap aware
either. NOTE: especially after "echo madvise >
/sys/kernel/mm/transparent_hugepage/enabled" the risk of overhead
caused by split_huge_page is exactly zero! (well unless you swap but
at that point you're generally I/O bound or the locking on anon_vma
lock is surely bigger scalability concern than the CPU cost of
splitting, with or without split_huge_page) Also for hugetlbfs the
overhead caused by the PG_compound_lock taken on tail pages is zero
for anything but O_DIRECT, O_DIRECT is the only thing that can call
put_page on tail pages. Everything else only work with head pages and
with head pages there is zero slowdown caused by the
PG_compound_lock. This is true for transparent hugepages too in fact,
and O_DIRECT is I/O bound so the PG_compound_lock shouldn't be a big
issue given it is a per-compound-page lock and so fully
scalable. In the future mmu notifier users that calls gup will stop
using FOLL_GET and in turn they will stop calling put_page, so
eliminating any need to take the PG_compound_lock in all KVM fast paths.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
