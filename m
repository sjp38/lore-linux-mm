Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id C1B3F8E0001
	for <linux-mm@kvack.org>; Fri, 28 Dec 2018 08:15:47 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id f9so19896051pgs.13
        for <linux-mm@kvack.org>; Fri, 28 Dec 2018 05:15:47 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id d69si38869432pga.184.2018.12.28.05.15.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Dec 2018 05:15:46 -0800 (PST)
Date: Fri, 28 Dec 2018 21:15:42 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [RFC][PATCH v2 00/21] PMEM NUMA node and hotness
 accounting/migration
Message-ID: <20181228131542.geshbmzvhr3litty@wfg-t540p.sh.intel.com>
References: <20181226131446.330864849@intel.com>
 <20181227203158.GO16738@dhcp22.suse.cz>
 <20181228050806.ewpxtwo3fpw7h3lq@wfg-t540p.sh.intel.com>
 <20181228084105.GQ16738@dhcp22.suse.cz>
 <20181228094208.7lgxhha34zpqu4db@wfg-t540p.sh.intel.com>
 <20181228121515.GS16738@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="sbnmklyntwize2li"
Content-Disposition: inline
In-Reply-To: <20181228121515.GS16738@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Fan Du <fan.du@intel.com>, Yao Yuan <yuan.yao@intel.com>, Peng Dong <dongx.peng@intel.com>, Huang Ying <ying.huang@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>


--sbnmklyntwize2li
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline

On Fri, Dec 28, 2018 at 01:15:15PM +0100, Michal Hocko wrote:
>On Fri 28-12-18 17:42:08, Wu Fengguang wrote:
>[...]
>> Those look unnecessary complexities for this post. This v2 patchset
>> mainly fulfills our first milestone goal: a minimal viable solution
>> that's relatively clean to backport. Even when preparing for new
>> upstreamable versions, it may be good to keep it simple for the
>> initial upstream inclusion.
>
>On the other hand this is creating a new NUMA semantic and I would like
>to have something long term thatn let's throw something in now and care
>about long term later. So I would really prefer to talk about long term
>plans first and only care about implementation details later.

That makes good sense. FYI here are the several in-house patches that
try to leverage (but not yet integrate with) NUMA balancing. The last
one is brutal force hacking. They obviously break original NUMA
balancing logic.

Thanks,
Fengguang

--sbnmklyntwize2li
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0074-migrate-set-PROT_NONE-on-the-PTEs-and-let-NUMA-balan.patch"

>From ef41a542568913c8c62251021c3bc38b7a549440 Mon Sep 17 00:00:00 2001
From: Liu Jingqi <jingqi.liu@intel.com>
Date: Sat, 29 Sep 2018 23:29:56 +0800
Subject: [PATCH 074/166] migrate: set PROT_NONE on the PTEs and let NUMA
 balancing

Need to enable CONFIG_NUMA_BALANCING firstly.
Set PROT_NONE on the PTEs that map to the page,
and do the actual migration in the context of process which initiate migration.

Signed-off-by: Liu Jingqi <jingqi.liu@intel.com>
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 mm/migrate.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/mm/migrate.c b/mm/migrate.c
index b27a287081c2..d933f6966601 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1530,6 +1530,21 @@ static int add_page_for_migration(struct mm_struct *mm, unsigned long addr,
 	if (page_mapcount(page) > 1 && !migrate_all)
 		goto out_putpage;
 
+	if (flags & MPOL_MF_SW_YOUNG) {
+		unsigned long start, end;
+		unsigned long nr_pte_updates = 0;
+
+		start = max(addr, vma->vm_start);
+
+		/* TODO: if huge page  */
+		end = ALIGN(addr + (1 << PAGE_SHIFT), PAGE_SIZE);
+		end = min(end, vma->vm_end);
+		nr_pte_updates = change_prot_numa(vma, start, end);
+
+		err = 0;
+		goto out_putpage;
+	}
+
 	if (PageHuge(page)) {
 		if (PageHead(page)) {
 			/* Check if the page is software young. */
-- 
2.15.0


--sbnmklyntwize2li
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0075-migrate-consolidate-MPOL_MF_SW_YOUNG-behaviors.patch"

>From e617e8c2034387cbed50bafa786cf83528dbe3df Mon Sep 17 00:00:00 2001
From: Fengguang Wu <fengguang.wu@intel.com>
Date: Sun, 30 Sep 2018 10:50:58 +0800
Subject: [PATCH 075/166] migrate: consolidate MPOL_MF_SW_YOUNG behaviors

- if page already in target node: SetPageReferenced
- otherwise: change_prot_numa

Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 arch/x86/kvm/Kconfig |  1 +
 mm/migrate.c         | 65 +++++++++++++++++++++++++++++++---------------------
 2 files changed, 40 insertions(+), 26 deletions(-)

diff --git a/arch/x86/kvm/Kconfig b/arch/x86/kvm/Kconfig
index 4c6dec47fac6..c103373536fc 100644
--- a/arch/x86/kvm/Kconfig
+++ b/arch/x86/kvm/Kconfig
@@ -100,6 +100,7 @@ config KVM_EPT_IDLE
 	tristate "KVM EPT idle page tracking"
 	depends on KVM_INTEL
 	depends on PROC_PAGE_MONITOR
+	depends on NUMA_BALANCING
 	---help---
 	  Provides support for walking EPT to get the A bits on Intel
 	  processors equipped with the VT extensions.
diff --git a/mm/migrate.c b/mm/migrate.c
index d933f6966601..d944f031c9ea 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1500,6 +1500,8 @@ static int add_page_for_migration(struct mm_struct *mm, unsigned long addr,
 {
 	struct vm_area_struct *vma;
 	struct page *page;
+	unsigned long end;
+	unsigned int page_nid;
 	unsigned int follflags;
 	int err;
 	bool migrate_all = flags & MPOL_MF_MOVE_ALL;
@@ -1522,49 +1524,60 @@ static int add_page_for_migration(struct mm_struct *mm, unsigned long addr,
 	if (!page)
 		goto out;
 
-	err = 0;
-	if (page_to_nid(page) == node)
-		goto out_putpage;
+	page_nid = page_to_nid(page);
 
 	err = -EACCES;
 	if (page_mapcount(page) > 1 && !migrate_all)
 		goto out_putpage;
 
-	if (flags & MPOL_MF_SW_YOUNG) {
-		unsigned long start, end;
-		unsigned long nr_pte_updates = 0;
-
-		start = max(addr, vma->vm_start);
-
-		/* TODO: if huge page  */
-		end = ALIGN(addr + (1 << PAGE_SHIFT), PAGE_SIZE);
-		end = min(end, vma->vm_end);
-		nr_pte_updates = change_prot_numa(vma, start, end);
-
-		err = 0;
-		goto out_putpage;
-	}
-
+	err = 0;
 	if (PageHuge(page)) {
-		if (PageHead(page)) {
-			/* Check if the page is software young. */
-			if (flags & MPOL_MF_SW_YOUNG)
+		if (!PageHead(page)) {
+			err = -EACCES;
+			goto out_putpage;
+		}
+		if (flags & MPOL_MF_SW_YOUNG) {
+			if (page_nid == node)
 				SetPageReferenced(page);
-			isolate_huge_page(page, pagelist);
-			err = 0;
+			else if (PageAnon(page)) {
+				end = addr + (hpage_nr_pages(page) << PAGE_SHIFT);
+				if (end <= vma->vm_end)
+					change_prot_numa(vma, addr, end);
+			}
+			goto out_putpage;
 		}
+		if (page_nid == node)
+			goto out_putpage;
+		isolate_huge_page(page, pagelist);
 	} else {
 		struct page *head;
 
 		head = compound_head(page);
+
+		if (flags & MPOL_MF_SW_YOUNG) {
+			if (page_nid == node)
+				SetPageReferenced(head);
+			else {
+				unsigned long size;
+				size = hpage_nr_pages(head) << PAGE_SHIFT;
+				end = addr + size;
+				if (unlikely(addr & (size - 1)))
+					err = -EXDEV;
+				else if (likely(end <= vma->vm_end))
+					change_prot_numa(vma, addr, end);
+				else
+					err = -ERANGE;
+			}
+			goto out_putpage;
+		}
+		if (page_nid == node)
+			goto out_putpage;
+
 		err = isolate_lru_page(head);
 		if (err)
 			goto out_putpage;
 
 		err = 0;
-		/* Check if the page is software young. */
-		if (flags & MPOL_MF_SW_YOUNG)
-			SetPageReferenced(head);
 		list_add_tail(&head->lru, pagelist);
 		mod_node_page_state(page_pgdat(head),
 			NR_ISOLATED_ANON + page_is_file_cache(head),
-- 
2.15.0


--sbnmklyntwize2li
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0076-mempolicy-force-NUMA-balancing.patch"

>From a2d9740d1639f807868014c16dc9e2620d356f3c Mon Sep 17 00:00:00 2001
From: Fengguang Wu <fengguang.wu@intel.com>
Date: Sun, 30 Sep 2018 19:22:27 +0800
Subject: [PATCH 076/166] mempolicy: force NUMA balancing

Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 mm/memory.c    | 3 ++-
 mm/mempolicy.c | 5 -----
 2 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index c467102a5cbc..20c7efdff63b 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3775,7 +3775,8 @@ static int numa_migrate_prep(struct page *page, struct vm_area_struct *vma,
 		*flags |= TNF_FAULT_LOCAL;
 	}
 
-	return mpol_misplaced(page, vma, addr);
+	return 0;
+	/* return mpol_misplaced(page, vma, addr); */
 }
 
 static vm_fault_t do_numa_page(struct vm_fault *vmf)
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index da858f794eb6..21dc6ba1d062 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2295,8 +2295,6 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
 	int ret = -1;
 
 	pol = get_vma_policy(vma, addr);
-	if (!(pol->flags & MPOL_F_MOF))
-		goto out;
 
 	switch (pol->mode) {
 	case MPOL_INTERLEAVE:
@@ -2336,9 +2334,6 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
 	/* Migrate the page towards the node whose CPU is referencing it */
 	if (pol->flags & MPOL_F_MORON) {
 		polnid = thisnid;
-
-		if (!should_numa_migrate_memory(current, page, curnid, thiscpu))
-			goto out;
 	}
 
 	if (curnid != polnid)
-- 
2.15.0


--sbnmklyntwize2li--
