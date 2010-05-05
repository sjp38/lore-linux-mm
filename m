Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 80CD962008B
	for <linux-mm@kvack.org>; Wed,  5 May 2010 11:34:20 -0400 (EDT)
Date: Wed, 5 May 2010 08:31:42 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm,migration: Prevent rmap_walk_[anon|ksm] seeing
 the wrong VMA information
In-Reply-To: <20100505145620.GP20979@csn.ul.ie>
Message-ID: <alpine.LFD.2.00.1005050815060.5478@i5.linux-foundation.org>
References: <1273065281-13334-1-git-send-email-mel@csn.ul.ie> <1273065281-13334-2-git-send-email-mel@csn.ul.ie> <alpine.LFD.2.00.1005050729000.5478@i5.linux-foundation.org> <20100505145620.GP20979@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>



On Wed, 5 May 2010, Mel Gorman wrote:
> 
> rmap_walk() appears to be the only one that takes multiple locks but it itself
> is not serialised. If there are more than one process calling rmap_walk()
> on different processes sharing the same VMAs, is there a guarantee they walk
> it in the same order?

So I had this notion of the list always getting deeper and us guaranteeing 
the order in it, but you're right - that's not the 'same_anon_vma' list, 
it's the 'same_vma' one.

Damn. So yeah, I don't see us guaranteeing any ordering guarantees. My 
bad.

That said, I do wonder if we could _make_ the ordering reliable. I did 
that for the 'same_vma' one, because I wanted to be able to verify that 
chains were consistent (and we also needed to be able to find the "oldest 
anon_vma" for the case of re-instantiating pages that migth exist in 
multiple different anon_vma's).

Any ideas?

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
