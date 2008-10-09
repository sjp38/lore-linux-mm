Date: Thu, 9 Oct 2008 11:24:36 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/2] Report the pagesize backing a VMA in /proc/pid/smaps
Message-ID: <20081009102436.GD24962@csn.ul.ie>
References: <1223052415-18956-1-git-send-email-mel@csn.ul.ie> <1223052415-18956-2-git-send-email-mel@csn.ul.ie> <20081008213831.GA23729@x200.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20081008213831.GA23729@x200.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, dave@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On (09/10/08 01:38), Alexey Dobriyan didst pronounce:
> On Fri, Oct 03, 2008 at 05:46:54PM +0100, Mel Gorman wrote:
> > It is useful to verify a hugepage-aware application is using the expected
> > pagesizes for its memory regions. This patch creates an entry called
> > KernelPageSize in /proc/pid/smaps that is the size of page used by the
> > kernel to back a VMA. The entry is not called PageSize as it is possible
> > the MMU uses a different size. This extension should not break any sensible
> > parser that skips lines containing unrecognised information.
> 
> > +		   "KernelPageSize: %8lu kB\n",
> 
> > +unsigned long vma_kernel_pagesize(struct vm_area_struct *vma)
> > +{
> > +	struct hstate *hstate;
> > +
> > +	if (!is_vm_hugetlb_page(vma))
> > +		return PAGE_SIZE;
> > +
> > +	hstate = hstate_vma(vma);
> > +	VM_BUG_ON(!hstate);
> > +
> > +	return 1UL << (hstate->order + PAGE_SHIFT);
> 			    ^^^^
> VM_BUG_ON is unneeded because kernel will oops here if hstate is NULL.
> 

Ok, will drop it. I used the VM_BUG_ON so if the situation was triggered,
it would come with line numbers but it'll be an obvious oops so I guess it
is redundant.

> Also, in /proc/*/maps it's printed only for hugetlb vmas and called
> hpagesize,

Well yes... because it's a huge pagesize for that VMA. The name reflects
what is being described there.

> in smaps it's printed for every vma and called
> KernelPageSize. All of this is inconsistent.
> 

In smaps, we are printing for every VMA because it's easier for parsers to
deal with the presense of information than its absense. The name KernelPageSize
there is an accurate description.

I don't feel it is inconsistent.

> And app will verify once that hugepages are of right size, so Pss cost
> argument for changing /proc/*/maps seems weak to me.
> 

Lets say someone wanted to monitor an application to see what its use of
hugepages were over time, they would have to constantly incur the PSS
cost to do that which seems a bit unfair.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
