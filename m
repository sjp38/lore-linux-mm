Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1ACE76B0031
	for <linux-mm@kvack.org>; Sun, 15 Jun 2014 22:31:15 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id hz1so763644pad.38
        for <linux-mm@kvack.org>; Sun, 15 Jun 2014 19:31:14 -0700 (PDT)
Received: from mail-pb0-x229.google.com (mail-pb0-x229.google.com [2607:f8b0:400e:c01::229])
        by mx.google.com with ESMTPS id fg5si12027999pad.120.2014.06.15.19.31.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 15 Jun 2014 19:31:14 -0700 (PDT)
Received: by mail-pb0-f41.google.com with SMTP id ma3so3955447pbc.28
        for <linux-mm@kvack.org>; Sun, 15 Jun 2014 19:31:13 -0700 (PDT)
Date: Sun, 15 Jun 2014 19:29:53 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: mm: shm: hang in shmem_fallocate
In-Reply-To: <539A0FC8.8090504@oracle.com>
Message-ID: <alpine.LSU.2.11.1406151921070.2850@eggly.anvils>
References: <52AE7B10.2080201@oracle.com> <52F6898A.50101@oracle.com> <alpine.LSU.2.11.1402081841160.26825@eggly.anvils> <52F82E62.2010709@oracle.com> <539A0FC8.8090504@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Thu, 12 Jun 2014, Sasha Levin wrote:
> On 02/09/2014 08:41 PM, Sasha Levin wrote:
> > On 02/08/2014 10:25 PM, Hugh Dickins wrote:
> >> Would trinity be likely to have a thread or process repeatedly faulting
> >> in pages from the hole while it is being punched?
> > 
> > I can see how trinity would do that, but just to be certain - Cc davej.
> > 
> > On 02/08/2014 10:25 PM, Hugh Dickins wrote:
> >> Does this happen with other holepunch filesystems?  If it does not,
> >> I'd suppose it's because the tmpfs fault-in-newly-created-page path
> >> is lighter than a consistent disk-based filesystem's has to be.
> >> But we don't want to make the tmpfs path heavier to match them.
> > 
> > No, this is strictly limited to tmpfs, and AFAIK trinity tests hole
> > punching in other filesystems and I make sure to get a bunch of those
> > mounted before starting testing.
> 
> Just pinging this one again. I still see hangs in -next where the hang
> location looks same as before:
> 

Please give this patch a try.  It fixes what I can reproduce, but given
your unexplained page_mapped() BUG in this area, we know there's more
yet to be understood, so perhaps this patch won't do enough for you.


[PATCH] shmem: fix faulting into a hole while it's punched

Trinity finds that mmap access to a hole while it's punched from shmem
can prevent the madvise(MADV_REMOVE) or fallocate(FALLOC_FL_PUNCH_HOLE)
from completing, until the reader chooses to stop; with the puncher's
hold on i_mutex locking out all other writers until it can complete.

It appears that the tmpfs fault path is too light in comparison with
its hole-punching path, lacking an i_data_sem to obstruct it; but we
don't want to slow down the common case.

Extend shmem_fallocate()'s existing range notification mechanism, so
shmem_fault() can refrain from faulting pages into the hole while it's
punched, waiting instead on i_mutex (when safe to sleep; or repeatedly
faulting when not).

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/shmem.c |   55 +++++++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 51 insertions(+), 4 deletions(-)

--- 3.16-rc1/mm/shmem.c	2014-06-12 11:20:43.200001098 -0700
+++ linux/mm/shmem.c	2014-06-15 18:32:00.049039969 -0700
@@ -80,11 +80,12 @@ static struct vfsmount *shm_mnt;
 #define SHORT_SYMLINK_LEN 128
 
 /*
- * shmem_fallocate and shmem_writepage communicate via inode->i_private
- * (with i_mutex making sure that it has only one user at a time):
- * we would prefer not to enlarge the shmem inode just for that.
+ * shmem_fallocate communicates with shmem_fault or shmem_writepage via
+ * inode->i_private (with i_mutex making sure that it has only one user at
+ * a time): we would prefer not to enlarge the shmem inode just for that.
  */
 struct shmem_falloc {
+	int	mode;		/* FALLOC_FL mode currently operating */
 	pgoff_t start;		/* start of range currently being fallocated */
 	pgoff_t next;		/* the next page offset to be fallocated */
 	pgoff_t nr_falloced;	/* how many new pages have been fallocated */
@@ -759,6 +760,7 @@ static int shmem_writepage(struct page *
 			spin_lock(&inode->i_lock);
 			shmem_falloc = inode->i_private;
 			if (shmem_falloc &&
+			    !shmem_falloc->mode &&
 			    index >= shmem_falloc->start &&
 			    index < shmem_falloc->next)
 				shmem_falloc->nr_unswapped++;
@@ -1233,6 +1235,43 @@ static int shmem_fault(struct vm_area_st
 	int error;
 	int ret = VM_FAULT_LOCKED;
 
+	/*
+	 * Trinity finds that probing a hole which tmpfs is punching can
+	 * prevent the hole-punch from ever completing: which in turn
+	 * locks writers out with its hold on i_mutex.  So refrain from
+	 * faulting pages into the hole while it's being punched, and
+	 * wait on i_mutex to be released if vmf->flags permits, 
+	 */
+	if (unlikely(inode->i_private)) {
+		struct shmem_falloc *shmem_falloc;
+		spin_lock(&inode->i_lock);
+		shmem_falloc = inode->i_private;
+		if (!shmem_falloc ||
+		    shmem_falloc->mode != FALLOC_FL_PUNCH_HOLE ||
+		    vmf->pgoff < shmem_falloc->start ||
+		    vmf->pgoff >= shmem_falloc->next)
+			shmem_falloc = NULL;
+		spin_unlock(&inode->i_lock);
+		/*
+		 * i_lock has protected us from taking shmem_falloc seriously
+		 * once return from shmem_fallocate() went back up that stack.
+		 * i_lock does not serialize with i_mutex at all, but it does
+		 * not matter if sometimes we wait unnecessarily, or sometimes
+		 * miss out on waiting: we just need to make those cases rare.
+		 */
+		if (shmem_falloc) {
+			if ((vmf->flags & FAULT_FLAG_ALLOW_RETRY) &&
+			   !(vmf->flags & FAULT_FLAG_RETRY_NOWAIT)) {
+				up_read(&vma->vm_mm->mmap_sem);
+				mutex_lock(&inode->i_mutex);
+				mutex_unlock(&inode->i_mutex);
+				return VM_FAULT_RETRY;
+			}
+			/* cond_resched? Leave that to GUP or return to user */
+			return VM_FAULT_NOPAGE;
+		}
+	}
+
 	error = shmem_getpage(inode, vmf->pgoff, &vmf->page, SGP_CACHE, &ret);
 	if (error)
 		return ((error == -ENOMEM) ? VM_FAULT_OOM : VM_FAULT_SIGBUS);
@@ -1726,18 +1765,26 @@ static long shmem_fallocate(struct file
 
 	mutex_lock(&inode->i_mutex);
 
+	shmem_falloc.mode = mode & ~FALLOC_FL_KEEP_SIZE;
+
 	if (mode & FALLOC_FL_PUNCH_HOLE) {
 		struct address_space *mapping = file->f_mapping;
 		loff_t unmap_start = round_up(offset, PAGE_SIZE);
 		loff_t unmap_end = round_down(offset + len, PAGE_SIZE) - 1;
 
+		shmem_falloc.start = unmap_start >> PAGE_SHIFT;
+		shmem_falloc.next = (unmap_end + 1) >> PAGE_SHIFT;
+		spin_lock(&inode->i_lock);
+		inode->i_private = &shmem_falloc;
+		spin_unlock(&inode->i_lock);
+
 		if ((u64)unmap_end > (u64)unmap_start)
 			unmap_mapping_range(mapping, unmap_start,
 					    1 + unmap_end - unmap_start, 0);
 		shmem_truncate_range(inode, offset, offset + len - 1);
 		/* No need to unmap again: hole-punching leaves COWed pages */
 		error = 0;
-		goto out;
+		goto undone;
 	}
 
 	/* We need to check rlimit even when FALLOC_FL_KEEP_SIZE */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
