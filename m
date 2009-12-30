Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 0EBDE60021B
	for <linux-mm@kvack.org>; Wed, 30 Dec 2009 11:19:34 -0500 (EST)
Date: Wed, 30 Dec 2009 16:19:29 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH -mmotm-2009-12-10-17-19] Fix wrong rss count of smaps
In-Reply-To: <20091230103349.1ec71aac.minchan.kim@barrios-desktop>
Message-ID: <alpine.LSU.2.00.0912301612180.3369@sister.anvils>
References: <20091228134619.92ba28f6.minchan.kim@barrios-desktop> <1262117339.3000.2023.camel@calx> <20091230103349.1ec71aac.minchan.kim@barrios-desktop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 30 Dec 2009, Minchan Kim wrote:
> On Tue, 29 Dec 2009 14:08:59 -0600
> Matt Mackall <mpm@selenic.com> wrote:
> > On Mon, 2009-12-28 at 13:46 +0900, Minchan Kim wrote:
> > > I am not sure we have to account zero page with file_rss. 
> > > Hugh and Kame's new zero page doesn't do it. 
> > > As side effect of this, we can prevent innocent process which have a lot
> > > of zero page when OOM happens. 
> > > (But I am not sure there is a process like this :)
> > > So I think not file_rss counting is not bad. 
> > > 
> > > RSS counting zero page with file_rss helps any program using smaps?
> > > If we have to keep the old behavior, I have to remake this patch. 
> > > 
> > > == CUT_HERE ==
> > > 
> > > Long time ago, We regards zero page as file_rss and
> > > vm_normal_page doesn't return NULL.
> > > 
> > > But now, we reinstated ZERO_PAGE and vm_normal_page's implementation
> > > can return NULL in case of zero page. Also we don't count it with
> > > file_rss any more.
> > > 
> > > Then, RSS and PSS can't be matched.
> > > For consistency, Let's ignore zero page in smaps_pte_range.
> > > 
> > 
> > Not counting the zero page in RSS is fine with me. But will this patch
> > make the total from smaps agree with get_mm_rss()?
> 
> Yes. Anon page fault handler also don't count zero page any more, now. 
> Nonetheless, smaps counts it with resident. 
> 
> It's point of this patch. 
> 
> But I reposted both anon fault handler and here counts it as file_rss
> as compatibility with old zero page counting.
> Pz, Look at that. :)

I am getting confused between your different patches in this area,
heading in different directions, not increments in the same series.
But I think this is the one to which, like Matt, I'll say

Acked-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>

> 
> > 
> > Regarding OOM handling: arguably RSS should play no role in OOM as it's
> > practically meaningless in a shared memory system. If we were instead
> 
> It's very arguable issue for us that OOM depens on RSS.
> 
> > used per-process unshared pages as the metric (aka USS), we'd have a
> > much better notion of how much memory an OOM kill would recover.
> > Unfortunately, that's not trivial to track as the accounting on COW
> > operations is not lightweight.
> 
> I think we can approximate it with the size of VM_SHARED vma of process
> when VM calculate badness. 
> What do you think about it?

Sounds like it'll end up even harder to understand than by size or by rss.

> 
> Thanks for good idea, Matt. 
> 
> > 
> > > CC: Matt Mackall <mpm@selenic.com>
> > > Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> > > ---
> > >  fs/proc/task_mmu.c |    3 +--
> > >  1 files changed, 1 insertions(+), 2 deletions(-)
> > > 
> > > diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> > > index 47c03f4..f277c4a 100644
> > > --- a/fs/proc/task_mmu.c
> > > +++ b/fs/proc/task_mmu.c
> > > @@ -361,12 +361,11 @@ static int smaps_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
> > >  		if (!pte_present(ptent))
> > >  			continue;
> > >  
> > > -		mss->resident += PAGE_SIZE;
> > > -
> > >  		page = vm_normal_page(vma, addr, ptent);
> > >  		if (!page)
> > >  			continue;
> > >  
> > > +		mss->resident += PAGE_SIZE;
> > >  		/* Accumulate the size in pages that have been accessed. */
> > >  		if (pte_young(ptent) || PageReferenced(page))
> > >  			mss->referenced += PAGE_SIZE;
> > > -- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
