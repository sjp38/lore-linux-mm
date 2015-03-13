Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f177.google.com (mail-ie0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id 299FA829B3
	for <linux-mm@kvack.org>; Fri, 13 Mar 2015 05:21:50 -0400 (EDT)
Received: by iecsl2 with SMTP id sl2so93783599iec.1
        for <linux-mm@kvack.org>; Fri, 13 Mar 2015 02:21:50 -0700 (PDT)
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com. [209.85.192.181])
        by mx.google.com with ESMTPS id d17si2876810pdf.186.2015.03.13.02.21.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Mar 2015 02:21:49 -0700 (PDT)
Received: by pdbnh10 with SMTP id nh10so27487165pdb.4
        for <linux-mm@kvack.org>; Fri, 13 Mar 2015 02:21:49 -0700 (PDT)
Received: from DDD (c-67-161-28-197.hsd1.ca.comcast.net. [67.161.28.197])
        by mx.google.com with ESMTPSA id mi9sm2470582pab.3.2015.03.13.02.21.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 13 Mar 2015 02:21:48 -0700 (PDT)
From: Derek <crquan@ymail.com>
Subject: [PATCH] mremap should return -ENOMEM when __vm_enough_memory fail
Date: Fri, 13 Mar 2015 02:21:38 -0700
Message-Id: <1426238498-21127-1-git-send-email-crquan@ymail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Recently I straced bash behavior in this dd zero pipe to read test,
in part of testing under vm.overcommit_memory=2 (OVERCOMMIT_NEVER mode):
    # dd if=/dev/zero | read x

The bash sub shell is calling mremap to reallocate more and more memory
untill it finally failed -ENOMEM (I expect), or to be killed by system
OOM killer (which should not happen under OVERCOMMIT_NEVER mode);
But the mremap system call actually failed of -EFAULT, which is a surprise
to me, I think it's supposed to be -ENOMEM? then I wrote this piece
of C code testing confirmed it:
https://gist.github.com/crquan/326bde37e1ddda8effe5

The -EFAULT comes from the branch of security_vm_enough_memory_mm failure,
underlyingly it calls __vm_enough_memory which returns only 0 for success
or -ENOMEM; So why vma_to_resize needs to return -EFAULT in this case?
it sounds like a mistake to me.

Some more digging into git history:
1) Before commit 119f657c7 in May 1 2005 (pre 2.6.12 days) it was returning
   -ENOMEM for this failure;
2) but commit 119f657c7 changed it accidentally, to what ever is preserved
   in local ret, which happened to be -EFAULT, in a previous assignment;
3) then in commit 54f5de709 code refactoring, it's explicitly returning
   -EFAULT, should be wrong.

Signed-off-by: Derek Che <crquan@ymail.com>
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
