Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 691396B01F2
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 11:16:35 -0400 (EDT)
Date: Wed, 28 Apr 2010 17:16:14 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 0/3] Fix migration races in rmap_walk() V2
Message-ID: <20100428151614.GQ510@random.random>
References: <1272403852-10479-1-git-send-email-mel@csn.ul.ie>
 <alpine.DEB.2.00.1004271723090.24133@router.home>
 <20100427223242.GG8860@random.random>
 <20100428091345.496ca4c4.kamezawa.hiroyu@jp.fujitsu.com>
 <20100428002056.GH510@random.random>
 <20100428142356.GF15815@csn.ul.ie>
 <20100428145737.GG15815@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100428145737.GG15815@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 28, 2010 at 03:57:38PM +0100, Mel Gorman wrote:
> On Wed, Apr 28, 2010 at 03:23:56PM +0100, Mel Gorman wrote:
> > On Wed, Apr 28, 2010 at 02:20:56AM +0200, Andrea Arcangeli wrote:
> > > On Wed, Apr 28, 2010 at 09:13:45AM +0900, KAMEZAWA Hiroyuki wrote:
> > > > Doing some check in move_ptes() after vma_adjust() is not safe.
> > > > IOW, when vma's information and information in page-table is incosistent...objrmap
> > > > is broken and migartion will cause panic.
> > > > 
> > > > Then...I think there are 2 ways.
> > > >   1. use seqcounter in "mm_struct" as previous patch and lock it at mremap.
> > > > or
> > > >   2. get_user_pages_fast() when do remap.
> > > 
> > > 3 take the anon_vma->lock
> > > 
> > 
> > <SNIP>
> >
> > Here is a different version of the same basic idea to skip temporary VMAs
> > during migration. Maybe go with this?
> > 
> > +static bool is_vma_temporary_stack(struct vm_area_struct *vma)
> > +{
> > +	if (vma->vm_flags != VM_STACK_FLAGS)
> > +		return false;
> > +
> > +	/*
> > +	 * Only during exec will the total VM consumed by a process
> > +	 * be exacly the same as the stack
> > +	 */
> > +	if (vma->vm_mm->stack_vm == 1 && vma->vm_mm->total_vm == 1)
> > +		return true;
> > +
> > +	return false;
> > +}
> > +
> 
> The assumptions on the vm flags is of course totally wrong. VM_EXEC might
> be applied as well as default flags from the mm.  The following is the same
> basic idea, skip VMAs belonging to processes in exec rather than trying
> to hold anon_vma->lock across move_page_tables(). Not tested yet.

This is better than the other, that made it look like people could set
broken rmap at arbitrary times, at least this shows it's ok only
during execve before anything run, but if we can't take the anon-vma
lock really better than having to make these special checks inside
every rmap_walk that has to be accurate, we should just delay the
linkage of the stack vma into its anon-vma, until after the move_pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
