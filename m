Return-Path: <SRS0=aXoD=SR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0BDA8C10F12
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 17:49:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C153020848
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 17:49:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C153020848
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A89C26B000A; Mon, 15 Apr 2019 13:49:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 94C166B000C; Mon, 15 Apr 2019 13:49:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 814256B000D; Mon, 15 Apr 2019 13:49:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4C6926B000A
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 13:49:52 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id q25so9489211otf.6
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 10:49:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=c8Oa8if3Ah0YDZHoU72RxzlhFP90iXNpwesyngeW7fE=;
        b=RFsq2AdcuVCSR2KKgSlurFt2EN+ta3AFRlQoI/1zeMT87tPxgoemLWAc+CtTswWWzC
         kc/XqlXfpiPMVMB/fIIMW+tSOG9M7Njy4Nk2pN9HxzT4UXLy4azy4bkNu7+mkiWMq7XW
         wy77FlW6uwDk4V0FM5I4GhP4VUwdasDr7OA7CO11oRh8j5uk9P8870H1gEtug1/M1Uul
         wYiGw56cl+Bs6VU7A7AqoZvRHHSnmhwXC7LSXhHMxn1EDPFYLmDmw9R0iQWQF7Tjp6UR
         Ly1g83PQK+6bFgKRbuZECIwVS/YaMaZa60s1MrmyITO6HodJyW7OhcozMhQFOjracPT4
         87Yw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: APjAAAVC6T0ypv9E3E1quxCC2hHCkPbwe7Tok8RVFOJYa/51iI/VJ/GJ
	oV6VRsABbrillUBMqTbYn+IVhvgR5Twy9z83k1RqAvwhmx0wQM6fIo8f1FLd6SNNJmrWAArtgFE
	cBgDe7DfpW+fS5Eh8YfnhPpnxtzacAiTHObDfqB7uj0vkhduBWsg37ezla/TT6dYTyw==
X-Received: by 2002:a9d:63c9:: with SMTP id e9mr48493187otl.76.1555350591965;
        Mon, 15 Apr 2019 10:49:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzEVVWoAbj3JROSFoQ4O5TLPgUnwu2zOrmjoReI1dG0L6cIWeAWP8QEPN1Jdlf/RFdBUswZ
X-Received: by 2002:a9d:63c9:: with SMTP id e9mr48493116otl.76.1555350590395;
        Mon, 15 Apr 2019 10:49:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555350590; cv=none;
        d=google.com; s=arc-20160816;
        b=je7CAsI7enwKbvhzYq/1VCFlw0Cy+iZseCgEbIFq3bdKL7uTZHP+RRjYsp2P61I2Ud
         aHU7n1CjMWFpERZiJK8pSmfE8p1+ixvpHoPhH3Kr31yxUyZ+fhTv6jlpnw9S9x7hbTWf
         iEzTTmN+Ab0E/GA86B/uyqqMyIxHYPbplG9lGpeJ7EWmvI3ZuRPWxyg6kUpEf7Yxzpg6
         1kSoIQ0CcvyY+cXsj9YwJDrziAXdYiO+rTYHsTU4GROfls0dEKX1LshnILBMs3Uph+7J
         5NMOXijYesLGY5y8UxANZxD0uYzkPPKHrW5mVaThCYx9WJXaJ8v1pqfo4F3af83IwVjO
         VO5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=c8Oa8if3Ah0YDZHoU72RxzlhFP90iXNpwesyngeW7fE=;
        b=a1Wi5szgsURLxq+ax9mlWpULGBuUJBXb/UhT5BuNvYnWkpe3aTvpnS75kse5xcnEA+
         +/TL+DdABc2wh9lkqLsv6Lug5mo2IKwjQ1nYtHWHU2STRTr0O4TAtdhSksAOBjtRNVEl
         j7vf7JWkwRTQuuu+t5U4BTDl50qfXhm2/RBwm9H3HhfUy3uvGW3VFXCvOipncB9xi1j8
         NV14SdCuYhNo8xAk0+tn/JzC9Bp3ZzKf12GgMr1Q7Q6MdKjdeCPnmfSEfKsGn8Qe7ltO
         3mIOnMydPQYZTDxQUsFFrBgeHLRTrc07KIbAZZAg55Ff5uSuohloS0wKCguQint2UmP4
         NF7g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id g9si14922636oib.37.2019.04.15.10.49.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Apr 2019 10:49:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.191 as permitted sender) client-ip=45.249.212.191;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS401-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id E4BA485083B4B38C348A;
	Tue, 16 Apr 2019 01:49:46 +0800 (CST)
Received: from FRA1000014316.huawei.com (100.126.230.97) by
 DGGEMS401-HUB.china.huawei.com (10.3.19.201) with Microsoft SMTP Server id
 14.3.408.0; Tue, 16 Apr 2019 01:49:37 +0800
From: Jonathan Cameron <Jonathan.Cameron@huawei.com>
To: <linux-mm@kvack.org>, <linux-acpi@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>
CC: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Keith Busch
	<keith.busch@intel.com>, "Rafael J . Wysocki" <rjw@rjwysocki.net>,
	<linuxarm@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, "Jonathan
 Cameron" <Jonathan.Cameron@huawei.com>
Subject: [PATCH 2/4 V3] arm64: Support Generic Initiator only domains
Date: Tue, 16 Apr 2019 01:49:05 +0800
Message-ID: <20190415174907.102307-3-Jonathan.Cameron@huawei.com>
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

The one thing that currently needs doing from an architecture
point of view is associating the GI domain with its nearest
memory domain.  This allows all the standard NUMA aware code
to get a 'reasonable' answer.

A clever driver might elect to do load balancing etc
if there are multiple host / memory domains nearby, but
that's a decision for the driver.

Signed-off-by: Jonathan Cameron <Jonathan.Cameron@huawei.com>
---
 arch/arm64/kernel/smp.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/arch/arm64/kernel/smp.c b/arch/arm64/kernel/smp.c
index 824de7038967..7c419bf92374 100644
--- a/arch/arm64/kernel/smp.c
+++ b/arch/arm64/kernel/smp.c
@@ -731,6 +731,7 @@ void __init smp_prepare_cpus(unsigned int max_cpus)
 {
 	int err;
 	unsigned int cpu;
+	unsigned int node;
 	unsigned int this_cpu;
 
 	init_cpu_topology();
@@ -769,6 +770,13 @@ void __init smp_prepare_cpus(unsigned int max_cpus)
 		set_cpu_present(cpu, true);
 		numa_store_cpu_info(cpu);
 	}
+
+	/*
+	 * Walk the numa domains and set the node to numa memory reference
+	 * for any that are Generic Initiator Only.
+	 */
+	for_each_node_state(node, N_GENERIC_INITIATOR)
+		set_gi_numa_mem(node, local_memory_node(node));
 }
 
 void (*__smp_cross_call)(const struct cpumask *, unsigned int);
-- 
2.19.1

