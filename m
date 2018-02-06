Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 684F56B0026
	for <linux-mm@kvack.org>; Tue,  6 Feb 2018 11:49:51 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id h33so1894513plh.19
        for <linux-mm@kvack.org>; Tue, 06 Feb 2018 08:49:51 -0800 (PST)
Received: from smtp-fw-9101.amazon.com (smtp-fw-9101.amazon.com. [207.171.184.25])
        by mx.google.com with ESMTPS id v5si2030639pfl.11.2018.02.06.08.49.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Feb 2018 08:49:50 -0800 (PST)
From: David Woodhouse <dwmw@amazon.co.uk>
Subject: [PATCH] mm: Always print RLIMIT_DATA warning
Date: Tue,  6 Feb 2018 16:45:05 +0000
Message-Id: <1517935505-9321-1-git-send-email-dwmw@amazon.co.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Vegard Nossum <vegard.nossum@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Vladimir Davydov <vdavydov@virtuozzo.com>, Andy Lutomirski <luto@amacapital.net>, Quentin Casasnovas <quentin.casasnovas@oracle.com>, Kees Cook <keescook@google.com>, Willy Tarreau <w@1wt.eu>, Pavel Emelyanov <xemul@virtuozzo.com>, Laura Abbott <labbott@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

The documentation for ignore_rlimit_data says that it will print a warning
at first misuse. Yet it doesn't seem to do that. Fix the code to print
the warning even when we allow the process to continue.

Signed-off-by: David Woodhouse <dwmw@amazon.co.uk>
---
We should probably also do what Linus suggested in 
https://lkml.org/lkml/2016/9/16/585

 mm/mmap.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 9efdc021..dd76ea3 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3184,13 +3184,15 @@ bool may_expand_vm(struct mm_struct *mm, vm_flags_t flags, unsigned long npages)
 		if (rlimit(RLIMIT_DATA) == 0 &&
 		    mm->data_vm + npages <= rlimit_max(RLIMIT_DATA) >> PAGE_SHIFT)
 			return true;
-		if (!ignore_rlimit_data) {
-			pr_warn_once("%s (%d): VmData %lu exceed data ulimit %lu. Update limits or use boot option ignore_rlimit_data.\n",
-				     current->comm, current->pid,
-				     (mm->data_vm + npages) << PAGE_SHIFT,
-				     rlimit(RLIMIT_DATA));
+
+		pr_warn_once("%s (%d): VmData %lu exceed data ulimit %lu. Update limits%s.\n",
+			     current->comm, current->pid,
+			     (mm->data_vm + npages) << PAGE_SHIFT,
+			     rlimit(RLIMIT_DATA),
+			     ignore_rlimit_data ? "" : " or use boot option ignore_rlimit_data");
+
+		if (!ignore_rlimit_data)
 			return false;
-		}
 	}
 
 	return true;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
