Date: Mon, 22 Nov 2004 15:00:37 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: page fault scalability patch V11 [1/7]: sloppy rss
In-Reply-To: <Pine.LNX.4.58.0411191729240.1719@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.44.0411221457240.2970-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: torvalds@osdl.org, akpm@osdl.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 19 Nov 2004, Christoph Lameter wrote:
> On Fri, 19 Nov 2004, Hugh Dickins wrote:
> 
> > Sorry, against what tree do these patches apply?
> > Apparently not linux-2.6.9, nor latest -bk, nor -mm?
> 
> 2.6.10-rc2-bk3

Ah, thanks - got it patched now, but your mailer (or something else)
is eating trailing spaces.  Better than adding them, but we have to
apply this patch before your set:

--- 2.6.10-rc2-bk3/include/asm-i386/system.h	2004-11-15 16:21:12.000000000 +0000
+++ linux/include/asm-i386/system.h	2004-11-22 14:44:30.761904592 +0000
@@ -273,9 +273,9 @@ static inline unsigned long __cmpxchg(vo
 #define cmpxchg(ptr,o,n)\
 	((__typeof__(*(ptr)))__cmpxchg((ptr),(unsigned long)(o),\
 					(unsigned long)(n),sizeof(*(ptr))))
-    
+
 #ifdef __KERNEL__
-struct alt_instr { 
+struct alt_instr {
 	__u8 *instr; 		/* original instruction */
 	__u8 *replacement;
 	__u8  cpuid;		/* cpuid bit set for replacement */
--- 2.6.10-rc2-bk3/include/asm-s390/pgalloc.h	2004-05-10 03:33:39.000000000 +0100
+++ linux/include/asm-s390/pgalloc.h	2004-11-22 14:54:43.704723120 +0000
@@ -99,7 +99,7 @@ static inline void pgd_populate(struct m
 
 #endif /* __s390x__ */
 
-static inline void 
+static inline void
 pmd_populate_kernel(struct mm_struct *mm, pmd_t *pmd, pte_t *pte)
 {
 #ifndef __s390x__
--- 2.6.10-rc2-bk3/mm/memory.c	2004-11-18 17:56:11.000000000 +0000
+++ linux/mm/memory.c	2004-11-22 14:39:33.924030808 +0000
@@ -1424,7 +1424,7 @@ out:
 /*
  * We are called with the MM semaphore and page_table_lock
  * spinlock held to protect against concurrent faults in
- * multithreaded programs. 
+ * multithreaded programs.
  */
 static int
 do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
@@ -1615,7 +1615,7 @@ static int do_file_page(struct mm_struct
 	 * Fall back to the linear mapping if the fs does not support
 	 * ->populate:
 	 */
-	if (!vma->vm_ops || !vma->vm_ops->populate || 
+	if (!vma->vm_ops || !vma->vm_ops->populate ||
 			(write_access && !(vma->vm_flags & VM_SHARED))) {
 		pte_clear(pte);
 		return do_no_page(mm, vma, address, write_access, pte, pmd);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
