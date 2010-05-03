Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id DED1C6007B8
	for <linux-mm@kvack.org>; Mon,  3 May 2010 13:19:09 -0400 (EDT)
Date: Mon, 3 May 2010 19:18:37 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/2] mm: Take all anon_vma locks in anon_vma_lock
Message-ID: <20100503171837.GG19891@random.random>
References: <20100503121743.653e5ecc@annuminas.surriel.com>
 <20100503121847.7997d280@annuminas.surriel.com>
 <1272905712.1642.150.camel@laptop>
 <20100503170230.GF19891@random.random>
 <1272906679.1642.152.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1272906679.1642.152.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Rik van Riel <riel@redhat.com>, akpm@linux-foundation.org, torvalds@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>
List-ID: <linux-mm.kvack.org>

On Mon, May 03, 2010 at 07:11:19PM +0200, Peter Zijlstra wrote:
> On Mon, 2010-05-03 at 19:02 +0200, Andrea Arcangeli wrote:
> > On Mon, May 03, 2010 at 06:55:12PM +0200, Peter Zijlstra wrote:
> > > This does leave me worrying about concurrent faults poking at
> > > vma->vm_end without synchronization.
> > 
> > I didn't check this patch in detail yet. I agree it can be removed and
> > I think it can be safely replaced with the page_table_lock.
> 
> Sure, it could probably be replaced with the ptl, but a single
> anon_vma->lock would I think be better since there's more of them.

ptl not enough, or it'd break if stack grows fast more than the size
of one pmd, page_table_lock enough instead.

Keeping anon_vma lock is sure fine with me ;), I was informally asked
if it was a must have, and I couldn't foresee any problem in
_replacing_ it (not removing) with page_table_lock (which I hope I
mentioned in my answer ;). But I never had an interest to remove it,
just I couldn't find any good reason to keep it either other than
"paranoid just in case", which is good enough justification to me ;)
considering these archs are uncommon and by definition gets less
testing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
