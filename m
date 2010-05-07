Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 66CB86200B2
	for <linux-mm@kvack.org>; Fri,  7 May 2010 05:16:54 -0400 (EDT)
Date: Fri, 7 May 2010 10:16:31 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/2] mm,migration: Fix race between shift_arg_pages and
	rmap_walk by guaranteeing rmap_walk finds PTEs created within the
	temporary stack
Message-ID: <20100507091631.GA4859@csn.ul.ie>
References: <1273188053-26029-1-git-send-email-mel@csn.ul.ie> <1273188053-26029-3-git-send-email-mel@csn.ul.ie> <alpine.LFD.2.00.1005061836110.901@i5.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1005061836110.901@i5.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Thu, May 06, 2010 at 06:40:39PM -0700, Linus Torvalds wrote:
> On Fri, 7 May 2010, Mel Gorman wrote:
> > 
> > Page migration requires rmap to be able to find all migration ptes
> > created by migration. If the second rmap_walk clearing migration PTEs
> > misses an entry, it is left dangling causing a BUG_ON to trigger during
> > fault. For example;
> 
> So I still absolutely detest this patch.
> 
> Why didn't the other - much simpler - patch work? The one Rik pointed to:
> 
> 	http://lkml.org/lkml/2010/4/30/198
> 

Oh, it works, but it depends on a magic check is_vma_temporary_stack().
Kamezawa had a variant that did not depend on magic but it increased the
size of vm_area_struct. That magic check was just something that would
be easy to break and not spot hence the temporary VMA instead.

> and didn't do that _disgusting_ temporary anon_vma?
> 
> Alternatively, why don't we just take the anon_vma lock over this region, 
> so that rmap can't _walk_ the damn thing?
> 

Because move_page_tables() calls into the page allocator. I'll create a
version that allocates the PMDs in advance and see what it looks like.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
