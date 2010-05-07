Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 054CF6B0225
	for <linux-mm@kvack.org>; Thu,  6 May 2010 21:43:41 -0400 (EDT)
Date: Thu, 6 May 2010 18:40:39 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 2/2] mm,migration: Fix race between shift_arg_pages and
 rmap_walk by guaranteeing rmap_walk finds PTEs created within the temporary
 stack
In-Reply-To: <1273188053-26029-3-git-send-email-mel@csn.ul.ie>
Message-ID: <alpine.LFD.2.00.1005061836110.901@i5.linux-foundation.org>
References: <1273188053-26029-1-git-send-email-mel@csn.ul.ie> <1273188053-26029-3-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>



On Fri, 7 May 2010, Mel Gorman wrote:
> 
> Page migration requires rmap to be able to find all migration ptes
> created by migration. If the second rmap_walk clearing migration PTEs
> misses an entry, it is left dangling causing a BUG_ON to trigger during
> fault. For example;

So I still absolutely detest this patch.

Why didn't the other - much simpler - patch work? The one Rik pointed to:

	http://lkml.org/lkml/2010/4/30/198

and didn't do that _disgusting_ temporary anon_vma?

Alternatively, why don't we just take the anon_vma lock over this region, 
so that rmap can't _walk_ the damn thing?

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
