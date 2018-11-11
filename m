Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 03C066B0003
	for <linux-mm@kvack.org>; Sun, 11 Nov 2018 12:36:56 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id o28-v6so2672950pfk.10
        for <linux-mm@kvack.org>; Sun, 11 Nov 2018 09:36:55 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j15sor15751733pgc.41.2018.11.11.09.36.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 11 Nov 2018 09:36:54 -0800 (PST)
Date: Sun, 11 Nov 2018 09:36:50 -0800
From: Joel Fernandes <joel@joelfernandes.org>
Subject: Re: [PATCH v3 resend 1/2] mm: Add an F_SEAL_FUTURE_WRITE seal to
 memfd
Message-ID: <20181111173650.GA256781@google.com>
References: <20181110182405.GB242356@google.com>
 <CAKOZuesQXRtthJTEr86LByH3gPpAdT-PQM0d1jqr131=zZNRKw@mail.gmail.com>
 <CAKOZueum8MtNvJ5P=W7_pRw62TdQdCgyjCwwbG1wezNboC1cxQ@mail.gmail.com>
 <20181110220933.GB96924@google.com>
 <907D942E-E321-4BD7-BED7-ACD1D96A3643@amacapital.net>
 <20181111023808.GA174670@google.com>
 <543A5181-3A16-438E-B372-97BEC48A74F8@amacapital.net>
 <20181111080945.GA78191@google.com>
 <CAKOZuethQ3eaV4uoEXiffVMc_S0hyk1FGPB3iQHHnv4NadW1UQ@mail.gmail.com>
 <91E8E1AA-859A-457A-8978-3EA39CBBF075@amacapital.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <91E8E1AA-859A-457A-8978-3EA39CBBF075@amacapital.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Daniel Colascione <dancol@google.com>, Jann Horn <jannh@google.com>, kernel list <linux-kernel@vger.kernel.org>, John Reck <jreck@google.com>, John Stultz <john.stultz@linaro.org>, Todd Kjos <tkjos@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Christoph Hellwig <hch@infradead.org>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Bruce Fields <bfields@fieldses.org>, Jeff Layton <jlayton@kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, Lei.Yang@windriver.com, linux-fsdevel@vger.kernel.org, linux-kselftest@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, marcandre.lureau@redhat.com, Mike Kravetz <mike.kravetz@oracle.com>, Minchan Kim <minchan@kernel.org>, Shuah Khan <shuah@kernel.org>, Valdis Kletnieks <valdis.kletnieks@vt.edu>, Hugh Dickins <hughd@google.com>, Linux API <linux-api@vger.kernel.org>

On Sun, Nov 11, 2018 at 07:14:33AM -0800, Andy Lutomirski wrote:
[...]
> >>>>>>>>>> I see two reasonable solutions:
> >>>>>>>>>> 
> >>>>>>>>>> 1. Dona??t fiddle with the struct file at all. Instead make the inode flag
> >>>>>>>>>> work by itself.
> >>>>>>>>> 
> >>>>>>>>> Currently, the various VFS paths check only the struct file's f_mode to deny
> >>>>>>>>> writes of already opened files. This would mean more checking in all those
> >>>>>>>>> paths (and modification of all those paths).
> >>>>>>>>> 
> >>>>>>>>> Anyway going with that idea, we could
> >>>>>>>>> 1. call deny_write_access(file) from the memfd's seal path which decrements
> >>>>>>>>> the inode::i_writecount.
> >>>>>>>>> 2. call get_write_access(inode) in the various VFS paths in addition to
> >>>>>>>>> checking for FMODE_*WRITE and deny the write (incase i_writecount is negative)
> >>>>>>>>> 
> >>>>>>>>> That will prevent both reopens, and writes from succeeding. However I worry a
> >>>>>>>>> bit about 2 not being too familiar with VFS internals, about what the
> >>>>>>>>> consequences of doing that may be.
> >>>>>>>> 
> >>>>>>>> IMHO, modifying both the inode and the struct file separately is fine,
> >>>>>>>> since they mean different things. In regular filesystems, it's fine to
> >>>>>>>> have a read-write open file description for a file whose inode grants
> >>>>>>>> write permission to nobody. Speaking of which: is fchmod enough to
> >>>>>>>> prevent this attack?
> >>>>>>> 
> >>>>>>> Well, yes and no. fchmod does prevent reopening the file RW, but
> >>>>>>> anyone with permissions (owner, CAP_FOWNER) can just fchmod it back. A
> >>>>>>> seal is supposed to be irrevocable, so fchmod-as-inode-seal probably
> >>>>>>> isn't sufficient by itself. While it might be good enough for Android
> >>>>>>> (in the sense that it'll prevent RW-reopens from other security
> >>>>>>> contexts to which we send an open memfd file), it's still conceptually
> >>>>>>> ugly, IMHO. Let's go with the original approach of just tweaking the
> >>>>>>> inode so that open-for-write is permanently blocked.
> >>>>>> 
> >>>>>> Agreed with the idea of modifying both file and inode flags. I was thinking
> >>>>>> modifying i_mode may do the trick but as you pointed it probably could be
> >>>>>> reverted by chmod or some other attribute setting calls.
> >>>>>> 
> >>>>>> OTOH, I don't think deny_write_access(file) can be reverted from any
> >>>>>> user-facing path so we could do that from the seal to prevent the future
> >>>>>> opens in write mode. I'll double check and test that out tomorrow.
> >>>>>> 
> >>>>>> 
> >>>>> 
> >>>>> This seems considerably more complicated and more fragile than needed. Just
> >>>>> add a new F_SEAL_WRITE_FUTURE.  Grep for F_SEAL_WRITE and make the _FUTURE
> >>>>> variant work exactly like it with two exceptions:
> >>>>> 
> >>>>> - shmem_mmap and maybe its hugetlbfs equivalent should check for it and act
> >>>>> accordingly.
> >>>> 
> >>>> There's more to it than that, we also need to block future writes through
> >>>> write syscall, so we have to hook into the write path too once the seal is
> >>>> set, not just the mmap. That means we have to add code in mm/shmem.c to do
> >>>> that in all those handlers, to check for the seal (and hope we didn't miss a
> >>>> file_operations handler). Is that what you are proposing?
> >>> 
> >>> The existing code already does this. Thata??s why I suggested grepping :)
> >>> 
> >>>> 
> >>>> Also, it means we have to keep CONFIG_TMPFS enabled so that the
> >>>> shmem_file_operations write handlers like write_iter are hooked up. Currently
> >>>> memfd works even with !CONFIG_TMPFS.
> >>> 
> >>> If so, that sounds like it may already be a bug.
> > 
> > Why shouldn't memfd work independently of CONFIG_TMPFS? In particular,
> > write(2) on tmpfs FDs shouldn't work differently. If it does, that's a
> > kernel implementation detail leaking out into userspace.
> > 
> >>>>> - add_seals wona??t need the wait_for_pins and mapping_deny_write logic.
> >>>>> 
> >>>>> That really should be all thata??s needed.
> >>>> 
> >>>> It seems a fair idea what you're saying. But I don't see how its less
> >>>> complex.. IMO its far more simple to have VFS do the denial of the operations
> >>>> based on the flags of its datastructures.. and if it works (which I will test
> >>>> to be sure it will), then we should be good.
> >>> 
> >>> I agree ita??s complicated, but the code is already written.  You should just
> >>> need to adjust some masks.
> >>> 
> >> 
> >> Its actually not that bad and a great idea, I did something like the
> >> following and it works pretty well. I would say its cleaner than the old
> >> approach for sure (and I also added a /proc/pid/fd/N reopen test to the
> >> selftest and made sure that issue goes away).
> >> 
> >> Side note: One subtelty I discovered from the existing selftests is once the
> >> F_SEAL_WRITE are active, an mmap of PROT_READ and MAP_SHARED region is
> >> expected to fail. This is also evident from this code in mmap_region:
> >>                if (vm_flags & VM_SHARED) {
> >>                        error = mapping_map_writable(file->f_mapping);
> >>                        if (error)
> >>                                goto allow_write_and_free_vma;
> >>                }
> >> 
> > 
> > This behavior seems like a bug. Why should MAP_SHARED writes be denied
> > here? There's no semantic incompatibility between shared mappings and
> > the seal. And I think this change would represent an ABI break using
> > memfd seals for ashmem, since ashmem currently allows MAP_SHARED
> > mappings after changing prot_mask.
> 
> Hmm. Ia??m guessing the intent is that the mmap count should track writable
> mappings in addition to mappings that could be made writable using
> mprotect.  I think you could address this for SEAL_FUTURE in two ways:
> 
> 1. In shmem_mmap, mask off VM_MAYWRITE if SEAL_FUTURE is set, or
> 
> 2. Add a new vm operation that allows a vma to reject an mprotect attempt,
> like security_file_mprotect but per vma.  Then give it reasonable semantics
> for shmem.
> 
> (1) probably gives the semantics you want for SEAL_FUTURE: old maps can be
> mprotected, but new maps cana??t.

Thanks Andy and Daniel! This occured to me too and I like the solution in (1).
I tested that now PROT_READ + MAP_SHARED works and the mrprotect is not able
to revert the protection. In fact (1) is exactly what we do in the ashmem
driver.

The updated patch now looks like the following:

---8<-----------------------

From: "Joel Fernandes" <joel@joelfernandes.org>
Subject: [PATCH] mm/memfd: implement future write seal using shmem ops

Signed-off-by: Joel Fernandes <joel@joelfernandes.org>
---
 fs/hugetlbfs/inode.c |  2 +-
 mm/memfd.c           | 19 -------------------
 mm/shmem.c           | 24 +++++++++++++++++++++---
 3 files changed, 22 insertions(+), 23 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 32920a10100e..1978581abfdf 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -530,7 +530,7 @@ static long hugetlbfs_punch_hole(struct inode *inode, loff_t offset, loff_t len)
 		inode_lock(inode);
 
 		/* protected by i_mutex */
-		if (info->seals & F_SEAL_WRITE) {
+		if (info->seals & (F_SEAL_WRITE | F_SEAL_FUTURE_WRITE)) {
 			inode_unlock(inode);
 			return -EPERM;
 		}
diff --git a/mm/memfd.c b/mm/memfd.c
index 5ba9804e9515..a9ece5fab439 100644
--- a/mm/memfd.c
+++ b/mm/memfd.c
@@ -220,25 +220,6 @@ static int memfd_add_seals(struct file *file, unsigned int seals)
 		}
 	}
 
-	if ((seals & F_SEAL_FUTURE_WRITE) &&
-	    !(*file_seals & F_SEAL_FUTURE_WRITE)) {
-		/*
-		 * The FUTURE_WRITE seal also prevents growing and shrinking
-		 * so we need them to be already set, or requested now.
-		 */
-		int test_seals = (seals | *file_seals) &
-				 (F_SEAL_GROW | F_SEAL_SHRINK);
-
-		if (test_seals != (F_SEAL_GROW | F_SEAL_SHRINK)) {
-			error = -EINVAL;
-			goto unlock;
-		}
-
-		spin_lock(&file->f_lock);
-		file->f_mode &= ~(FMODE_WRITE | FMODE_PWRITE);
-		spin_unlock(&file->f_lock);
-	}
-
 	*file_seals |= seals;
 	error = 0;
 
diff --git a/mm/shmem.c b/mm/shmem.c
index 446942677cd4..ef6039f1ea2a 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2163,6 +2163,23 @@ int shmem_lock(struct file *file, int lock, struct user_struct *user)
 
 static int shmem_mmap(struct file *file, struct vm_area_struct *vma)
 {
+	struct shmem_inode_info *info = SHMEM_I(file_inode(file));
+
+	/*
+	 * New PROT_READ and MAP_SHARED mmaps are not allowed when "future
+	 * write" seal active.
+	 */
+	if ((vma->vm_flags & VM_SHARED) && (vma->vm_flags & VM_WRITE) &&
+	    (info->seals & F_SEAL_FUTURE_WRITE))
+		return -EPERM;
+
+	/*
+	 * Since the F_SEAL_FUTURE_WRITE seals allow for a MAP_SHARED read-only
+	 * mapping, take care to not allow mprotect to revert protections.
+	 */
+	if (info->seals & F_SEAL_FUTURE_WRITE)
+		vma->vm_flags &= ~(VM_MAYWRITE);
+
 	file_accessed(file);
 	vma->vm_ops = &shmem_vm_ops;
 	if (IS_ENABLED(CONFIG_TRANSPARENT_HUGE_PAGECACHE) &&
@@ -2391,8 +2408,9 @@ shmem_write_begin(struct file *file, struct address_space *mapping,
 	pgoff_t index = pos >> PAGE_SHIFT;
 
 	/* i_mutex is held by caller */
-	if (unlikely(info->seals & (F_SEAL_WRITE | F_SEAL_GROW))) {
-		if (info->seals & F_SEAL_WRITE)
+	if (unlikely(info->seals & (F_SEAL_GROW |
+				   F_SEAL_WRITE | F_SEAL_FUTURE_WRITE))) {
+		if (info->seals & (F_SEAL_WRITE | F_SEAL_FUTURE_WRITE))
 			return -EPERM;
 		if ((info->seals & F_SEAL_GROW) && pos + len > inode->i_size)
 			return -EPERM;
@@ -2657,7 +2675,7 @@ static long shmem_fallocate(struct file *file, int mode, loff_t offset,
 		DECLARE_WAIT_QUEUE_HEAD_ONSTACK(shmem_falloc_waitq);
 
 		/* protected by i_mutex */
-		if (info->seals & F_SEAL_WRITE) {
+		if (info->seals & F_SEAL_WRITE || info->seals & F_SEAL_FUTURE_WRITE) {
 			error = -EPERM;
 			goto out;
 		}
-- 
2.19.1.930.g4563a0d9d0-goog
