Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C819BC31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 23:30:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8BD6720896
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 23:30:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8BD6720896
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 99F288E0006; Thu, 13 Jun 2019 19:30:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 950838E0002; Thu, 13 Jun 2019 19:30:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 83DD08E0006; Thu, 13 Jun 2019 19:30:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 56EE48E0002
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 19:30:17 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id a17so301718otd.19
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 16:30:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=qOFD3Vu5k5uvjb9pS72jZXaVfrvyzRyCNIQoGs68Qno=;
        b=eM14OFwMrSI12zucnDukAIR+zy9BfKoYSpISBCAOxYEEqYzvrnKa/G5zrTeY0sK9Zx
         FA5zoj2q4webSAs87GpsNU16fzcBNP3Sr0Ikm8rTCmCRT/jdqgxS1gVqnbkcZYRlxSCz
         mgY9bULuyujuaSqQziNoo/Y0BuxCVaLg57kAsywQVI3lO6mCYl+F/Dp/Sfd42cZNoaPL
         mFP5392sb2WbMZIbqhIk2DbrN1H3OjioKPtytjcFpRowYztQpQvq48m27bEP1BWKcQcU
         DHxcDl1qfkGAogCoHLeRhR0i67aiBwIxb5QX4f7qr4FwulmX9oVyJSXepcMvmnTTVyGh
         xxzg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAVMm6E7ept1gxARel9Sgl7ksGtaW173EzNd/aKLcUdtaa64iSgh
	XqH4YnByvgxHlt43rU7sTneajUUyNQGdxxMphOPRtuz7ILp64wQiMuEyTGg3JDdfoeE7r0AvTGn
	r+fa09f47m3UH+WTKXS5uKlwejy/EU0d/0T5EF5BYbhwTUVDWP4XOj1KBiRdBm1xaTQ==
X-Received: by 2002:a9d:6d0e:: with SMTP id o14mr38000168otp.205.1560468617025;
        Thu, 13 Jun 2019 16:30:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqznbLtCRUnirJa69qKiIDPu9RtT981NF3YQ06rSoJdTCtdHJ/6bu0ncal0h1tMrKtcOtj+k
X-Received: by 2002:a9d:6d0e:: with SMTP id o14mr38000091otp.205.1560468615825;
        Thu, 13 Jun 2019 16:30:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560468615; cv=none;
        d=google.com; s=arc-20160816;
        b=YWGp0xXqxg9IK/3q8BLQ0fIJt9MNmol6G37MRpHyFXdnkIjIYIZBSt3sBY91wvHjhV
         HFNNSDwZcZvzl8PPvaD8XQCurjSpDbowFz4CyqZTLG2vgLA5IJsSft1+gLMl1sT0FZ9P
         04orfwi4HtT0/+/HYFh8zmjESR4/6YiZGv92KV0snCypJbZTpu+gI1yBfZCCKBNzoRwq
         pcpsTEknrqR3zhUi8jNKRWXbGmTX1mpbgwcW+KkrIzyeKiQU/Siso898CKA7pMEzH4L2
         7tSZ5WSHvnl5jkZwt9dqp0nR25zCvrtmyw0KHb3Le9MmZ5JzDakpT3Xa21JzrjukC1nR
         39WA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=qOFD3Vu5k5uvjb9pS72jZXaVfrvyzRyCNIQoGs68Qno=;
        b=QmKfBQ6XWfqaKxK2ZiCsXEbo9NFsszbaFGvM6HOIhvzxQRUYmL2jBFmLDkCu2aRXw7
         zZFDRsPstiDZqGgLfhSjS5zniktqkk/Ur8mZNysGgYVTSdE/kLnn0hAyVwfat8RSZBuV
         BwVUF3BbfM0g0L9uMp1xnTqwT83rxKfOrIiX8B1gRMUPlnWzhDc+mssMv5jgHCq263Mt
         eJls00RUtTjrkDAVC41h7Gs4vY1CYDDAVOpiwaC6wdG1/2UBBWhEor3YK7zH+dFSyk4D
         z6U9aqRXj9lfeJMbKHeYzHva3EHasSggl2ZLGH6wgUK/j3VFQBfoOqnpXPbk72MZo/ZH
         xEyw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-54.freemail.mail.aliyun.com (out30-54.freemail.mail.aliyun.com. [115.124.30.54])
        by mx.google.com with ESMTPS id j5si531541oif.224.2019.06.13.16.30.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 16:30:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) client-ip=115.124.30.54;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R151e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04391;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=15;SR=0;TI=SMTPD_---0TU6DYEz_1560468591;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TU6DYEz_1560468591)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 14 Jun 2019 07:30:01 +0800
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
Subject: [v3 PATCH 9/9] mm: numa: add page promotion counter
Date: Fri, 14 Jun 2019 07:29:37 +0800
Message-Id: <1560468577-101178-10-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1560468577-101178-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1560468577-101178-1-git-send-email-yang.shi@linux.alibaba.com>
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
index 9f8bce9..01cfe29 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1638,6 +1638,10 @@ vm_fault_t do_huge_pmd_numa_page(struct vm_fault *vmf, pmd_t pmd)
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
index 96f1d47..e554cd5 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3770,6 +3770,10 @@ static vm_fault_t do_numa_page(struct vm_fault *vmf)
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
index eee29a9..0140736 100644
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

