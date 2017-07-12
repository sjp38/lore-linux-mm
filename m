Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 53F65440874
	for <linux-mm@kvack.org>; Wed, 12 Jul 2017 14:06:24 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id 16so16019485qkg.15
        for <linux-mm@kvack.org>; Wed, 12 Jul 2017 11:06:24 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s2si2960371qts.42.2017.07.12.11.06.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jul 2017 11:06:22 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH 4/5] mm/memcontrol: support MEMORY_DEVICE_PRIVATE and MEMORY_DEVICE_HOST v2
Date: Wed, 12 Jul 2017 14:06:06 -0400
Message-Id: <20170712180607.2885-5-jglisse@redhat.com>
In-Reply-To: <20170712180607.2885-1-jglisse@redhat.com>
References: <20170712180607.2885-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Balbir Singh <bsingharora@gmail.com>, Michal Hocko <mhocko@kernel.org>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org

HMM pages (private or host device pages) are ZONE_DEVICE page and
thus need special handling when it comes to lru or refcount. This
patch make sure that memcontrol properly handle those when it face
them. Those pages are use like regular pages in a process address
space either as anonymous page or as file back page. So from memcg
point of view we want to handle them like regular page for now at
least.

Changed since v1:
  - s/public/host
  - add comments explaining how device memory behave and why

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: cgroups@vger.kernel.org
---
 kernel/memremap.c |  2 ++
 mm/memcontrol.c   | 63 ++++++++++++++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 60 insertions(+), 5 deletions(-)

diff --git a/kernel/memremap.c b/kernel/memremap.c
index 8e19f6513dfd..165818363e6a 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -479,6 +479,8 @@ void put_zone_device_private_or_host_page(struct page *page)
 		__ClearPageActive(page);
 		__ClearPageWaiters(page);
 
+		mem_cgroup_uncharge(page);
+
 		page->pgmap->page_free(page, page->pgmap->data);
 	}
 	else if (!count)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c709fdceac13..f8a961c7b3a0 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4391,12 +4391,13 @@ enum mc_target_type {
 	MC_TARGET_NONE = 0,
 	MC_TARGET_PAGE,
 	MC_TARGET_SWAP,
+	MC_TARGET_DEVICE,
 };
 
 static struct page *mc_handle_present_pte(struct vm_area_struct *vma,
 						unsigned long addr, pte_t ptent)
 {
-	struct page *page = vm_normal_page(vma, addr, ptent);
+	struct page *page = _vm_normal_page(vma, addr, ptent, true);
 
 	if (!page || !page_mapped(page))
 		return NULL;
@@ -4407,13 +4408,20 @@ static struct page *mc_handle_present_pte(struct vm_area_struct *vma,
 		if (!(mc.flags & MOVE_FILE))
 			return NULL;
 	}
-	if (!get_page_unless_zero(page))
+	if (is_device_host_page(page)) {
+		/*
+		 * MEMORY_DEVICE_HOST means ZONE_DEVICE page and which have a
+		 * refcount of 1 when free (unlike normal page)
+		 */
+		if (!page_ref_add_unless(page, 1, 1))
+			return NULL;
+	} else if (!get_page_unless_zero(page))
 		return NULL;
 
 	return page;
 }
 
-#ifdef CONFIG_SWAP
+#if defined(CONFIG_SWAP) || defined(CONFIG_DEVICE_PRIVATE)
 static struct page *mc_handle_swap_pte(struct vm_area_struct *vma,
 			pte_t ptent, swp_entry_t *entry)
 {
@@ -4422,6 +4430,23 @@ static struct page *mc_handle_swap_pte(struct vm_area_struct *vma,
 
 	if (!(mc.flags & MOVE_ANON) || non_swap_entry(ent))
 		return NULL;
+
+	/*
+	 * Handle MEMORY_DEVICE_PRIVATE which are ZONE_DEVICE page belonging to
+	 * a device and because they are not accessible by CPU they are store
+	 * as special swap entry in the CPU page table.
+	 */
+	if (is_device_private_entry(ent)) {
+		page = device_private_entry_to_page(ent);
+		/*
+		 * MEMORY_DEVICE_PRIVATE means ZONE_DEVICE page and which have
+		 * a refcount of 1 when free (unlike normal page)
+		 */
+		if (!page_ref_add_unless(page, 1, 1))
+			return NULL;
+		return page;
+	}
+
 	/*
 	 * Because lookup_swap_cache() updates some statistics counter,
 	 * we call find_get_page() with swapper_space directly.
@@ -4582,6 +4607,13 @@ static int mem_cgroup_move_account(struct page *page,
  *   2(MC_TARGET_SWAP): if the swap entry corresponding to this pte is a
  *     target for charge migration. if @target is not NULL, the entry is stored
  *     in target->ent.
+ *   3(MC_TARGET_DEVICE): like MC_TARGET_PAGE  but page is MEMORY_DEVICE_HOST
+ *     or MEMORY_DEVICE_PRIVATE (so ZONE_DEVICE page and thus not on the lru).
+ *     For now we such page is charge like a regular page would be as for all
+ *     intent and purposes it is just special memory taking the place of a
+ *     regular page. See Documentations/vm/hmm.txt and include/linux/hmm.h for
+ *     more informations on this type of memory how it is use and why it is
+ *     charge like this.
  *
  * Called with pte lock held.
  */
@@ -4610,6 +4642,9 @@ static enum mc_target_type get_mctgt_type(struct vm_area_struct *vma,
 		 */
 		if (page->mem_cgroup == mc.from) {
 			ret = MC_TARGET_PAGE;
+			if (is_device_private_page(page) ||
+			    is_device_host_page(page))
+				ret = MC_TARGET_DEVICE;
 			if (target)
 				target->page = page;
 		}
@@ -4669,6 +4704,11 @@ static int mem_cgroup_count_precharge_pte_range(pmd_t *pmd,
 
 	ptl = pmd_trans_huge_lock(pmd, vma);
 	if (ptl) {
+		/*
+		 * Note their can not be MC_TARGET_DEVICE for now as we do not
+		 * support transparent huge page with MEMORY_DEVICE_HOST or
+		 * MEMORY_DEVICE_PRIVATE but this might change.
+		 */
 		if (get_mctgt_type_thp(vma, addr, *pmd, NULL) == MC_TARGET_PAGE)
 			mc.precharge += HPAGE_PMD_NR;
 		spin_unlock(ptl);
@@ -4884,6 +4924,14 @@ static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
 				putback_lru_page(page);
 			}
 			put_page(page);
+		} else if (target_type == MC_TARGET_DEVICE) {
+			page = target.page;
+			if (!mem_cgroup_move_account(page, true,
+						     mc.from, mc.to)) {
+				mc.precharge -= HPAGE_PMD_NR;
+				mc.moved_charge += HPAGE_PMD_NR;
+			}
+			put_page(page);
 		}
 		spin_unlock(ptl);
 		return 0;
@@ -4895,12 +4943,16 @@ static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
 	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
 	for (; addr != end; addr += PAGE_SIZE) {
 		pte_t ptent = *(pte++);
+		bool device = false;
 		swp_entry_t ent;
 
 		if (!mc.precharge)
 			break;
 
 		switch (get_mctgt_type(vma, addr, ptent, &target)) {
+		case MC_TARGET_DEVICE:
+			device = true;
+			/* fall through */
 		case MC_TARGET_PAGE:
 			page = target.page;
 			/*
@@ -4911,7 +4963,7 @@ static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
 			 */
 			if (PageTransCompound(page))
 				goto put;
-			if (isolate_lru_page(page))
+			if (!device && isolate_lru_page(page))
 				goto put;
 			if (!mem_cgroup_move_account(page, false,
 						mc.from, mc.to)) {
@@ -4919,7 +4971,8 @@ static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
 				/* we uncharge from mc.from later. */
 				mc.moved_charge++;
 			}
-			putback_lru_page(page);
+			if (!device)
+				putback_lru_page(page);
 put:			/* get_mctgt_type() gets the page */
 			put_page(page);
 			break;
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
