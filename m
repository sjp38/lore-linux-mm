Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id AB4776B0039
	for <linux-mm@kvack.org>; Wed, 18 Jun 2014 16:41:00 -0400 (EDT)
Received: by mail-wg0-f44.google.com with SMTP id x13so1396551wgg.27
        for <linux-mm@kvack.org>; Wed, 18 Jun 2014 13:41:00 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id cb12si36298wib.106.2014.06.18.13.40.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Jun 2014 13:40:59 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 04/13] mm: huge_memory: use GFP_TRANSHUGE when charging huge pages
Date: Wed, 18 Jun 2014 16:40:36 -0400
Message-Id: <1403124045-24361-5-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1403124045-24361-1-git-send-email-hannes@cmpxchg.org>
References: <1403124045-24361-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Transparent huge page charges prefer falling back to regular pages
rather than spending a lot of time in direct reclaim.

Desired reclaim behavior is usually declared in the gfp mask, but THP
charges use GFP_KERNEL and then rely on the fact that OOM is disabled
for THP charges, and that OOM-disabled charges don't retry reclaim.
Needless to say, this is anything but obvious and quite error prone.

Convert THP charges to use GFP_TRANSHUGE instead, which implies
__GFP_NORETRY, to indicate the low-latency requirement.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Michal Hocko <mhocko@suse.cz>
---
 mm/huge_memory.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index e60837dc785c..10cd7f2bf776 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -827,7 +827,7 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		count_vm_event(THP_FAULT_FALLBACK);
 		return VM_FAULT_FALLBACK;
 	}
-	if (unlikely(mem_cgroup_charge_anon(page, mm, GFP_KERNEL))) {
+	if (unlikely(mem_cgroup_charge_anon(page, mm, GFP_TRANSHUGE))) {
 		put_page(page);
 		count_vm_event(THP_FAULT_FALLBACK);
 		return VM_FAULT_FALLBACK;
@@ -1101,7 +1101,7 @@ alloc:
 		goto out;
 	}
 
-	if (unlikely(mem_cgroup_charge_anon(new_page, mm, GFP_KERNEL))) {
+	if (unlikely(mem_cgroup_charge_anon(new_page, mm, GFP_TRANSHUGE))) {
 		put_page(new_page);
 		if (page) {
 			split_huge_page(page);
@@ -2368,7 +2368,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	if (!new_page)
 		return;
 
-	if (unlikely(mem_cgroup_charge_anon(new_page, mm, GFP_KERNEL)))
+	if (unlikely(mem_cgroup_charge_anon(new_page, mm, GFP_TRANSHUGE)))
 		return;
 
 	/*
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
