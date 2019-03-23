Return-Path: <SRS0=0AWy=R2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EDF26C43381
	for <linux-mm@archiver.kernel.org>; Sat, 23 Mar 2019 04:46:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A48C0218E2
	for <linux-mm@archiver.kernel.org>; Sat, 23 Mar 2019 04:46:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A48C0218E2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 47D3B6B0270; Sat, 23 Mar 2019 00:46:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 403206B0272; Sat, 23 Mar 2019 00:46:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2A3936B0273; Sat, 23 Mar 2019 00:46:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id D9AD56B0270
	for <linux-mm@kvack.org>; Sat, 23 Mar 2019 00:45:59 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id a72so4229956pfj.19
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 21:45:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=GbACvGM2k0XChSgXP2m0OAFhhF6wTX5VAiPEQe8PPuA=;
        b=W1xGXoKvhFSobbn4jt8LLo3+XqlT1YyzFqXBWFtUuC6vpiHUIMBl/kYXDy7HallAH2
         cEtBvIpBHt6KTa7+Tivg5MXu5HLw4KLzh2DSpO5OeQbNoEf6TSIwZvDcwtjnUbpYj0mj
         M4jtlFeg8vI2frQfqxMNS39uYOxKQeUQf5EAZzJusLiV6uglDxX5sKBbzDPtoZgrjg2r
         je6FkIPf5TkaKbNzhrfjpC09rxEU9Y0bV1FvNd4thKHANcoTJDfScULg2eRmWSKTIsPx
         p8ipYyE0r6eVxWYHM97Y6zjEcM3+6BpeXbsfJ1WMmhFUX2biciwA4QNqlPsoKQkyPbvj
         s7wg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAXcibNmuOupD9I7gAywj+3pE2cgu63Gp7/O4H2E2HYic0r6HSVR
	NDhLvm6sKifCB6bbEGxXHHgDHwBFAlxfu5JSdjYZFtl0kqvfmW8zmBRewgJ6UeQzWy1x8OU4Akv
	k0SBNOHxZuElUMpoJ3Qh8bjl7M3ra84uuDc2GTIJ2TgmMyVNClhxo0G1eSxCK/2D+BQ==
X-Received: by 2002:a63:f544:: with SMTP id e4mr12558675pgk.145.1553316359570;
        Fri, 22 Mar 2019 21:45:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw9/FQG/p43Ig4KppLZOgux/mwgl37qoeL6kuwrengdWTU141QuvV86QVuO1AejXug+RuNh
X-Received: by 2002:a63:f544:: with SMTP id e4mr12558621pgk.145.1553316358330;
        Fri, 22 Mar 2019 21:45:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553316358; cv=none;
        d=google.com; s=arc-20160816;
        b=XM0NyIlel5TNnk5ipLafkIbkULit74NJjmZ1SnzDtL4Eh4xgc00qyYjsojhAur0ekj
         tNvQe9/SwYnZEZB6bUgxSEYCzHFpbZzT/9JTAKrpQfae54eKEfdzHtupksNQc022y8k7
         E1YpPbYX1G0I+JTrZofgbTx/oX5+vL1fmDowkKh2fJ+AODhUwOI6O9Lmg5+BUznAEISC
         wzdqh/acQCFIlu2fkjTFMNjVhUg5z9tNtZRFmpI3BBBPV4/yd4J1KdHWXGXJEMUhiexr
         Zo1VRIqLgZctHnzHxyvm+2StyzXLT8f5M4d40DMVB1a9vXoMpMuwg00YDGpFqGk6bQXo
         0LuA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=GbACvGM2k0XChSgXP2m0OAFhhF6wTX5VAiPEQe8PPuA=;
        b=T54dqSQxoyj2F1hbs1sNTufHUz7TZlpkOiuYNEiBKRteRJ0BR7ufyRV8Ix5mCmu5Z0
         DTjVKA8ad220SrfnSDV9n+bvJtR8/WNWuEoruHIqtjoD8+JH/HDveJGtjAsEybBPL6lF
         bfP2N1EpVsnxjBH2C6ParVCvJFe1C/q8O7R7ukGLIs6SxhKkPCEpR5Fz1LYKpeIlX1FQ
         RdhPCAZhvsBR4Q3XLOBzyafGzJfjGk3gqTCSAw33ZWfkHc8bWeCMl28gsT/02ty3gjRN
         NRU4pP/WQgOPK31+zOp7i4AE/a1N6Pu+5lUscdyX7W0mR7JGF0G4JNP4Ad7P79x91+Ec
         gUJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-54.freemail.mail.aliyun.com (out30-54.freemail.mail.aliyun.com. [115.124.30.54])
        by mx.google.com with ESMTPS id e9si8100867pgs.450.2019.03.22.21.45.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Mar 2019 21:45:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) client-ip=115.124.30.54;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R981e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04455;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=14;SR=0;TI=SMTPD_---0TNPuxAM_1553316293;
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
Subject: [PATCH 07/10] mm: vmscan: add page demotion counter
Date: Sat, 23 Mar 2019 12:44:32 +0800
Message-Id: <1553316275-21985-8-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Demoted pages are counted into reclaim_state->nr_demoted instead of
nr_reclaimed since they are not reclaimed actually.  They are still in
memory, but just migrated to PMEM.

Add pgdemote_kswapd and pgdemote_direct VM counters showed in
/proc/vmstat.

Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 include/linux/vm_event_item.h |  2 ++
 include/linux/vmstat.h        |  1 +
 mm/vmscan.c                   | 14 ++++++++++++++
 mm/vmstat.c                   |  2 ++
 4 files changed, 19 insertions(+)

diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 47a3441..499a3aa 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -32,6 +32,8 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		PGREFILL,
 		PGSTEAL_KSWAPD,
 		PGSTEAL_DIRECT,
+		PGDEMOTE_KSWAPD,
+		PGDEMOTE_DIRECT,
 		PGSCAN_KSWAPD,
 		PGSCAN_DIRECT,
 		PGSCAN_DIRECT_THROTTLE,
diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index 2db8d60..eb5d21c 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -29,6 +29,7 @@ struct reclaim_stat {
 	unsigned nr_activate;
 	unsigned nr_ref_keep;
 	unsigned nr_unmap_fail;
+	unsigned nr_demoted;
 };
 
 #ifdef CONFIG_VM_EVENT_COUNTERS
diff --git a/mm/vmscan.c b/mm/vmscan.c
index bdcab6b..3c7ba7e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1286,6 +1286,10 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 
 			if (has_nonram_online()) {
 				list_add(&page->lru, &demote_pages);
+				if (PageTransHuge(page))
+					stat->nr_demoted += HPAGE_PMD_NR;
+				else
+					stat->nr_demoted++;
 				unlock_page(page);
 				continue;
 			}
@@ -1523,7 +1527,17 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			putback_movable_pages(&demote_pages);
 
 			list_splice(&ret_pages, &demote_pages);
+
+			if (err > 0)
+				stat->nr_demoted -= err;
+			else
+				stat->nr_demoted = 0;
 		}
+
+		if (current_is_kswapd())
+			__count_vm_events(PGDEMOTE_KSWAPD, stat->nr_demoted);
+		else
+			__count_vm_events(PGDEMOTE_DIRECT, stat->nr_demoted);
 	}
 
 	mem_cgroup_uncharge_list(&free_pages);
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 36b56f8..0e863e7 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1192,6 +1192,8 @@ int fragmentation_index(struct zone *zone, unsigned int order)
 	"pgrefill",
 	"pgsteal_kswapd",
 	"pgsteal_direct",
+	"pgdemote_kswapd",
+	"pgdemote_direct",
 	"pgscan_kswapd",
 	"pgscan_direct",
 	"pgscan_direct_throttle",
-- 
1.8.3.1

