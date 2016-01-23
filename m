Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f51.google.com (mail-lf0-f51.google.com [209.85.215.51])
	by kanga.kvack.org (Postfix) with ESMTP id E399F6B0005
	for <linux-mm@kvack.org>; Sat, 23 Jan 2016 02:39:47 -0500 (EST)
Received: by mail-lf0-f51.google.com with SMTP id m198so59592803lfm.0
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 23:39:47 -0800 (PST)
Received: from mail-lb0-x244.google.com (mail-lb0-x244.google.com. [2a00:1450:4010:c04::244])
        by mx.google.com with ESMTPS id 84si4510984lfy.115.2016.01.22.23.39.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jan 2016 23:39:46 -0800 (PST)
Received: by mail-lb0-x244.google.com with SMTP id ad5so4067292lbc.3
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 23:39:46 -0800 (PST)
Subject: [PATCH 1/2] mm: do not limit VmData with RLIMIT_DATA
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Sat, 23 Jan 2016 10:39:40 +0300
Message-ID: <145353478067.23962.14991739413777907906.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linuxfoundation.org>, linux-kernel@vger.kernel.org
Cc: Vegard Nossum <vegard.nossum@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Vladimir Davydov <vdavydov@virtuozzo.com>, Andy Lutomirski <luto@amacapital.net>, Quentin Casasnovas <quentin.casasnovas@oracle.com>, Kees Cook <keescook@google.com>, Willy Tarreau <w@1wt.eu>, Pavel Emelyanov <xemul@virtuozzo.com>

This partially reverts 84638335900f ("mm: rework virtual memory accounting")

Before that commit RLIMIT_DATA have control only over size of the brk region.
But that change have caused problems with all existing versions of valgrind
because they set RLIMIT_DATA to zero for some reason.

More over, current check has a major flaw: RLIMIT_DATA in bytes,
not pages. So, some problems might have slipped through testing.
Let's revert it for now and put back in next release.

Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
Link: http://lkml.kernel.org/r/20151228211015.GL2194@uranus
Reported-by: Christian Borntraeger <borntraeger@de.ibm.com>
---
 mm/mmap.c |    4 ----
 1 file changed, 4 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 84b12624ceb0..e0cd98c510ba 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2982,10 +2982,6 @@ bool may_expand_vm(struct mm_struct *mm, vm_flags_t flags, unsigned long npages)
 	if (mm->total_vm + npages > rlimit(RLIMIT_AS) >> PAGE_SHIFT)
 		return false;
 
-	if ((flags & (VM_WRITE | VM_SHARED | (VM_STACK_FLAGS &
-				(VM_GROWSUP | VM_GROWSDOWN)))) == VM_WRITE)
-		return mm->data_vm + npages <= rlimit(RLIMIT_DATA);
-
 	return true;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
