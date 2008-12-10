From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH] fix mapping_writably_mapped()
Date: Wed, 10 Dec 2008 20:48:52 +0000 (GMT)
Message-ID: <Pine.LNX.4.64.0812102043060.25282@blonde.anvils>
References: <1228855666.6379.84.camel@lts-notebook>
 <Pine.LNX.4.64.0812101312340.16066@blonde.anvils>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <Pine.LNX.4.64.0812101312340.16066@blonde.anvils>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, stable@kernel.org
List-Id: linux-mm.kvack.org

Lee Schermerhorn noticed yesterday that I broke the mapping_writably_mapped
test in 2.6.7!  Bad bad bug, good good find.

The i_mmap_writable count must be incremented for VM_SHARED (just as
i_writecount is for VM_DENYWRITE, but while holding the i_mmap_lock)
when dup_mmap() copies the vma for fork: it has its own more optimal
version of __vma_link_file(), and I missed this out.  So the count
was later going down to 0 (dangerous) when one end unmapped, then
wrapping negative (inefficient) when the other end unmapped.

The only impact on x86 would have been that setting a mandatory lock on
a file which has at some time been opened O_RDWR and mapped MAP_SHARED
(but not necessarily PROT_WRITE) across a fork, might fail with -EAGAIN
when it should succeed, or succeed when it should fail.

But those architectures which rely on flush_dcache_page() to flush
userspace modifications back into the page before the kernel reads it,
may in some cases have skipped the flush after such a fork - though any
repetitive test will soon wrap the count negative, in which case it will
flush_dcache_page() unnecessarily.

Fix would be a two-liner, but mapping variable added, and comment moved.

Reported-by: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 kernel/fork.c |   15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

--- 2.6.28-rc7/kernel/fork.c	2008-11-15 23:09:30.000000000 +0000
+++ linux/kernel/fork.c	2008-12-10 12:49:13.000000000 +0000
@@ -315,17 +315,20 @@ static int dup_mmap(struct mm_struct *mm
 		file = tmp->vm_file;
 		if (file) {
 			struct inode *inode = file->f_path.dentry->d_inode;
+			struct address_space *mapping = file->f_mapping;
+
 			get_file(file);
 			if (tmp->vm_flags & VM_DENYWRITE)
 				atomic_dec(&inode->i_writecount);
-
-			/* insert tmp into the share list, just after mpnt */
-			spin_lock(&file->f_mapping->i_mmap_lock);
+			spin_lock(&mapping->i_mmap_lock);
+			if (tmp->vm_flags & VM_SHARED)
+				mapping->i_mmap_writable++;
 			tmp->vm_truncate_count = mpnt->vm_truncate_count;
-			flush_dcache_mmap_lock(file->f_mapping);
+			flush_dcache_mmap_lock(mapping);
+			/* insert tmp into the share list, just after mpnt */
 			vma_prio_tree_add(tmp, mpnt);
-			flush_dcache_mmap_unlock(file->f_mapping);
-			spin_unlock(&file->f_mapping->i_mmap_lock);
+			flush_dcache_mmap_unlock(mapping);
+			spin_unlock(&mapping->i_mmap_lock);
 		}
 
 		/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
