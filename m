Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C2F146B01E3
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 05:00:14 -0400 (EDT)
Date: Tue, 27 Apr 2010 09:59:51 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/2] mm,migration: Prevent rmap_walk_[anon|ksm] seeing
	the wrong VMA information
Message-ID: <20100427085951.GB4895@csn.ul.ie>
References: <1272321478-28481-1-git-send-email-mel@csn.ul.ie> <1272321478-28481-3-git-send-email-mel@csn.ul.ie> <20100427090706.7ca68e12.kamezawa.hiroyu@jp.fujitsu.com> <20100427125040.634f56b3.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100427125040.634f56b3.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 27, 2010 at 12:50:40PM +0900, KAMEZAWA Hiroyuki wrote:
> On Tue, 27 Apr 2010 09:07:06 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Mon, 26 Apr 2010 23:37:58 +0100
> > Mel Gorman <mel@csn.ul.ie> wrote:
> > 
> > > vma_adjust() is updating anon VMA information without any locks taken.
> > > In contrast, file-backed mappings use the i_mmap_lock and this lack of
> > > locking can result in races with page migration. During rmap_walk(),
> > > vma_address() can return -EFAULT for an address that will soon be valid.
> > > This leaves a dangling migration PTE behind which can later cause a BUG_ON
> > > to trigger when the page is faulted in.
> > > 
> > > With the recent anon_vma changes, there can be more than one anon_vma->lock
> > > that can be taken in a anon_vma_chain but a second lock cannot be spinned
> > > upon in case of deadlock. Instead, the rmap walker tries to take locks of
> > > different anon_vma's. If the attempt fails, the operation is restarted.
> > > 
> > > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > 
> > Ok, acquiring vma->anon_vma->spin_lock always sounds very safe.
> > (but slow.)
> > 
> > I'll test this, too.
> > 
> > Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> 
> Sorry. reproduced. It seems the same bug before patch. 
> mapcount 1 -> unmap -> remap -> mapcount 0. And it was SwapCache.
> 

Same here, reproduced after 18 hours.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
