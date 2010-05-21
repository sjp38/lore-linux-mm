Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 2DCEA6B01B1
	for <linux-mm@kvack.org>; Fri, 21 May 2010 16:56:10 -0400 (EDT)
Received: from hpaq5.eem.corp.google.com (hpaq5.eem.corp.google.com [172.25.149.5])
	by smtp-out.google.com with ESMTP id o4LKu4Eh012890
	for <linux-mm@kvack.org>; Fri, 21 May 2010 13:56:05 -0700
Received: from pvg6 (pvg6.prod.google.com [10.241.210.134])
	by hpaq5.eem.corp.google.com with ESMTP id o4LKu1AD019539
	for <linux-mm@kvack.org>; Fri, 21 May 2010 13:56:02 -0700
Received: by pvg6 with SMTP id 6so751044pvg.18
        for <linux-mm@kvack.org>; Fri, 21 May 2010 13:56:01 -0700 (PDT)
Date: Fri, 21 May 2010 13:55:51 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: TMPFS over NFSv4
In-Reply-To: <AANLkTik47c6l3y8CdJ-hUCd2h3SRSb3qAtRovWryb8_p@mail.gmail.com>
Message-ID: <alpine.LSU.2.00.1005211344440.7369@sister.anvils>
References: <AANLkTik47c6l3y8CdJ-hUCd2h3SRSb3qAtRovWryb8_p@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Tharindu Rukshan Bamunuarachchi <btharindu@gmail.com>
Cc: linux-mm@kvack.org, linux-nfs@vger.kernel.org, Alan Cox <alan@lxorguk.ukuu.org.uk>
List-ID: <linux-mm.kvack.org>

On Fri, 21 May 2010, Tharindu Rukshan Bamunuarachchi wrote:
> 
> I tried to export tmpfs file system over NFS and got followin oops ....
> this kernel is provided with SLES 11 and tainted due to OFED installation.
> 
> I am using NFSv4. Please help me to find the root cause if you feel free ....
> 
> 
> BUG: unable to handle kernel NULL pointer dereference at 00000000000000b0
> IP: __vm_enough_memory+0xf9/0x14e
> PGD 0
> Oops: 0000 [1] SMP
> last sysfs file:
> /sys/devices/pci0000:00/0000:00:09.0/0000:24:00.0/infiniband/mlx4_1/node_desc
> CPU 0
> Modules linked in: blah blah blah
> Supported: No, Unsupported modules are loaded
> Pid: 8855, comm: nfsd Tainted: G 2.6.27.45-0.1-default #1
> RIP: 0010: __vm_enough_memory+0xf9/0x14e
...
> Process nfsd (pid: 8855, threadinfo ffff8803642cc000, task ffff88036f140380)
> Stack: ffff88037b93b668 ffff88037009de40 ffff88037b93b668 0000000000000000
> ffff88037b93b601 ffffffff802a8573 ffffffff80a33680 ffffffff80a30730
> 0000000000000000 0000000300000002 ffff8803642cd930 0000000000000000
> Call Trace:
> shmem_getpage+0x4d8/0x764
> generic_perform_write+0xae/0x1b5
> generic_file_buffered_write+0x80/0x130
> __generic_file_aio_write_nolock+0x349/0x37d
> generic_file_aio_write+0x64/0xc4
> do_sync_readv_writev+0xc0/0x107
> do_readv_writev+0xb2/0x18b
> nfsd_vfs_write+0x10a/0x328 [nfsd]
> nfsd_write+0x79/0xe2 [nfsd]
> nfsd4_write+0xd9/0x10d [nfsd]
> nfsd4_proc_compound+0x1bd/0x2c7 [nfsd]
> nfsd_dispatch+0xdd/0x1b9 [nfsd]
> svc_process+0x3d8/0x700 [sunrpc]
> nfsd+0x1b1/0x27e [nfsd]
> kthread+0x47/0x73
> child_rip+0xa/0x11

I believe that was fixed in 2.6.28 by the patch below:
please would you try it, and if it works for you, then
I'll ask for it to be included in the next 2.6.27-stable,
which I expect SLES 11 will include in an update later.
Strange that more people haven't suffered from it...

Hugh

commit 731572d39fcd3498702eda4600db4c43d51e0b26
Author: Alan Cox <alan@redhat.com>
Date:   Wed Oct 29 14:01:20 2008 -0700

    nfsd: fix vm overcommit crash
    
    Junjiro R.  Okajima reported a problem where knfsd crashes if you are
    using it to export shmemfs objects and run strict overcommit.  In this
    situation the current->mm based modifier to the overcommit goes through a
    NULL pointer.
    
    We could simply check for NULL and skip the modifier but we've caught
    other real bugs in the past from mm being NULL here - cases where we did
    need a valid mm set up (eg the exec bug about a year ago).
    
    To preserve the checks and get the logic we want shuffle the checking
    around and add a new helper to the vm_ security wrappers
    
    Also fix a current->mm reference in nommu that should use the passed mm
    
    [akpm@linux-foundation.org: coding-style fixes]
    [akpm@linux-foundation.org: fix build]
    Reported-by: Junjiro R. Okajima <hooanon05@yahoo.co.jp>
    Acked-by: James Morris <jmorris@namei.org>
    Signed-off-by: Alan Cox <alan@redhat.com>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

diff --git a/include/linux/security.h b/include/linux/security.h
index f5c4a51..c13f1ce 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -1585,6 +1585,7 @@ int security_syslog(int type);
 int security_settime(struct timespec *ts, struct timezone *tz);
 int security_vm_enough_memory(long pages);
 int security_vm_enough_memory_mm(struct mm_struct *mm, long pages);
+int security_vm_enough_memory_kern(long pages);
 int security_bprm_alloc(struct linux_binprm *bprm);
 void security_bprm_free(struct linux_binprm *bprm);
 void security_bprm_apply_creds(struct linux_binprm *bprm, int unsafe);
@@ -1820,6 +1821,11 @@ static inline int security_vm_enough_memory(long pages)
 	return cap_vm_enough_memory(current->mm, pages);
 }
 
+static inline int security_vm_enough_memory_kern(long pages)
+{
+	return cap_vm_enough_memory(current->mm, pages);
+}
+
 static inline int security_vm_enough_memory_mm(struct mm_struct *mm, long pages)
 {
 	return cap_vm_enough_memory(mm, pages);
diff --git a/mm/mmap.c b/mm/mmap.c
index 74f4d15..de14ac2 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -175,7 +175,8 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 
 	/* Don't let a single process grow too big:
 	   leave 3% of the size of this process for other processes */
-	allowed -= mm->total_vm / 32;
+	if (mm)
+		allowed -= mm->total_vm / 32;
 
 	/*
 	 * cast `allowed' as a signed long because vm_committed_space
diff --git a/mm/nommu.c b/mm/nommu.c
index 2696b24..7695dc8 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1454,7 +1454,8 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 
 	/* Don't let a single process grow too big:
 	   leave 3% of the size of this process for other processes */
-	allowed -= current->mm->total_vm / 32;
+	if (mm)
+		allowed -= mm->total_vm / 32;
 
 	/*
 	 * cast `allowed' as a signed long because vm_committed_space
diff --git a/mm/shmem.c b/mm/shmem.c
index d38d7e6..0ed0752 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -161,8 +161,8 @@ static inline struct shmem_sb_info *SHMEM_SB(struct super_block *sb)
  */
 static inline int shmem_acct_size(unsigned long flags, loff_t size)
 {
-	return (flags & VM_ACCOUNT)?
-		security_vm_enough_memory(VM_ACCT(size)): 0;
+	return (flags & VM_ACCOUNT) ?
+		security_vm_enough_memory_kern(VM_ACCT(size)) : 0;
 }
 
 static inline void shmem_unacct_size(unsigned long flags, loff_t size)
@@ -179,8 +179,8 @@ static inline void shmem_unacct_size(unsigned long flags, loff_t size)
  */
 static inline int shmem_acct_block(unsigned long flags)
 {
-	return (flags & VM_ACCOUNT)?
-		0: security_vm_enough_memory(VM_ACCT(PAGE_CACHE_SIZE));
+	return (flags & VM_ACCOUNT) ?
+		0 : security_vm_enough_memory_kern(VM_ACCT(PAGE_CACHE_SIZE));
 }
 
 static inline void shmem_unacct_blocks(unsigned long flags, long pages)
diff --git a/security/security.c b/security/security.c
index 255b085..c0acfa7 100644
--- a/security/security.c
+++ b/security/security.c
@@ -198,14 +198,23 @@ int security_settime(struct timespec *ts, struct timezone *tz)
 
 int security_vm_enough_memory(long pages)
 {
+	WARN_ON(current->mm == NULL);
 	return security_ops->vm_enough_memory(current->mm, pages);
 }
 
 int security_vm_enough_memory_mm(struct mm_struct *mm, long pages)
 {
+	WARN_ON(mm == NULL);
 	return security_ops->vm_enough_memory(mm, pages);
 }
 
+int security_vm_enough_memory_kern(long pages)
+{
+	/* If current->mm is a kernel thread then we will pass NULL,
+	   for this specific case that is fine */
+	return security_ops->vm_enough_memory(current->mm, pages);
+}
+
 int security_bprm_alloc(struct linux_binprm *bprm)
 {
 	return security_ops->bprm_alloc_security(bprm);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
