Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0D9C48D0001
	for <linux-mm@kvack.org>; Fri, 26 Nov 2010 06:40:48 -0500 (EST)
Date: Fri, 26 Nov 2010 11:40:28 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 03 of 66] transparent hugepage support documentation
Message-ID: <20101126114028.GM26037@csn.ul.ie>
References: <patchbomb.1288798055@v2.random> <93158196e1ddec19fc6b.1288798058@v2.random> <20101118114105.GH8135@csn.ul.ie> <20101125143520.GM6118@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20101125143520.GM6118@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

On Thu, Nov 25, 2010 at 03:35:20PM +0100, Andrea Arcangeli wrote:
> > <SNIP>

I agree with all the changes you made up to this point.

> > > +- if some task quits and more hugepages become available (either
> > > +  immediately in the buddy or through the VM), guest physical memory
> > > +  backed by regular pages should be relocated on hugepages
> > > +  automatically (with khugepaged)
> > > +
> > > +- it doesn't require boot-time memory reservation and in turn it uses
> > 
> > neither does hugetlbfs.
> > 
> > > +  hugepages whenever possible (the only possible reservation here is
> > > +  kernelcore= to avoid unmovable pages to fragment all the memory but
> > > +  such a tweak is not specific to transparent hugepage support and
> > > +  it's a generic feature that applies to all dynamic high order
> > > +  allocations in the kernel)
> > > +
> > > +- this initial support only offers the feature in the anonymous memory
> > > +  regions but it'd be ideal to move it to tmpfs and the pagecache
> > > +  later
> > > +
> > > +Transparent Hugepage Support maximizes the usefulness of free memory
> > > +if compared to the reservation approach of hugetlbfs by allowing all
> > > +unused memory to be used as cache or other movable (or even unmovable
> > > +entities).
> > 
> > hugetlbfs with memory overcommit offers something similar, particularly
> > in combination with libhugetlbfs with can automatically fall back to base
> > pages. I've run benchmarks comparing hugetlbfs using a static hugepage
> > pool with hugetlbfs dynamically allocating hugepages as required with no
> > discernable performance difference. So this statement is not strictly accurate.
> 
> Ok, but without libhugetlbfs fallback to regular pages splitting the
> vma and creating a no-hugetlbfs one in the middle, it really requires
> memory reservation to be _sure_ (libhugtlbfs runs outside of hugetlbfs
> and I doubt it allows later collapsing like khugepaged provides,
> furthermore I'm comparing kernel vs kernel not kernel vs
> kernel+userlandwrapping)...So I think mentioning the fact THP doesn't
> require memory reservation is more or less fair enough.

Ok, what you say is true. There is no collapsing of huge pages in
hugetlbfs and reservations are required to be sure.

> I removed
> "boot-time" though.
> 
> > > +It doesn't require reservation to prevent hugepage
> > > +allocation failures to be noticeable from userland. It allows paging
> > > +and all other advanced VM features to be available on the
> > > +hugepages. It requires no modifications for applications to take
> > > +advantage of it.
> > > +
> > > +Applications however can be further optimized to take advantage of
> > > +this feature, like for example they've been optimized before to avoid
> > > +a flood of mmap system calls for every malloc(4k). Optimizing userland
> > > +is by far not mandatory and khugepaged already can take care of long
> > > +lived page allocations even for hugepage unaware applications that
> > > +deals with large amounts of memory.
> > > +
> > > +In certain cases when hugepages are enabled system wide, application
> > > +may end up allocating more memory resources. An application may mmap a
> > > +large region but only touch 1 byte of it, in that case a 2M page might
> > > +be allocated instead of a 4k page for no good. This is why it's
> > > +possible to disable hugepages system-wide and to only have them inside
> > > +MADV_HUGEPAGE madvise regions.
> > > +
> > > +Embedded systems should enable hugepages only inside madvise regions
> > > +to eliminate any risk of wasting any precious byte of memory and to
> > > +only run faster.
> > > +
> > > +Applications that gets a lot of benefit from hugepages and that don't
> > > +risk to lose memory by using hugepages, should use
> > > +madvise(MADV_HUGEPAGE) on their critical mmapped regions.
> > > +
> > > +== sysfs ==
> > > +
> > > +Transparent Hugepage Support can be entirely disabled (mostly for
> > > +debugging purposes) or only enabled inside MADV_HUGEPAGE regions (to
> > > +avoid the risk of consuming more memory resources) or enabled system
> > > +wide. This can be achieved with one of:
> > > +
> > > +echo always >/sys/kernel/mm/transparent_hugepage/enabled
> > > +echo madvise >/sys/kernel/mm/transparent_hugepage/enabled
> > > +echo never >/sys/kernel/mm/transparent_hugepage/enabled
> > > +
> > > +It's also possible to limit defrag efforts in the VM to generate
> > > +hugepages in case they're not immediately free to madvise regions or
> > > +to never try to defrag memory and simply fallback to regular pages
> > > +unless hugepages are immediately available.
> > 
> > This is the first mention of defrag but hey, it's not a paper :)
> 
> Not sure I get it this, is this too early or too late to mention
> defrag? But yes this is not a paper so I guess I don't need to care ;)
> 

You don't need to care. The reader just has to know what defrag means
here. It's not worth sweating over.

> > > <SNIP>

I agree with all the changes.

> 
> > > +The transparent_hugepage/enabled values only affect future
> > > +behavior. So to make them effective you need to restart any
> > 
> > s/behavior/behaviour/
> 
> Funny, after this change my spell checker asks me to rename behaviour
> back to behavior. I'll stick to the spell checker, they are synonymous
> anyway.
> 

They are. Might be a difference in UK and US spelling again.

> > > +In case you can't handle compound pages if they're returned by
> > > +follow_page, the FOLL_SPLIT bit can be specified as parameter to
> > > +follow_page, so that it will split the hugepages before returning
> > > +them. Migration for example passes FOLL_SPLIT as parameter to
> > > +follow_page because it's not hugepage aware and in fact it can't work
> > > +at all on hugetlbfs (but it instead works fine on transparent
> > 
> > hugetlbfs pages can now migrate although it's only used by hwpoison.
> 
> Yep. I'll need to teach migrate to avoid splitting the hugepage to
> migrate it too... (especially for numa, not much for hwpoison). And
> the migration support for hugetlbfs now makes it more complicated to
> migrate transhuge pages too with the same function because that code
> isn't inside a VM_HUGETLB check... Worst case we can check the hugepage
> destructor to differentiate the two, I've yet to check that. Surely
> it's feasible and mostly an implementation issue.
> 

It should be feasible.

> > > +Code walking pagetables but unware about huge pmds can simply call
> > > +split_huge_page_pmd(mm, pmd) where the pmd is the one returned by
> > > +pmd_offset. It's trivial to make the code transparent hugepage aware
> > > +by just grepping for "pmd_offset" and adding split_huge_page_pmd where
> > > +missing after pmd_offset returns the pmd. Thanks to the graceful
> > > +fallback design, with a one liner change, you can avoid to write
> > > +hundred if not thousand of lines of complex code to make your code
> > > +hugepage aware.
> > > +
> > 
> > It'd be nice if you could point to a specific example but by no means
> > mandatory.
> 
> Ok:
> 
> diff --git a/Documentation/vm/transhuge.txt b/Documentation/vm/transhuge.txt
> --- a/Documentation/vm/transhuge.txt
> +++ b/Documentation/vm/transhuge.txt
> @@ -226,6 +226,20 @@ but you can't handle it natively in your
>  calling split_huge_page(page). This is what the Linux VM does before
>  it tries to swapout the hugepage for example.
>  
> +Example to make mremap.c transparent hugepage aware with a one liner
> +change:
> +
> +diff --git a/mm/mremap.c b/mm/mremap.c
> +--- a/mm/mremap.c
> ++++ b/mm/mremap.c
> +@@ -41,6 +41,7 @@ static pmd_t *get_old_pmd(struct mm_stru
> + 		return NULL;
> + 
> + 	pmd = pmd_offset(pud, addr);
> ++	split_huge_page_pmd(mm, pmd);
> + 	if (pmd_none_or_clear_bad(pmd))
> + 		return NULL;
> +
>  == Locking in hugepage aware code ==
>  

Perfect.

>  We want as much code as possible hugepage aware, as calling
> 
> 
> > Ok, I'll need to read the rest of the series to verify if this is
> > correct but by and large it looks good. I think some of the language is
> > stronger than it should be and some of the comparisons with libhugetlbfs
> > are a bit off but I'd be naturally defensive on that topic. Make the
> > suggested changes if you like but if you don't, it shouldn't affect the
> > series.
> 
> I hope it looks better now, thanks!
> 

It does, thanks.

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
