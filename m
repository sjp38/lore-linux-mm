Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id F11176B0038
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 21:40:04 -0400 (EDT)
Received: by mail-da0-f41.google.com with SMTP id w4so3923460dam.14
        for <linux-mm@kvack.org>; Tue, 26 Mar 2013 18:40:04 -0700 (PDT)
Date: Tue, 26 Mar 2013 18:40:00 -0700
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH] Revert "mm: introduce VM_POPULATE flag to better deal with
 racy userspace programs"
Message-ID: <20130327014000.GA9876@google.com>
References: <alpine.LNX.2.00.1303261646070.23041@eggly.anvils>
 <CANN689HuK7773-B3NOxLN9xRRXY=5i1j5Sv_CT8WKChMRw5_Aw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANN689HuK7773-B3NOxLN9xRRXY=5i1j5Sv_CT8WKChMRw5_Aw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Andy Lutomirski <luto@amacapital.net>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This reverts commit 1869305009857cdeaabe6283bcdc2359c5784543.

VM_POPULATE only has any effect when userspace plays racy games with
vmas by trying to unmap and remap memory regions that mmap or mlock
are operating on.

Also, the only effect of VM_POPULATE when userspace plays such games
is that it avoids populating new memory regions that get remapped into
the address range that was being operated on by the original mmap or
mlock calls.

Let's remove VM_POPULATE as there isn't any strong argument to mandate
a new vm_flag.

Proposed-by: Hugh Dickins <hughd@google.com>
Signed-off-by: Michel Lespinasse <walken@google.com>

---
 include/linux/mm.h   |  1 -
 include/linux/mman.h |  4 +---
 mm/fremap.c          | 12 ++----------
 mm/mlock.c           | 11 +++++------
 mm/mmap.c            |  4 +++-
 5 files changed, 11 insertions(+), 21 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 7acc9dc73c9f..e19ff30ad0a2 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -87,7 +87,6 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_PFNMAP	0x00000400	/* Page-ranges managed without "struct page", just pure PFN */
 #define VM_DENYWRITE	0x00000800	/* ETXTBSY on write attempts.. */
 
-#define VM_POPULATE     0x00001000
 #define VM_LOCKED	0x00002000
 #define VM_IO           0x00004000	/* Memory mapped I/O or similar */
 
diff --git a/include/linux/mman.h b/include/linux/mman.h
index 61c7a87e5d2b..9aa863da287f 100644
--- a/include/linux/mman.h
+++ b/include/linux/mman.h
@@ -79,8 +79,6 @@ calc_vm_flag_bits(unsigned long flags)
 {
 	return _calc_vm_trans(flags, MAP_GROWSDOWN,  VM_GROWSDOWN ) |
 	       _calc_vm_trans(flags, MAP_DENYWRITE,  VM_DENYWRITE ) |
-	       ((flags & MAP_LOCKED) ? (VM_LOCKED | VM_POPULATE) : 0) |
-	       (((flags & (MAP_POPULATE | MAP_NONBLOCK)) == MAP_POPULATE) ?
-							VM_POPULATE : 0);
+	       _calc_vm_trans(flags, MAP_LOCKED,     VM_LOCKED    );
 }
 #endif /* _LINUX_MMAN_H */
diff --git a/mm/fremap.c b/mm/fremap.c
index 4723ac8d2fc2..87da3590c61e 100644
--- a/mm/fremap.c
+++ b/mm/fremap.c
@@ -204,10 +204,8 @@ get_write_lock:
 			unsigned long addr;
 			struct file *file = get_file(vma->vm_file);
 
-			vm_flags = vma->vm_flags;
-			if (!(flags & MAP_NONBLOCK))
-				vm_flags |= VM_POPULATE;
-			addr = mmap_region(file, start, size, vm_flags, pgoff);
+			addr = mmap_region(file, start, size,
+					vma->vm_flags, pgoff);
 			fput(file);
 			if (IS_ERR_VALUE(addr)) {
 				err = addr;
@@ -226,12 +224,6 @@ get_write_lock:
 		mutex_unlock(&mapping->i_mmap_mutex);
 	}
 
-	if (!(flags & MAP_NONBLOCK) && !(vma->vm_flags & VM_POPULATE)) {
-		if (!has_write_lock)
-			goto get_write_lock;
-		vma->vm_flags |= VM_POPULATE;
-	}
-
 	if (vma->vm_flags & VM_LOCKED) {
 		/*
 		 * drop PG_Mlocked flag for over-mapped range
diff --git a/mm/mlock.c b/mm/mlock.c
index 1c5e33fce639..79b7cf7d1bca 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -358,7 +358,7 @@ static int do_mlock(unsigned long start, size_t len, int on)
 
 		newflags = vma->vm_flags & ~VM_LOCKED;
 		if (on)
-			newflags |= VM_LOCKED | VM_POPULATE;
+			newflags |= VM_LOCKED;
 
 		tmp = vma->vm_end;
 		if (tmp > end)
@@ -418,8 +418,7 @@ int __mm_populate(unsigned long start, unsigned long len, int ignore_errors)
 		 * range with the first VMA. Also, skip undesirable VMA types.
 		 */
 		nend = min(end, vma->vm_end);
-		if ((vma->vm_flags & (VM_IO | VM_PFNMAP | VM_POPULATE)) !=
-		    VM_POPULATE)
+		if (vma->vm_flags & (VM_IO | VM_PFNMAP))
 			continue;
 		if (nstart < vma->vm_start)
 			nstart = vma->vm_start;
@@ -492,9 +491,9 @@ static int do_mlockall(int flags)
 	struct vm_area_struct * vma, * prev = NULL;
 
 	if (flags & MCL_FUTURE)
-		current->mm->def_flags |= VM_LOCKED | VM_POPULATE;
+		current->mm->def_flags |= VM_LOCKED;
 	else
-		current->mm->def_flags &= ~(VM_LOCKED | VM_POPULATE);
+		current->mm->def_flags &= ~VM_LOCKED;
 	if (flags == MCL_FUTURE)
 		goto out;
 
@@ -503,7 +502,7 @@ static int do_mlockall(int flags)
 
 		newflags = vma->vm_flags & ~VM_LOCKED;
 		if (flags & MCL_CURRENT)
-			newflags |= VM_LOCKED | VM_POPULATE;
+			newflags |= VM_LOCKED;
 
 		/* Ignore errors */
 		mlock_fixup(vma, &prev, vma->vm_start, vma->vm_end, newflags);
diff --git a/mm/mmap.c b/mm/mmap.c
index 2664a47cec93..6466699b16cb 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1306,7 +1306,9 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 	}
 
 	addr = mmap_region(file, addr, len, vm_flags, pgoff);
-	if (!IS_ERR_VALUE(addr) && (vm_flags & VM_POPULATE))
+	if (!IS_ERR_VALUE(addr) &&
+	    ((vm_flags & VM_LOCKED) ||
+	     (flags & (MAP_POPULATE | MAP_NONBLOCK)) == MAP_POPULATE))
 		*populate = len;
 	return addr;
 }
-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
