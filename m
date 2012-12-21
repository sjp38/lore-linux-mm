Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id EB8026B0088
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 19:50:25 -0500 (EST)
Received: by mail-da0-f53.google.com with SMTP id x6so1785645dac.26
        for <linux-mm@kvack.org>; Thu, 20 Dec 2012 16:50:25 -0800 (PST)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 9/9] mm: introduce VM_POPULATE flag to better deal with racy userspace programs
Date: Thu, 20 Dec 2012 16:49:57 -0800
Message-Id: <1356050997-2688-10-git-send-email-walken@google.com>
In-Reply-To: <1356050997-2688-1-git-send-email-walken@google.com>
References: <1356050997-2688-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Ingo Molnar <mingo@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Jorn_Engel <joern@logfs.org>, Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The vm_populate() code populates user mappings without constantly
holding the mmap_sem. This makes it susceptible to racy userspace
programs: the user mappings may change while vm_populate() is running,
and in this case vm_populate() may end up populating the new mapping
instead of the old one.

In order to reduce the possibility of userspace getting surprised by
this behavior, this change introduces the VM_POPULATE vma flag which
gets set on vmas we want vm_populate() to work on. This way
vm_populate() may still end up populating the new mapping after such a
race, but only if the new mapping is also one that the user has
requested (using MAP_SHARED, MAP_LOCKED or mlock) to be populated.

Signed-off-by: Michel Lespinasse <walken@google.com>

---
 include/linux/mm.h   |    1 +
 include/linux/mman.h |    4 +++-
 mm/fremap.c          |   12 ++++++++++--
 mm/mlock.c           |   19 ++++++++++---------
 mm/mmap.c            |    4 +---
 5 files changed, 25 insertions(+), 15 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index d32ace5fba93..77311274f0b5 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -87,6 +87,7 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_PFNMAP	0x00000400	/* Page-ranges managed without "struct page", just pure PFN */
 #define VM_DENYWRITE	0x00000800	/* ETXTBSY on write attempts.. */
 
+#define VM_POPULATE     0x00001000
 #define VM_LOCKED	0x00002000
 #define VM_IO           0x00004000	/* Memory mapped I/O or similar */
 
diff --git a/include/linux/mman.h b/include/linux/mman.h
index d09dde1e57fb..e4ad758962e5 100644
--- a/include/linux/mman.h
+++ b/include/linux/mman.h
@@ -77,6 +77,8 @@ calc_vm_flag_bits(unsigned long flags)
 {
 	return _calc_vm_trans(flags, MAP_GROWSDOWN,  VM_GROWSDOWN ) |
 	       _calc_vm_trans(flags, MAP_DENYWRITE,  VM_DENYWRITE ) |
-	       _calc_vm_trans(flags, MAP_LOCKED,     VM_LOCKED    );
+	       ((flags & MAP_LOCKED) ? (VM_LOCKED | VM_POPULATE) : 0) |
+	       (((flags & (MAP_POPULATE | MAP_NONBLOCK)) == MAP_POPULATE) ?
+							VM_POPULATE : 0);
 }
 #endif /* _LINUX_MMAN_H */
diff --git a/mm/fremap.c b/mm/fremap.c
index 503a72387087..0cd4c11488ed 100644
--- a/mm/fremap.c
+++ b/mm/fremap.c
@@ -204,8 +204,10 @@ get_write_lock:
 			unsigned long addr;
 			struct file *file = get_file(vma->vm_file);
 
-			addr = mmap_region(file, start, size,
-					vma->vm_flags, pgoff);
+			vm_flags = vma->vm_flags;
+			if (!(flags & MAP_NONBLOCK))
+				vm_flags |= VM_POPULATE;
+			addr = mmap_region(file, start, size, vm_flags, pgoff);
 			fput(file);
 			if (IS_ERR_VALUE(addr)) {
 				err = addr;
@@ -224,6 +226,12 @@ get_write_lock:
 		mutex_unlock(&mapping->i_mmap_mutex);
 	}
 
+	if (!(flags & MAP_NONBLOCK) && !(vma->vm_flags & VM_POPULATE)) {
+		if (!has_write_lock)
+			goto get_write_lock;
+		vma->vm_flags |= VM_POPULATE;
+	}
+
 	if (vma->vm_flags & VM_LOCKED) {
 		/*
 		 * drop PG_Mlocked flag for over-mapped range
diff --git a/mm/mlock.c b/mm/mlock.c
index ab0cfe21f538..b1647fbd6bce 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -340,9 +340,9 @@ static int do_mlock(unsigned long start, size_t len, int on)
 
 		/* Here we know that  vma->vm_start <= nstart < vma->vm_end. */
 
-		newflags = vma->vm_flags | VM_LOCKED;
-		if (!on)
-			newflags &= ~VM_LOCKED;
+		newflags = vma->vm_flags & ~VM_LOCKED;
+		if (on)
+			newflags |= VM_LOCKED | VM_POPULATE;
 
 		tmp = vma->vm_end;
 		if (tmp > end)
@@ -402,7 +402,8 @@ int __mm_populate(unsigned long start, unsigned long len, int ignore_errors)
 		 * range with the first VMA. Also, skip undesirable VMA types.
 		 */
 		nend = min(end, vma->vm_end);
-		if (vma->vm_flags & (VM_IO | VM_PFNMAP))
+		if ((vma->vm_flags & (VM_IO | VM_PFNMAP | VM_POPULATE)) !=
+		    VM_POPULATE)
 			continue;
 		if (nstart < vma->vm_start)
 			nstart = vma->vm_start;
@@ -475,9 +476,9 @@ static int do_mlockall(int flags)
 	struct vm_area_struct * vma, * prev = NULL;
 	unsigned int def_flags;
 
-	def_flags = current->mm->def_flags & ~VM_LOCKED;
+	def_flags = current->mm->def_flags & ~(VM_LOCKED | VM_POPULATE);
 	if (flags & MCL_FUTURE)
-		def_flags |= VM_LOCKED;
+		def_flags |= (VM_LOCKED | VM_POPULATE);
 	current->mm->def_flags = def_flags;
 	if (flags == MCL_FUTURE)
 		goto out;
@@ -485,9 +486,9 @@ static int do_mlockall(int flags)
 	for (vma = current->mm->mmap; vma ; vma = prev->vm_next) {
 		vm_flags_t newflags;
 
-		newflags = vma->vm_flags | VM_LOCKED;
-		if (!(flags & MCL_CURRENT))
-			newflags &= ~VM_LOCKED;
+		newflags = vma->vm_flags & ~VM_LOCKED;
+		if (flags & MCL_CURRENT)
+			newflags |= VM_LOCKED | VM_POPULATE;
 
 		/* Ignore errors */
 		mlock_fixup(vma, &prev, vma->vm_start, vma->vm_end, newflags);
diff --git a/mm/mmap.c b/mm/mmap.c
index 290d023632e6..27f98850fa8c 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1153,9 +1153,7 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 	}
 
 	addr = mmap_region(file, addr, len, vm_flags, pgoff);
-	if (!IS_ERR_VALUE(addr) &&
-	    ((vm_flags & VM_LOCKED) ||
-	     (flags & (MAP_POPULATE | MAP_NONBLOCK)) == MAP_POPULATE))
+	if (!IS_ERR_VALUE(addr) && (vm_flags & VM_POPULATE))
 		*populate = true;
 	return addr;
 }
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
