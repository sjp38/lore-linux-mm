Received: from willy by www.linux.org.uk with local (Exim 3.13 #1)
	id 14ZikE-00047t-00
	for linux-mm@kvack.org; Mon, 05 Mar 2001 00:20:58 +0000
Date: Mon, 5 Mar 2001 00:20:58 +0000
From: Matthew Wilcox <matthew@wil.cx>
Subject: Shared mmaps
Message-ID: <20010305002058.H1865@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I don't think the hack that Sparc uses works.

The problem exists on machines with virtual addressed dcaches and no
physical tags.  This applies to at least some models of MIPS, Sparc
& PA-RISC.  if you have shared mmaps which don't map to the same cache
line, they're not coherent.  This breaks stuff.

The sparc hack involves aligning all shared mmaps on a cache aliasing
boundary.  Unfortunately, this has two problems, one performance and
one correctness.  The implementation also had an uglyness problem,
but that's a different matter.

The performance problem is that _all_ shared mmaps get mapped to the
same start address, so we're not using the caches as well as we could.

The correctness problem is that the start offset of the mmap is not
taken into account.  So if you mmap a file starting at 0k length 8k and
another starting at 4k, the changes you make to one mmap will not get
reflected in the other in a deterministic way.

I think I can fix this in a sane manner... but it's going to mean
adding a field (mmap_off) to struct inode (struct address_space?)
then do_mmap_pgoff has code something like:

#define DCACHE_ALIGN_MASK (4 * 1024 * 1024 - 1) /* Example */
#define DCACHE_ALIGN(addr, offset) \
	((addr - offset) & DCACHE_ALIGN_MASK) + offset

	if (flags & MAP_SHARED) {
		if (inode->i_mmap_off == -1) {
			addr = get_unmapped_area(addr, len);
			inode->i_mmap_off = (addr - (pgoff << PAGE_SHIFT))
					& DCACHE_ALIGN_MASK;
		} else {
			addr = get_unmapped_aligned_area(addr, len,
	(inode->i_mmap_off + (pgoff << PAGE_SHIFT)) & DCACHE_ALIGN_MASK);
		}
	} else {
		addr = get_unmapped_area(addr, len);
	}

u_long get_unmapped_aligned_area(u_long addr, u_long len, u_long offset) {
	struct vm_area_struct * vmm;

	if (len > TASK_SIZE)
		return 0;
	if (!addr)
		addr = TASK_UNMAPPED_BASE;
	addr = DCACHE_ALIGN(addr, offset);

	for (vmm = find_vma(current->mm, addr); ; vmm = vmm->vm_next) {
		/* At this point:  (!vmm || addr < vmm->vm_end). */
		if (TASK_SIZE - len < addr)
			return 0;
		if (!vmm || addr + len <= vmm->vm_start)
			return addr;
		addr = DCACHE_ALIGN(vmm->vm_end, offset);
	}
}

Thoughts?  I'm particularly interested in knowing whether people think
about where the mmap_off should go.  inode or address_space?

-- 
Revolutions do not require corporate support.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
