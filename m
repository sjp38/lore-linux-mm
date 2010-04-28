Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id DFEF46B01F4
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 16:41:12 -0400 (EDT)
Date: Wed, 28 Apr 2010 22:40:43 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 0/3] Fix migration races in rmap_walk() V2
Message-ID: <20100428204043.GF510@random.random>
References: <1272403852-10479-1-git-send-email-mel@csn.ul.ie>
 <alpine.DEB.2.00.1004271723090.24133@router.home>
 <20100427223242.GG8860@random.random>
 <20100428091345.496ca4c4.kamezawa.hiroyu@jp.fujitsu.com>
 <20100428002056.GH510@random.random>
 <20100428142356.GF15815@csn.ul.ie>
 <20100428145737.GG15815@csn.ul.ie>
 <20100428151614.GQ510@random.random>
 <20100428152354.GH15815@csn.ul.ie>
 <20100428154508.GT510@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100428154508.GT510@random.random>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 28, 2010 at 05:45:08PM +0200, Andrea Arcangeli wrote:
> On Wed, Apr 28, 2010 at 04:23:54PM +0100, Mel Gorman wrote:
> > Is it possible to delay the linkage like that? As arguments get copied into
> > the temporary stack before it gets moved, I'd have expected the normal fault
> > path to prepare and attach the anon_vma. We could special case it but
> > that isn't very palatable either.
> 
> I'm not sure what is more palatable, but I feel it should be fixed in
> execve.

Ok the best idea so far I had is to add a fake temporary fake vma to
the anon_vma list with the old vm_start and same vm_pgoff before
shifting down vma->vm_start and calling move_page_tables. Then after
the move is complete we remove the fake vma. So all the fast paths
will remain unmodified and no magic is required. I'll try to fix this
for the old stable anon-vma code and test in aa.git first as the code
will differ. If it works ok anybody can port it to new anon-vma code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
