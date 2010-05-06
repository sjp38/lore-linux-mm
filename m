Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7CCA1620096
	for <linux-mm@kvack.org>; Thu,  6 May 2010 10:08:37 -0400 (EDT)
Date: Thu, 6 May 2010 07:06:08 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm,migration: Prevent rmap_walk_[anon|ksm] seeing
 the  wrong VMA information
In-Reply-To: <p2s28c262361005060247m2983625clff01aeaa1668402f@mail.gmail.com>
Message-ID: <alpine.LFD.2.00.1005060703540.901@i5.linux-foundation.org>
References: <1273065281-13334-1-git-send-email-mel@csn.ul.ie>  <1273065281-13334-2-git-send-email-mel@csn.ul.ie>  <alpine.LFD.2.00.1005050729000.5478@i5.linux-foundation.org>  <20100505145620.GP20979@csn.ul.ie>  <alpine.LFD.2.00.1005050815060.5478@i5.linux-foundation.org>
  <20100505175311.GU20979@csn.ul.ie>  <alpine.LFD.2.00.1005051058380.27218@i5.linux-foundation.org>  <20100506002255.GY20979@csn.ul.ie> <p2s28c262361005060247m2983625clff01aeaa1668402f@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>



On Thu, 6 May 2010, Minchan Kim wrote:
> > + A  A  A  A */
> > + A  A  A  avc = list_first_entry(&anon_vma->head, struct anon_vma_chain, same_anon_vma);
> 
> Dumb question.
> 
> I can't understand why we should use list_first_entry.

It's not that we "should" use list_entry_first. It's that we want to find 
_any_ entry on the list, and the most natural one is the first one.

So we could take absolutely any 'avc' entry that is reachable from the 
anon_vma, and use that to look up _any_ 'vma' that is associated with that 
anon_vma. And then, from _any_ of those vma's, we know how to get to the 
"root anon_vma" - the one that they are all associated with.

So no, there's absolutely nothing special about the first entry. It's 
just a random easily found one.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
