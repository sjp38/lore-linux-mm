Date: Wed, 13 Feb 2008 14:09:55 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [-mm PATCH] register_memory/unregister_memory clean ups
In-Reply-To: <1202853976.11188.86.camel@nimitz.home.sr71.net>
References: <1202853415.25604.59.camel@dyn9047017100.beaverton.ibm.com> <1202853976.11188.86.camel@nimitz.home.sr71.net>
Message-Id: <20080213120746.FB76.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>, Badari Pulavarty <pbadari@us.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, greg@kroah.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Thanks Badari-san.

I understand what was occured. :-)

> On Tue, 2008-02-12 at 13:56 -0800, Badari Pulavarty wrote:
> > > > +   /*
> > > > +    * Its ugly, but this is the best I can do - HELP !!
> > > > +    * We don't know where the allocations for section memmap and usemap
> > > > +    * came from. If they are allocated at the boot time, they would come
> > > > +    * from bootmem. If they are added through hot-memory-add they could be
> > > > +    * from sla or vmalloc. If they are allocated as part of hot-mem-add
> > > > +    * free them up properly. If they are allocated at boot, no easy way
> > > > +    * to correctly free them :(
> > > > +    */
> > > > +   if (usemap) {
> > > > +           if (PageSlab(virt_to_page(usemap))) {
> > > > +                   kfree(usemap);
> > > > +                   if (memmap)
> > > > +                           __kfree_section_memmap(memmap, nr_pages);
> > > > +           }
> > > > +   }
> > > > +}
> > > 
> > > Do what we did with the memmap and store some of its origination
> > > information in the low bits.
> > 
> > Hmm. my understand of memmap is limited. Can you help me out here ?
> 
> Never mind.  That was a bad suggestion.  I do think it would be a good
> idea to mark the 'struct page' of ever page we use as bootmem in some
> way.  Perhaps page->private? 

I agree. page->private is not used by bootmem allocator.

I would like to mark not only memmap but also pgdat (and so on)
for next step. It will be necessary for removing whole node. :-)


>  Otherwise, you can simply try all of the
> possibilities and consider the remainder bootmem.  Did you ever find out
> if we properly initialize the bootmem 'struct page's?
> 
> Please have mercy and put this in a helper, first of all.
> 
> static void free_usemap(unsigned long *usemap)
> {
> 	if (!usemap_
> 		return;
> 
> 	if (PageSlab(virt_to_page(usemap))) {
> 		kfree(usemap)
> 	} else if (is_vmalloc_addr(usemap)) {
> 		vfree(usemap);
> 	} else {
> 		int nid = page_to_nid(virt_to_page(usemap));
> 		bootmem_fun_here(NODE_DATA(nid), usemap);
> 	}
> }
> 
> right?

It may work. But, to be honest, I feel there are TOO MANY allocation/free
way for memmap (usemap and so on). If possible, I would like to
unify some of them. I would like to try it.

Bye.

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
