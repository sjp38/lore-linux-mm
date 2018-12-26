Return-Path: <SRS0=eTfr=PD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F009BC43444
	for <linux-mm@archiver.kernel.org>; Wed, 26 Dec 2018 13:37:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ACF49218AD
	for <linux-mm@archiver.kernel.org>; Wed, 26 Dec 2018 13:37:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ACF49218AD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CEE398E0006; Wed, 26 Dec 2018 08:37:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 41C018E0015; Wed, 26 Dec 2018 08:37:10 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 058958E0012; Wed, 26 Dec 2018 08:37:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id A7AF08E000B
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 08:37:08 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id f69so17813903pff.5
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 05:37:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:subject
         :references:mime-version:content-disposition;
        bh=pybQb2bIsIMoSE+nhg2Fmhc1oq+DOuwKQqNor65wLbc=;
        b=K4LwyMRobzh272l0a30cRWw7mhgfcJ36AGHHW8QBMiYTE4H/HlH9DCR8S24avuO/O9
         jCPqVdV3Flu+qL95A4h/nTck9jnDq1mb4mz0qFLhENf3S2K6Wp8ZbpOoHCCJJkRkt0lL
         h3rYTRIoGsXahH3gDtgYash4/6kJyPCwpPfcTOr9W/mvlhqc3rxv0eKf0cX6DDTt8wRj
         XwLZ0czRfpSWG+U0Z22ath5G6rlECr7R+Jg45kM4CkQ4RAMQfNOj832UtsRKmlqEKtoh
         OkS2SNL+oY9OnDtU4yGkb0S7iEFG8k3KvRnrz34BLzgh4poHU3kTUQfvMfDtBpPhSClr
         Jq6g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukfHkXEK79XJHVLlkM5u/4Y7OOXcxs64so9dqupPiS2j8LCw3AEI
	RVXOFsMNlolgUS+3W49JY3uK+kfaW4R97TJpqyYduo0YoFiB2MCFcvlL770OU0kbpTAx3keVsRW
	z3csESnAOJfL95E5744yYBCIKL2slhogN7q+T7TIx7uGyCeCWURZtjt8QUHhXIfewzg==
X-Received: by 2002:a17:902:33c2:: with SMTP id b60mr19800499plc.211.1545831428384;
        Wed, 26 Dec 2018 05:37:08 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6SFVbWGRzDvrswlQwO87CPALQsYihNvIXcuFobPSwIDC8DUwhYYgMD9vFq/xkHVM57JQZl
X-Received: by 2002:a17:902:33c2:: with SMTP id b60mr19800463plc.211.1545831427737;
        Wed, 26 Dec 2018 05:37:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545831427; cv=none;
        d=google.com; s=arc-20160816;
        b=sD2jCjcKrwtOusXHndYypdFH/JxK2NfiN3PPm1fQjFgeYWSYWuCOevTicJDiYql+gN
         PGrvm8C1hR0eM6yyTPzXnrCSK4EPBTiY32KMvJHVLIfq9ggtj5m4gaoPcm7jzZpX9UBC
         y+/SzAO4ZN1AKGAF4LpxOFV2zQUopQ7q1scN8MSLO1yrxYoOfprV+/8dN+2Hui3XfGg6
         6c/RW8teLijNtob81c1NhInGXyPabsHDzU7AcCusF9DOb9n6TtmJx7cOldCCe8JXuIwh
         ZEy8EdzjpMibAQ9L4riDc/loDWozAqysKVNVYZcsoBR71HnYB3E2wz/lHO/xf9jUHtkC
         /vWA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-disposition:mime-version:references:subject:cc:cc:cc:cc:cc
         :cc:cc:cc:cc:cc:cc:to:from:date:user-agent:message-id;
        bh=pybQb2bIsIMoSE+nhg2Fmhc1oq+DOuwKQqNor65wLbc=;
        b=le2nGtjnH1sb9oE7vcLnY7GHUcMakMSkQHxPSiYdxwbOCc3b5uoNvlUfw246tGOXtp
         9pljxQc2ZBCITjgGtlr0zwM6yqIOeataimDKSq4TKEMDZrt8ScRydnrH+X1ZCxUyC6gR
         8i3Gda867JlUUZ6Rgvyz64MFZ/GaTLSx/poR9T8oeQFF3hMdirqlG4leQZxsMqNUHMFx
         9c/jTYbqTqMKKmUqd4M3UExfleoagbSwVLqoPCW9lR9MWjLzEsqvck8jABzUCmXOvzRa
         FqZmSH0/OudEL76wQY5yObC7fUAVeN5UwV/I3JcHA9CCNE0edezkQQdRUUXv4CRQ2sV2
         ZajA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id r12si1487152plo.59.2018.12.26.05.37.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Dec 2018 05:37:07 -0800 (PST)
Received-SPF: pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 26 Dec 2018 05:37:05 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,400,1539673200"; 
   d="scan'208";a="113358949"
Received: from wangdan1-mobl1.ccr.corp.intel.com (HELO wfg-t570.sh.intel.com) ([10.254.210.154])
  by orsmga003.jf.intel.com with ESMTP; 26 Dec 2018 05:37:02 -0800
Received: from wfg by wfg-t570.sh.intel.com with local (Exim 4.89)
	(envelope-from <fengguang.wu@intel.com>)
	id 1gc9Mr-0005PN-M1; Wed, 26 Dec 2018 21:37:01 +0800
Message-Id: <20181226133352.189896494@intel.com>
User-Agent: quilt/0.65
Date: Wed, 26 Dec 2018 21:15:05 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
To: Andrew Morton <akpm@linux-foundation.org>
cc: Linux Memory Management List <linux-mm@kvack.org>,
 Liu Jingqi <jingqi.liu@intel.com>,
 Fengguang Wu <fengguang.wu@intel.com>
cc: kvm@vger.kernel.org
Cc: LKML <linux-kernel@vger.kernel.org>
cc: Fan Du <fan.du@intel.com>
cc: Yao Yuan <yuan.yao@intel.com>
cc: Peng Dong <dongx.peng@intel.com>
cc: Huang Ying <ying.huang@intel.com>
cc: Dong Eddie <eddie.dong@intel.com>
cc: Dave Hansen <dave.hansen@intel.com>
cc: Zhang Yi <yi.z.zhang@linux.intel.com>
cc: Dan Williams <dan.j.williams@intel.com>
Subject: [RFC][PATCH v2 19/21] mm/migrate.c: add move_pages(MPOL_MF_SW_YOUNG) flag
References: <20181226131446.330864849@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline; filename=0010-migrate-check-if-the-page-is-software-young-when-mov.patch
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181226131505.XE-GwjPIQloU_9Rr7NVGwGyncb4_Dx84BHCqS8sRGbo@z>

From: Liu Jingqi <jingqi.liu@intel.com>

Introduce MPOL_MF_SW_YOUNG flag to move_pages(). When on,
the already-in-DRAM pages will be set PG_referenced.

Background:
The use space migration daemon will frequently scan page table and
read-clear accessed bits to detect hot/cold pages. Then migrate hot
pages from PMEM to DRAM node. When doing so, it btw tells kernel that
these are the hot page set. This maintains a persistent view of hot/cold
pages between kernel and user space daemon.

The more concrete steps are

1) do multiple scan of page table, count accessed bits
2) highest accessed count => hot pages
3) call move_pages(hot pages, DRAM nodes, MPOL_MF_SW_YOUNG)

(1) regularly clears PTE young, which makes kernel lose access to
    PTE young information

(2) for anonymous pages, user space daemon defines which is hot and
    which is cold

(3) conveys user space view of hot/cold pages to kernel through
    PG_referenced

In the long run, most hot pages could already be in DRAM.
move_pages(MPOL_MF_SW_YOUNG) sets PG_referenced for those already in
DRAM hot pages. But not for newly migrated hot pages. Since they are
expected to put to the end of LRU, thus has long enough time in LRU to
gather accessed/PG_referenced bit and prove to kernel they are really hot.

The daemon may only select DRAM/2 pages as hot for 2 purposes:
- avoid thrashing, eg. some warm pages got promoted then demoted soon
- make sure enough DRAM LRU pages look "cold" to kernel, so that vmscan
  won't run into trouble busy scanning LRU lists

Signed-off-by: Liu Jingqi <jingqi.liu@intel.com>
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 mm/migrate.c |   13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

--- linux.orig/mm/migrate.c	2018-12-23 20:37:12.604621319 +0800
+++ linux/mm/migrate.c	2018-12-23 20:37:12.604621319 +0800
@@ -55,6 +55,8 @@
 
 #include "internal.h"
 
+#define MPOL_MF_SW_YOUNG (1<<7)
+
 /*
  * migrate_prep() needs to be called before we start compiling a list of pages
  * to be migrated using isolate_lru_page(). If scheduling work on other CPUs is
@@ -1484,12 +1486,13 @@ static int do_move_pages_to_node(struct
  * the target node
  */
 static int add_page_for_migration(struct mm_struct *mm, unsigned long addr,
-		int node, struct list_head *pagelist, bool migrate_all)
+		int node, struct list_head *pagelist, int flags)
 {
 	struct vm_area_struct *vma;
 	struct page *page;
 	unsigned int follflags;
 	int err;
+	bool migrate_all = flags & MPOL_MF_MOVE_ALL;
 
 	down_read(&mm->mmap_sem);
 	err = -EFAULT;
@@ -1519,6 +1522,8 @@ static int add_page_for_migration(struct
 
 	if (PageHuge(page)) {
 		if (PageHead(page)) {
+			if (flags & MPOL_MF_SW_YOUNG)
+				SetPageReferenced(page);
 			isolate_huge_page(page, pagelist);
 			err = 0;
 		}
@@ -1531,6 +1536,8 @@ static int add_page_for_migration(struct
 			goto out_putpage;
 
 		err = 0;
+		if (flags & MPOL_MF_SW_YOUNG)
+			SetPageReferenced(head);
 		list_add_tail(&head->lru, pagelist);
 		mod_node_page_state(page_pgdat(head),
 			NR_ISOLATED_ANON + page_is_file_cache(head),
@@ -1606,7 +1613,7 @@ static int do_pages_move(struct mm_struc
 		 * report them via status
 		 */
 		err = add_page_for_migration(mm, addr, current_node,
-				&pagelist, flags & MPOL_MF_MOVE_ALL);
+				&pagelist, flags);
 		if (!err)
 			continue;
 
@@ -1725,7 +1732,7 @@ static int kernel_move_pages(pid_t pid,
 	nodemask_t task_nodes;
 
 	/* Check flags */
-	if (flags & ~(MPOL_MF_MOVE|MPOL_MF_MOVE_ALL))
+	if (flags & ~(MPOL_MF_MOVE|MPOL_MF_MOVE_ALL|MPOL_MF_SW_YOUNG))
 		return -EINVAL;
 
 	if ((flags & MPOL_MF_MOVE_ALL) && !capable(CAP_SYS_NICE))


