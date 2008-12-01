Date: Mon, 1 Dec 2008 17:32:58 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch][rfc] acpi: do not use kmem caches
Message-ID: <20081201163257.GG10790@wotan.suse.de>
References: <20081201083128.GB2529@wotan.suse.de> <84144f020812010318v205579ean57edecf7992ec7ef@mail.gmail.com> <20081201120002.GB10790@wotan.suse.de> <4933E2C3.4020400@gmail.com> <20081201133646.GC10790@wotan.suse.de> <4933F14C.7020200@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4933F14C.7020200@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexey Starikovskiy <aystarik@gmail.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, lenb@kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Dec 01, 2008 at 05:14:36PM +0300, Alexey Starikovskiy wrote:
> Nick Piggin wrote:
> >On Mon, Dec 01, 2008 at 04:12:35PM +0300, Alexey Starikovskiy wrote:
> >  
> >>Nick Piggin wrote:
> >>    
> >>>On Mon, Dec 01, 2008 at 01:18:33PM +0200, Pekka Enberg wrote:
> >>> 
> >>>      
> >>>>Hi Nick,
> >>>>
> >>>>On Mon, Dec 1, 2008 at 10:31 AM, Nick Piggin <npiggin@suse.de> wrote:
> >>>>   
> >>>>        
> >>>>>What does everyone think about this patch?
> >>>>>     
> >>>>>          
> >>>>Doesn't matter all that much for SLUB which already merges the ACPI
> >>>>caches with the generic kmalloc caches. But for SLAB, it's an obvious
> >>>>wil so:
> >>>>
> >>>>Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>
> >>>>   
> >>>>        
> >>>Actually I think it is also somewhat of a bugfix (not to mention that it
> >>>seems like a good idea to share testing code with other operating 
> >>>systems).
> >>>
> >>> 
> >>>      
> >>It is not "kind of a bugfix". Caches were used to allocate all frequenly
> >>created objects of fixed size. Removing native cache interface will
> >>increase memory consumption and increase code size, and will make it 
> >>harder
> >>to spot actual memory leaks.
> >>    
> >
> >Slabs can take a non-trivial amount of memory. On bigger machines it can
> >be many megabytes. On smaller machines perhaps not, but what is the 
> >benefit??
> >The only ACPI slabs I have with anything in them total a couple of hundred
> >kB, and anyway they are 64 and 32 bytes so they will pack exactly into
> >kmalloc slabs.
> >  
> Oh right, we don't care about memory footprint any longer...

On the contrary
http://marc.info/?l=linux-fsdevel&m=122812043206762&w=2

Some people still do. I'm hoping to save memory. With my configuration, the
patch definitely saves memory.


> >Code size... Does it matter? Is it really performance critical? If you are
> >worried about code size, then I will implement them directly with kmalloc
> >and kfree for you.
> >  
> Why then you try to delete ACPICA code, which might be just disabled by
> undefining ACPI_USE_LOCAL_CACHE?
> If you do want to go that path, you need to create patch against ACPICA, not
> Linux code.

I don't know what else uses ACPICA, so no.


> >kmem caches are not exactly an appropriate tool to detect memory leaks. If
> >that were the case then we'd have million kmem caches everywhere.
> >
> >
> >  
> >>>Because acpi_os_purge_cache seems to want to free all active objects in 
> >>>the
> >>>cache, but kmem_cache_shrink actually does nothing of the sort. So there
> >>>ends up being a memory leak.
> >>> 
> >>>      
> >>No. acpi_os_purge_cache wants to free only unused objects, so it is a 
> >>direct map to
> >>    
> >
> >Ah OK I misread, that's the cache's freelist... ACPI shouldn't be poking
> >this button inside the slab allocator anyway, honestly. What is it
> >for?
> >  
> And it is not actually used -- you cannot unload ACPI interpreter, and
> this function is called only from there.

Should be deleted anyway. This seems to be the only user of kmem_cache_shrink
in the kernel and it's bogus anyway.


> >Is there a reasonable performance or memory win by using kmem cache? If
> >not, then they should not be used
> ACPI is still working in machines with several megabytes of RAM and 
> 100mhz Pentium processors. Do you say we should just not consider them 
> any longer?

No. As I said, I am trying to save RAM. If it turns out not to save RAM
in some configurations then of course I will reconsider.


> If so, then just delete all ACPICA caches altogether.
> And this still needs to be patch against ACPICA, not Linux -- at least 
> with BSD license attached.

I don't have a problem with that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
