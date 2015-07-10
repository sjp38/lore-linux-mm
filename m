Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0BAB26B0038
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 09:42:52 -0400 (EDT)
Received: by qgeg89 with SMTP id g89so129229681qge.3
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 06:42:51 -0700 (PDT)
Received: from emvm-gh1-uea09.nsa.gov (emvm-gh1-uea09.nsa.gov. [63.239.67.10])
        by mx.google.com with ESMTP id n27si7461689qkh.32.2015.07.10.06.42.50
        for <linux-mm@kvack.org>;
        Fri, 10 Jul 2015 06:42:51 -0700 (PDT)
From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: [PATCH] selinux: fix mprotect PROT_EXEC regression caused by mm change
Date: Fri, 10 Jul 2015 09:40:59 -0400
Message-Id: <1436535659-13124-1-git-send-email-sds@tycho.nsa.gov>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paul@paul-moore.com, hughd@google.com
Cc: prarit@redhat.com, mstevens@fedoraproject.org, esandeen@redhat.com, david@fromorbit.com, linux-kernel@vger.kernel.org, eparis@redhat.com, linux-mm@kvack.org, wagi@monom.org, selinux@tycho.nsa.gov, akpm@linux-foundation.org, torvalds@linux-foundation.org, Stephen Smalley <sds@tycho.nsa.gov>

commit 66fc13039422ba7df2d01a8ee0873e4ef965b50b ("mm: shmem_zero_setup skip
security check and lockdep conflict with XFS") caused a regression for
SELinux by disabling any SELinux checking of mprotect PROT_EXEC on
shared anonymous mappings.  However, even before that regression, the
checking on such mprotect PROT_EXEC calls was inconsistent with the
checking on a mmap PROT_EXEC call for a shared anonymous mapping.  On a
mmap, the security hook is passed a NULL file and knows it is dealing with
an anonymous mapping and therefore applies an execmem check and no file
checks.  On a mprotect, the security hook is passed a vma with a
non-NULL vm_file (as this was set from the internally-created shmem
file during mmap) and therefore applies the file-based execute check and
no execmem check.  Since the aforementioned commit now marks the shmem
zero inode with the S_PRIVATE flag, the file checks are disabled and
we have no checking at all on mprotect PROT_EXEC.  Add a test to
the mprotect hook logic for such private inodes, and apply an execmem
check in that case.  This makes the mmap and mprotect checking consistent
for shared anonymous mappings, as well as for /dev/zero and ashmem.

Signed-off-by: Stephen Smalley <sds@tycho.nsa.gov>
---
 security/selinux/hooks.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 6231081..564079c 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -3283,7 +3283,8 @@ static int file_map_prot_check(struct file *file, unsigned long prot, int shared
 	int rc = 0;
 
 	if (default_noexec &&
-	    (prot & PROT_EXEC) && (!file || (!shared && (prot & PROT_WRITE)))) {
+	    (prot & PROT_EXEC) && (!file || IS_PRIVATE(file_inode(file)) ||
+				   (!shared && (prot & PROT_WRITE)))) {
 		/*
 		 * We are making executable an anonymous mapping or a
 		 * private file mapping that will also be writable.
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
