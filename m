Date: Sat, 1 Mar 2008 13:33:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [rfc 05/10] Sparsemem: Vmemmap does not need section bits
Message-Id: <20080301133312.9ab8d826.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080301040814.772847658@sgi.com>
References: <20080301040755.268426038@sgi.com>
	<20080301040814.772847658@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 29 Feb 2008 20:08:00 -0800
Christoph Lameter <clameter@sgi.com> wrote:

> Sparsemem vmemmap does not need any section bits. This patch has
> the effect of reducing the number of bits used in page->flags
> by at least 6.
> 
> Add an #error in sparse.c to avoid trouble if the page flags use
> becomes so large that no node number fits in there anymore. We can then
> no longer fallback from the use of the node to the use of the sectionID
> for sparsemem vmemmap. The node width is always smaller than the width
> of the section. So one would never want to fallback this way for
> vmemmap.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 

I like this change. BTW, could you add following change ?
(or drop this function in sparsemem-vmemmap.)

== /inclurde/linux/mm.h==
#ifndef CONFIG_SPARSEMEM_VMEMMAP
static inline unsigned long page_to_section(struct page *page)
{
	return pfn_to_section(page_to_pfn(page));
}
#else
static inline unsigned long page_to_section(struct page *page)
{
        return (page->flags >> SECTIONS_PGSHIFT) & SECTIONS_MASK;
}
#endif


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
