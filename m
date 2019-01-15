Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id EEE8A8E0006
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 13:13:31 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id q64so2531173pfa.18
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 10:13:31 -0800 (PST)
Received: from smtp2.provo.novell.com (smtp2.provo.novell.com. [137.65.250.81])
        by mx.google.com with ESMTPS id v75si3889866pfd.157.2019.01.15.10.13.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jan 2019 10:13:30 -0800 (PST)
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: [PATCH 4/6] drivers/IB,hfi1: do not se mmap_sem
Date: Tue, 15 Jan 2019 10:12:58 -0800
Message-Id: <20190115181300.27547-5-dave@stgolabs.net>
In-Reply-To: <20190115181300.27547-1-dave@stgolabs.net>
References: <20190115181300.27547-1-dave@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: dledford@redhat.com, jgg@mellanox.com, linux-rdma@vger.kernel.org, linux-mm@kvack.org, dave@stgolabs.net, mike.marciniszyn@intel.com, dennis.dalessandro@intel.com, Davidlohr Bueso <dbueso@suse.de>

This driver already uses gup_fast() and thus we can just drop
the mmap_sem protection around the pinned_vm counter. Note that
the window between when hfi1_can_pin_pages() is called and the
actual counter is incremented remains the same as mmap_sem was
_only_ used for when ->pinned_vm was touched.

Cc: mike.marciniszyn@intel.com
Cc: dennis.dalessandro@intel.com
Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 drivers/infiniband/hw/hfi1/user_pages.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/infiniband/hw/hfi1/user_pages.c b/drivers/infiniband/hw/hfi1/user_pages.c
index df86a596d746..f0c6f219f575 100644
--- a/drivers/infiniband/hw/hfi1/user_pages.c
+++ b/drivers/infiniband/hw/hfi1/user_pages.c
@@ -91,9 +91,7 @@ bool hfi1_can_pin_pages(struct hfi1_devdata *dd, struct mm_struct *mm,
 	/* Convert to number of pages */
 	size = DIV_ROUND_UP(size, PAGE_SIZE);
 
-	down_read(&mm->mmap_sem);
 	pinned = atomic_long_read(&mm->pinned_vm);
-	up_read(&mm->mmap_sem);
 
 	/* First, check the absolute limit against all pinned pages. */
 	if (pinned + npages >= ulimit && !can_lock)
@@ -111,9 +109,7 @@ int hfi1_acquire_user_pages(struct mm_struct *mm, unsigned long vaddr, size_t np
 	if (ret < 0)
 		return ret;
 
-	down_write(&mm->mmap_sem);
 	atomic_long_add(ret, &mm->pinned_vm);
-	up_write(&mm->mmap_sem);
 
 	return ret;
 }
@@ -130,8 +126,6 @@ void hfi1_release_user_pages(struct mm_struct *mm, struct page **p,
 	}
 
 	if (mm) { /* during close after signal, mm can be NULL */
-		down_write(&mm->mmap_sem);
 		atomic_long_sub(npages, &mm->pinned_vm);
-		up_write(&mm->mmap_sem);
 	}
 }
-- 
2.16.4
