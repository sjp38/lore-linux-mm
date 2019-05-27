Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EF9AFC07542
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 11:13:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B09B220883
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 11:13:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B09B220883
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 49E0A6B027F; Mon, 27 May 2019 07:13:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 474776B0280; Mon, 27 May 2019 07:13:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 389EC6B0281; Mon, 27 May 2019 07:13:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1064F6B027F
	for <linux-mm@kvack.org>; Mon, 27 May 2019 07:13:06 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id g80so8650100otg.12
        for <linux-mm@kvack.org>; Mon, 27 May 2019 04:13:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=jwqamueXeySfeFxINzjppTw9mQ9ehliTYQXoU7pLAas=;
        b=G/fBbfbopM1Gor1W1sb1Ow59tgBcupaqQNpkxNMObH0R+A6AM89GqHuLfq7TLGAPQI
         OZQYhn3z58FpbREoRnNy4To+N/6/ZM4YvoCmdq44w6vLoyGERg9XAWBmBlW4vmfN2EXz
         RJBUUYifbBQD/cq772nEM0Y3tPy5QI6bEoK9Cfg3mC6rlABJHJQ9285vy/hutqj9cXFW
         S7BN1OrUDphkXcQANE/KCGadiZpfIdbutdBRUTiCqcMDr4txsZK/Y2hWbY7/NcVNBANI
         6rbMbXwR4Tkor3ybej4xs5WPU/JMnUfL0GfQ5TQI+XYLKkUjaBYwA6oe080b70h4T68l
         ofng==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWY8ygfR0ODn5IEXszs1AsW9tm021a5ZIMpcNpcOT+7wSdfrplp
	F37ooJUIiQhUoy79t5jDZQlBk9xvyjZNfNsTUzhv4B5r4AaZ38JtOX20xe3GogtIpK+vx4A/5Vl
	pc11XWsnbn+nx7wdDGjwoGN5aWcQw3vtTWyKCH5D4nu0r7105/tNU4fFvdzq508CjfA==
X-Received: by 2002:aca:48c2:: with SMTP id v185mr13977051oia.171.1558955585727;
        Mon, 27 May 2019 04:13:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz7SZpMpzvAdNzb54JIBqXBtz9dM+G3sVterAaauUxaoq7dKSlMWkbQEg/C7xdUyfPrqHiV
X-Received: by 2002:aca:48c2:: with SMTP id v185mr13977021oia.171.1558955585134;
        Mon, 27 May 2019 04:13:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558955585; cv=none;
        d=google.com; s=arc-20160816;
        b=LvAmQqrjO6um92HamE2Q8ayi9riAZZc/AYwuLSf8/xcZDc9kjPRk3oFGfI2V/uMDCB
         kRXIG2hom9MzmBRF4/mqXo+hI/Hx9fhvOI1G1LHNX89NmDQlc++F45HKqao1GKgLCQ5P
         iiyzJEld/kdPwbOCHNpVEtmeGNNElo5KRQwuH+SArnfFmXU1htTiHbXG6Coxn+hsuiY/
         q5a//utdLrIiNRnFfM6dGFeeC8z1EB0ZqYlUx3IZrxx/sEoK4ZCbDgqsYigo7QTmxe10
         AIdqJWGBc56Jo3b9M9epEIaifNcmZQzIyx/BPTk1HOeqlZpU8lqo6TCOt39tNl3ht/BB
         W2TA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=jwqamueXeySfeFxINzjppTw9mQ9ehliTYQXoU7pLAas=;
        b=LrJ2EvIohfyN6ame98kAHon5BvVa5geDsMIsvh9Gv4iF3+tErNYbpgEZ+Vsrxw+ATZ
         DmqO0gyQDozd7wyfcKuNUCHPtct2xpoPjV5QL46aPPdYFnbuodRhqkJy1fTpT3ebmy6h
         CpF7OnRaWXN3LCmEduGok9u6h+VhXUwsn7UCILkt50KztCgMcLelSTRRH7S9mB9Ovw1y
         kB6Bn5YqHTxQUU07IwJmsmPdddfsHmpjzAagk+9NrTGjBUUxWO24VqF0cebED4NPnGxE
         E/SZBAA2hdoaK0+4QXOkKqmhBbstfhhGSuGbRYd1OFbvtKEMjQXETCzyKPXzvoUMcu5k
         d+7w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m88si5804831otc.103.2019.05.27.04.13.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 04:13:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 551563082B5F;
	Mon, 27 May 2019 11:13:04 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-89.ams2.redhat.com [10.36.117.89])
	by smtp.corp.redhat.com (Postfix) with ESMTP id B086919C7F;
	Mon, 27 May 2019 11:13:00 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	linux-ia64@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	akpm@linux-foundation.org,
	Dan Williams <dan.j.williams@intel.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Igor Mammedov <imammedo@redhat.com>,
	David Hildenbrand <david@redhat.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Alex Deucher <alexander.deucher@amd.com>,
	"David S. Miller" <davem@davemloft.net>,
	Mark Brown <broonie@kernel.org>,
	Chris Wilson <chris@chris-wilson.co.uk>,
	Oscar Salvador <osalvador@suse.de>,
	Jonathan Cameron <Jonathan.Cameron@huawei.com>
Subject: [PATCH v3 10/11] mm/memory_hotplug: Make unregister_memory_block_under_nodes() never fail
Date: Mon, 27 May 2019 13:11:51 +0200
Message-Id: <20190527111152.16324-11-david@redhat.com>
In-Reply-To: <20190527111152.16324-1-david@redhat.com>
References: <20190527111152.16324-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Mon, 27 May 2019 11:13:04 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We really don't want anything during memory hotunplug to fail.
We always pass a valid memory block device, that check can go. Avoid
allocating memory and eventually failing. As we are always called under
lock, we can use a static piece of memory. This avoids having to put
the structure onto the stack, having to guess about the stack size
of callers.

Patch inspired by a patch from Oscar Salvador.

In the future, there might be no need to iterate over nodes at all.
mem->nid should tell us exactly what to remove. Memory block devices
with mixed nodes (added during boot) should properly fenced off and never
removed.

Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: Alex Deucher <alexander.deucher@amd.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Mark Brown <broonie@kernel.org>
Cc: Chris Wilson <chris@chris-wilson.co.uk>
Cc: David Hildenbrand <david@redhat.com>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Jonathan Cameron <Jonathan.Cameron@huawei.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 drivers/base/node.c  | 18 +++++-------------
 include/linux/node.h |  5 ++---
 2 files changed, 7 insertions(+), 16 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 04fdfa99b8bc..9be88fd05147 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -803,20 +803,14 @@ int register_mem_sect_under_node(struct memory_block *mem_blk, void *arg)
 
 /*
  * Unregister memory block device under all nodes that it spans.
+ * Has to be called with mem_sysfs_mutex held (due to unlinked_nodes).
  */
-int unregister_memory_block_under_nodes(struct memory_block *mem_blk)
+void unregister_memory_block_under_nodes(struct memory_block *mem_blk)
 {
-	NODEMASK_ALLOC(nodemask_t, unlinked_nodes, GFP_KERNEL);
 	unsigned long pfn, sect_start_pfn, sect_end_pfn;
+	static nodemask_t unlinked_nodes;
 
-	if (!mem_blk) {
-		NODEMASK_FREE(unlinked_nodes);
-		return -EFAULT;
-	}
-	if (!unlinked_nodes)
-		return -ENOMEM;
-	nodes_clear(*unlinked_nodes);
-
+	nodes_clear(unlinked_nodes);
 	sect_start_pfn = section_nr_to_pfn(mem_blk->start_section_nr);
 	sect_end_pfn = section_nr_to_pfn(mem_blk->end_section_nr);
 	for (pfn = sect_start_pfn; pfn <= sect_end_pfn; pfn++) {
@@ -827,15 +821,13 @@ int unregister_memory_block_under_nodes(struct memory_block *mem_blk)
 			continue;
 		if (!node_online(nid))
 			continue;
-		if (node_test_and_set(nid, *unlinked_nodes))
+		if (node_test_and_set(nid, unlinked_nodes))
 			continue;
 		sysfs_remove_link(&node_devices[nid]->dev.kobj,
 			 kobject_name(&mem_blk->dev.kobj));
 		sysfs_remove_link(&mem_blk->dev.kobj,
 			 kobject_name(&node_devices[nid]->dev.kobj));
 	}
-	NODEMASK_FREE(unlinked_nodes);
-	return 0;
 }
 
 int link_mem_sections(int nid, unsigned long start_pfn, unsigned long end_pfn)
diff --git a/include/linux/node.h b/include/linux/node.h
index 02a29e71b175..548c226966a2 100644
--- a/include/linux/node.h
+++ b/include/linux/node.h
@@ -139,7 +139,7 @@ extern int register_cpu_under_node(unsigned int cpu, unsigned int nid);
 extern int unregister_cpu_under_node(unsigned int cpu, unsigned int nid);
 extern int register_mem_sect_under_node(struct memory_block *mem_blk,
 						void *arg);
-extern int unregister_memory_block_under_nodes(struct memory_block *mem_blk);
+extern void unregister_memory_block_under_nodes(struct memory_block *mem_blk);
 
 extern int register_memory_node_under_compute_node(unsigned int mem_nid,
 						   unsigned int cpu_nid,
@@ -175,9 +175,8 @@ static inline int register_mem_sect_under_node(struct memory_block *mem_blk,
 {
 	return 0;
 }
-static inline int unregister_memory_block_under_nodes(struct memory_block *mem_blk)
+static inline void unregister_memory_block_under_nodes(struct memory_block *mem_blk)
 {
-	return 0;
 }
 
 static inline void register_hugetlbfs_with_node(node_registration_func_t reg,
-- 
2.20.1

