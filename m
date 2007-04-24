From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Tue, 24 Apr 2007 15:33:33 +1000
Subject: [PATCH 0/12] Pass MAP_FIXED down to get_unmapped_area
Message-Id: <1177392813.924664.32930750763.qpush@grosgo>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a "first step" as there are still cleanups to be done in various
areas touched by that code but I think it's probably good to go as is and
at least enables me to implement what I need for PowerPC.

(Andrew, this is also candidate for 2.6.22 since I haven't had any real
objection, mostly suggestion for improving further, which I'll try to
do later, and I have further powerpc patches that rely on this).

The current get_unmapped_area code calls the f_ops->get_unmapped_area or
the arch one (via the mm) only when MAP_FIXED is not passed. That makes
it impossible for archs to impose proper constraints on regions of the
virtual address space. To work around that, get_unmapped_area() then
calls some hugetlbfs specific hacks.

This cause several problems, among others:

 - It makes it impossible for a driver or filesystem to do the same thing
that hugetlbfs does (for example, to allow a driver to use larger page
sizes to map external hardware) if that requires applying a constraint
on the addresses (constraining that mapping in certain regions and other
mappings out of those regions).

 - Some archs like arm, mips, sparc, sparc64, sh and sh64 already want
MAP_FIXED to be passed down in order to deal with aliasing issues.
The code is there to handle it... but is never called.

This serie of patches moves the logic to handle MAP_FIXED down to the
various arch/driver get_unmapped_area() implementations, and then changes
the generic code to always call them. The hugetlbfs hacks then disappear
from the generic code.

Since I need to do some special 64K pages mappings for SPEs on cell, I need
to work around the first problem at least. I have further patches thus
implementing a "slices" layer that handles multiple page sizes through
slices of the address space for use by hugetlbfs, the SPE code, and possibly
others, but it requires that serie of patches first/

There is still a potential (but not practical) issue due to the fact that
filesystems/drivers implemeting g_u_a will effectively bypass all arch
checks. This is not an issue in practice as the only filesystems/drivers
using that hook are doing so for arch specific purposes in the first place.

There is also a problem with mremap that will completely bypass all arch
checks. I'll try to address that separately, I'm not 100% certain yet how,
possibly by making it not work when the vma has a file whose f_ops has a
get_unmapped_area callback, and by making it use is_hugepage_only_range()
before expanding into a new area.

Also, I want to turn is_hugepage_only_range() into a more generic
is_normal_page_range() as that's really what it will end up meaning
when used in stack grow, brk grow and mremap.

None of the above "issues" however are introduced by this patch, they are
already there, so I think the patch can go ini for 2.6.22.

(Patch is against Linus current git, I'll give a go at -mm asap)

Cheers,
Ben.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
