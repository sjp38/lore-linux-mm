Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8A9756B0003
	for <linux-mm@kvack.org>; Sat,  3 Mar 2018 22:47:24 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id s17so7659785pfm.23
        for <linux-mm@kvack.org>; Sat, 03 Mar 2018 19:47:24 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k9-v6si7245420plt.293.2018.03.03.19.47.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 03 Mar 2018 19:47:22 -0800 (PST)
Date: Sat, 3 Mar 2018 19:47:04 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC PATCH] Randomization of address chosen by mmap.
Message-ID: <20180304034704.GB20725@bombadil.infradead.org>
References: <20180227131338.3699-1-blackzert@gmail.com>
 <CAGXu5jKF7ysJqj57ZktrcVL4G2NWOFHCud8dtXFHLs=tvVLXnQ@mail.gmail.com>
 <55C92196-5398-4C19-B7A7-6C122CD78F32@gmail.com>
 <20180228183349.GA16336@bombadil.infradead.org>
 <CA+DvKQKoo1U7T_iOOLhfEf9c+K1pzD068au+kGtx0RokFFNKHw@mail.gmail.com>
 <2CF957C6-53F2-4B00-920F-245BEF3CA1F6@gmail.com>
 <CA+DvKQ+mrnm4WX+3cBPuoSLFHmx2Zwz8=FsEx51fH-7yQMAd9w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+DvKQ+mrnm4WX+3cBPuoSLFHmx2Zwz8=FsEx51fH-7yQMAd9w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Micay <danielmicay@gmail.com>
Cc: Ilya Smith <blackzert@gmail.com>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Jerome Glisse <jglisse@redhat.com>, Hugh Dickins <hughd@google.com>, Helge Deller <deller@gmx.de>, Andrea Arcangeli <aarcange@redhat.com>, Oleg Nesterov <oleg@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On Sat, Mar 03, 2018 at 04:00:45PM -0500, Daniel Micay wrote:
> The main thing I'd like to see is just the option to get a guarantee
> of enforced gaps around mappings, without necessarily even having
> randomization of the gap size. It's possible to add guard pages in
> userspace but it adds overhead by doubling the number of system calls
> to map memory (mmap PROT_NONE region, mprotect the inner portion to
> PROT_READ|PROT_WRITE) and *everything* using mmap would need to
> cooperate which is unrealistic.

So something like this?

To use it, OR in PROT_GUARD(n) to the PROT flags of mmap, and it should
pad the map by n pages.  I haven't tested it, so I'm sure it's buggy,
but it seems like a fairly cheap way to give us padding after every
mapping.

Running it on an old kernel will result in no padding, so to see if it
worked or not, try mapping something immediately after it.

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 4ef7fb1726ab..9da6df7f62fc 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2183,8 +2183,8 @@ extern int install_special_mapping(struct mm_struct *mm,
 extern unsigned long get_unmapped_area(struct file *, unsigned long, unsigned long, unsigned long, unsigned long);
 
 extern unsigned long mmap_region(struct file *file, unsigned long addr,
-	unsigned long len, vm_flags_t vm_flags, unsigned long pgoff,
-	struct list_head *uf);
+	unsigned long len, unsigned long pad_len, vm_flags_t vm_flags,
+	unsigned long pgoff, struct list_head *uf);
 extern unsigned long do_mmap(struct file *file, unsigned long addr,
 	unsigned long len, unsigned long prot, unsigned long flags,
 	vm_flags_t vm_flags, unsigned long pgoff, unsigned long *populate,
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 1c5dea402501..9c2b66fa0561 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -299,6 +299,7 @@ struct vm_area_struct {
 	struct mm_struct *vm_mm;	/* The address space we belong to. */
 	pgprot_t vm_page_prot;		/* Access permissions of this VMA. */
 	unsigned long vm_flags;		/* Flags, see mm.h. */
+	unsigned int vm_guard;		/* Number of trailing guard pages */
 
 	/*
 	 * For areas with an address space and backing store,
diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
index f8b134f5608f..d88babdf97f9 100644
--- a/include/uapi/asm-generic/mman-common.h
+++ b/include/uapi/asm-generic/mman-common.h
@@ -12,6 +12,7 @@
 #define PROT_EXEC	0x4		/* page can be executed */
 #define PROT_SEM	0x8		/* page may be used for atomic ops */
 #define PROT_NONE	0x0		/* page can not be accessed */
+#define PROT_GUARD(x)	((x) & 0xffff) << 4	/* guard pages */
 #define PROT_GROWSDOWN	0x01000000	/* mprotect flag: extend change to start of growsdown vma */
 #define PROT_GROWSUP	0x02000000	/* mprotect flag: extend change to end of growsup vma */
 
diff --git a/mm/memory.c b/mm/memory.c
index 1cfc4699db42..5b0f87afa0af 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4125,6 +4125,9 @@ int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 					    flags & FAULT_FLAG_REMOTE))
 		return VM_FAULT_SIGSEGV;
 
+	if (DIV_ROUND_UP(vma->vm_end - address, PAGE_SIZE) < vma->vm_guard)
+		return VM_FAULT_SIGSEGV;
+
 	/*
 	 * Enable the memcg OOM handling for faults triggered in user
 	 * space.  Kernel faults are handled more gracefully.
diff --git a/mm/mmap.c b/mm/mmap.c
index 575766ec02f8..b9844b810ee7 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1433,6 +1433,7 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
 			unsigned long pgoff, unsigned long *populate,
 			struct list_head *uf)
 {
+	unsigned int guard_len = ((prot >> 4) & 0xffff) << PAGE_SHIFT;
 	struct mm_struct *mm = current->mm;
 	int pkey = 0;
 
@@ -1458,6 +1459,8 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
 	len = PAGE_ALIGN(len);
 	if (!len)
 		return -ENOMEM;
+	if (len + guard_len < len)
+		return -ENOMEM;
 
 	/* offset overflow? */
 	if ((pgoff + (len >> PAGE_SHIFT)) < pgoff)
@@ -1472,7 +1475,7 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
 	/* Obtain the address to map to. we verify (or select) it and ensure
 	 * that it represents a valid section of the address space.
 	 */
-	addr = get_unmapped_area(file, addr, len, pgoff, flags);
+	addr = get_unmapped_area(file, addr, len + guard_len, pgoff, flags);
 	if (offset_in_page(addr))
 		return addr;
 
@@ -1591,7 +1594,7 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
 			vm_flags |= VM_NORESERVE;
 	}
 
-	addr = mmap_region(file, addr, len, vm_flags, pgoff, uf);
+	addr = mmap_region(file, addr, len, len + guard_len, vm_flags, pgoff, uf);
 	if (!IS_ERR_VALUE(addr) &&
 	    ((vm_flags & VM_LOCKED) ||
 	     (flags & (MAP_POPULATE | MAP_NONBLOCK)) == MAP_POPULATE))
@@ -1727,8 +1730,8 @@ static inline int accountable_mapping(struct file *file, vm_flags_t vm_flags)
 }
 
 unsigned long mmap_region(struct file *file, unsigned long addr,
-		unsigned long len, vm_flags_t vm_flags, unsigned long pgoff,
-		struct list_head *uf)
+		unsigned long len, unsigned long pad_len, vm_flags_t vm_flags,
+		unsigned long pgoff, struct list_head *uf)
 {
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma, *prev;
@@ -1737,24 +1740,24 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 	unsigned long charged = 0;
 
 	/* Check against address space limit. */
-	if (!may_expand_vm(mm, vm_flags, len >> PAGE_SHIFT)) {
+	if (!may_expand_vm(mm, vm_flags, pad_len >> PAGE_SHIFT)) {
 		unsigned long nr_pages;
 
 		/*
 		 * MAP_FIXED may remove pages of mappings that intersects with
 		 * requested mapping. Account for the pages it would unmap.
 		 */
-		nr_pages = count_vma_pages_range(mm, addr, addr + len);
+		nr_pages = count_vma_pages_range(mm, addr, addr + pad_len);
 
 		if (!may_expand_vm(mm, vm_flags,
-					(len >> PAGE_SHIFT) - nr_pages))
+					(pad_len >> PAGE_SHIFT) - nr_pages))
 			return -ENOMEM;
 	}
 
 	/* Clear old maps */
-	while (find_vma_links(mm, addr, addr + len, &prev, &rb_link,
+	while (find_vma_links(mm, addr, addr + pad_len, &prev, &rb_link,
 			      &rb_parent)) {
-		if (do_munmap(mm, addr, len, uf))
+		if (do_munmap(mm, addr, pad_len, uf))
 			return -ENOMEM;
 	}
 
@@ -1771,7 +1774,7 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 	/*
 	 * Can we just expand an old mapping?
 	 */
-	vma = vma_merge(mm, prev, addr, addr + len, vm_flags,
+	vma = vma_merge(mm, prev, addr, addr + pad_len, vm_flags,
 			NULL, file, pgoff, NULL, NULL_VM_UFFD_CTX);
 	if (vma)
 		goto out;
@@ -1789,9 +1792,10 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 
 	vma->vm_mm = mm;
 	vma->vm_start = addr;
-	vma->vm_end = addr + len;
+	vma->vm_end = addr + pad_len;
 	vma->vm_flags = vm_flags;
 	vma->vm_page_prot = vm_get_page_prot(vm_flags);
+	vma->vm_guard = (pad_len - len) >> PAGE_SHIFT;
 	vma->vm_pgoff = pgoff;
 	INIT_LIST_HEAD(&vma->anon_vma_chain);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
