Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com [209.85.217.180])
	by kanga.kvack.org (Postfix) with ESMTP id 742E16B0035
	for <linux-mm@kvack.org>; Tue, 12 Aug 2014 09:23:59 -0400 (EDT)
Received: by mail-lb0-f180.google.com with SMTP id v6so6902279lbi.25
        for <linux-mm@kvack.org>; Tue, 12 Aug 2014 06:23:58 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lv11si23928356lac.51.2014.08.12.06.23.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 12 Aug 2014 06:23:57 -0700 (PDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH] hugetlb_cgroup: use lockdep_assert_held rather than spin_is_locked
Date: Tue, 12 Aug 2014 15:23:50 +0200
Message-Id: <1407849830-22500-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

spin_lock may be an empty struct for !SMP configurations and so
arch_spin_is_locked may return unconditional 0 and trigger the VM_BUG_ON
even when the lock is held.

Replace spin_is_locked by lockdep_assert_held. We will not BUG anymore
but it is questionable whether crashing makes a lot of sense in the
uncharge path. Uncharge happens after the last page reference was
released so nobody should touch the page and the function doesn't update
any shared state except for res counter which uses synchronization of
its own.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/hugetlb_cgroup.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
index 9aae6f47433f..9edf189a5ef3 100644
--- a/mm/hugetlb_cgroup.c
+++ b/mm/hugetlb_cgroup.c
@@ -217,7 +217,7 @@ void hugetlb_cgroup_uncharge_page(int idx, unsigned long nr_pages,
 
 	if (hugetlb_cgroup_disabled())
 		return;
-	VM_BUG_ON(!spin_is_locked(&hugetlb_lock));
+	lockdep_assert_held(&hugetlb_lock);
 	h_cg = hugetlb_cgroup_from_page(page);
 	if (unlikely(!h_cg))
 		return;
-- 
2.1.0.rc1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
