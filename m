From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199906072045.NAA71235@google.engr.sgi.com>
Subject: Re: Questions on cache flushing in do_wp_page
Date: Mon, 7 Jun 1999 13:45:29 -0700 (PDT)
In-Reply-To: <199906071944.MAA07363@pizda.davem.net> from "David S. Miller" at Jun 7, 99 12:44:06 pm
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, ralf@uni-koblenz.de
List-ID: <linux-mm.kvack.org>

> 
> flush_cache_page()
> 
> 	Remove all "user/tlb view" references to the page in the cache
> 	(any cache, L1, L2, BCACHE, etc.) for this user virtual mapping
> 	in address space mm.  It should be back flushed to ram if
> 	necessary on non-coherent copy-back style caches.
> 
> flush_page_to_ram()
> 
> 	Push kernel address space references to the page in the cache
> 	(any cache, L1, L2, BCACHE, etc.).  It should be back flushed
> 	to ram if necessary on non-coherent copy-back style caches
> 	because we want the user to see the most up to data copy
> 	in his mapping.
> 
> In general the first is used when we tear down or change userspace
> mappings of a page and the latter is done when we are making the page
> visible to user space.
> 
> As per virtual cache aliasing issues we handle them in other ways,
> and it is done on a port-by-port basis since most machines need not
> handle this brain damage.

I am assuming then that in the above, your definition of "non-coherent"
does not include virtual coherency/aliasing issues, since the above
paragraph seems to imply that those issues are handled differently.
Applying the above formalisms to the MIPS processor in do_wp_page,
I still can't see why a cache wbinv would be done by the
flush_page_to_ram(old_page); And if I can not use the argument of
cache aliasing, I am at a complete loss to explain either of
flush_page_to_ram(new_page); and flush_cache_page(vma, address);
doing cache wbinv on the MIPS.

You do mention in the general case where the primitives need to be
invoked, except I still don't understand which processors can define
the primitives as no-ops (Intel) and which should do some real work
(like the MIPS seems to be doing). Is there some way to figure out
how a given processor/architecture needs to define these routines?

Thanks.

Kanoj

> 
> For IPC shared memory some ports enforce an alignment.  For other MMU
> activities, the update_mmu_cache method can do things like remap a
> page as non-cacheable in all user references if an alias has been
> created which is unavoidable.  update_mmu_cache is sort of the "catch
> all" area for handling stuff like this, you could use it to work
> around the MIPS R4x00 "branch at end of page" hardware bug for example.
> 
> Later,
> David S. Miller
> davem@redhat.com
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
