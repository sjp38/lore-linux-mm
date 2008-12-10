Date: Wed, 10 Dec 2008 13:27:04 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: Question:  mmotm-081207 - Should i_mmap_writable go negative?
In-Reply-To: <1228855666.6379.84.camel@lts-notebook>
Message-ID: <Pine.LNX.4.64.0812101312340.16066@blonde.anvils>
References: <1228855666.6379.84.camel@lts-notebook>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 9 Dec 2008, Lee Schermerhorn wrote:
> I've been trying to figure out how to determine when the last shared
> mapping [vma with VM_SHARED] is removed from a mmap()ed file.  Looking
> at the sources, it appears that vma->vm_file->f_mapping->i_mmap_writable
> counts the number of vmas with VM_SHARED mapping the file.  However, in
> 2.6.28-rc7-mmotm-081207, it appears that i_mmap_writable doesn't get
> incremented when a task fork()s, and can go negative when the parent and
> child both unmap the file.

Wow, that's what I call a good find!

> I recall that this used to work [as I expected] at one time.

Are you sure?  It looks to me to have been wrong ever since I added
i_mmap_writable.  Not that I've tested yet at all.  Here's the patch
I intend to send Linus a.s.a.p: but I do need to test it, and also
extend the comment to say just what's been done wrong all this time.

Big thank you from all our users!
Hugh


Lee Schermerhorn noticed yesterday that I broke the mapping_writably_mapped
test in 2.6.7!  Bad bad bug, good good find.

The i_mmap_writable count must be incremented for VM_SHARED (just as
i_writecount is for VM_DENYWRITE, but while holding the i_mmap_lock)
when dup_mmap() copies the vma for fork: it has its own more optimal
version of __vma_link_file() and I missed this out.  So the count
was later going down to 0 (dangerous) when one end unmapped, then
wrapping negative (inefficient) when the other end unmapped.

Fix would be a two-liner, but mapping variable added and comment moved.

Reported-by: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Not-Quite-Signed-off-by: Hugh Dickins <hugh@veritas.com>
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
