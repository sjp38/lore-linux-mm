Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7CC946B00E7
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 06:45:19 -0500 (EST)
Date: Tue, 11 Jan 2011 11:44:54 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] mm: fix migration hangs on anon_vma lock
Message-ID: <20110111114453.GC11932@csn.ul.ie>
References: <alpine.LSU.2.00.1101102259160.24988@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1101102259160.24988@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 10, 2011 at 11:08:04PM -0800, Hugh Dickins wrote:
> Increased usage of page migration in mmotm reveals that the anon_vma
> locking in unmap_and_move() has been deficient since 2.6.36 (or even
> earlier). 

Hmm, a certain amount of the compaction work was spent fixing migration
bugs. I wonder if there are mysterious bug reports out there related to the
use of move_pages() that are only getting fixed now.

> Review at the time of f18194275c39835cb84563500995e0d503a32d9a
> "mm: fix hang on anon_vma->root->lock" missed the issue here: the anon_vma
> to which we get a reference may already have been freed back to its slab
> (it is in use when we check page_mapped, but that can change), and so its
> anon_vma->root may be switched at any moment by reuse in anon_vma_prepare.
> 
> Perhaps we could fix that with a get_anon_vma_unless_zero(), but let's not:
> just rely on page_lock_anon_vma() to do all the hard thinking for us, then
> we don't need any rcu read locking over here.
> 
> In removing the rcu_unlock label: since PageAnon is a bit in page->mapping,
> it's impossible for a !page->mapping page to be anon; but insert VM_BUG_ON
> in case the implementation ever changes.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Cc: stable@kernel.org [2.6.37, 2.6.36]

Reasoning and patch look correct. Light testing did not show up any
obvious problems.

Reviewed-by: Mel Gorman <mel@csn.ul.ie>

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
