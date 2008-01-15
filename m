Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate8.de.ibm.com (8.13.8/8.13.8) with ESMTP id m0FD5oJs293154
	for <linux-mm@kvack.org>; Tue, 15 Jan 2008 13:05:50 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0FD5oJb2494636
	for <linux-mm@kvack.org>; Tue, 15 Jan 2008 14:05:50 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0FD5ohV032513
	for <linux-mm@kvack.org>; Tue, 15 Jan 2008 14:05:50 +0100
Subject: Re: [rfc][patch 1/4] include: add callbacks to toggle reference
	counting for VM_MIXEDMAP pages
From: Carsten Otte <cotte@de.ibm.com>
In-Reply-To: <20080113024410.GA22285@wotan.suse.de>
References: <20071221102052.GB28484@wotan.suse.de>
	 <476B96D6.2010302@de.ibm.com> <20071221104701.GE28484@wotan.suse.de>
	 <1199784954.25114.27.camel@cotte.boeblingen.de.ibm.com>
	 <1199891032.28689.9.camel@cotte.boeblingen.de.ibm.com>
	 <1199891645.28689.22.camel@cotte.boeblingen.de.ibm.com>
	 <6934efce0801091017t7f9041abs62904de3722cadc@mail.gmail.com>
	 <4785D064.1040501@de.ibm.com>
	 <6934efce0801101201t72e9b7c4ra88d6fda0f08b1b2@mail.gmail.com>
	 <47872CA7.40802@de.ibm.com>  <20080113024410.GA22285@wotan.suse.de>
Content-Type: text/plain
Date: Tue, 15 Jan 2008 14:05:50 +0100
Message-Id: <1200402350.27120.28.camel@cotte.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: carsteno@de.ibm.com, Jared Hulbert <jaredeh@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>
List-ID: <linux-mm.kvack.org>

Am Sonntag, den 13.01.2008, 03:44 +0100 schrieb Nick Piggin:
> I've just been looking at putting everything together (including the
> pte_special patch). I still hit one problem with your required modification
> to the filemap_xip patch.
> 
> You need to unconditionally do a vm_insert_pfn in xip_file_fault, and rely
> on the pte bit to tell the rest of the VM that the page has not been
> refcounted. For architectures without such a bit, this breaks VM_MIXEDMAP,
> because it relies on testing pfn_valid() rather than a pte bit here.
> We can go 2 ways here: either s390 can make pfn_valid() work like we'd
> like; or we can have a vm_insert_mixedmap_pfn(), which has
> #ifdef __HAVE_ARCH_PTE_SPECIAL
> in order to do the right thing (ie. those architectures which do have pte
> special can just do vm_insert_pfn, and those that don't will either do a
> vm_insert_pfn or vm_insert_page depending on the result of pfn_valid).
> 
> The latter I guess is more efficient for those that do implement pte_special,
> however if anything I would rather investigate that as an incremental patch
> after the basics are working. It would also break the dependency of the
> xip stuff on the pte_special patch, and basically make everything much
> more likely to get merged IMO.
The change in semantic of pfn_valid() for VM_MIXEDMAP keeps coming up,
and I keep saying it's a bad idea. To figure how it really looks like,
I've done the patch (at the end of this mail) to make pfn_valid() walk
the list of dcss segments. I ran into a few issues:
a) it does'nt work because we need to grab a mutex in atomic
This sanity check in vm_normal_page uses pfn_valid() in the fast path:
        /*
         * Add some anal sanity checks for now. Eventually, we should just do
         * "return pfn_to_page(pfn)", but in the meantime we check thaclarificationt we get
         * a valid pfn, and that the resulting page looks ok.
         */
        if (unlikely(!pfn_valid(pfn))) {
                print_bad_pte(vma, pte, addr);
                return NULL;
        }
And that is evaluated in context of get_user_pages() where we may not
grab our list mutex. The result looks like this:
    <3>BUG: sleeping function called from invalid context at
kernel/mutex.c:87
    <4>in_atomic():1, irqs_disabled():0
    <4>Call Trace:
    <4>([<0000000000103556>] show_trace+0x12e/0x148)
    <4> [<00000000001208da>] __might_sleep+0x10a/0x118
    <4> [<0000000000409024>] mutex_lock+0x30/0x6c
    <4> [<0000000000102158>] pfn_in_shared_memory+0x38/0xcc
    <4> [<000000000017f1be>] vm_normal_page+0xa2/0x140
    <4> [<000000000017fc9e>] follow_page+0x1da/0x274
    <4> [<0000000000182030>] get_user_pages+0x144/0x488
    <4> [<00000000001a2926>] get_arg_page+0x5a/0xc4
    <4> [<00000000001a2c60>] copy_strings+0x164/0x274
    <4> [<00000000001a2dcc>] copy_strings_kernel+0x5c/0xb0
    <4> [<00000000001a47a8>] do_execve+0x194/0x214
    <4> [<0000000000110262>] kernel_execve+0x28/0x70
    <4> [<0000000000100112>] init_post+0x72/0x114
    <4> [<000000000064e3f0>] kernel_init+0x288/0x398
    <4> [<0000000000107366>] kernel_thread_starter+0x6/0xc
    <4> [<0000000000107360>] kernel_thread_starter+0x0/0xc
The list protection could be changed to a spinlock to make this work.

b) is is a big performance penality in the fast path
Due to the fact that pfn_valid() is checked on regular minor faults
without VM_MIXEDMAP, we'll have a lock and walking a potentially long
list on a critical path.

c) the patch looks ugly
Primitives like pfn_valid() should be a small check or a small inline
assembly. The need to call back to high level kernel code from core-vm
looks wrong to me. Read the patch, and I think you'll come to the same
conclusion.

d) timing
pfn_valid() is evaluated before our dcss list got initialized. We could
circumvent this by adding an extra check like "if the list was not
initialized, and we have memory behind the pfn we assume that the pfn is
valid without reading the list", but that would make this thing even
more ugly.

I've talked this over with Martin, and we concluded that:
- the semantics of pfn_valid() are unclear and need to be clarified
- using pfn_valid() to tell which pages have a struct page backing is
not an option for s390. We'd rather prefer to keep our struct page
entries that we'd love to get rid of over this ugly hack.

Thus, I think we have a dependency on pte_special as a prereqisite to
VM_PFNMAP for xip.

---
Index: linux-2.6/arch/s390/mm/vmem.c
===================================================================
--- linux-2.6.orig/arch/s390/mm/vmem.c
+++ linux-2.6/arch/s390/mm/vmem.c
@@ -339,6 +339,27 @@ out:
 	return ret;
 }
 
+int pfn_in_shared_memory(unsigned long pfn)
+{
+	int rc;
+	struct memory_segment *tmp;
+
+	mutex_lock(&vmem_mutex);
+
+	list_for_each_entry(tmp, &mem_segs, list) {
+		if ((tmp->start >= pfn << PAGE_SHIFT) &&
+		    (tmp->start + tmp->size - 1 < pfn << PAGE_SHIFT)) {
+			rc = 1;
+			goto out;
+		}
+	}
+	rc = 0;
+out:
+	mutex_unlock(&vmem_mutex);
+	return rc;
+}
+
+
 /*
  * map whole physical memory to virtual memory (identity mapping)
  */
Index: linux-2.6/include/asm-s390/page.h
===================================================================
--- linux-2.6.orig/include/asm-s390/page.h
+++ linux-2.6/include/asm-s390/page.h
@@ -135,7 +135,11 @@ page_get_storage_key(unsigned long addr)
 
 extern unsigned long max_pfn;
 
-static inline int pfn_valid(unsigned long pfn)
+extern int add_shared_memory(unsigned long start, unsigned long size);
+extern int remove_shared_memory(unsigned long start, unsigned long size);
+extern int pfn_in_shared_memory(unsigned long pfn);
+
+static inline int __pfn_in_kmap(unsigned long pfn)
 {
 	unsigned long dummy;
 	int ccode;
@@ -153,6 +157,13 @@ static inline int pfn_valid(unsigned lon
 	return !ccode;
 }
 
+static inline int pfn_valid(unsigned long pfn)
+{
+	if (__pfn_in_kmap(pfn) && !pfn_in_shared_memory(pfn))
+		return 1;
+	return 0;
+}
+
 #endif /* !__ASSEMBLY__ */
 
 /* to align the pointer to the (next) page boundary */
@@ -164,7 +175,7 @@ static inline int pfn_valid(unsigned lon
 #define __va(x)                 (void *)(unsigned long)(x)
 #define virt_to_page(kaddr)	pfn_to_page(__pa(kaddr) >> PAGE_SHIFT)
 #define page_to_phys(page)	(page_to_pfn(page) << PAGE_SHIFT)
-#define virt_addr_valid(kaddr)	pfn_valid(__pa(kaddr) >> PAGE_SHIFT)
+#define virt_addr_valid(kaddr)	__pfn_in_kmap(__pa(kaddr) >> PAGE_SHIFT)
 
 #define VM_DATA_DEFAULT_FLAGS	(VM_READ | VM_WRITE | VM_EXEC | \
 				 VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC)
Index: linux-2.6/include/asm-s390/pgtable.h
===================================================================
--- linux-2.6.orig/include/asm-s390/pgtable.h
+++ linux-2.6/include/asm-s390/pgtable.h
@@ -957,9 +957,6 @@ static inline pte_t mk_swap_pte(unsigned
 
 #define kern_addr_valid(addr)   (1)
 
-extern int add_shared_memory(unsigned long start, unsigned long size);
-extern int remove_shared_memory(unsigned long start, unsigned long size);
-
 /*
  * No page table caches to initialise
  */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
