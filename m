Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id CFDB66B0069
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 13:50:11 -0500 (EST)
Date: Wed, 11 Jan 2012 10:50:09 -0800
From: Arun Sharma <asharma@fb.com>
Subject: MAP_UNINITIALIZED (Was Re: MAP_NOZERO revisited)
Message-ID: <20120111185009.GA26693@dev3310.snc6.facebook.com>
References: <4F04F0B9.5040401@fb.com>
 <20120105162311.09dac4b7.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120105162311.09dac4b7.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Arun Sharma <asharma@fb.com>, linux-mm@kvack.org, Davide Libenzi <davidel@xmailserver.org>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>

On Thu, Jan 05, 2012 at 04:23:11PM +0900, KAMEZAWA Hiroyuki wrote:
> When pages are freed, it goes back to global page allocator.
> memcg has no page allocator hooks for alloc/free.

I missed this part. Thanks for reminding me.

> We, memcg guys, tries to reduce size of page_cgroup remove page_cgroup->flags.
> And finally want to integrate it to struct 'page'. 
> So, I don't like your idea very much.
> please find another way.

Thinking a bit more, it may be possible to implement this without
page_cgroup->flags using mm_match_cgroup(current->mm, page->mem_cgroup).

> 
> > Security implications: this is not as good as the UID based checks in 
> > Davide's implementation, so should probably be an opt-in instead of 
> > being enabled by default.
> > 
> 
> I think you need an another page allocator as hugetlb.c does and need to
> maintain 'page pool'.

That sounds like a bigger change. All I need is a way of computing
"was this page previously mapped into the current cgroup?" 
without affecting allocator performance. I'm thinking this more relaxed
check is sufficient for many real world use cases.

I also realized that I could use MAP_UNINITIALIZED for this purpose.
Attached is a completely insecure patch, which may be interesting for
embedded use cases on CPUs with MMU.

Yeah, the VM_SAO hack is ugly. Any better suggestions?

 -Arun

commit 37b83f3fb77a177a2f81ebb8aeaec28c2a46e503
Author: Arun Sharma <asharma@fb.com>
Date:   Tue Jan 10 17:02:46 2012 -0800

    mm: Enable MAP_UNINITIALIZED for archs with mmu
    
    This enables malloc optimizations where we might
    madvise(..,MADV_DONTNEED) a page only to fault it
    back at a different virtual address.
    
    Signed-off-by: Arun Sharma <asharma@fb.com>

diff --git a/include/asm-generic/mman-common.h b/include/asm-generic/mman-common.h
index 787abbb..71e079f 100644
--- a/include/asm-generic/mman-common.h
+++ b/include/asm-generic/mman-common.h
@@ -19,11 +19,7 @@
 #define MAP_TYPE	0x0f		/* Mask for type of mapping */
 #define MAP_FIXED	0x10		/* Interpret addr exactly */
 #define MAP_ANONYMOUS	0x20		/* don't use a file */
-#ifdef CONFIG_MMAP_ALLOW_UNINITIALIZED
-# define MAP_UNINITIALIZED 0x4000000	/* For anonymous mmap, memory could be uninitialized */
-#else
-# define MAP_UNINITIALIZED 0x0		/* Don't support this flag */
-#endif
+#define MAP_UNINITIALIZED 0x4000000	/* For anonymous mmap, memory could be uninitialized */
 
 #define MS_ASYNC	1		/* sync memory asynchronously */
 #define MS_INVALIDATE	2		/* invalidate the caches */
diff --git a/include/linux/highmem.h b/include/linux/highmem.h
index 3a93f73..04d838e 100644
--- a/include/linux/highmem.h
+++ b/include/linux/highmem.h
@@ -156,6 +156,11 @@ __alloc_zeroed_user_highpage(gfp_t movableflags,
 	struct page *page = alloc_page_vma(GFP_HIGHUSER | movableflags,
 			vma, vaddr);
 
+#ifdef CONFIG_MMAP_ALLOW_UNINITIALIZED
+	if (!vma->vm_file && vma->vm_flags & VM_UNINITIALIZED)
+		return page;
+#endif
+
 	if (page)
 		clear_user_highpage(page, vaddr);
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 4baadd1..6345c57 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -118,6 +118,8 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_SAO		0x20000000	/* Strong Access Ordering (powerpc) */
 #define VM_PFN_AT_MMAP	0x40000000	/* PFNMAP vma that is fully mapped at mmap time */
 #define VM_MERGEABLE	0x80000000	/* KSM may merge identical pages */
+#define VM_UNINITIALIZED VM_SAO		/* Steal a powerpc bit for now, since we're out 
+					   bits for 32 bit archs */
 
 /* Bits set in the VMA until the stack is in its final location */
 #define VM_STACK_INCOMPLETE_SETUP	(VM_RAND_READ | VM_SEQ_READ)
diff --git a/include/linux/mman.h b/include/linux/mman.h
index 51647b4..f7d4f60 100644
--- a/include/linux/mman.h
+++ b/include/linux/mman.h
@@ -88,6 +88,7 @@ calc_vm_flag_bits(unsigned long flags)
 	return _calc_vm_trans(flags, MAP_GROWSDOWN,  VM_GROWSDOWN ) |
 	       _calc_vm_trans(flags, MAP_DENYWRITE,  VM_DENYWRITE ) |
 	       _calc_vm_trans(flags, MAP_EXECUTABLE, VM_EXECUTABLE) |
+	       _calc_vm_trans(flags, MAP_UNINITIALIZED, VM_UNINITIALIZED) |
 	       _calc_vm_trans(flags, MAP_LOCKED,     VM_LOCKED    );
 }
 #endif /* __KERNEL__ */
diff --git a/init/Kconfig b/init/Kconfig
index 43298f9..428e047 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1259,7 +1259,7 @@ endchoice
 
 config MMAP_ALLOW_UNINITIALIZED
 	bool "Allow mmapped anonymous memory to be uninitialized"
-	depends on EXPERT && !MMU
+	depends on EXPERT
 	default n
 	help
 	  Normally, and according to the Linux spec, anonymous memory obtained
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index c3fdbcb..e6dd642 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1868,6 +1868,12 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
 		put_mems_allowed();
 		return page;
 	}
+
+#ifdef CONFIG_MMAP_ALLOW_UNINITIALIZED
+	if (!vma->vm_file && vma->vm_flags & VM_UNINITIALIZED)
+		gfp &= ~__GFP_ZERO;
+#endif
+
 	/*
 	 * fast path:  default or task policy
 	 */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
