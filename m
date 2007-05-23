Subject: Re: [patch 2/8] mm: merge populate and nopage into fault (fixes
	nonlinear)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <alpine.LFD.0.98.0705180758450.3890@woody.linux-foundation.org>
References: <200705180737.l4I7b5aR010752@shell0.pdx.osdl.net>
	 <alpine.LFD.0.98.0705180758450.3890@woody.linux-foundation.org>
Content-Type: text/plain
Date: Thu, 24 May 2007 09:37:19 +1000
Message-Id: <1179963439.32247.987.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, npiggin@suse.de, randy.dunlap@oracle.com
List-ID: <linux-mm.kvack.org>

On Fri, 2007-05-18 at 08:11 -0700, Linus Torvalds wrote:
> On Fri, 18 May 2007, akpm@linux-foundation.org wrote:
> > 
> > Nonlinear mappings are (AFAIKS) simply a virtual memory concept that encodes
> > the virtual address -> file offset differently from linear mappings.
> 
> I'm not going to merge this one.

I'm a potential user of some of that stuff, so I'll tiptoe in...
 
> First off, I don't see the point of renaming "nopage" to "fault". If you 
> are looking for compiler warnings, you might as well just change the 
> prototype and be done with it. The new name is not even descriptive, since 
> it's all about nopage, and not about any other kind of faults.

Well, it's nice to merge nopfn and nopage in one thing, for one :-) 

> [ Side note: why is "address" there in the fault data? It would seem that 
>   anybody that uses it is by definition buggy, so it shouldn't be there if 
>   we're fixing up the interfaces. ]

I have examples where I need address for things like special page size
mappings that we have in spufs (we map SPU local stores on cell using
64K HW pages when possible for performance). There have also been some
discussions about some issues we had with 64K base page size vs. some
hypervisors forcing you to use 4K appart regions for some devices, thus
ossibly using sub-page mappings in some device drivers, using arch
specific facilities. Those require address full, with all the bits. It's
kind of a special case though and currently, we have a workaround for
these that doesn't involves that much contorsions but it might come back
and bite us. 

> Also, the commentary says that you're planning on replacing "nopfn" too, 
> which means that returning a "struct page *" is wrong. So the patch is
> introducing a new interface that is already known to be broken. 

Agreed.

>  - make "nopage()" return "int" (the status code). Move the "struct page" 
>    pointer into the data area, and add a "pte_t" entry there too, so that 
>    the callee can now decide to fill in one or the other (or neither, if 
>    it returns an error).

Actually, I think that's not a good idea.

I think a no_pfn() handler should insert the PTE itself using
vm_insert_pfn() and return an error code that means "refault".

This is what I do for spufs now (using NOPFN_REFAULT that I introduced
specifically for that purpose) and I think what the DRI should do with
their new dynamic memory mapping as well.

In fact, anything using unmap_mapping_range() along with ->no_pfn() to
change mappings on the fly should do that since that's the only way to
avoid nasty races (by having the PTE insertion use the same lock as
whatever can trigger the unmapping, in my case, the spu context
switching code).

(In spufs, we do that so that the user mapping to the SPU local store is
transparently mapped to either the actual SPU HW or a backing store in
memory when the SPU is context switched around. In the DRI, the need is
to have objects/textures that can transparently migrate between main
memory, AGP, and video memory).

>  - "struct fault_data" is a stupid name. Of *course* it is data: it's a 
>    struct. It can't be code. But it's not even about faults. It's about 
>    missing pages.
> 
>    So call it something else. Maybe just "struct nopage". Or, "struct 
>    vm_fault" at least, so that it's at least not about *random* faults.
> 
>  - drop "address" from "struct fault_data". Even if some user were to have 
>    some reason to use it (doubtful), it should be called somethign long 
>    and cumbersome, so that you don't use it by mistake, not realizing that 
>    you should use the page index instead.

I'd rather have it in, even if it's long and cumbersome :-) As I said,
there are a few HW drivers around the tree like spufs or some weirdo IBM
infiniband stuff that do really tricky games with nopage/nopfn and which
can have good use of it (at the very least, it's useful for debugging to
printk where the accesses that ended up doing the wrong thing precisely
was done :-)

>  - and keep calling it "nopage". 

Fine by me.

> But regardless, it's *way* too late for introducing things like this that 
> don't even fix a bug after -rc1.

Fine by me too.

Ben.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
