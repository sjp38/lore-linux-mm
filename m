Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3011C31E4A
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 23:30:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 61EBC20896
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 23:30:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 61EBC20896
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 13A788E0003; Thu, 13 Jun 2019 19:30:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0EB918E0002; Thu, 13 Jun 2019 19:30:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F1CBF8E0003; Thu, 13 Jun 2019 19:30:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id BA6858E0002
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 19:30:14 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 71so446446pld.17
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 16:30:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=IKfYPAGeHfLGYh0x3q+TVfPTsBQlwnb0pH+gyZISSqU=;
        b=A4Jnp+3yWQzPHVA7zGnGMl/gD7dtTrD0gIAdddf3oXfLjyFutEO2qZdF1A+t8rRl0m
         W+3o7dM+3FOvffnVlVdRY+1zddKX+9J9Lj42QLv+9jMy3l0J2bDW2D/8Ln/mgDdNQG2J
         jz/H6uYLDznkZsn4dCfTyFo3ZX2QdQE669Ml4KC5rs1VuengXg3PvvIbK6zR+qTeBBpV
         ptTOkzxVaVQAEK1kRjTfRp7e++7sk+URudDbvFt/IDvG/FHt/rRlTSzSGPfARjKUD8R2
         l6hCvSetRXYOtt4VLJTfBcwHEii2G3FOfTdfxZkaBm5SU8/xUrvR3qCnSVNA1fwXQ5xl
         nMsg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWawBAWUh34eBA10GO0F5Usi5LIsdOyw+/E0ifdYpboWAR9Dofj
	dANYomkvVu/K2BelwQy0P9NJ22LEmvkkrEd1GrKIvSFKElfJInBkZVTGQdXgkyt5XP35znJ0YEZ
	SFGwCiQvHqD90vZoCOm86r6+60mYwBfTIF5a9zsLWRHFR+owY5CKYGOSJ6lZD5GbgDQ==
X-Received: by 2002:a63:4a1f:: with SMTP id x31mr22907318pga.150.1560468614284;
        Thu, 13 Jun 2019 16:30:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz+NJpJVgNtdBjoiZuCM8JsBRK5EZei2wdbX+ChBFzmVBlITMeVNMOlwvbexW/OKAhILeMf
X-Received: by 2002:a63:4a1f:: with SMTP id x31mr22907258pga.150.1560468613479;
        Thu, 13 Jun 2019 16:30:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560468613; cv=none;
        d=google.com; s=arc-20160816;
        b=iCGYBpMozpg429qNlct/KoBubKb1Nqeko2tXXLQtA1quJOwSaqxI83B4QlxJrV15Ab
         BxgJgeE7pIpHP6l3mcNx/E2qyuI1/0hsI+gqlU2NCapAyS+Zf4hG+0vx64EOxiICVC3u
         K+70dGGn55FjbCgc5VwpmrD8T6UIbYf2eWIFm+aEfcSl6EcSCgGV3IH/GDGGLnUGlpX+
         1W3UtFt3I8n9DMcuLh4TWzQeGSaIWThsSq7TLA5WNBIyAf02p6CwuFnYljY4riplFtu9
         QKtOqSTVCHiNzIOZdTiCu5Fpdi/C8DaeMuyK6INmHDIEFB8h+2t7vWg++PNTviPsBdNx
         Ox9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=IKfYPAGeHfLGYh0x3q+TVfPTsBQlwnb0pH+gyZISSqU=;
        b=FDlLQMyg6Dhk2d7Vj7xNhqASXYeDSVx86usctgSIchLoI94573tzj/ZcJeeic3eVDa
         v9aWJ5UPfZhxF/bWcVFyrcUUWeSnHXyTtBDCzd6MKHRRlEmyKI7ZwnkjFHVojq70C2jd
         5Av3wUJ5TDpqsaIMP0ux8cAAbigUR8KcFym/zL3GGYSUmhWXwQsqg82o2qpiTMDFMBtr
         vO2a6glyJ4X6siQ1UhOfAm1KmyaVYqplhEHszhZU+1xdj1mBqtGqRF8grlgpX97I+6sV
         +CnKBoNOYyMq3ZSd2O1DheWGEgfeWvKbVOC8k7ju4Jt9ezUYS/svKtYbO5yurAjKNmoj
         vcJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id j20si740305pjn.91.2019.06.13.16.30.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 16:30:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) client-ip=47.88.44.36;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R351e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07487;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=15;SR=0;TI=SMTPD_---0TU6DYEz_1560468591;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TU6DYEz_1560468591)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 14 Jun 2019 07:29:59 +0800
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
Subject: [v3 PATCH 2/9] mm: Introduce migrate target nodemask
Date: Fri, 14 Jun 2019 07:29:30 +0800
Message-Id: <1560468577-101178-3-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1560468577-101178-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1560468577-101178-1-git-send-email-yang.shi@linux.alibaba.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

With more memory types are invented, the system may have heterogeneous
memory hierarchy, i.e. DRAM and PMEM.  Some of them are cheaper and
slower than DRAM, may be good candidates to be used as secondary memory
to store not recently or frequently used data.

Introduce the "migrate target" nodemask for such memory nodes.  The
migrate target could be any memory types which are cheaper and/or
slower than DRAM.  Currently PMEM is one of such memory.

Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 drivers/acpi/numa.c      | 12 ++++++++++++
 drivers/base/node.c      |  2 ++
 include/linux/nodemask.h |  1 +
 mm/page_alloc.c          |  1 +
 4 files changed, 16 insertions(+)

diff --git a/drivers/acpi/numa.c b/drivers/acpi/numa.c
index 3099583..f75adba 100644
--- a/drivers/acpi/numa.c
+++ b/drivers/acpi/numa.c
@@ -296,6 +296,18 @@ void __init acpi_numa_slit_init(struct acpi_table_slit *slit)
 		goto out_err_bad_srat;
 	}
 
+	/*
+	 * The system may have memory hierarchy, some memory may be good
+	 * candidate for migration target, i.e. PMEM is one of them.  Mark
+	 * such memory as migration target.
+	 *
+	 * It may be better to retrieve such information from HMAT, but
+	 * SRAT sounds good enough for now.  May switch to HMAT in the
+	 * future.
+	 */ 
+	if (ma->flags & ACPI_SRAT_MEM_NON_VOLATILE)
+		node_set_state(node, N_MIGRATE_TARGET);
+
 	node_set(node, numa_nodes_parsed);
 
 	pr_info("SRAT: Node %u PXM %u [mem %#010Lx-%#010Lx]%s%s\n",
diff --git a/drivers/base/node.c b/drivers/base/node.c
index 4d80fc8..351b694 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -985,6 +985,7 @@ static ssize_t show_node_state(struct device *dev,
 	[N_MEMORY] = _NODE_ATTR(has_memory, N_MEMORY),
 	[N_CPU] = _NODE_ATTR(has_cpu, N_CPU),
 	[N_CPU_MEM] = _NODE_ATTR(primary, N_CPU_MEM),
+	[N_MIGRATE_TARGET] = _NODE_ATTR(migrate_target, N_MIGRATE_TARGET),
 };
 
 static struct attribute *node_state_attrs[] = {
@@ -997,6 +998,7 @@ static ssize_t show_node_state(struct device *dev,
 	&node_state_attr[N_MEMORY].attr.attr,
 	&node_state_attr[N_CPU].attr.attr,
 	&node_state_attr[N_CPU_MEM].attr.attr,
+	&node_state_attr[N_MIGRATE_TARGET].attr.attr,
 	NULL
 };
 
diff --git a/include/linux/nodemask.h b/include/linux/nodemask.h
index 66a8964..411618c 100644
--- a/include/linux/nodemask.h
+++ b/include/linux/nodemask.h
@@ -400,6 +400,7 @@ enum node_states {
 	N_MEMORY,		/* The node has memory(regular, high, movable) */
 	N_CPU,			/* The node has one or more cpus */
 	N_CPU_MEM,		/* The node has both cpus and memory */
+	N_MIGRATE_TARGET,	/* The node is suitable migrate target */
 	NR_NODE_STATES
 };
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 757db89e..3b37c71 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -125,6 +125,7 @@ struct pcpu_drain {
 	[N_MEMORY] = { { [0] = 1UL } },
 	[N_CPU] = { { [0] = 1UL } },
 	[N_CPU_MEM] = { { [0] = 1UL } },
+	[N_MIGRATE_TARGET] = { { [0] = 1UL } },
 #endif	/* NUMA */
 };
 EXPORT_SYMBOL(node_states);
-- 
1.8.3.1

