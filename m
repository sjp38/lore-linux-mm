Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1376C6B0005
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 20:28:03 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id q5so7779408pll.17
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 17:28:03 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h1-v6si2071263pld.637.2018.02.04.17.28.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Feb 2018 17:28:01 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 04/64] mm: add a range parameter to the vm_fault structure
Date: Mon,  5 Feb 2018 02:26:54 +0100
Message-Id: <20180205012754.23615-5-dbueso@wotan.suse.de>
In-Reply-To: <20180205012754.23615-1-dbueso@wotan.suse.de>
References: <20180205012754.23615-1-dbueso@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mingo@kernel.org
Cc: peterz@infradead.org, ldufour@linux.vnet.ibm.com, jack@suse.cz, mhocko@kernel.org, kirill.shutemov@linux.intel.com, mawilcox@microsoft.com, mgorman@techsingularity.net, dave@stgolabs.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

From: Davidlohr Bueso <dave@stgolabs.net>

When handling a page fault, it happens that the mmap_sem is released
during the processing. As moving to range lock requires to pass the
range parameter to the lock/unlock operation, this patch add a pointer
to the range structure used when locking the mmap_sem to vm_fault
structure.

It is currently unused, but will be in the next patches.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 include/linux/mm.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 9d2ed23aa894..bcf2509d448d 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -361,6 +361,10 @@ struct vm_fault {
 					 * page table to avoid allocation from
 					 * atomic context.
 					 */
+	struct range_lock *lockrange;	/* Range lock interval in use for when
+					 * the mm lock is manipulated throughout
+					 * its lifespan.
+					 */
 };
 
 /* page entry size for vm->huge_fault() */
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
