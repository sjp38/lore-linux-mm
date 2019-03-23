Return-Path: <SRS0=0AWy=R2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ABD1FC4360F
	for <linux-mm@archiver.kernel.org>; Sat, 23 Mar 2019 04:45:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 70D0E218E2
	for <linux-mm@archiver.kernel.org>; Sat, 23 Mar 2019 04:45:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 70D0E218E2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 05D656B026E; Sat, 23 Mar 2019 00:45:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F263A6B0270; Sat, 23 Mar 2019 00:45:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DEEA96B0271; Sat, 23 Mar 2019 00:45:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9DFD66B026E
	for <linux-mm@kvack.org>; Sat, 23 Mar 2019 00:45:44 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 33so3941274pgv.17
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 21:45:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=cL/AGuSDoqRTGwGzMJZQWG4Buhnh3vg9z83nZE9E16I=;
        b=Ni53IBV4f0mAOJm0YU7OakXUk2oCIA+YUaWBWvf2oOn5+X+ZxCYHd7gKpBK/X8SMZU
         YoQuD/qvhSatwID0RIW1nQyd63L3vXl99kfjQzI+G5lq/rb53vUZblg4Ax7AJmy4S/pj
         M4tVv9CQNcrjNJlBAzumVhoI+Sptk2LLcUfX+lCs2ERdbApIHnWCK6po8OsMvEZkvSWD
         kFcYv/kr/roD2ezI1dMY/TeqwEHagJLOEe5m5uLOD0pULW+dSvjVQoQOTZZbXxzhS3Rq
         3RYRRaFDKhDNB6W+tIg4gmJjTbUaurSoCmHfOV9FTZvxFMLCiSnI9+08N2H8tvP3IyM/
         gCRQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUdA0bxfE86RPOANml2Lt0OWKgCbo6/YFk5pzDoduTQOE7y8Q1R
	ymDQmSbO3a4GpPza4hAXhAmnYVyLzGHQxnE24rxTvRyIfoIeaEAoPqlQWZqi3WkTEvFwl+aOF80
	s/moTF4oUxaYAZb7YJd2H0aUGGiTFLOIUPV9wHQnNRHhlzHUdoqOyqKiQlLkvRpZ8gw==
X-Received: by 2002:a63:5c66:: with SMTP id n38mr12415641pgm.15.1553316344287;
        Fri, 22 Mar 2019 21:45:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyFPgXqS0oEBi43zcqDeB32MVfkl2vauEt1xsI9RuGjOXxyvyJXasYcUYoq2v8sCpQ1K5Gj
X-Received: by 2002:a63:5c66:: with SMTP id n38mr12415558pgm.15.1553316342896;
        Fri, 22 Mar 2019 21:45:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553316342; cv=none;
        d=google.com; s=arc-20160816;
        b=w6OWX/gTJDFf7ceLddF2AzuTxYWG40zI1KSBiwiVz9r4x/2Zw+B5LcHNZeidJAMn20
         SgmrqHyijwwDuROSG7gN/Mr+IiBCMXF6JPpwYE0ECA/aaVMQsoNtO4v24QUY2xBfV/2b
         nuwAJ2HOykqUpFUMOE3NBZUcSrN6MLOhU24kta+blIGpL5UKFizgDlwkao1uw9J1pgvE
         EaWNhJeyPx99M8Bm3cLRtfhZrMUua5K8KGJqYjuKpdLhfHOMSH4euiT5KBVLroqO4XHE
         YiOnfcumfdx1PPqn5uO3XOoYcctl6JNMu0JfpgosH8tzUg/niRb9O9/Me1PFCBWkH53d
         1kMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=cL/AGuSDoqRTGwGzMJZQWG4Buhnh3vg9z83nZE9E16I=;
        b=zNzFhK3uLhYFwFTzQjwSW2OVP3+rUGUFXzcDT1JMoZrERbE7B/hnkADszKDU1q22WJ
         ErH+/D4Yqjv+C9/n4EGAtZDq02UgqJt92n8yZyXrneuWLGgsPU5Y6Xy5cjPhg3MXcNTh
         kq8E8jDAR3R+aIDCe9XltW/LbFsmXsWQMsklEQ3g7daUgQtNJFJ9SZTlxUwDRgp73FgA
         Caf5rN54OzVm8I7BEOEhfXLNpyo55s+Iasaj3mHV9sRhX6gS2AoRdW/a22k7AtUudq+3
         rrHq9Szh/o6yYTV2RolBgzogPcKZx3UU11V412fVjqOU6vDat+XGHfh4Inx04/w4TCir
         RtRw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-43.freemail.mail.aliyun.com (out30-43.freemail.mail.aliyun.com. [115.124.30.43])
        by mx.google.com with ESMTPS id d17si6746521pgk.479.2019.03.22.21.45.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Mar 2019 21:45:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) client-ip=115.124.30.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R191e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04428;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=14;SR=0;TI=SMTPD_---0TNPuxAM_1553316293;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TNPuxAM_1553316293)
          by smtp.aliyun-inc.com(127.0.0.1);
          Sat, 23 Mar 2019 12:45:03 +0800
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
	ying.huang@intel.com
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 08/10] mm: numa: add page promotion counter
Date: Sat, 23 Mar 2019 12:44:33 +0800
Message-Id: <1553316275-21985-9-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
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
index 8268a3c..9d5f5ce 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1607,6 +1607,10 @@ vm_fault_t do_huge_pmd_numa_page(struct vm_fault *vmf, pmd_t pmd)
 	migrated = migrate_misplaced_transhuge_page(vma->vm_mm, vma,
 				vmf->pmd, pmd, vmf->address, page, target_nid);
 	if (migrated) {
+		if (!node_isset(page_nid, def_alloc_nodemask) &&
+		    node_isset(target_nid, def_alloc_nodemask))
+			count_vm_numa_events(NUMA_PAGE_PROMOTE, HPAGE_PMD_NR);
+
 		flags |= TNF_MIGRATED;
 		page_nid = target_nid;
 	} else
diff --git a/mm/memory.c b/mm/memory.c
index 2494c11..554191b 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3691,6 +3691,10 @@ static vm_fault_t do_numa_page(struct vm_fault *vmf)
 	/* Migrate to the requested node */
 	migrated = migrate_misplaced_page(page, vma, target_nid);
 	if (migrated) {
+		if (!node_isset(page_nid, def_alloc_nodemask) &&
+		    node_isset(target_nid, def_alloc_nodemask))
+			count_vm_numa_event(NUMA_PAGE_PROMOTE);
+
 		page_nid = target_nid;
 		flags |= TNF_MIGRATED;
 	} else
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 0e863e7..4b44fc8 100644
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

