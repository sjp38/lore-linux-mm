Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 7DDED6B00E8
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 15:14:20 -0400 (EDT)
Date: Fri, 20 Apr 2012 21:14:18 +0200
From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: Weirdness in __alloc_bootmem_node_high
Message-ID: <20120420191418.GA3569@merkur.ravnborg.org>
References: <20120417155502.GE22687@tiehlicka.suse.cz> <20120420182907.GG32324@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120420182907.GG32324@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@suse.cz>, yinghai@kernel.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri, Apr 20, 2012 at 11:29:07AM -0700, Tejun Heo wrote:
> On Tue, Apr 17, 2012 at 05:55:02PM +0200, Michal Hocko wrote:
> > Hi,
> > I just come across the following condition in __alloc_bootmem_node_high
> > which I have hard times to understand. I guess it is a bug and we need
> > something like the following. But, to be honest, I have no idea why we
> > care about those 128MB above MAX_DMA32_PFN.
> > ---
> >  mm/bootmem.c |    2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/mm/bootmem.c b/mm/bootmem.c
> > index 0131170..5adb072 100644
> > --- a/mm/bootmem.c
> > +++ b/mm/bootmem.c
> > @@ -737,7 +737,7 @@ void * __init __alloc_bootmem_node_high(pg_data_t *pgdat, unsigned long size,
> >  	/* update goal according ...MAX_DMA32_PFN */
> >  	end_pfn = pgdat->node_start_pfn + pgdat->node_spanned_pages;
> >  
> > -	if (end_pfn > MAX_DMA32_PFN + (128 >> (20 - PAGE_SHIFT)) &&
> > +	if (end_pfn > MAX_DMA32_PFN + (128 << (20 - PAGE_SHIFT)) &&
> >  	    (goal >> PAGE_SHIFT) < MAX_DMA32_PFN) {
> >  		void *ptr;
> >  		unsigned long new_goal;
> 
> Regardless of x86 not using it, this is a bug fix and this code path
> seems to be used by mips at least.

I took a quick look at this.
__alloc_bootmem_node_high() is used in mm/sparse.c - but only
if SPARSEMEM_VMEMMAP is enabled.

mips has this:

config ARCH_SPARSEMEM_ENABLE
        bool
        select SPARSEMEM_STATIC

So SPARSEMEM_VMEMMAP is not enabled.

__alloc_bootmem_node_high() is used in mm/sparse-vmemmap.c which
also depends on CONFIG_SPARSEMEM_VMEMMAP.


So I really do not see the logic in __alloc_bootmem_node_high()
being used anymore and it can be replaced by __alloc_bootmem_node()

	Sam

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
