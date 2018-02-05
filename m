Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7ECDF6B005D
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 20:28:09 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id o16so18653564pgv.3
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 17:28:09 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p3-v6si4270091plo.99.2018.02.04.17.28.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Feb 2018 17:28:08 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 63/64] mm/mmap: hack drop down_write_nest_lock()
Date: Mon,  5 Feb 2018 02:27:53 +0100
Message-Id: <20180205012754.23615-64-dbueso@wotan.suse.de>
In-Reply-To: <20180205012754.23615-1-dbueso@wotan.suse.de>
References: <20180205012754.23615-1-dbueso@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mingo@kernel.org
Cc: peterz@infradead.org, ldufour@linux.vnet.ibm.com, jack@suse.cz, mhocko@kernel.org, kirill.shutemov@linux.intel.com, mawilcox@microsoft.com, mgorman@techsingularity.net, dave@stgolabs.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

From: Davidlohr Bueso <dave@stgolabs.net>

* THIS IS A HACK *

Directly call down_write() on i_mmap_rwsem (such that
we don't have to convert it to a range lock)

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 mm/mmap.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index e10d005f7e2f..1d3a5edd19b2 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3394,7 +3394,7 @@ static void vm_lock_anon_vma(struct mm_struct *mm, struct anon_vma *anon_vma)
 		 * The LSB of head.next can't change from under us
 		 * because we hold the mm_all_locks_mutex.
 		 */
-		down_write_nest_lock(&anon_vma->root->rwsem, &mm->mmap_sem);
+		down_write(&anon_vma->root->rwsem);
 		/*
 		 * We can safely modify head.next after taking the
 		 * anon_vma->root->rwsem. If some other vma in this mm shares
@@ -3424,7 +3424,7 @@ static void vm_lock_mapping(struct mm_struct *mm, struct address_space *mapping)
 		 */
 		if (test_and_set_bit(AS_MM_ALL_LOCKS, &mapping->flags))
 			BUG();
-		down_write_nest_lock(&mapping->i_mmap_rwsem, &mm->mmap_sem);
+		down_write(&mapping->i_mmap_rwsem);
 	}
 }
 
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
