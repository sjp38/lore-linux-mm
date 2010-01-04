Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id B15FB600068
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 10:50:35 -0500 (EST)
Date: Mon, 4 Jan 2010 16:49:37 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 25 of 28] transparent hugepage core
Message-ID: <20100104154937.GD17401@random.random>
References: <patchbomb.1261076403@v2.random>
 <4d96699c8fb89a4a22eb.1261076428@v2.random>
 <20091218200345.GH21194@csn.ul.ie>
 <20091219164143.GC29790@random.random>
 <20091221203149.GD23345@csn.ul.ie>
 <20091223000640.GI6429@random.random>
 <20100103183802.GA11420@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100103183802.GA11420@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, Paul Mundt <lethal@linux-sh.org>
List-ID: <linux-mm.kvack.org>

On Sun, Jan 03, 2010 at 06:38:03PM +0000, Mel Gorman wrote:
> HPAGE_PMD_SIZE is better

Ok I converted the whole patchset after adding:

#define HPAGE_PMD_SHIFT HPAGE_SHIFT
#define HPAGE_PMD_MASK HPAGE_MASK
#define HPAGE_PMD_SIZE HPAGE_SIZE

to huge_mm.h.

> Ok, if it is a case that the huge pages get demoted and migrated, then
> the use of GFP_HIGHUSER_MOVABLE is not a problem.

Yes they're identical to regular pages, this is the whole point of
transparency. So I'll keep only MOVABLE.

> There is no benefit in turning of the gfp movable flag. The presense of

Agreed.

> I prototyped memory deframentation ages ago. It worked for the most case
> but has bit-rotted significantly. I really should dig it out from
> whatever hole I left it in.

You really should. Luckily despite the code move heavily the internal
design is about to identical, so you will have to rewrite but
algorithms won't need to change substantially, except to handle all
those new features and more tedious accounting than before.

Marcelo also had a patch in defrag area. Also khugepaged is now defrag
unaware, that means it will only wait on new hugepages to be added to
the freelist. But it won't create it itself. That should change but
until there's no real defrag algorithm I don't want to waste cpu in a
not-targeted way.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
