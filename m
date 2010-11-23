Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 576AF6B0071
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 04:51:10 -0500 (EST)
Date: Tue, 23 Nov 2010 09:50:53 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC 2/2] Prevent promotion of page in madvise_dontneed
Message-ID: <20101123095053.GG19571@csn.ul.ie>
References: <bdd6628e81c06f6871983c971d91160fca3f8b5e.1290349672.git.minchan.kim@gmail.com> <5d205f8a4df078b0da3681063bbf37382b02dd23.1290349672.git.minchan.kim@gmail.com> <20101122142109.2f3e168c.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20101122142109.2f3e168c.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Mon, Nov 22, 2010 at 02:21:09PM -0800, Andrew Morton wrote:
> On Sun, 21 Nov 2010 23:30:24 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
> 
> > Now zap_pte_range alwayas promotes pages which are pte_young &&
> > !VM_SequentialReadHint(vma). But in case of calling MADV_DONTNEED,
> > it's unnecessary since the page wouldn't use any more.
> > 
> > If the page is sharred by other processes and it's real working set
> 
> This patch doesn't actually do anything.  It passes variable `promote'
> all the way down to unmap_vmas(), but unmap_vmas() doesn't use that new
> variable.
> 
> Have a comment fixlet:
> 
> --- a/mm/memory.c~mm-prevent-promotion-of-page-in-madvise_dontneed-fix
> +++ a/mm/memory.c
> @@ -1075,7 +1075,7 @@ static unsigned long unmap_page_range(st
>   * @end_addr: virtual address at which to end unmapping
>   * @nr_accounted: Place number of unmapped pages in vm-accountable vma's here
>   * @details: details of nonlinear truncation or shared cache invalidation
> - * @promote: whether pages inclued vma would be promoted or not
> + * @promote: whether pages included in the vma should be promoted or not
>   *
>   * Returns the end address of the unmapping (restart addr if interrupted).
>   *
> _
> 
> Also, I'd suggest that we avoid introducing the term "promote". 

Promote also has special meaning for huge pages. Demoting or promoting a
page refers to changing its size. The same applies to the other patch -
s/demote/deactive/ s/promote/activate/ . Currently this is no confusion
within the VM but when Andrea's THP patches are merged, it'll become an
issue.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
