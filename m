Return-Path: <SRS0=aXoD=SR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95870C10F0E
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 17:49:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 56B2020848
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 17:49:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 56B2020848
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EF2FF6B0008; Mon, 15 Apr 2019 13:49:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EA2286B000A; Mon, 15 Apr 2019 13:49:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D904E6B000C; Mon, 15 Apr 2019 13:49:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id A2A726B0008
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 13:49:51 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id j20so9514227otr.0
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 10:49:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=hF0XPxmSlriUa3biRRCnOMC8/O51OfJgLGjA5b/WPw4=;
        b=HgLVBMWSLlhVaGuXz12vhuo0Ue114AM6MQx8akHXrVkYxex2OtMaHO4oxtCvjXAPpJ
         S6FD2w6vYqvBqNYuY5MO909Al1Ux5qgpljRW/x9Tj+uahILNHPTpGsq/Ku8y4LUVK6mB
         KOjYHCE/F6jX4OKsThSJi31jCkxlocOAI0+kjAEP1/ndMBghvD4mlv5j63VDpPY8lnp3
         2W83dzBL6d6TXLKYIHuq1Lh8idPjIIDKAVUH5sePl6sq5YGPGUrHp4rxytXt2+dJWalb
         3NYm4s+MxRWc4whytzakTMTxtCTvI7Gd6m0n4L8ypQdSD1lVwunSvMLZYC2zCPGh/i0Q
         WbDg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: APjAAAVdrBZ/XYnaZVp2EKBSyobWOx0JOgXMSGM/99sX50pql7/0EqiG
	eKl09uYDrXD2iNPFNPeJkkNLnR335A14CSXd1IC0NbuaPVjGrtlt8lJQpYCEz7u24uQ3u986y6v
	t1GovbKvBMj/KKQ04HRiaKCH+urUIGLfmLbMsCifT/0ZRzHeVPjjWF8jTMVd/L5siGg==
X-Received: by 2002:a9d:6344:: with SMTP id y4mr40042007otk.11.1555350591285;
        Mon, 15 Apr 2019 10:49:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw3G85ShjNKJ1YYderLm55mekLTOln78aZ75o/GmiSj3UHMMiG5ziUkd9DsUNz2StLQ3Rwq
X-Received: by 2002:a9d:6344:: with SMTP id y4mr40041973otk.11.1555350590432;
        Mon, 15 Apr 2019 10:49:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555350590; cv=none;
        d=google.com; s=arc-20160816;
        b=or7uo4LnIqjVyelwxRbh5Ot4l1EmH52jwGgRhRmYrb0tCQIk2Tq6/KoXAw+uEh91RX
         pD3CUfBq4UeaUb0aC+ZeVZGNUhal4zDWwxkEJ/cI7jUsZxsh0MAxU0vhuXVXOWFRKc36
         aeAbypiCDOLw6hqzXYVjuK7ijwgVMp+5IPxm6BghKv6AWfPKW0ujsDR9R4okQnrp92T+
         7USXU3+zCWzlpEUybNvUCr+F0fjdpVc6xWMvrsy0muLxt+8Ik7X5iC3ZNSxSEOkxrSDQ
         /N7Qg3jliDwP8funf3ORMjvCIrlvvyuHCqKPFOhXXJzdIChkRJNAb0xffejQ64fmdCty
         bZgQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=hF0XPxmSlriUa3biRRCnOMC8/O51OfJgLGjA5b/WPw4=;
        b=w99o2upRW1OXpEFsnQfjlrHa0H9PSSV2e5ht42rJ7yg3WCTHfqqIDNAHlrQekoSnim
         uAC5eTlYz7iWA3DdAewqjVDTZANA6CPnok7IKlCB7BONFIY2mLL8yNrb0DaRtjfBw1Ei
         9oKd0agxiKLqL+aj82HrVutMeyDqYEU88o35FNZ5QtcxeeZXbcnNG5JTpXqyQ1x5JeYR
         vQ29YLejQhP8SBFlShNm9D/8EYdn2i1G6Jn6t2dBRFBhr5lXCVVQa/lKf+TgurYv0Sla
         a/ZJGyHwGMVIyu+29NicB5GX8S4PfvTenSyjefw6kiRQ/P9MgoeTvwoNnAGrFw05WcQs
         IlOg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id 32si22039336ots.280.2019.04.15.10.49.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Apr 2019 10:49:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.191 as permitted sender) client-ip=45.249.212.191;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS401-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id E9F36BCDACFC859002AD;
	Tue, 16 Apr 2019 01:49:46 +0800 (CST)
Received: from FRA1000014316.huawei.com (100.126.230.97) by
 DGGEMS401-HUB.china.huawei.com (10.3.19.201) with Microsoft SMTP Server id
 14.3.408.0; Tue, 16 Apr 2019 01:49:40 +0800
From: Jonathan Cameron <Jonathan.Cameron@huawei.com>
To: <linux-mm@kvack.org>, <linux-acpi@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>
CC: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Keith Busch
	<keith.busch@intel.com>, "Rafael J . Wysocki" <rjw@rjwysocki.net>,
	<linuxarm@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, "Jonathan
 Cameron" <Jonathan.Cameron@huawei.com>
Subject: [PATCH 3/4 V3] x86: Support Generic Initiator only proximity domains
Date: Tue, 16 Apr 2019 01:49:06 +0800
Message-ID: <20190415174907.102307-4-Jonathan.Cameron@huawei.com>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190415174907.102307-1-Jonathan.Cameron@huawei.com>
References: <20190415174907.102307-1-Jonathan.Cameron@huawei.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
X-Originating-IP: [100.126.230.97]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Done in a somewhat different fashion to arm64.
Here the infrastructure for memoryless domains was already
in place.  That infrastruture applies just as well to
domains that also don't have a CPU, hence it works for
Generic Initiator Domains.

In common with memoryless domains we only register GI domains
if the proximity node is not online. If a domain is already
a memory containing domain, or a memoryless domain there is
nothing to do just because it also contains a Generic Initiator.

Signed-off-by: Jonathan Cameron <Jonathan.Cameron@huawei.com>
---
 arch/x86/include/asm/numa.h |  2 ++
 arch/x86/kernel/setup.c     |  1 +
 arch/x86/mm/numa.c          | 14 ++++++++++++++
 3 files changed, 17 insertions(+)

diff --git a/arch/x86/include/asm/numa.h b/arch/x86/include/asm/numa.h
index bbfde3d2662f..f631467272a3 100644
--- a/arch/x86/include/asm/numa.h
+++ b/arch/x86/include/asm/numa.h
@@ -62,12 +62,14 @@ extern void numa_clear_node(int cpu);
 extern void __init init_cpu_to_node(void);
 extern void numa_add_cpu(int cpu);
 extern void numa_remove_cpu(int cpu);
+extern void init_gi_nodes(void);
 #else	/* CONFIG_NUMA */
 static inline void numa_set_node(int cpu, int node)	{ }
 static inline void numa_clear_node(int cpu)		{ }
 static inline void init_cpu_to_node(void)		{ }
 static inline void numa_add_cpu(int cpu)		{ }
 static inline void numa_remove_cpu(int cpu)		{ }
+static inline void init_gi_nodes(void)			{ }
 #endif	/* CONFIG_NUMA */
 
 #ifdef CONFIG_DEBUG_PER_CPU_MAPS
diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index 3d872a527cd9..240568c3ac60 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -1245,6 +1245,7 @@ void __init setup_arch(char **cmdline_p)
 	prefill_possible_map();
 
 	init_cpu_to_node();
+	init_gi_nodes();
 
 	io_apic_init_mappings();
 
diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index dfb6c4df639a..5770d2dcad29 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -732,6 +732,20 @@ static void __init init_memory_less_node(int nid)
 	 */
 }
 
+/*
+ * Generic Initiator Nodes may have neither CPU nor Memory.
+ * At this stage if either of the others were present we would
+ * already be online.
+ */
+void __init init_gi_nodes(void)
+{
+	int nid;
+
+	for_each_node_state(nid, N_GENERIC_INITIATOR)
+		if (!node_online(nid))
+			init_memory_less_node(nid);
+}
+
 /*
  * Setup early cpu_to_node.
  *
-- 
2.19.1

