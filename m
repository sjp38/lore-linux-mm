Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 556316B01EE
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 21:06:45 -0400 (EDT)
Date: Wed, 28 Apr 2010 03:05:43 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 3/3] mm,migration: Remove straggling migration PTEs
 when page tables are being moved after the VMA has already moved
Message-ID: <20100428010543.GJ510@random.random>
References: <1272403852-10479-1-git-send-email-mel@csn.ul.ie>
 <1272403852-10479-4-git-send-email-mel@csn.ul.ie>
 <20100427223004.GF8860@random.random>
 <20100427225852.GH8860@random.random>
 <20100428093948.c4e6faa1.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100428093948.c4e6faa1.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 28, 2010 at 09:39:48AM +0900, KAMEZAWA Hiroyuki wrote:
> Seems nice.

What did you mean with objrmap inconsistency? I think this is single
threaded there, userland didn't run yet and I don't think page faults
could run. Maybe it's safer to add a VM_BUG_ON(vma->anon_vma) just
before vma->anon_vma = anon_vma to be sure nothing run in between.

> I'll test this but I think we need to take care of do_mremap(), too.
> And it's more complicated....

do_mremap has to be safe by:

1) adjusting page->index atomically with the pte updates inside pt
   lock (while it moves from one pte to another)

2) having both vmas src and dst (not overlapping) indexed in the
   proper anon_vmas before move_page_table runs

As long as it's not overlapping it shouldn't be difficult to enforce
the above two invariants, exec.c is magic as it works on overlapping
areas and src and dst are the same vma and it's indexed into just one
anon-vma. So we've to stop the rmap_walks before we mangle over the
vma with vma_adjust and move_page_tables and truncate the end of the
vma with vma_adjust again, and finally we resume the rmap_walks.

I'm not entirely sure of the above so review greatly appreciated ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
