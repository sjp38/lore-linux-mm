Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 73F196B01EE
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 11:16:27 -0400 (EDT)
Date: Wed, 28 Apr 2010 16:46:26 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 3/3] mm,migration: Remove straggling migration PTEs
 when page tables are being moved after the VMA has already moved
Message-ID: <20100428144626.GP510@random.random>
References: <1272403852-10479-1-git-send-email-mel@csn.ul.ie>
 <1272403852-10479-4-git-send-email-mel@csn.ul.ie>
 <20100428173054.7b6716cf.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100428173054.7b6716cf.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 28, 2010 at 05:30:54PM +0900, KAMEZAWA Hiroyuki wrote:
> On Tue, 27 Apr 2010 22:30:52 +0100
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > During exec(), a temporary stack is setup and moved later to its final
> > location. There is a race between migration and exec whereby a migration
> > PTE can be placed in the temporary stack. When this VMA is moved under the
> > lock, migration no longer knows where the PTE is, fails to remove the PTE
> > and the migration PTE gets copied to the new location.  This later causes
> > a bug when the migration PTE is discovered but the page is not locked.
> > 
> > This patch handles the situation by removing the migration PTE when page
> > tables are being moved in case migration fails to find them. The alternative
> > would require significant modification to vma_adjust() and the locks taken
> > to ensure a VMA move and page table copy is atomic with respect to migration.
> > 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> 
> Here is my final proposal (before going vacation.)
> 
> I think this is very simple. The biggest problem is when move_page_range
> fails, setup_arg_pages pass it all to exit() ;)
> 
> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> This is an band-aid patch for avoiding unmap->remap of stack pages
> while it's udner exec(). At exec, pages for stack is moved by
> setup_arg_pages(). Under this, (vma,page)<->address relationship
> can be in broken state.
> Moreover, if moving ptes fails, pages with not-valid-rmap remains
> in the page table and objrmap for the page is completely broken
> until exit() frees all up.
> 
> This patch adds vma->broken_rmap. If broken_rmap != 0, vma_address()
> returns -EFAULT always and try_to_unmap() fails.
> (IOW, the pages for stack are pinned until setup_arg_pages() ends.)
> 
> And this prevents page migration because the page's mapcount never
> goes to 0 until exec() fixes it up.

I don't get it, I don't see the pinning and returning -EFAULT is not
solution for things that cannot fail (i.e. remove_migration_ptes and
split_huge_page). Plus there's no point to return failure to rmap_walk
when we can just stop the rmap_walk with the proper lock.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
