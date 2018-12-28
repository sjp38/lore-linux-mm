Return-Path: <SRS0=dGUi=PF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 446B4C43612
	for <linux-mm@archiver.kernel.org>; Fri, 28 Dec 2018 13:15:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D08762146F
	for <linux-mm@archiver.kernel.org>; Fri, 28 Dec 2018 13:15:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D08762146F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 276A88E0042; Fri, 28 Dec 2018 08:15:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 224D28E0001; Fri, 28 Dec 2018 08:15:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0EEA78E0042; Fri, 28 Dec 2018 08:15:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id C1B3F8E0001
	for <linux-mm@kvack.org>; Fri, 28 Dec 2018 08:15:47 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id f9so19896051pgs.13
        for <linux-mm@kvack.org>; Fri, 28 Dec 2018 05:15:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=LkuqzoEvGWY3L+/exhV7qHVqp8mocfHNj6E12XXZdzI=;
        b=ZpbjpdsSBNtY0EuZ65OQPv3FDqinKL72vbDuO9HfxHiO+KwVPmCx17Ljbg3u+6JN2L
         DJ6jHbmmS65koo0EvDTINjXpFCOnr96CFdWgedGUPorW2dT9/0UjKHsKcgPZzdxo5GMf
         BybK2aY5AIjYtEL/Dmu6ylaMoDEGq8K8UB2iY4LWOB1hgeuAzGZmcjA41yJTqOjS9/6y
         WqXRFokJ06th53ud5WnJw8F/zYWo2h8Y1ur/1sAq71hca0Pihu1OJJFz2QvncBzGGsry
         cxPRDxDHLJz2SdIAtft9kgxeyyHq0RmVSPq5eq/QqALWVmaoh/Wggbf0Zu2aS7CD5rvp
         idWw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fengguang.wu@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukc/XoCenWBvuKQT3HqijrwunLOErr1va+an038JCprNKdruRAcw
	zIoCQVxDk/cGDGb6AIxdNSRAfXnJB93+i12jnkpntg+4VD2p5/0twzUtkaTLVG5+9t49EhLrXZC
	jYK4On6pSeq0abGgVj2ZbYlod1OpPpA67FE5g5SAFAM6/4rFBcVzQK8lh2C6x/gL3BQ==
X-Received: by 2002:a17:902:7614:: with SMTP id k20mr27864722pll.285.1546002947431;
        Fri, 28 Dec 2018 05:15:47 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6KpMkpmYy6yP9ED/WYRj35eFdGjSnfsu42LA+5MecotEB86cm2c4dtjl1v3Hqlkc1Cpkd0
X-Received: by 2002:a17:902:7614:: with SMTP id k20mr27864681pll.285.1546002946680;
        Fri, 28 Dec 2018 05:15:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546002946; cv=none;
        d=google.com; s=arc-20160816;
        b=LuIN8jxsyQen+vi3YAF/fAZdZIT89Mk7nqWgoFucIVOIUIThlf53l6LNXvM6mGrqWN
         OYSHOanJ5jFDmq2sZG21aumzVXgtw2CudOEbHF9J4KcmC/HQfmaPN4bI3B+U5jzoHsgy
         +JqPl7V4INS6Phb9cQATVH93BcxF9xfZ4Z9M0sGTEkXshrzrMJ9/+wx93Rxx57rDaZBr
         25Ec1/O5vvdeFU6ooKu6BbASWIP9zEC+y4/yvqt5kcmo5iFsJWAZe9peIl7jA3i9vXIi
         dWweOmcfoniw9YytOT1T17Q6+PmiJ+1qosWppu50HFOduiJ+ZQPkz/Ci+hqceHRAQm53
         beSQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=LkuqzoEvGWY3L+/exhV7qHVqp8mocfHNj6E12XXZdzI=;
        b=xVR70Rq8sAoERUAhQLqrT5OJ4yyi7QDUVxt01FbzU9TtQ+yUj5WNmGbHQUio/f/dp8
         N9ts3zvqnaV57O9w5bmbeVmnS04eAG1Qnl2g7+CdY1dK7/1U0rKMB+kN6Ik1ND2xFsOR
         oaxKCmHBMNHcGYEdeISbxaoiOpZ5AFBNXvKSv5uC4X2NPXVM1mAzeAqoAV8oSFMyLFrh
         G2JbytjmETa2/tN+VxyuDjLAeqIW5mOQnFCtLPhd/iR6ospY9H8awztIHKDa/NQiLXkW
         tqQuT3a4pz4ZUC6NY+WK0JjEuRvc50EkU1afHUrS6soaGZ5tgyCpyNDPAOewxsvrpKzz
         HZwA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id d69si38869432pga.184.2018.12.28.05.15.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Dec 2018 05:15:46 -0800 (PST)
Received-SPF: pass (google.com: domain of fengguang.wu@intel.com designates 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Dec 2018 05:15:45 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,409,1539673200"; 
   d="scan'208,223";a="121783989"
Received: from wangdan1-mobl1.ccr.corp.intel.com (HELO wfg-t570.sh.intel.com) ([10.254.210.154])
  by FMSMGA003.fm.intel.com with ESMTP; 28 Dec 2018 05:15:43 -0800
Received: from wfg by wfg-t570.sh.intel.com with local (Exim 4.89)
	(envelope-from <fengguang.wu@intel.com>)
	id 1gcrzK-0007b1-JE; Fri, 28 Dec 2018 21:15:42 +0800
Date: Fri, 28 Dec 2018 21:15:42 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Fan Du <fan.du@intel.com>, Yao Yuan <yuan.yao@intel.com>,
	Peng Dong <dongx.peng@intel.com>, Huang Ying <ying.huang@intel.com>,
	Liu Jingqi <jingqi.liu@intel.com>,
	Dong Eddie <eddie.dong@intel.com>,
	Dave Hansen <dave.hansen@intel.com>,
	Zhang Yi <yi.z.zhang@linux.intel.com>,
	Dan Williams <dan.j.williams@intel.com>
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
User-Agent: NeoMutt/20170609 (1.8.3)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181228131542.1yqTlAEoTT-xwmVSALCrBIlEJlSKFhv_w4Eb9QiZD1E@z>


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

From ef41a542568913c8c62251021c3bc38b7a549440 Mon Sep 17 00:00:00 2001
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

From e617e8c2034387cbed50bafa786cf83528dbe3df Mon Sep 17 00:00:00 2001
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

From a2d9740d1639f807868014c16dc9e2620d356f3c Mon Sep 17 00:00:00 2001
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

