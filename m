Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id AECE56B2DD1
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 18:09:11 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id o9so3261633pgv.19
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 15:09:11 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y17sor22621626pll.68.2018.11.22.15.09.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 22 Nov 2018 15:09:09 -0800 (PST)
Date: Thu, 22 Nov 2018 15:09:06 -0800
From: Joel Fernandes <joel@joelfernandes.org>
Subject: Re: [PATCH -next 1/2] mm/memfd: make F_SEAL_FUTURE_WRITE seal more
 robust
Message-ID: <20181122230906.GA198127@google.com>
References: <20181120052137.74317-1-joel@joelfernandes.org>
 <CALCETrXgBENat=5=7EuU-ttQ-YSXT+ifjLGc=hpJ=unRgSsndw@mail.gmail.com>
 <20181120183926.GA124387@google.com>
 <20181121070658.011d576d@canb.auug.org.au>
 <469B80CB-D982-4802-A81D-95AC493D7E87@amacapital.net>
 <20181120204710.GB22801@google.com>
 <F8E28229-C99E-4711-982B-5B5DE0F70F16@amacapital.net>
 <20181120211335.GC22801@google.com>
 <20181121182701.0d8a775fda6af1f8d2be8f25@linux-foundation.org>
 <CALCETrUGyhqi+M3cTdqJNNOPfTWn-R-ekM_R5heq2mbdVqPUAw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrUGyhqi+M3cTdqJNNOPfTWn-R-ekM_R5heq2mbdVqPUAw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>, LKML <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Jann Horn <jannh@google.com>, Khalid Aziz <khalid.aziz@oracle.com>, Linux API <linux-api@vger.kernel.org>, "open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, marcandre.lureau@redhat.com, Matthew Wilcox <willy@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>, Shuah Khan <shuah@kernel.org>

On Wed, Nov 21, 2018 at 07:25:26PM -0800, Andy Lutomirski wrote:
> On Wed, Nov 21, 2018 at 6:27 PM Andrew Morton <akpm@linux-foundation.org> wrote:
> >
> > On Tue, 20 Nov 2018 13:13:35 -0800 Joel Fernandes <joel@joelfernandes.org> wrote:
> >
> > > > > I am Ok with whatever Andrew wants to do, if it is better to squash it with
> > > > > the original, then I can do that and send another patch.
> > > > >
> > > > >
> > > >
> > > > From experience, Andrew will food in fixups on request :)
> > >
> > > Andrew, could you squash this patch into the one titled ("mm: Add an
> > > F_SEAL_FUTURE_WRITE seal to memfd")?
> >
> > Sure.
> >
> > I could of course queue them separately but I rarely do so - I don't
> > think that the intermediate development states are useful in the
> > infinite-term, and I make them available via additional Link: tags in
> > the changelog footers anyway.
> >
> > I think that the magnitude of these patches is such that John Stultz's
> > Reviewed-by is invalidated, so this series is now in the "unreviewed"
> > state.
> >
> > So can we have a re-review please?  For convenience, here's the
> > folded-together [1/1] patch, as it will go to Linus.

Sure, I removed the old tags and also provide an updated patch below inline.

> > From: "Joel Fernandes (Google)" <joel@joelfernandes.org>
> > Subject: mm: Add an F_SEAL_FUTURE_WRITE seal to memfd
> >
> > Android uses ashmem for sharing memory regions.  We are looking forward to
> > migrating all usecases of ashmem to memfd so that we can possibly remove
> > the ashmem driver in the future from staging while also benefiting from
> > using memfd and contributing to it.  Note staging drivers are also not ABI
> > and generally can be removed at anytime.
[...]
> > --- a/include/uapi/linux/fcntl.h~mm-add-an-f_seal_future_write-seal-to-memfd
> > +++ a/include/uapi/linux/fcntl.h
> > @@ -41,6 +41,7 @@
> >  #define F_SEAL_SHRINK  0x0002  /* prevent file from shrinking */
> >  #define F_SEAL_GROW    0x0004  /* prevent file from growing */
> >  #define F_SEAL_WRITE   0x0008  /* prevent writes */
> > +#define F_SEAL_FUTURE_WRITE    0x0010  /* prevent future writes while mapped */
> >  /* (1U << 31) is reserved for signed error codes */
> >
> >  /*
> > --- a/mm/memfd.c~mm-add-an-f_seal_future_write-seal-to-memfd
> > +++ a/mm/memfd.c
> > @@ -131,7 +131,8 @@ static unsigned int *memfd_file_seals_pt
> >  #define F_ALL_SEALS (F_SEAL_SEAL | \
> >                      F_SEAL_SHRINK | \
> >                      F_SEAL_GROW | \
> > -                    F_SEAL_WRITE)
> > +                    F_SEAL_WRITE | \
> > +                    F_SEAL_FUTURE_WRITE)
> >
> >  static int memfd_add_seals(struct file *file, unsigned int seals)
> >  {
> > --- a/fs/hugetlbfs/inode.c~mm-add-an-f_seal_future_write-seal-to-memfd
> > +++ a/fs/hugetlbfs/inode.c
> > @@ -530,7 +530,7 @@ static long hugetlbfs_punch_hole(struct
> >                 inode_lock(inode);
> >
> >                 /* protected by i_mutex */
> > -               if (info->seals & F_SEAL_WRITE) {
> > +               if (info->seals & (F_SEAL_WRITE | F_SEAL_FUTURE_WRITE)) {
> >                         inode_unlock(inode);
> >                         return -EPERM;
> >                 }
> > --- a/mm/shmem.c~mm-add-an-f_seal_future_write-seal-to-memfd
> > +++ a/mm/shmem.c
> > @@ -2119,6 +2119,23 @@ out_nomem:
> >
> >  static int shmem_mmap(struct file *file, struct vm_area_struct *vma)
> >  {
> > +       struct shmem_inode_info *info = SHMEM_I(file_inode(file));
> > +
> > +       /*
> > +        * New PROT_READ and MAP_SHARED mmaps are not allowed when "future
> 
> PROT_WRITE, perhaps?

Yes, fixed.

> > +        * write" seal active.
> > +        */
> > +       if ((vma->vm_flags & VM_SHARED) && (vma->vm_flags & VM_WRITE) &&
> > +           (info->seals & F_SEAL_FUTURE_WRITE))
> > +               return -EPERM;
> > +
> > +       /*
> > +        * Since the F_SEAL_FUTURE_WRITE seals allow for a MAP_SHARED read-only
> > +        * mapping, take care to not allow mprotect to revert protections.
> > +        */
> > +       if (info->seals & F_SEAL_FUTURE_WRITE)
> > +               vma->vm_flags &= ~(VM_MAYWRITE);
> > +
> 
> This might all be clearer as:
> 
> if (info->seals & F_SEAL_FUTURE_WRITE) {
>   if (vma->vm_flags ...)
>     return -EPERM;
>   vma->vm_flags &= ~VM_MAYWRITE;
> }
> 
> with appropriate comments inserted.

Agreed, its simpler. Updated patch is below. I squashed it with all the
earlier ones. Andy, could you provide Acks and/or Reviewed-by tag as well?

---8<-----------------------

>From b5a4960e755af67e9f6f9e65db5113e712cf338e Mon Sep 17 00:00:00 2001
From: "Joel Fernandes (Google)" <joel@joelfernandes.org>
Date: Sat, 10 Nov 2018 22:21:31 -0800
Subject: [PATCH v4] mm/memfd: Add an F_SEAL_FUTURE_WRITE seal to memfd

Android uses ashmem for sharing memory regions.  We are looking forward to
migrating all usecases of ashmem to memfd so that we can possibly remove
the ashmem driver in the future from staging while also benefiting from
using memfd and contributing to it.  Note staging drivers are also not ABI
and generally can be removed at anytime.

One of the main usecases Android has is the ability to create a region and
mmap it as writeable, then add protection against making any "future"
writes while keeping the existing already mmap'ed writeable-region active.
This allows us to implement a usecase where receivers of the shared
memory buffer can get a read-only view, while the sender continues to
write to the buffer.  See CursorWindow documentation in Android for more
details:
https://developer.android.com/reference/android/database/CursorWindow

This usecase cannot be implemented with the existing F_SEAL_WRITE seal.
To support the usecase, this patch adds a new F_SEAL_FUTURE_WRITE seal
which prevents any future mmap and write syscalls from succeeding while
keeping the existing mmap active.

A better way to do F_SEAL_FUTURE_WRITE seal was discussed [1] last week
where we don't need to modify core VFS structures to get the same
behavior of the seal. This solves several side-effects pointed by Andy.
self-tests are provided in later patch to verify the expected semantics.

[1] https://lore.kernel.org/lkml/20181111173650.GA256781@google.com/

Suggested-by: Andy Lutomirski <luto@kernel.org>
Signed-off-by: Joel Fernandes (Google) <joel@joelfernandes.org>
---
 fs/hugetlbfs/inode.c       |  2 +-
 include/uapi/linux/fcntl.h |  1 +
 mm/memfd.c                 |  3 ++-
 mm/shmem.c                 | 26 +++++++++++++++++++++++---
 4 files changed, 27 insertions(+), 5 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 762028994f47..5b54bf893a67 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -558,7 +558,7 @@ static long hugetlbfs_punch_hole(struct inode *inode, loff_t offset, loff_t len)
 		inode_lock(inode);
 
 		/* protected by i_mutex */
-		if (info->seals & F_SEAL_WRITE) {
+		if (info->seals & (F_SEAL_WRITE | F_SEAL_FUTURE_WRITE)) {
 			inode_unlock(inode);
 			return -EPERM;
 		}
diff --git a/include/uapi/linux/fcntl.h b/include/uapi/linux/fcntl.h
index 594b85f7cb86..1d338357df8a 100644
--- a/include/uapi/linux/fcntl.h
+++ b/include/uapi/linux/fcntl.h
@@ -41,6 +41,7 @@
 #define F_SEAL_SHRINK	0x0002	/* prevent file from shrinking */
 #define F_SEAL_GROW	0x0004	/* prevent file from growing */
 #define F_SEAL_WRITE	0x0008	/* prevent writes */
+#define F_SEAL_FUTURE_WRITE	0x0010  /* prevent future writes while mapped */
 /* (1U << 31) is reserved for signed error codes */
 
 /*
diff --git a/mm/memfd.c b/mm/memfd.c
index 97264c79d2cd..650e65a46b9c 100644
--- a/mm/memfd.c
+++ b/mm/memfd.c
@@ -131,7 +131,8 @@ static unsigned int *memfd_file_seals_ptr(struct file *file)
 #define F_ALL_SEALS (F_SEAL_SEAL | \
 		     F_SEAL_SHRINK | \
 		     F_SEAL_GROW | \
-		     F_SEAL_WRITE)
+		     F_SEAL_WRITE | \
+		     F_SEAL_FUTURE_WRITE)
 
 static int memfd_add_seals(struct file *file, unsigned int seals)
 {
diff --git a/mm/shmem.c b/mm/shmem.c
index 32eb29bd72c6..f5069e8225cc 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2121,6 +2121,25 @@ int shmem_lock(struct file *file, int lock, struct user_struct *user)
 
 static int shmem_mmap(struct file *file, struct vm_area_struct *vma)
 {
+	struct shmem_inode_info *info = SHMEM_I(file_inode(file));
+
+
+	if (info->seals & F_SEAL_FUTURE_WRITE) {
+		/*
+		 * New PROT_WRITE and MAP_SHARED mmaps are not allowed when
+		 * "future write" seal active.
+		 */
+		if ((vma->vm_flags & VM_SHARED) && (vma->vm_flags & VM_WRITE))
+			return -EPERM;
+
+		/*
+		 * Since the F_SEAL_FUTURE_WRITE seals allow for a MAP_SHARED
+		 * read-only mapping, take care to not allow mprotect to revert
+		 * protections.
+		 */
+		vma->vm_flags &= ~(VM_MAYWRITE);
+	}
+
 	file_accessed(file);
 	vma->vm_ops = &shmem_vm_ops;
 	if (IS_ENABLED(CONFIG_TRANSPARENT_HUGE_PAGECACHE) &&
@@ -2346,8 +2365,9 @@ shmem_write_begin(struct file *file, struct address_space *mapping,
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
@@ -2610,7 +2630,7 @@ static long shmem_fallocate(struct file *file, int mode, loff_t offset,
 		DECLARE_WAIT_QUEUE_HEAD_ONSTACK(shmem_falloc_waitq);
 
 		/* protected by i_mutex */
-		if (info->seals & F_SEAL_WRITE) {
+		if (info->seals & (F_SEAL_WRITE | F_SEAL_FUTURE_WRITE)) {
 			error = -EPERM;
 			goto out;
 		}
-- 
2.19.1.1215.g8438c0b245-goog
