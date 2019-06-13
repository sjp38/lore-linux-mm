Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81982C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 23:30:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 40B1020896
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 23:30:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 40B1020896
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1FE238E0005; Thu, 13 Jun 2019 19:30:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 163088E0002; Thu, 13 Jun 2019 19:30:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ED3268E0005; Thu, 13 Jun 2019 19:30:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id B259C8E0002
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 19:30:16 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 91so459835pla.7
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 16:30:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=hDNydRbA83jbliMn/y7MvMj1b1V45KErjlHbPtM+FvQ=;
        b=gqEKgUXc7RlZ2jOgyjHEkERyY+7u0w/JcuaogcI4R4wJm1EHqRNbJctnd77iH4M2DW
         7IYLs4OcANDbezdeW6q+h+AcfwbL9yBVzqw1dbkhoMd1UPBrVhtu/vBvbto6cEryT+uz
         S1HWknVe0xdgZMoIlX2lcc3x44JR3IC2m650mfY7r2tWlgtVEevuC+Ah0JTVnvH7QXSe
         ZCQgyvQ8+zQJuHAzCMSG+/URT0NPCvZQIjlmH5q1dX6kSxKXfBNcye652gJbK1jAOuOj
         YXOP0qjLcJVpA68T1iehvnSa63y6WyM6WrQDLi1pBvUgFhki6rLdyHCVknH6EjT+bm2p
         ZjaA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUAF8h/c7UdDnj/kYHjZKFufIJrHQmxa9556hlp95KvpavoEN10
	JoGTU6tdgwuc49XrYh8RcjB1V6pVT68Iley63HUN4sECurAIb8mmQuzMIQTDWmKigP+KBXLSNaf
	PlLZV4f6sn0tRGcJ+3WQM2qlNvbpt2kAAO4yvpNY0Ixvmxe0bAtbFluohIG7MpaByFQ==
X-Received: by 2002:a63:5c41:: with SMTP id n1mr1190693pgm.69.1560468616259;
        Thu, 13 Jun 2019 16:30:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyOhG3yVslHWmRzZpUEy+q/tRec8E14XSfrUbMHfYvndrU74vyHKdlsxIsmsrRmslTxBmfg
X-Received: by 2002:a63:5c41:: with SMTP id n1mr1190599pgm.69.1560468615102;
        Thu, 13 Jun 2019 16:30:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560468615; cv=none;
        d=google.com; s=arc-20160816;
        b=uS3NgFzS3/fbp5dmkJj6HsvwG/+6ieZcMnOTX+iK8pwz4PS+EbZksQYQAF5XGu4g97
         5PCh022GrBRKCHgGsnvuWRMJj4+GjJStjOaWmfmFT+8JEYr2R57N3nhXfMSIwpyZ1fZ/
         LaiWYH7KjVKTWSkoWgxJefaE9R626Bn5n3Mhn2xtBRbEIvToe/RDIYjLVErssn1X47fN
         979qA0yoxARdjXrqwJZeYuTqClRk9rwPW/rr1sDas+/B/XWVx8Ye6oEgsDIbSg60Xwvb
         DFZv7RG/6kduq9yHvcSCcmyZ9lQBV0fPrdVtE1ucRLcmVPBtMX/w+Iyi49muF/KwYHfi
         JYsA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=hDNydRbA83jbliMn/y7MvMj1b1V45KErjlHbPtM+FvQ=;
        b=1Ibqrhysi8nPXMm64293NS89AZCjGawWr+HBh2FdcmokHBOQqbCE7J3Jx7Q3RU2Ntq
         Vg77dMGkcWHWeZQo8x3DaqGyb1bHhdk15+juZZtJc81F1BLTavhvkYNEqxgeS4rbW4R5
         xKWMcqm0Y0xILjvjuTxlImDUtdghN7ih0SDuIguV6qGj+1vwOO8Vtr/6kJu4BPextF5g
         YjIsUwPPlf8uHWmiZXDTJ53rpq9BHkJlNMjS1xKzDr3ZvSbzHRtwdu5ckg9ZMJ/O7MNN
         yyq7jo+8Xpco4n6RfzXXv80//86SimslIIyTwZnSAApnyu4gR6UQuZDITlB/xWWiUgFr
         hRdQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id b69si749875pjc.104.2019.06.13.16.30.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 16:30:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) client-ip=47.88.44.36;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R701e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04426;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=15;SR=0;TI=SMTPD_---0TU6DYEz_1560468591;
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
Subject: [v3 PATCH 8/9] mm: vmscan: add page demotion counter
Date: Fri, 14 Jun 2019 07:29:36 +0800
Message-Id: <1560468577-101178-9-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1560468577-101178-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1560468577-101178-1-git-send-email-yang.shi@linux.alibaba.com>
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
 mm/vmscan.c                   | 8 ++++++++
 mm/vmstat.c                   | 2 ++
 4 files changed, 13 insertions(+)

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
index bdeda4b..00d53d4 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -29,6 +29,7 @@ struct reclaim_stat {
 	unsigned nr_activate[2];
 	unsigned nr_ref_keep;
 	unsigned nr_unmap_fail;
+	unsigned nr_demoted;
 };
 
 #ifdef CONFIG_VM_EVENT_COUNTERS
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9ec55d7..f65cd45 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -130,6 +130,7 @@ struct scan_control {
 		unsigned int immediate;
 		unsigned int file_taken;
 		unsigned int taken;
+		unsigned int demoted;
 	} nr;
 };
 
@@ -1582,6 +1583,12 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 
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
@@ -2097,6 +2104,7 @@ static int current_may_throttle(void)
 	sc->nr.unqueued_dirty += stat.nr_unqueued_dirty;
 	sc->nr.writeback += stat.nr_writeback;
 	sc->nr.immediate += stat.nr_immediate;
+	sc->nr.demoted += stat.nr_demoted;
 	sc->nr.taken += nr_taken;
 	if (file)
 		sc->nr.file_taken += nr_taken;
diff --git a/mm/vmstat.c b/mm/vmstat.c
index d876ac0..eee29a9 100644
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

