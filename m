Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id E2DD16B0033
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 11:02:44 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id z52so11364526wrc.5
        for <linux-mm@kvack.org>; Tue, 14 Nov 2017 08:02:44 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id p6si14733433wrh.512.2017.11.14.08.02.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 14 Nov 2017 08:02:43 -0800 (PST)
Date: Tue, 14 Nov 2017 17:01:50 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCHv2 1/2] x86/mm: Do not allow non-MAP_FIXED mapping across
 DEFAULT_MAP_WINDOW border
In-Reply-To: <20171114134322.40321-1-kirill.shutemov@linux.intel.com>
Message-ID: <alpine.DEB.2.20.1711141630210.2044@nanos>
References: <20171114134322.40321-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Nicholas Piggin <npiggin@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 14 Nov 2017, Kirill A. Shutemov wrote:
> --- a/arch/x86/mm/hugetlbpage.c
> +++ b/arch/x86/mm/hugetlbpage.c
> @@ -166,11 +166,20 @@ hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
>  
>  	if (addr) {
>  		addr = ALIGN(addr, huge_page_size(h));
> +		if (TASK_SIZE - len >= addr)
> +			goto get_unmapped_area;

That's wrong. You got it right in arch_get_unmapped_area_topdown() ...

> +
> +		/* See a comment in arch_get_unmapped_area_topdown */

This is lame, really.

> +		if ((addr > DEFAULT_MAP_WINDOW) !=
> +				(addr + len > DEFAULT_MAP_WINDOW))
> +			goto get_unmapped_area;

Instead of duplicating that horrible formatted condition and adding this
lousy comment why can't you just put all of it (including the TASK_SIZE
check) into a proper validation function and put the comment there?

The fixed up variant of your patch below does that.

Aside of that please spend a bit more time on describing things precisely
at the technical and factual level next time. I fixed that up (once more)
both in the comment and the changelog.

Please double check.

Thanks,

	tglx

8<----------------
Subject: x86/mm: Prevent non-MAP_FIXED mapping across DEFAULT_MAP_WINDOW border
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Date: Tue, 14 Nov 2017 16:43:21 +0300

In case of 5-level paging, the kernel does not place any mapping above
47-bit, unless userspace explicitly asks for it.

Userspace can request an allocation from the full address space by
specifying the mmap address hint above 47-bit.

Nicholas noticed that the current implementation violates this interface:

  If user space requests a mapping at the end of the 47-bit address space
  with a length which causes the mapping to cross the 47-bit border
  (DEFAULT_MAP_WINDOW), then the vma is partially in the address space
  below and above.

Sanity check the mmap address hint so that start and end of the resulting
vma are on the same side of the 47-bit border. If that's not the case fall
back to the code path which ignores the address hint and allocate from the
regular address space below 47-bit.

[ tglx: Moved the address check to a function and massaged comment and
  	changelog ]

Reported-by: Nicholas Piggin <npiggin@gmail.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Link: https://lkml.kernel.org/r/20171114134322.40321-1-kirill.shutemov@linux.intel.com

---
 arch/x86/include/asm/elf.h   |    1 
 arch/x86/kernel/sys_x86_64.c |    8 +++++--
 arch/x86/mm/hugetlbpage.c    |    9 ++++++-
 arch/x86/mm/mmap.c           |   49 +++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 63 insertions(+), 4 deletions(-)

--- a/arch/x86/include/asm/elf.h
+++ b/arch/x86/include/asm/elf.h
@@ -309,6 +309,7 @@ static inline int mmap_is_ia32(void)
 extern unsigned long task_size_32bit(void);
 extern unsigned long task_size_64bit(int full_addr_space);
 extern unsigned long get_mmap_base(int is_legacy);
+extern bool mmap_address_hint_valid(unsigned long addr, unsigned long len);
 
 #ifdef CONFIG_X86_32
 
--- a/arch/x86/kernel/sys_x86_64.c
+++ b/arch/x86/kernel/sys_x86_64.c
@@ -188,6 +188,7 @@ arch_get_unmapped_area_topdown(struct fi
 	if (len > TASK_SIZE)
 		return -ENOMEM;
 
+	/* No address checking. See comment at mmap_address_hint_valid() */
 	if (flags & MAP_FIXED)
 		return addr;
 
@@ -198,11 +199,14 @@ arch_get_unmapped_area_topdown(struct fi
 	/* requesting a specific address */
 	if (addr) {
 		addr = PAGE_ALIGN(addr);
+		if (!mmap_address_hint_valid(addr, len))
+			goto get_unmapped_area;
+
 		vma = find_vma(mm, addr);
-		if (TASK_SIZE - len >= addr &&
-				(!vma || addr + len <= vm_start_gap(vma)))
+		if (!vma || addr + len <= vm_start_gap(vma))
 			return addr;
 	}
+get_unmapped_area:
 
 	info.flags = VM_UNMAPPED_AREA_TOPDOWN;
 	info.length = len;
--- a/arch/x86/mm/hugetlbpage.c
+++ b/arch/x86/mm/hugetlbpage.c
@@ -158,6 +158,7 @@ hugetlb_get_unmapped_area(struct file *f
 	if (len > TASK_SIZE)
 		return -ENOMEM;
 
+	/* No address checking. See comment at mmap_address_hint_valid() */
 	if (flags & MAP_FIXED) {
 		if (prepare_hugepage_range(file, addr, len))
 			return -EINVAL;
@@ -166,11 +167,15 @@ hugetlb_get_unmapped_area(struct file *f
 
 	if (addr) {
 		addr = ALIGN(addr, huge_page_size(h));
+		if (!mmap_address_hint_valid(addr, len))
+			goto get_unmapped_area;
+
 		vma = find_vma(mm, addr);
-		if (TASK_SIZE - len >= addr &&
-		    (!vma || addr + len <= vm_start_gap(vma)))
+		if (!vma || addr + len <= vm_start_gap(vma))
 			return addr;
 	}
+
+get_unmapped_area:
 	if (mm->get_unmapped_area == arch_get_unmapped_area)
 		return hugetlb_get_unmapped_area_bottomup(file, addr, len,
 				pgoff, flags);
--- a/arch/x86/mm/mmap.c
+++ b/arch/x86/mm/mmap.c
@@ -174,3 +174,52 @@ const char *arch_vma_name(struct vm_area
 		return "[mpx]";
 	return NULL;
 }
+
+/**
+ * mmap_address_hint_valid - Validate the address hint of mmap
+ * @addr:	Address hint
+ * @len:	Mapping length
+ *
+ * Check whether @addr and @addr + @len result in a valid mapping.
+ *
+ * On 32bit this only checks whether @addr + @len is <= TASK_SIZE.
+ *
+ * On 64bit with 5-level page tables another sanity check is required
+ * because mappings requested by mmap(@addr, 0) which cross the 47-bit
+ * virtual address boundary can cause the following theoretical issue:
+ *
+ *  An application calls mmap(addr, 0), i.e. without MAP_FIXED, where @addr
+ *  is below the border of the 47-bit address space and @addr + @len is
+ *  above the border.
+ *
+ *  With 4-level paging this request succeeds, but the resulting mapping
+ *  address will always be within the 47-bit virtual address space, because
+ *  the hint address does not result in a valid mapping and is
+ *  ignored. Hence applications which are not prepared to handle virtual
+ *  addresses above 47-bit work correctly.
+ *
+ *  With 5-level paging this request would be granted and result in a
+ *  mapping which crosses the border of the 47-bit virtual address
+ *  space. If the application cannot handle addresses above 47-bit this
+ *  will lead to misbehaviour and hard to diagnose failures.
+ *
+ * Therefore ignore address hints which would result in a mapping crossing
+ * the 47-bit virtual address boundary.
+ *
+ * Note, that in the same scenario with MAP_FIXED the behaviour is
+ * different. The request with @addr < 47-bit and @addr + @len > 47-bit
+ * fails on a 4-level paging machine but succeeds on a 5-level paging
+ * machine. It is reasonable to expect that an application does not rely on
+ * the failure of such a fixed mapping request, so the restriction is not
+ * applied.
+ */
+bool mmap_address_hint_valid(unsigned long addr, unsigned long len)
+{
+	if (TASK_SIZE - len < addr)
+		return false;
+#if CONFIG_PGTABLE_LEVELS >= 5
+	return (addr > DEFAULT_MAP_WINDOW) == (addr + len > DEFAULT_MAP_WINDOW);
+#else
+	return true;
+#endif
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
