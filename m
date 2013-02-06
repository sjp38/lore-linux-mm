Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id DE9566B0005
	for <linux-mm@kvack.org>; Wed,  6 Feb 2013 10:49:55 -0500 (EST)
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Wed, 6 Feb 2013 15:48:37 -0000
Received: from d06av11.portsmouth.uk.ibm.com (d06av11.portsmouth.uk.ibm.com [9.149.37.252])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r16FngE127721834
	for <linux-mm@kvack.org>; Wed, 6 Feb 2013 15:49:42 GMT
Received: from d06av11.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av11.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r16FnooQ029869
	for <linux-mm@kvack.org>; Wed, 6 Feb 2013 08:49:51 -0700
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: [PATCH] mm: don't overwrite mm->def_flags in do_mlockall()
Date: Wed,  6 Feb 2013 16:49:34 +0100
Message-Id: <1360165774-55458-1-git-send-email-gerald.schaefer@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vivek Goyal <vgoyal@redhat.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>

With commit 8e72033 "thp: make MADV_HUGEPAGE check for mm->def_flags"
the VM_NOHUGEPAGE flag may be set on s390 in mm->def_flags for certain
processes, to prevent future thp mappings. This would be overwritten
by do_mlockall(), which sets it back to 0 with an optional VM_LOCKED
flag set.

To fix this, instead of overwriting mm->def_flags in do_mlockall(),
only the VM_LOCKED flag should be set or cleared.

Reported-by: Vivek Goyal <vgoyal@redhat.com>
Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
---
 mm/mlock.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/mlock.c b/mm/mlock.c
index f0b9ce5..c9bd528 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -517,11 +517,11 @@ SYSCALL_DEFINE2(munlock, unsigned long, start, size_t, len)
 static int do_mlockall(int flags)
 {
 	struct vm_area_struct * vma, * prev = NULL;
-	unsigned int def_flags = 0;
 
 	if (flags & MCL_FUTURE)
-		def_flags = VM_LOCKED;
-	current->mm->def_flags = def_flags;
+		current->mm->def_flags |= VM_LOCKED;
+	else
+		current->mm->def_flags &= ~VM_LOCKED;
 	if (flags == MCL_FUTURE)
 		goto out;
 
-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
