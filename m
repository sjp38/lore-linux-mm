Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C2C386B02F4
	for <linux-mm@kvack.org>; Wed, 24 May 2017 07:20:16 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id c6so192980339pfj.5
        for <linux-mm@kvack.org>; Wed, 24 May 2017 04:20:16 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id i67si24213205pfj.149.2017.05.24.04.20.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 May 2017 04:20:16 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4OB9kZK085436
	for <linux-mm@kvack.org>; Wed, 24 May 2017 07:20:15 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2amxxk8sg5-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 24 May 2017 07:20:15 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 24 May 2017 12:20:12 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [RFC v2 02/10] mm: Remove nest locking operation with mmap_sem
Date: Wed, 24 May 2017 13:19:53 +0200
In-Reply-To: <1495624801-8063-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1495624801-8063-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1495624801-8063-3-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Davidlohr Bueso <dave@stgolabs.net>, akpm@linux-foundation.org, Jan Kara <jack@suse.cz>, "Kirill A . Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@techsingularity.net>, Andi Kleen <andi@firstfloor.org>, haren@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, linux-kernel@vger.kernel.org

The range locking framework doesn't yet provide nest locking
operation.

Once the range locking API while provide nested operation support,
this patch will have to be reviewed.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 mm/mmap.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/mm/mmap.c b/mm/mmap.c
index f82741e199c0..87c8625ae91d 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3284,7 +3284,11 @@ static void vm_lock_anon_vma(struct mm_struct *mm, struct anon_vma *anon_vma)
 		 * The LSB of head.next can't change from under us
 		 * because we hold the mm_all_locks_mutex.
 		 */
+#ifndef CONFIG_MEM_RANGE_LOCK
 		down_write_nest_lock(&anon_vma->root->rwsem, &mm->mmap_sem);
+#else
+		down_write(&anon_vma->root->rwsem);
+#endif
 		/*
 		 * We can safely modify head.next after taking the
 		 * anon_vma->root->rwsem. If some other vma in this mm shares
@@ -3314,7 +3318,11 @@ static void vm_lock_mapping(struct mm_struct *mm, struct address_space *mapping)
 		 */
 		if (test_and_set_bit(AS_MM_ALL_LOCKS, &mapping->flags))
 			BUG();
+#ifndef CONFIG_MEM_RANGE_LOCK
 		down_write_nest_lock(&mapping->i_mmap_rwsem, &mm->mmap_sem);
+#else
+		down_write(&mapping->i_mmap_rwsem);
+#endif
 	}
 }
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
