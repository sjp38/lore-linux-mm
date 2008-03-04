Date: Tue, 4 Mar 2008 09:18:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [rfc 05/10] Sparsemem: Vmemmap does not need section bits
Message-Id: <20080304091809.b02b1e16.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0803031204170.16049@schroedinger.engr.sgi.com>
References: <20080301040755.268426038@sgi.com>
	<20080301040814.772847658@sgi.com>
	<20080301133312.9ab8d826.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0803031204170.16049@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 3 Mar 2008 12:06:56 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> On Sat, 1 Mar 2008, KAMEZAWA Hiroyuki wrote:
> 
> > I like this change. BTW, could you add following change ?
> > (or drop this function in sparsemem-vmemmap.)
> 
> I cannot find the function in mm/spase-vmemmap.c
>  
> > == /inclurde/linux/mm.h==
> > #ifndef CONFIG_SPARSEMEM_VMEMMAP
> > static inline unsigned long page_to_section(struct page *page)
> > {
> > 	return pfn_to_section(page_to_pfn(page));
> > }
> > #else
> > static inline unsigned long page_to_section(struct page *page)
> > {
> >         return (page->flags >> SECTIONS_PGSHIFT) & SECTIONS_MASK;
> > }
> > #endif
> 
> Not sure what this means. If we have CONFIG_SPARSEMEM_VMEMMAP then 
> SECTION_MASK == 0. So this would reduce to
> 
> #ifndef CONFIG_SPARSEMEM_VMEMMAP
> static inline unsigned long page_to_section(struct page *page)
> {
>        return pfn_to_section(page_to_pfn(page));
> }
> #else
> static inline unsigned long page_to_section(struct page *page)
> {
>          return 0;
> }
> #endif
> 
> Do you propose to also remove the use of the section bits for regular (non 
> vmemmap) sparsemem?
> 
No. My point is that page_to_section() should return correct number.
(0 is not correct for pages in some section other than 'section 0')

"Now" there are no users of page_to_section() if sparsemem_vmemmap
is configured. But it seems to be defined as generic function.
So, someone may use this function in future.
 
Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
