Message-Id: <200505200214.j4K2Ecg06778@unix-os.sc.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: [PATCH] Avoiding mmap fragmentation - clean rev
Date: Thu, 19 May 2005 19:14:38 -0700
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: 
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Andrew Morton' <akpm@osdl.org>, 'Wolfgang Wander' <wwc@rentec.com>
Cc: herve@elma.fr, mingo@elte.hu, arjanv@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Chen, Kenneth W wrote on Thursday, May 19, 2005 7:02 PM
> Oh well, I guess we have to take a performance hit here in favor of
> functionality.  Though this is a problem specific to 32-bit address
> space, please don't unnecessarily penalize 64-bit arch.  If Andrew is
> going to take Wolfgang's patch, then we should minimally take the
> following patch.  This patch revert changes made in arch/ia64 and make
> x86_64 to use alternate cache algorithm for 32-bit app.

Oh, crap, there is a typo in my patch and it won't compile on x86_64.
Here is an updated version.  Please this one instead.


Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>

--- linux-2.6.11/arch/ia64/kernel/sys_ia64.c.orig	2005-05-19 18:35:31.468087777 -0700
+++ linux-2.6.11/arch/ia64/kernel/sys_ia64.c	2005-05-19 18:35:46.521798000 -0700
@@ -38,14 +38,8 @@ arch_get_unmapped_area (struct file *fil
 	if (REGION_NUMBER(addr) == REGION_HPAGE)
 		addr = 0;
 #endif
-	if (!addr) {
-	        if (len > mm->cached_hole_size) {
-		        addr = mm->free_area_cache;
-		} else {
-		        addr = TASK_UNMAPPED_BASE;
-			mm->cached_hole_size = 0;
-		}
-	}
+	if (!addr)
+		addr = mm->free_area_cache;
 
 	if (map_shared && (TASK_SIZE > 0xfffffffful))
 		/*
@@ -65,7 +59,6 @@ arch_get_unmapped_area (struct file *fil
 			if (start_addr != TASK_UNMAPPED_BASE) {
 				/* Start a new search --- just in case we missed some holes.  */
 				addr = TASK_UNMAPPED_BASE;
-				mm->cached_hole_size = 0;
 				goto full_search;
 			}
 			return -ENOMEM;
@@ -75,8 +68,6 @@ arch_get_unmapped_area (struct file *fil
 			mm->free_area_cache = addr + len;
 			return addr;
 		}
-		if (addr + mm->cached_hole_size < vma->vm_start)
-		        mm->cached_hole_size = vma->vm_start - addr;
 		addr = (vma->vm_end + align_mask) & ~align_mask;
 	}
 }
--- linux-2.6.11/arch/x86_64/kernel/sys_x86_64.c.orig	2005-05-19 18:37:32.202461298 -0700
+++ linux-2.6.11/arch/x86_64/kernel/sys_x86_64.c	2005-05-19 18:39:03.110663309 -0700
@@ -111,7 +111,7 @@ arch_get_unmapped_area(struct file *filp
 		    (!vma || addr + len <= vma->vm_start))
 			return addr;
 	}
-	if (len <= mm->cached_hole_size) {
+	if (begin != TASK_UNMAPPED_64 && len <= mm->cached_hole_size) {
 	        mm->cached_hole_size = 0;
 		mm->free_area_cache = begin;
 	}



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
