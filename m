Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id A36206B0039
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 17:07:48 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id p10so11044081pdj.23
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 14:07:48 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id ec3si4062447pbc.36.2014.09.11.14.07.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 11 Sep 2014 14:07:47 -0700 (PDT)
Received: by mail-pa0-f53.google.com with SMTP id rd3so10125777pab.12
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 14:07:47 -0700 (PDT)
Date: Thu, 11 Sep 2014 14:05:52 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: lockdep warning when logging in via ssh
In-Reply-To: <20140911023213.GN20518@dastard>
Message-ID: <alpine.LSU.2.11.1409111344450.1002@eggly.anvils>
References: <5410D3E7.2020804@redhat.com> <alpine.LSU.2.11.1409101609380.3685@eggly.anvils> <20140911023213.GN20518@dastard>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Prarit Bhargava <prarit@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Dave Chinner <david@fromorbit.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Eric Sandeen <esandeen@redhat.com>

On Thu, 11 Sep 2014, Dave Chinner wrote:
> On Wed, Sep 10, 2014 at 04:24:16PM -0700, Hugh Dickins wrote:
> > On Wed, 10 Sep 2014, Prarit Bhargava wrote:
> > 
> > > I see this when I attempt to login via ssh.  I do not see it if I login on
> > > the serial console.
> ....
> > > 
> > > According to Dave Chinner:
> > > 
> > > "It's the shmem code that is broken - instantiating an inode while
> > > holding the mmap_sem inverts lock orders all over the place,
> > > especially in the security subsystem...."
> > 
> > Interesting, thank you.  But it seems a bit late to accuse shmem
> > of doing the wrong thing here: mmap -> shmem_zero_setup worked this
> > way in 2.4.0 (if not before) and has done ever since.
> > 
> > Only now is a problem reported, so perhaps a change is needed rather
> > at the xfs end - unless Dave has a suggestion for how to change it
> > easily at the shmem end.
> > 
> > Or is xfs not the one to change recently, but something else in the stack?
> 
> XFS recently added directory inode specific lockdep class
> annotations. AFAIA, nobody else has done this so nobody else will
> have tripped over this issue. Effectively, lockdep is complaining
> that shmem is taking inode security locks in a different order to
> what it sees XFS taking directory locks and page faults in the
> readdir path.
> 
> That is, VFS lock order is directory i_mutex/security lock on file
> creation, directory i_mutex/filldir/may_fault(mmap_sem) on readdir
> operations. Hence both the security lock and mmap_sem nest under
> i_mutex in real filesystems, but on shmem the security lock nests
> under mmap_sem because of inode instantiation.
> 
> Now, lockdep is too naive to realise that these are completely
> different filesystems and so (probably) aren't in danger of
> deadlocks, but the fact is that having shmem instantiate an inode as
> a result of a page fault is -surprising- to say the least.
> 
> I said that "It's the shmem code that is broken" bluntly because
> this has already been reported to the linux-mm list twice by me, and
> it's been ignored twice. it may be that what shmem is doing is OK,
> but the fact is that it is /very different/ to anyone else and is
> triggering lockdep reports against the normal behaviour on other
> filesystems.
> 
> My point is that avoiding the lockdep report or fixing any other
> issue that it uncovers is not an XFS problem - shmem is doing the
> weird thing and we should not be working around shmem idiosyncracies
> in XFS or other filesystems....

Prarit, please would you try the patch below - thanks.

Dave might prefer a more extensive rework of the long-standing
mmap_region() -> file->f_op->mmap of /dev/zero -> shmem_zero_setup()
path which surprised him, but if this S_PRIVATE patch actually fixes
all the lockdep problems for you (rather than just stopping one and
exposing another), then I think it's precisely what's needed - there
is no reason to apply selinux inode checks to the internal object
supporting a shared-anonymous mapping, and this is much easier than
going down some road of special lock classes at the xfs or shmem end.

Not-yet-Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/shmem.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- 3.17-rc4/mm/shmem.c	2014-08-16 16:00:54.151189065 -0700
+++ linux/mm/shmem.c	2014-09-11 13:37:46.048040904 -0700
@@ -3375,7 +3375,7 @@ int shmem_zero_setup(struct vm_area_stru
 	struct file *file;
 	loff_t size = vma->vm_end - vma->vm_start;
 
-	file = shmem_file_setup("dev/zero", size, vma->vm_flags);
+	file = __shmem_file_setup("dev/zero", size, vma->vm_flags, S_PRIVATE);
 	if (IS_ERR(file))
 		return PTR_ERR(file);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
