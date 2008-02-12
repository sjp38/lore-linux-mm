Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m1CM6PK2004030
	for <linux-mm@kvack.org>; Tue, 12 Feb 2008 17:06:25 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1CM6C9h078824
	for <linux-mm@kvack.org>; Tue, 12 Feb 2008 15:06:15 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1CM6Cp1020036
	for <linux-mm@kvack.org>; Tue, 12 Feb 2008 15:06:12 -0700
Subject: Re: [-mm PATCH] register_memory/unregister_memory clean ups
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <1202853415.25604.59.camel@dyn9047017100.beaverton.ibm.com>
References: <20080211114818.74c9dcc7.akpm@linux-foundation.org>
	 <1202765553.25604.12.camel@dyn9047017100.beaverton.ibm.com>
	 <20080212154309.F9DA.Y-GOTO@jp.fujitsu.com>
	 <1202836953.25604.42.camel@dyn9047017100.beaverton.ibm.com>
	 <1202849972.11188.71.camel@nimitz.home.sr71.net>
	 <1202853415.25604.59.camel@dyn9047017100.beaverton.ibm.com>
Content-Type: text/plain
Date: Tue, 12 Feb 2008 14:06:16 -0800
Message-Id: <1202853976.11188.86.camel@nimitz.home.sr71.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, greg@kroah.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2008-02-12 at 13:56 -0800, Badari Pulavarty wrote:
> > > +   /*
> > > +    * Its ugly, but this is the best I can do - HELP !!
> > > +    * We don't know where the allocations for section memmap and usemap
> > > +    * came from. If they are allocated at the boot time, they would come
> > > +    * from bootmem. If they are added through hot-memory-add they could be
> > > +    * from sla or vmalloc. If they are allocated as part of hot-mem-add
> > > +    * free them up properly. If they are allocated at boot, no easy way
> > > +    * to correctly free them :(
> > > +    */
> > > +   if (usemap) {
> > > +           if (PageSlab(virt_to_page(usemap))) {
> > > +                   kfree(usemap);
> > > +                   if (memmap)
> > > +                           __kfree_section_memmap(memmap, nr_pages);
> > > +           }
> > > +   }
> > > +}
> > 
> > Do what we did with the memmap and store some of its origination
> > information in the low bits.
> 
> Hmm. my understand of memmap is limited. Can you help me out here ?

Never mind.  That was a bad suggestion.  I do think it would be a good
idea to mark the 'struct page' of ever page we use as bootmem in some
way.  Perhaps page->private?  Otherwise, you can simply try all of the
possibilities and consider the remainder bootmem.  Did you ever find out
if we properly initialize the bootmem 'struct page's?

Please have mercy and put this in a helper, first of all.

static void free_usemap(unsigned long *usemap)
{
	if (!usemap_
		return;

	if (PageSlab(virt_to_page(usemap))) {
		kfree(usemap)
	} else if (is_vmalloc_addr(usemap)) {
		vfree(usemap);
	} else {
		int nid = page_to_nid(virt_to_page(usemap));
		bootmem_fun_here(NODE_DATA(nid), usemap);
	}
}

right?

> I was trying to use free_bootmem_node() to free up the allocations,
> but I need nodeid from which allocation came from :(

How is this any different from pfn_to_nid() on the thing?  Or, can you
not use that because we never init'd the bootmem 'struct page's?

If so, I think the *CORRECT* fix is to give the bootmem areas real
struct pages, probably at boot-time.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
