Received: by uproxy.gmail.com with SMTP id u40so584946ugc
        for <linux-mm@kvack.org>; Mon, 20 Mar 2006 05:37:59 -0800 (PST)
Message-ID: <bc56f2f0603200537s6157aec8m@mail.gmail.com>
Date: Mon, 20 Mar 2006 08:37:59 -0500
From: "Stone Wang" <pwstone@gmail.com>
Subject: [PATCH][6/8] mm: munmap/munmap/mremap and relative
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Adjust VM_LOCKED relative operations in munmap/mmap/mremap:
 replacing make_pages_present with make_pages_wired.

Signed-off-by: Shaoping Wang <pwstone@gmail.com>

 mmap.c   |    8 ++++----
 mremap.c |    4 ++--
 2 files changed, 6 insertions(+), 6 deletions(-)
--

diff -urN linux-2.6.15.orig/mm/mmap.c linux-2.6.15/mm/mmap.c
--- linux-2.6.15.orig/mm/mmap.c	2006-02-17 05:24:09.000000000 -0500
+++ linux-2.6.15/mm/mmap.c	2006-03-06 06:30:08.000000000 -0500
@@ -1119,7 +1119,7 @@
 	vm_stat_account(mm, vm_flags, file, len >> PAGE_SHIFT);
 	if (vm_flags & VM_LOCKED) {
 		mm->locked_vm += len >> PAGE_SHIFT;
-		make_pages_present(addr, addr + len);
+		make_pages_wired(addr, addr + len);
 	}
 	if (flags & MAP_POPULATE) {
 		up_write(&mm->mmap_sem);
@@ -1551,7 +1551,7 @@
 	if (!prev || expand_stack(prev, addr))
 		return NULL;
 	if (prev->vm_flags & VM_LOCKED) {
-		make_pages_present(addr, prev->vm_end);
+		make_pages_wired(addr, prev->vm_end);
 	}
 	return prev;
 }
@@ -1614,7 +1614,7 @@
 	if (expand_stack(vma, addr))
 		return NULL;
 	if (vma->vm_flags & VM_LOCKED) {
-		make_pages_present(addr, start);
+		make_pages_wired(addr, start);
 	}
 	return vma;
 }
@@ -1921,7 +1921,7 @@
 	mm->total_vm += len >> PAGE_SHIFT;
 	if (flags & VM_LOCKED) {
 		mm->locked_vm += len >> PAGE_SHIFT;
-		make_pages_present(addr, addr + len);
+		make_pages_wired(addr, addr + len);
 	}
 	return addr;
 }
diff -urN linux-2.6.15.orig/mm/mremap.c linux-2.6.15/mm/mremap.c
--- linux-2.6.15.orig/mm/mremap.c	2006-01-02 22:21:10.000000000 -0500
+++ linux-2.6.15/mm/mremap.c	2006-03-06 06:30:08.000000000 -0500
@@ -230,7 +230,7 @@
 	if (vm_flags & VM_LOCKED) {
 		mm->locked_vm += new_len >> PAGE_SHIFT;
 		if (new_len > old_len)
-			make_pages_present(new_addr + old_len,
+			make_pages_wired(new_addr + old_len,
 					   new_addr + new_len);
 	}

@@ -367,7 +367,7 @@
 			vm_stat_account(mm, vma->vm_flags, vma->vm_file, pages);
 			if (vma->vm_flags & VM_LOCKED) {
 				mm->locked_vm += pages;
-				make_pages_present(addr + old_len,
+				make_pages_wired(addr + old_len,
 						   addr + new_len);
 			}
 			ret = addr;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
