Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id A815F6B0038
	for <linux-mm@kvack.org>; Tue, 17 Mar 2015 04:25:41 -0400 (EDT)
Received: by pdbop1 with SMTP id op1so3109542pdb.2
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 01:25:41 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id bh1si27814418pdb.191.2015.03.17.01.25.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Mar 2015 01:25:40 -0700 (PDT)
Received: by pabyw6 with SMTP id yw6so3143648pab.2
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 01:25:40 -0700 (PDT)
From: denc716@gmail.com
Subject: [PATCH 1/2] mremap should return -ENOMEM when __vm_enough_memory fail
Date: Tue, 17 Mar 2015 01:25:12 -0700
Message-Id: <1426580713-21151-1-git-send-email-denc716@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill@shutemov.name>, David Rientjes <rientjes@google.com>
Cc: Derek Che <crquan@ymail.com>

Recently I straced bash behavior in this dd zero pipe to read test,
in part of testing under vm.overcommit_memory=2 (OVERCOMMIT_NEVER mode):
    # dd if=/dev/zero | read x

The bash sub shell is calling mremap to reallocate more and more memory
untill it finally failed -ENOMEM (I expect), or to be killed by system
OOM killer (which should not happen under OVERCOMMIT_NEVER mode);
But the mremap system call actually failed of -EFAULT, which is a
surprise to me, I think it's supposed to be -ENOMEM? then I wrote this
piece of C code testing confirmed it:
https://gist.github.com/crquan/326bde37e1ddda8effe5

    $ ./remap
    allocated one page @0x7f686bf71000, (PAGE_SIZE: 4096)
    grabbed 7680512000 bytes of memory (1875125 pages) @ 00007f6690993000.
    mremap failed Bad address (14).

The -EFAULT comes from the branch of security_vm_enough_memory_mm
failure, underlyingly it calls __vm_enough_memory which returns only
0 for success or -ENOMEM; So why vma_to_resize needs to return
-EFAULT in this case? this sounds like a mistake to me.

Some more digging into git history:
1) Before commit 119f657c7 in May 1 2005 (pre 2.6.12 days) it was
   returning -ENOMEM for this failure;
2) but commit 119f657c7 changed it accidentally, to what ever is
   preserved in local ret, which happened to be -EFAULT, in a previous assignment;
3) then in commit 54f5de709 code refactoring, it's explicitly returning
   -EFAULT, should be wrong.

Signed-off-by: Derek Che <crquan@ymail.com>
Acked-by: "Kirill A. Shutemov" <kirill@shutemov.name>
Acked-by: David Rientjes <rientjes@google.com>
---
 mm/mremap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/mremap.c b/mm/mremap.c
index 57dadc0..5da81cb 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -375,7 +375,7 @@ static struct vm_area_struct *vma_to_resize(unsigned long addr,
 	if (vma->vm_flags & VM_ACCOUNT) {
 		unsigned long charged = (new_len - old_len) >> PAGE_SHIFT;
 		if (security_vm_enough_memory_mm(mm, charged))
-			goto Efault;
+			goto Enomem;
 		*p = charged;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
