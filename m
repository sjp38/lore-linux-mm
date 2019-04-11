Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 69B62C10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 03:58:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 305CB2133D
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 03:58:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 305CB2133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CBB996B000E; Wed, 10 Apr 2019 23:58:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C6A686B0010; Wed, 10 Apr 2019 23:58:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B0C666B0266; Wed, 10 Apr 2019 23:58:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 733A56B000E
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 23:58:10 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id j184so3551031pgd.7
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 20:58:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=VBnAD41t69RqBOb9zPduWfXXPAif/Mt2uvTkTO6jcCY=;
        b=JlJ9PJc+lTp5Gw0Kcn3RMlQu0AMn/8rI49rGuyqh5icQpLayiDrsf6eRNJkENG6L7M
         +EkMFvA50hycN0pugg6JrD8gvHMZB9mEec3lk9T84jQguFv0bFiL6bfQq0zqrPqmFU6H
         rjJcFgRlwTnh+sz6pSlhb/NvmJMbQbU5fTgghHDTFfinY6cZzifQrEpSGrTN3bmUWA52
         n+kc2QP4rcZkPSGkS9S20tWBlI/9nJdbBtP3BiC8LAtF5uCc7VPh0i2BtejmiP4o3iI9
         eOQ16jRWDDISgixfS8dnfcbR/LL9Lph8bKWi6Gn/oMlXx3XOCZk4jK5KOa3dhDT4qNax
         /BUA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.44 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAV8dZ/a7UPEwZI5PAG9PH8RocFVpYnmnsNORMCWhigrFy7YjWGn
	0ByuK1oHFs2Knd7meV9sSCXaRzzSFpDMQ96o2YmaXKrxuSFTTzn4fWpny0/f0jzyLIEhJqyOZ6/
	iqrZsQuMyMHFjc/mbvUYtTL7CUiJNv5iR8bcGsLbhW7aN3OsOuH8X4olV/m6uf+x/vw==
X-Received: by 2002:aa7:8208:: with SMTP id k8mr48203906pfi.69.1554955090103;
        Wed, 10 Apr 2019 20:58:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxgThj1c2HUo7PVm1SD82v/7lVustNb/ddJUsOBDdXcROSn7gdoP/NPwpXgBoAgAWi5+ONr
X-Received: by 2002:aa7:8208:: with SMTP id k8mr48203839pfi.69.1554955088839;
        Wed, 10 Apr 2019 20:58:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554955088; cv=none;
        d=google.com; s=arc-20160816;
        b=tpzZ/TpN2KvdN17YiEZalSr20h8eAmgpoSnQ1mmoGQYVqZcEW0kPl9cHTfmAJ7jL9G
         kAPo1zzrbCkLAqy6tFWFSikqc4SK9AcsZuPlVPcLfdgdVdw/HM9G9TlPyE1JrqDEF26I
         wTkoScA2r0rBCcoiiGwEiJMqmkYR1yTXYjmvWXDoz0KmYr9a7XEwkpOeGcZdLWNf4Jp6
         P2OFT9SsHoyEL4irl8d3PmRRfPyO6sLMFOfwc6/VHMdnLzWabfDdydDmMGsgkksoZd4T
         QqXNOnhvS3TSy2b0VvqhYW+TNMJaZcRFXYp7XS9JQHQSiSoqfDUKUuW37cSEFRddlJrZ
         pu8w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=VBnAD41t69RqBOb9zPduWfXXPAif/Mt2uvTkTO6jcCY=;
        b=DAtkOQikZmjsO3vqnR3PUNGVuwsFZVTvDcR8+1y8DvLt0x9kVDUwqtj0YSrBK7HiNn
         Aibay8hdZtfnExg/mc/gAr/pKX6R7ZAFXFCogf5vXwa3KY3mTUDGZ9B8p/zKLki6WNwT
         7fsX4Q0HfiGHfyYUr9wFEpPMPAY9cBkSaYYF/QYFm07hnjObiGlKn3Ym5BjNmL5Oe7qA
         2MFPrU+wkE8P70oVe0PJpXAnAQ4piETqh0ohWtTBSGpI28/mqzhOERKgb+wrUrVRYmwy
         g9dime7aI1ms8qXu1FBEOHSlulsvnIP9xRI0NGMoFnpg16yWAriGQJYPqTgjtaKIZkWF
         jNsg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.44 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-44.freemail.mail.aliyun.com (out30-44.freemail.mail.aliyun.com. [115.124.30.44])
        by mx.google.com with ESMTPS id a5si33597356pff.39.2019.04.10.20.58.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 20:58:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.44 as permitted sender) client-ip=115.124.30.44;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.44 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R501e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04395;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=15;SR=0;TI=SMTPD_---0TP0I5rB_1554955031;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TP0I5rB_1554955031)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 11 Apr 2019 11:57:24 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: mhocko@suse.com,
	mgorman@techsingularity.net,
	riel@surriel.com,
	hannes@cmpxchg.org,
	akpm@linux-foundation.org,
	dave.hansen@intel.com,
	keith.busch@intel.com,
	dan.j.williams@intel.com,
	fengguang.wu@intel.com,
	fan.du@intel.com,
	ying.huang@intel.com,
	ziy@nvidia.com
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [v2 PATCH 9/9] mm: numa: add page promotion counter
Date: Thu, 11 Apr 2019 11:56:59 +0800
Message-Id: <1554955019-29472-10-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1554955019-29472-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1554955019-29472-1-git-send-email-yang.shi@linux.alibaba.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add counter for page promotion for NUMA balancing.

Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 include/linux/vm_event_item.h | 1 +
 mm/huge_memory.c              | 4 ++++
 mm/memory.c                   | 4 ++++
 mm/vmstat.c                   | 1 +
 4 files changed, 10 insertions(+)

diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 499a3aa..9f52a62 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -51,6 +51,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		NUMA_HINT_FAULTS,
 		NUMA_HINT_FAULTS_LOCAL,
 		NUMA_PAGE_MIGRATE,
+		NUMA_PAGE_PROMOTE,
 #endif
 #ifdef CONFIG_MIGRATION
 		PGMIGRATE_SUCCESS, PGMIGRATE_FAIL,
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 0b18ac45..ca9d688 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1609,6 +1609,10 @@ vm_fault_t do_huge_pmd_numa_page(struct vm_fault *vmf, pmd_t pmd)
 	migrated = migrate_misplaced_transhuge_page(vma->vm_mm, vma,
 				vmf->pmd, pmd, vmf->address, page, target_nid);
 	if (migrated) {
+		if (!node_state(page_nid, N_CPU_MEM) &&
+		    node_state(target_nid, N_CPU_MEM))
+			count_vm_numa_events(NUMA_PAGE_PROMOTE, HPAGE_PMD_NR);
+
 		flags |= TNF_MIGRATED;
 		page_nid = target_nid;
 	} else
diff --git a/mm/memory.c b/mm/memory.c
index 01c1ead..7b1218b 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3704,6 +3704,10 @@ static vm_fault_t do_numa_page(struct vm_fault *vmf)
 	/* Migrate to the requested node */
 	migrated = migrate_misplaced_page(page, vma, target_nid);
 	if (migrated) {
+		if (!node_state(page_nid, N_CPU_MEM) &&
+		    node_state(target_nid, N_CPU_MEM))
+			count_vm_numa_event(NUMA_PAGE_PROMOTE);
+
 		page_nid = target_nid;
 		flags |= TNF_MIGRATED;
 	} else
diff --git a/mm/vmstat.c b/mm/vmstat.c
index d1e4993..fd194e3 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1220,6 +1220,7 @@ int fragmentation_index(struct zone *zone, unsigned int order)
 	"numa_hint_faults",
 	"numa_hint_faults_local",
 	"numa_pages_migrated",
+	"numa_pages_promoted",
 #endif
 #ifdef CONFIG_MIGRATION
 	"pgmigrate_success",
-- 
1.8.3.1

