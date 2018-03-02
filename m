Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6D4736B0007
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 12:43:47 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id 100so5660248oti.19
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 09:43:47 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h207si2009414oic.3.2018.03.02.09.43.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Mar 2018 09:43:46 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 1/1] mm: gup: teach get_user_pages_unlocked to handle FOLL_NOWAIT
Date: Fri,  2 Mar 2018 18:43:43 +0100
Message-Id: <20180302174343.5421-2-aarcange@redhat.com>
In-Reply-To: <20180302174343.5421-1-aarcange@redhat.com>
References: <20180302174343.5421-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, qemu-devel@nongnu.org, linux-mm@kvack.org

KVM is hanging during postcopy live migration with userfaultfd because
get_user_pages_unlocked is not capable to handle FOLL_NOWAIT.

Earlier FOLL_NOWAIT was only ever passed to get_user_pages.

Specifically faultin_page (the callee of get_user_pages_unlocked
caller) doesn't know that if FAULT_FLAG_RETRY_NOWAIT was set in the
page fault flags, when VM_FAULT_RETRY is returned, the mmap_sem wasn't
actually released (even if nonblocking is not NULL). So it sets
*nonblocking to zero and the caller won't release the mmap_sem
thinking it was already released, but it wasn't because of
FOLL_NOWAIT.

Reported-by: Dr. David Alan Gilbert <dgilbert@redhat.com>
Tested-by: Dr. David Alan Gilbert <dgilbert@redhat.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/gup.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index 1b46e6e74881..6afae32571ca 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -516,7 +516,7 @@ static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
 	}
 
 	if (ret & VM_FAULT_RETRY) {
-		if (nonblocking)
+		if (nonblocking && !(fault_flags & FAULT_FLAG_RETRY_NOWAIT))
 			*nonblocking = 0;
 		return -EBUSY;
 	}
@@ -890,7 +890,10 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
 				break;
 		}
 		if (*locked) {
-			/* VM_FAULT_RETRY didn't trigger */
+			/*
+			 * VM_FAULT_RETRY didn't trigger or it was a
+			 * FOLL_NOWAIT.
+			 */
 			if (!pages_done)
 				pages_done = ret;
 			break;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
