Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f48.google.com (mail-yh0-f48.google.com [209.85.213.48])
	by kanga.kvack.org (Postfix) with ESMTP id B1BED6B0071
	for <linux-mm@kvack.org>; Thu, 27 Feb 2014 12:23:47 -0500 (EST)
Received: by mail-yh0-f48.google.com with SMTP id z6so2890432yhz.35
        for <linux-mm@kvack.org>; Thu, 27 Feb 2014 09:23:47 -0800 (PST)
Received: from relay.sgi.com (relay1.sgi.com. [192.48.179.29])
        by mx.google.com with ESMTP id o69si8466877yhb.132.2014.02.27.09.23.46
        for <linux-mm@kvack.org>;
        Thu, 27 Feb 2014 09:23:47 -0800 (PST)
From: Alex Thorlton <athorlton@sgi.com>
Subject: [PATCH 2/4] mm, s390: Ignore MADV_HUGEPAGE on s390 to prevent SIGSEGV in qemu
Date: Thu, 27 Feb 2014 11:23:24 -0600
Message-Id: <c856e298ae180842638bdf85d74436ad8bbb84e4.1393516106.git.athorlton@sgi.com>
In-Reply-To: <cover.1393516106.git.athorlton@sgi.com>
References: <cover.1393516106.git.athorlton@sgi.com>
In-Reply-To: <cover.1393516106.git.athorlton@sgi.com>
References: <cover.1393516106.git.athorlton@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Alex Thorlton <athorlton@sgi.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Oleg Nesterov <oleg@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux390@de.ibm.com, linux-s390@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org

As Christian pointed out, the recent 'Revert "thp: make MADV_HUGEPAGE
check for mm->def_flags"' breaks qemu, it does QEMU_MADV_HUGEPAGE for
all kvm pages but this doesn't work after s390_enable_sie/thp_split_mm.

Paolo suggested that instead of failing on the call to madvise, we
simply ignore the call (return 0).

Reported-by: Christian Borntraeger <borntraeger@de.ibm.com>
Suggested-by: Paolo Bonzini <pbonzini@redhat.com>
Suggested-by: Oleg Nesterov <oleg@redhat.com>
Signed-off-by: Alex Thorlton <athorlton@sgi.com>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux390@de.ibm.com
Cc: linux-s390@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: linux-api@vger.kernel.org

---
 mm/huge_memory.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index a4310a5..61d234d 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1970,6 +1970,15 @@ int hugepage_madvise(struct vm_area_struct *vma,
 {
 	switch (advice) {
 	case MADV_HUGEPAGE:
+#ifdef CONFIG_S390
+		/*
+		 * qemu blindly sets MADV_HUGEPAGE on all allocations, but s390
+		 * can't handle this properly after s390_enable_sie, so we simply
+		 * ignore the madvise to prevent qemu from causing a SIGSEGV.
+		 */
+		if (mm_has_pgste(vma->vm_mm))
+			return 0;
+#endif
 		/*
 		 * Be somewhat over-protective like KSM for now!
 		 */
-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
