Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 750C46B01F2
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 13:58:33 -0400 (EDT)
Date: Wed, 28 Apr 2010 19:58:22 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/3] mm,migration: Prevent rmap_walk_[anon|ksm] seeing
 the wrong VMA information
Message-ID: <20100428175822.GB510@random.random>
References: <1272403852-10479-1-git-send-email-mel@csn.ul.ie>
 <1272403852-10479-3-git-send-email-mel@csn.ul.ie>
 <20100427231007.GA510@random.random>
 <20100428091555.GB15815@csn.ul.ie>
 <20100428153525.GR510@random.random>
 <20100428155558.GI15815@csn.ul.ie>
 <20100428162305.GX510@random.random>
 <20100428173416.GJ15815@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100428173416.GJ15815@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 28, 2010 at 06:34:17PM +0100, Mel Gorman wrote:
> Well, in the easiest case, the details of the VMA (particularly vm_start
> and vm_pgoff) can confuse callers of vma_address during rmap_walk. In the
> case of migration, it will return other false positives or negatives.

false positives are fine ;). Only problems are false negatives...

> > After you fix vma_adjust to be as safe as expand_downards you've also
> > to take care of the rmap_walk that may run on a page->mapping =
> > anon_vma that isn't the vma->anon_vma and you're not taking that
> > anon_vma->lock of the shared page, when you change the vma
> > vm_pgoff/vm_start.
> 
> Is this not what the try-lock-different-vmas-or-backoff-and-retry logic
> in patch 2 is doing or am I missing something else?

yes exactly. This is why patch 2 can't be dropped, both for the
vma_adjust and the rmap_walk that are really two separate issues.

> How so? The old PTE should have been left in place, the page count of
> the page remain positive and migration not occur.

Right only problem is for remove_migration_ptes (and for both
split_huge_page rmap_walks). For migrate the only issue is the second
rmap_walk.

> Because the list could be very large, it would make more sense to
> introduce the shared lock if this is what was required.

Kind of agree, we'll see...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
