Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 3A81B6B006E
	for <linux-mm@kvack.org>; Sun, 14 Jun 2015 12:48:15 -0400 (EDT)
Received: by wicnd19 with SMTP id nd19so5165069wic.1
        for <linux-mm@kvack.org>; Sun, 14 Jun 2015 09:48:14 -0700 (PDT)
Received: from mail-wg0-x231.google.com (mail-wg0-x231.google.com. [2a00:1450:400c:c00::231])
        by mx.google.com with ESMTPS id t1si13993450wif.84.2015.06.14.09.48.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Jun 2015 09:48:14 -0700 (PDT)
Received: by wgv5 with SMTP id 5so52697636wgv.1
        for <linux-mm@kvack.org>; Sun, 14 Jun 2015 09:48:13 -0700 (PDT)
Date: Sun, 14 Jun 2015 09:48:09 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: mm: shmem_zero_setup skip security check and lockdep conflict with
 XFS
Message-ID: <alpine.LSU.2.11.1506140944380.11018@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Prarit Bhargava <prarit@redhat.com>, Morten Stevens <mstevens@fedoraproject.org>, Daniel Wagner <wagi@monom.org>, Dave Chinner <david@fromorbit.com>, Eric Paris <eparis@redhat.com>, Eric Sandeen <esandeen@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

It appears that, at some point last year, XFS made directory handling
changes which bring it into lockdep conflict with shmem_zero_setup():
it is surprising that mmap() can clone an inode while holding mmap_sem,
but that has been so for many years.

Since those few lockdep traces that I've seen all implicated selinux,
I'm hoping that we can use the __shmem_file_setup(,,,S_PRIVATE) which
v3.13's commit c7277090927a ("security: shmem: implement kernel private
shmem inodes") introduced to avoid LSM checks on kernel-internal inodes:
the mmap("/dev/zero") cloned inode is indeed a kernel-internal detail.

This also covers the !CONFIG_SHMEM use of ramfs to support /dev/zero
(and MAP_SHARED|MAP_ANONYMOUS).  I thought there were also drivers
which cloned inode in mmap(), but if so, I cannot locate them now.

Reported-and-tested-by: Prarit Bhargava <prarit@redhat.com>
Reported-by: Daniel Wagner <wagi@monom.org>
Reported-by: Morten Stevens <mstevens@fedoraproject.org>
Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/shmem.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

--- 4.1-rc7/mm/shmem.c	2015-04-26 19:16:31.352191298 -0700
+++ linux/mm/shmem.c	2015-06-14 09:26:49.461120166 -0700
@@ -3401,7 +3401,13 @@ int shmem_zero_setup(struct vm_area_stru
 	struct file *file;
 	loff_t size = vma->vm_end - vma->vm_start;
 
-	file = shmem_file_setup("dev/zero", size, vma->vm_flags);
+	/*
+	 * Cloning a new file under mmap_sem leads to a lock ordering conflict
+	 * between XFS directory reading and selinux: since this file is only
+	 * accessible to the user through its mapping, use S_PRIVATE flag to
+	 * bypass file security, in the same way as shmem_kernel_file_setup().
+	 */
+	file = __shmem_file_setup("dev/zero", size, vma->vm_flags, S_PRIVATE);
 	if (IS_ERR(file))
 		return PTR_ERR(file);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
