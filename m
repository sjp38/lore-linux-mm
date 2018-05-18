Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id DE9F56B0578
	for <linux-mm@kvack.org>; Fri, 18 May 2018 00:41:23 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id s16-v6so4046951pfm.1
        for <linux-mm@kvack.org>; Thu, 17 May 2018 21:41:23 -0700 (PDT)
Received: from ns.ascade.co.jp (ext-host0001.ascade.co.jp. [218.224.228.194])
        by mx.google.com with ESMTP id v2-v6si6821976plo.138.2018.05.17.21.41.22
        for <linux-mm@kvack.org>;
        Thu, 17 May 2018 21:41:22 -0700 (PDT)
Subject: [PATCH v2 7/7] memcg: supports movement of surplus hugepages
 statistics
References: <e863529b-7ce5-4fbe-8cff-581b5789a5f9@ascade.co.jp>
From: TSUKADA Koutaro <tsukada@ascade.co.jp>
Message-ID: <caab17ea-840e-c9c3-4da1-e99050c4256d@ascade.co.jp>
Date: Fri, 18 May 2018 13:41:15 +0900
MIME-Version: 1.0
In-Reply-To: <e863529b-7ce5-4fbe-8cff-581b5789a5f9@ascade.co.jp>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, David Rientjes <rientjes@google.com>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Marc-Andre Lureau <marcandre.lureau@redhat.com>, Punit Agrawal <punit.agrawal@arm.com>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, tsukada@ascade.co.jp

When the task that charged surplus hugepages moves memory cgroup, it
updates the statistical information correctly.

Signed-off-by: TSUKADA Koutaro <tsukada@ascade.co.jp>
---
 memcontrol.c |   99 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 99 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index a8f1ff8..63f0922 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4698,12 +4698,110 @@ static int mem_cgroup_count_precharge_pte_range(pmd_t *pmd,
 	return 0;
 }

+#ifdef CONFIG_HUGETLB_PAGE
+static enum mc_target_type get_mctgt_type_hugetlb(struct vm_area_struct *vma,
+			unsigned long addr, pte_t *pte, union mc_target *target)
+{
+	struct page *page = NULL;
+	pte_t entry;
+	enum mc_target_type ret = MC_TARGET_NONE;
+
+	if (!(mc.flags & MOVE_ANON))
+		return ret;
+
+	entry = huge_ptep_get(pte);
+	if (!pte_present(entry))
+		return ret;
+
+	page = pte_page(entry);
+	VM_BUG_ON_PAGE(!page || !PageHead(page), page);
+	if (likely(!PageSurplusCharge(page)))
+		return ret;
+	if (page->mem_cgroup == mc.from) {
+		ret = MC_TARGET_PAGE;
+		if (target) {
+			get_page(page);
+			target->page = page;
+		}
+	}
+
+	return ret;
+}
+
+static int hugetlb_count_precharge_pte_range(pte_t *pte, unsigned long hmask,
+					unsigned long addr, unsigned long end,
+					struct mm_walk *walk)
+{
+	struct vm_area_struct *vma = walk->vma;
+	struct mm_struct *mm = walk->mm;
+	spinlock_t *ptl;
+	union mc_target target;
+
+	ptl = huge_pte_lock(hstate_vma(vma), mm, pte);
+	if (get_mctgt_type_hugetlb(vma, addr, pte, &target) == MC_TARGET_PAGE) {
+		mc.precharge += (1 << compound_order(target.page));
+		put_page(target.page);
+	}
+	spin_unlock(ptl);
+
+	return 0;
+}
+
+static int hugetlb_move_charge_pte_range(pte_t *pte, unsigned long hmask,
+					unsigned long addr, unsigned long end,
+					struct mm_walk *walk)
+{
+	struct vm_area_struct *vma = walk->vma;
+	struct mm_struct *mm = walk->mm;
+	spinlock_t *ptl;
+	enum mc_target_type target_type;
+	union mc_target target;
+	struct page *page;
+	unsigned long nr_pages;
+
+	ptl = huge_pte_lock(hstate_vma(vma), mm, pte);
+	target_type = get_mctgt_type_hugetlb(vma, addr, pte, &target);
+	if (target_type == MC_TARGET_PAGE) {
+		page = target.page;
+		nr_pages = (1 << compound_order(page));
+		if (mc.precharge < nr_pages) {
+			put_page(page);
+			goto unlock;
+		}
+		if (!mem_cgroup_move_account(page, true, mc.from, mc.to)) {
+			mc.precharge -= nr_pages;
+			mc.moved_charge += nr_pages;
+		}
+		put_page(page);
+	}
+unlock:
+	spin_unlock(ptl);
+
+	return 0;
+}
+#else
+static int hugetlb_count_precharge_pte_range(pte_t *pte, unsigned long hmask,
+					unsigned long addr, unsigned long end,
+					struct mm_walk *walk)
+{
+	return 0;
+}
+
+static int hugetlb_move_charge_pte_range(pte_t *pte, unsigned long hmask,
+					unsigned long addr, unsigned long end,
+					struct mm_walk *walk)
+{
+	return 0;
+}
+#endif
+
 static unsigned long mem_cgroup_count_precharge(struct mm_struct *mm)
 {
 	unsigned long precharge;

 	struct mm_walk mem_cgroup_count_precharge_walk = {
 		.pmd_entry = mem_cgroup_count_precharge_pte_range,
+		.hugetlb_entry = hugetlb_count_precharge_pte_range,
 		.mm = mm,
 	};
 	down_read(&mm->mmap_sem);
@@ -4981,6 +5079,7 @@ static void mem_cgroup_move_charge(void)
 {
 	struct mm_walk mem_cgroup_move_charge_walk = {
 		.pmd_entry = mem_cgroup_move_charge_pte_range,
+		.hugetlb_entry = hugetlb_move_charge_pte_range,
 		.mm = mc.mm,
 	};

-- 
Tsukada
