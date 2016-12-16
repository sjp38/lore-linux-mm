Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 12A116B027C
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 09:48:30 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id b132so21281183iti.5
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 06:48:30 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r3si2961275ita.25.2016.12.16.06.48.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 06:48:29 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 35/42] userfaultfd: shmem: lock the page before adding it to pagecache
Date: Fri, 16 Dec 2016 15:48:14 +0100
Message-Id: <20161216144821.5183-36-aarcange@redhat.com>
In-Reply-To: <20161216144821.5183-1-aarcange@redhat.com>
References: <20161216144821.5183-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@parallels.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

A VM_BUG_ON triggered on the shmem selftest.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/shmem.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/mm/shmem.c b/mm/shmem.c
index 75866a3..f0f1431 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2241,6 +2241,10 @@ int shmem_mcopy_atomic_pte(struct mm_struct *dst_mm,
 		*pagep = NULL;
 	}
 
+	VM_BUG_ON(PageLocked(page) || PageSwapBacked(page));
+	__SetPageLocked(page);
+	__SetPageSwapBacked(page);
+
 	ret = mem_cgroup_try_charge(page, dst_mm, gfp, &memcg, false);
 	if (ret)
 		goto out_release;
@@ -2290,6 +2294,7 @@ int shmem_mcopy_atomic_pte(struct mm_struct *dst_mm,
 out_release_uncharge:
 	mem_cgroup_cancel_charge(page, memcg, false);
 out_release:
+	unlock_page(page);
 	put_page(page);
 out_dec_used_blocks:
 	if (sbinfo->max_blocks)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
