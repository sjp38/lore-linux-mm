Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0D1ECC10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 03:57:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BC088217F4
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 03:57:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BC088217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 05DD96B000A; Wed, 10 Apr 2019 23:57:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0111C6B000C; Wed, 10 Apr 2019 23:57:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E65E76B000E; Wed, 10 Apr 2019 23:57:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id AC4686B000A
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 23:57:27 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id z14so3571646pgv.0
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 20:57:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=8cOivVWY4TyKGsTwqMSmS+kBKv0VXMIFbIVXDNKOfGQ=;
        b=SjPkSwyuE8D5PNhGNSSyAThPnVKbfZ0bxmEM3ejM83aSROomyDFRnMDQEPCDAE5XnZ
         0el0AZ0TlmYfhLvTTpUfmiDEv+BIKnOLXbAUGRpG9fujdhd9UdMKlZ8cfsS5NJ7LH/+A
         1hEemF0DAKrwGjeIe3SaVYOgAJ52rIz59KM15NkJ5nx9mo78/0vtO/1RlklT6HHiTezA
         aLJZEOggw2AQK5Amd8nMYSCOU1ksHua85BFl+OKcW+s4/8xnX59dqDtk/fxmTcpLFSEl
         mKfpap8q4+bs/DUao3SnuNHc6/zvhafIGF1b5003tRJT2xMlXPxdtRJLR2ggxPjRW8i2
         9C1Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWioqin6IYyw93B/6vrvVEsdejsCMidh2v3H9N2C/TD32wjynKw
	Qm9SioXQ452kvzS/cfEMHZiHBHkfs3OS03Hr3chwz6UdlEDl9eFdbe8E68Lrq5/JIHzisTkZCU1
	+KlFWRP9MuDRHr0mugSeqgRk93pNmB60s/ZAvTx+XX/YeT7h5Z1Ys7MQvcVRhYSICcg==
X-Received: by 2002:a63:6942:: with SMTP id e63mr45299360pgc.102.1554955047315;
        Wed, 10 Apr 2019 20:57:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwTqYjhEIyyscqODo+xkyFYT11XuiNdJ4F1kqlQ+/ZL6w8qan5Wz73m7HF2G0IL44IPeYCR
X-Received: by 2002:a63:6942:: with SMTP id e63mr45299296pgc.102.1554955046212;
        Wed, 10 Apr 2019 20:57:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554955046; cv=none;
        d=google.com; s=arc-20160816;
        b=iZQPvoaIlcCZ7FnY6EcRr1bTd0mJ8M7aAgsmmRaGSoI3T5+227BjnfhV1AklVo1t2m
         xH8xM/YvuVYVaIifK2LWwgpG9nijjTAMxVqIjAB4PcvvUZN7G1IuwTi4s+m7IdJfThE9
         Zd6I5VxdN02xZCjC3738IuNQLIb5Vwkhxacuty/xAH/QtItfQpoeOtRzrFtJ74RL2Xv6
         GunloawdGZWTsAdr2PpSBObKgk7utj2LsjYdIWpeAr9+f0/7cyWy1uLmK/wCAnygHhXH
         ZPD44eH8+INv8ijpIacozwUiVxThaGZmFSp7QHBibFKgpGMA6FGAsSdAsCxKFajhr5hH
         vtpg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=8cOivVWY4TyKGsTwqMSmS+kBKv0VXMIFbIVXDNKOfGQ=;
        b=F4UfoYPFc4zHf0CTisCKGlXTv5NEC6Obt2CiNTbBSQwYJQbZ8YanrPofzrL+KxQIKX
         GNuMdLBz8QGbqn1dut3lX+SAgothNdvUlAmraPRhZ/z+8P6sIuEfrP/1Y22TeDyxzDZw
         0dA7ZZeF6sNq76OKAglyzwA+hpqzht4czA8WULWifSBRjEgiJ+Lr40RWQ6r097w2Y9BB
         /7kLh/JQM64OuLzC8VFCpAWBzyEPwfEQE04xhE1AdEKAu6kjezse457TFxXw+U4CVAur
         g1kGwXrmKrHDzSrgXRD1DBRmzcM7B8OISCt+pSCDohyWuEqIxjgbRuzM2CmL/dEnHQEY
         mM7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com. [115.124.30.131])
        by mx.google.com with ESMTPS id g90si13116127plb.140.2019.04.10.20.57.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 20:57:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.131 as permitted sender) client-ip=115.124.30.131;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R991e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04400;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=15;SR=0;TI=SMTPD_---0TP0I5rB_1554955031;
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
Subject: [v2 PATCH 8/9] mm: vmscan: add page demotion counter
Date: Thu, 11 Apr 2019 11:56:58 +0800
Message-Id: <1554955019-29472-9-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1554955019-29472-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1554955019-29472-1-git-send-email-yang.shi@linux.alibaba.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Account the number of demoted pages into reclaim_state->nr_demoted.

Add pgdemote_kswapd and pgdemote_direct VM counters showed in
/proc/vmstat.

Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 include/linux/vm_event_item.h | 2 ++
 include/linux/vmstat.h        | 1 +
 mm/internal.h                 | 1 +
 mm/vmscan.c                   | 7 +++++++
 mm/vmstat.c                   | 2 ++
 5 files changed, 13 insertions(+)

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
diff --git a/mm/internal.h b/mm/internal.h
index 8c424b5..8ba4853 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -156,6 +156,7 @@ struct scan_control {
 		unsigned int immediate;
 		unsigned int file_taken;
 		unsigned int taken;
+		unsigned int demoted;
 	} nr;
 };
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 50cde53..a52c8248 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1511,6 +1511,12 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 
 		nr_reclaimed += nr_succeeded;
 
+		stat->nr_demoted = nr_succeeded;
+		if (current_is_kswapd())
+			__count_vm_events(PGDEMOTE_KSWAPD, stat->nr_demoted);
+		else
+			__count_vm_events(PGDEMOTE_DIRECT, stat->nr_demoted);
+
 		if (err) {
 			if (err == -ENOMEM)
 				set_bit(PGDAT_CONTENDED,
@@ -2019,6 +2025,7 @@ static int current_may_throttle(void)
 	sc->nr.unqueued_dirty += stat.nr_unqueued_dirty;
 	sc->nr.writeback += stat.nr_writeback;
 	sc->nr.immediate += stat.nr_immediate;
+	sc->nr.demoted += stat.nr_demoted;
 	sc->nr.taken += nr_taken;
 	if (file)
 		sc->nr.file_taken += nr_taken;
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 1a431dc..d1e4993 100644
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

