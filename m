Date: Wed, 15 Aug 2001 13:35:35 -0400 (EDT)
From: Ben LaHaise <bcrl@redhat.com>
Subject: [PATCH]
Message-ID: <Pine.LNX.4.33.0108151326180.31764-100000@touchme.toronto.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@transmeta.com, alan@redhat.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

The patch below enables vma merging for a couple of additional cases with
anon mmaps as glibc has a habit of passing in differing flags for some
cases (ie memory remapping, extending specific malloc blocks, etc).  This
is to help Mozilla which ends up with thousands of vma's that are
sequential and anonymous, but unmerged.  There may still be issues with
mremap, but I think this is a step in the right direction.

		-ben

diff -urN /md0/kernels/2.4/v2.4.8-ac5/mm/mmap.c work-v2.4.8-ac5/mm/mmap.c
--- /md0/kernels/2.4/v2.4.8-ac5/mm/mmap.c	Wed Aug 15 12:57:40 2001
+++ work-v2.4.8-ac5/mm/mmap.c	Wed Aug 15 13:02:35 2001
@@ -309,7 +309,8 @@
 	if (addr && !file && !(vm_flags & VM_SHARED)) {
 		struct vm_area_struct * vma = find_vma(mm, addr-1);
 		if (vma && vma->vm_end == addr && !vma->vm_file &&
-		    vma->vm_flags == vm_flags) {
+		    (vma->vm_flags & ~(MAP_NORESERVE | MAP_FIXED)) ==
+		    (vm_flags & ~(MAP_NORESERVE | MAP_FIXED))) {
 			vma->vm_end = addr + len;
 			goto out;
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
