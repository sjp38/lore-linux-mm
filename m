Date: Mon, 2 Apr 2007 11:30:31 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [SLUB 2/2] i386 arch page size slab fixes
In-Reply-To: <20070331125536.a984e5ce.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0704021125210.31277@schroedinger.engr.sgi.com>
References: <20070331193056.1800.68058.sendpatchset@schroedinger.engr.sgi.com>
 <20070331193107.1800.28259.sendpatchset@schroedinger.engr.sgi.com>
 <20070331125536.a984e5ce.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mpm@selenic.com
List-ID: <linux-mm.kvack.org>

On Sat, 31 Mar 2007, Andrew Morton wrote:

> Can we disable SLUB on i386 in Kconfig until it gets sorted out?

Found it. Another issue with relying on page size special casing in the 
SLAB.


i386: Another case of i386 exploiting page sized slab cache special casing

i386 uses kmalloc to allocate the thread structure assuming that the 
allocation results in a page size aligned allocation. That has worked so 
far because SLAB exempts page sized slabs from debugging and aligns them 
in special ways that gobeyond the restrictions imposed by 
KMALLOC_ARCH_MINALIGN (which are valid for all other kmalloc caches).

SLUB also works fine since the page sized allocations neatly align at page
boundaries. However, if debugging is switched on then SLUB have to add 
additional debugging information after the object increasing the slab 
size. The total object only be aligned following the requirements imposed 
by KMALLOC_ARCH_MINALIGN. There is nothing there that would require
a page size alignment.

The solution here is to replace the calls to kmalloc with calls into 
the page allocator. An alternate solution may be to create a custom slab 
cache and setting the alignment is to PAGE_SIZE (works with SLUB. 
There is no problem here with page_struct modifications). That would allow slub 
debugging to be used on the threadinfo structure.

But this is a page sized allocation after all and for efficiencies sake we 
should call directly into the page allocator and not use slab.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-rc5-mm3/include/asm-i386/thread_info.h
===================================================================
--- linux-2.6.21-rc5-mm3.orig/include/asm-i386/thread_info.h	2007-04-02 05:57:31.000000000 +0000
+++ linux-2.6.21-rc5-mm3/include/asm-i386/thread_info.h	2007-04-02 06:03:09.000000000 +0000
@@ -95,12 +95,14 @@
 
 /* thread information allocation */
 #ifdef CONFIG_DEBUG_STACK_USAGE
-#define alloc_thread_info(tsk) kzalloc(THREAD_SIZE, GFP_KERNEL)
+#define alloc_thread_info(tsk) ((struct thread_info *) \
+	__get_free_pages(GFP_KERNEL| __GFP_ZERO, get_order(THREAD_SIZE)))
 #else
-#define alloc_thread_info(tsk) kmalloc(THREAD_SIZE, GFP_KERNEL)
+#define alloc_thread_info(tsk) ((struct thread_info *) \
+	__get_free_pages(GFP_KERNEL, get_order(THREAD_SIZE)))
 #endif
 
-#define free_thread_info(info)	kfree(info)
+#define free_thread_info(info)	free_pages((unsigned long)(info), get_order(THREAD_SIZE))
 
 #else /* !__ASSEMBLY__ */
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
