Message-ID: <46023055.1030004@yahoo.com.au>
Date: Thu, 22 Mar 2007 18:29:25 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC/PATCH 0/15] Pass MAP_FIXED down to get_unmapped_area
References: <1174543217.531981.572863804039.qpush@grosgo>
In-Reply-To: <1174543217.531981.572863804039.qpush@grosgo>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Linux Memory Management <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Benjamin Herrenschmidt wrote:
> !!! This is a first cut, and there are still cleanups to be done in various
> areas touched by that code. I also haven't done descriptions yet for the
> individual patches.
> 
> The current get_unmapped_area code calls the f_ops->get_unmapped_area or
> the arch one (via the mm) only when MAP_FIXED is not passed. That makes
> it impossible for archs to impose proper constraints on regions of the
> virtual address space. To work around that, get_unmapped_area() then
> calls some hugetlbfs specific hacks.
> 
> This cause several problems, among others:
> 
>  - It makes it impossible for a driver or filesystem to do the same thing
> that hugetlbfs does (for example, to allow a driver to use larger page
> sizes to map external hardware) if that requires applying a constraint
> on the addresses (constraining that mapping in certain regions and other
> mappings out of those regions).
> 
>  - Some archs like arm, mips, sparc, sparc64, sh and sh64 already want
> MAP_FIXED to be passed down in order to deal with aliasing issues.
> The code is there to handle it... but is never called.
> 
> This serie of patches moves the logic to handle MAP_FIXED down to the
> various arch/driver get_unmapped_area() implementations, and then changes
> the generic code to always call them. The hugetlbfs hacks then disappear
> from the generic code.
> 
> Since I need to do some special 64K pages mappings for SPEs on cell, I need
> to work around the first problem at least. I have further patches thus
> implementing a "slices" layer that handles multiple page sizes through
> slices of the address space for use by hugetlbfs, the SPE code, and possibly
> others, but it requires that serie of patches first/
> 
> There is still a potential (but not practical) issue due to the fact that
> filesystems/drivers implemeting g_u_a will effectively bypass all arch
> checks. This is not an issue in practice as the only users of those are
> actually doing so are doing it using arch hooks in the first place.
> 
> There is also a problem with mremap that will completely bypass all arch
> checks. I'll try to address that separately mostly by making it not work
> when the vma has a file whose f_ops has a get_unmapped_area callback,
> and by making it use is_hugepage_only_range() before expanding into a
> new area.
> 
> Also, I want to turn is_hugepage_only_range() into a more generic
> is_normal_page_range() as that's really what it will end up meaning
> when used in stack grow, brk grow and mremap.

Great, this is long overdue for a cleanup.

I haven't looked at all users of this, but does it make sense to switch
to an API that takes an address range and modifies / filters it? Perhaps
also filling in some other annotations (eg. alignment, topdown/bottom up).
This way you could stack as many arch and driver callbacks as you need,
while hopefully also having just a single generic allocator.

OTOH, that might end up being too inefficient or simply over engineered.
Did you have any other thoughts about how to do this more generically?

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
