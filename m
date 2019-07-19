Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E4DBC76196
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 13:52:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B966E21851
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 13:52:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B966E21851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1A4CE6B0005; Fri, 19 Jul 2019 09:52:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 157CF8E0003; Fri, 19 Jul 2019 09:52:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 043BF8E0001; Fri, 19 Jul 2019 09:52:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id D59C46B0005
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 09:52:51 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id b139so26280772qkc.21
        for <linux-mm@kvack.org>; Fri, 19 Jul 2019 06:52:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=GpI15cvRuqjnFWa3JMsvR2mzFMyeGrq3ufNEnq471Jc=;
        b=MIFsBPh8xcct1+yBBEcbqiCwmrulS7n6Ujxnp5sCxUMK33+0fEEg/DfTBg/J9e5wbP
         6nVUDMEp9SZgY0OZjPMwm2JQesJHgKo8cGPhnQXqMBnGr6+dOr2OtaOUkJ+1vDGI/4QJ
         WNh3YBNrEJBK3gn6eoDnt9rRpOguW4wpidUgpVk2OQHMvtCfeHbUO3JQLXW2gmKJ0gAd
         c676Q0Udlwii35gFIt+yi9DbfP7maG12bF1TB6rYDVM4GV0nT8IyxWJcAXr+Dd2sM+7t
         QBscKskyy8o7ugVrhrkiMqEz5/gOyFRiVwy2HV8TnyGto/QHNu6i9gxzizBOHGpl64Ak
         OxWA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUBaGaQmTb4G8D3DCJG1BIsRTrjrBQ5W17/iKMve+n2gqhAYJV3
	cts7D5gsX1eEdxM30TIsecUDtngpsvef6VwWhqn4w1g9zthRQjx3UabgD6/eqQOw+frFrYwH8i7
	Oy0khNSAY5FxQpDv/sjXUn1F2M0jeY7LmkNyPqDdtc6THAsO87jDUn5Nt2kLSWNAHhg==
X-Received: by 2002:a0c:9687:: with SMTP id a7mr39247317qvd.163.1563544371593;
        Fri, 19 Jul 2019 06:52:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyDWl3wTg2XR8kYVYudbMTV8TesAixh2ERVOiT+IUynWguopRTFpJuBOKMfayUAFHZVYn/7
X-Received: by 2002:a0c:9687:: with SMTP id a7mr39247251qvd.163.1563544370775;
        Fri, 19 Jul 2019 06:52:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563544370; cv=none;
        d=google.com; s=arc-20160816;
        b=TIHN5EAA2z8jxXY5eb2Y1Ix74utv+9/YCNQkl+qi1lFngtjjPgGpFIoQqbIModlkRR
         NwBYejGIBwNe+9sjO40GpBEI2+o9AYWMwYWUDjR9lwmhkYO8WSYOlVdRO5s2ImK9taR3
         ERO2KqTzIdeB+oLXmZHD8qZLVjvk+x7s8wvP595QqnPd/at2ImoGgJsZpAEyv+a/TZTP
         9SpsXpPdtM/uZTPiDTXUGUerZnvkK4GNlFrU3h3lQ9Mu/9bLwPPj8LvpINJOJ9xDu2wG
         Yyq7ciVUhjdY11mCjcHti3CwPPdkcBU1vjYI29HGTTak30awSC+yT+zV/KnJIEgQwk/n
         cD8w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=GpI15cvRuqjnFWa3JMsvR2mzFMyeGrq3ufNEnq471Jc=;
        b=eD8PA+FEm/4FlZFgs47Lqq8qwVA6MdtTm37CtupjqnS24ah4k1YmaoXpkl4RATwDWJ
         5qYCoo7BxYWfxn3QlAb4Ri0RSdaWQGADj/An6dc+3GeA2uo60uS9a6LZojF3ElI34fgN
         6FqA3rFAqvSx5JFp10Me7pDzHn7b7LubLaLPOW1acNgTRzJ6WcHT48Z3GnlnUEGBwEto
         Gux6GsEesa/TAtTt+icBp6SevulbPyId6hnUW7fMXwC0g+hYzrdJl4DjUkQMoFxFWMmu
         AyxyWJMNPWJLONLSrAVWsrvoIbwUdA6TN6uLK2izKix2WGYe+8K8k3IkvgWyfnUQ0tiq
         MtdA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u9si21209262qvg.28.2019.07.19.06.52.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jul 2019 06:52:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E00703084295;
	Fri, 19 Jul 2019 13:52:49 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-116-220.ams2.redhat.com [10.36.116.220])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 5A8B81019615;
	Fri, 19 Jul 2019 13:52:45 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	David Hildenbrand <david@redhat.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Michal Hocko <mhocko@suse.com>,
	Oscar Salvador <osalvador@suse.de>
Subject: [PATCH v2] drivers/base/node.c: Simplify unregister_memory_block_under_nodes()
Date: Fri, 19 Jul 2019 15:52:44 +0200
Message-Id: <20190719135244.15242-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Fri, 19 Jul 2019 13:52:50 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We don't allow to offline memory block devices that belong to multiple
numa nodes. Therefore, such devices can never get removed. It is
sufficient to process a single node when removing the memory block. No
need to iterate over each and every PFN.

We already have the nid stored for each memory block. Make sure that
the nid always has a sane value.

Please note that checking for node_online(nid) is not required. If we
would have a memory block belonging to a node that is no longer offline,
then we would have a BUG in the node offlining code.

Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: David Hildenbrand <david@redhat.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Oscar Salvador <osalvador@suse.de>
Signed-off-by: David Hildenbrand <david@redhat.com>
---

v1 -> v2:
- Remove the "mixed nid" part, add a comment instead. Drop the warning.

---
 drivers/base/memory.c |  1 +
 drivers/base/node.c   | 39 +++++++++++++++------------------------
 2 files changed, 16 insertions(+), 24 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 20c39d1bcef8..154d5d4a0779 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -674,6 +674,7 @@ static int init_memory_block(struct memory_block **memory,
 	mem->state = state;
 	start_pfn = section_nr_to_pfn(mem->start_section_nr);
 	mem->phys_device = arch_get_memory_phys_device(start_pfn);
+	mem->nid = NUMA_NO_NODE;
 
 	ret = register_memory(mem);
 
diff --git a/drivers/base/node.c b/drivers/base/node.c
index 75b7e6f6535b..840c95baa1d8 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -759,8 +759,6 @@ static int register_mem_sect_under_node(struct memory_block *mem_blk,
 	int ret, nid = *(int *)arg;
 	unsigned long pfn, sect_start_pfn, sect_end_pfn;
 
-	mem_blk->nid = nid;
-
 	sect_start_pfn = section_nr_to_pfn(mem_blk->start_section_nr);
 	sect_end_pfn = section_nr_to_pfn(mem_blk->end_section_nr);
 	sect_end_pfn += PAGES_PER_SECTION - 1;
@@ -789,6 +787,13 @@ static int register_mem_sect_under_node(struct memory_block *mem_blk,
 			if (page_nid != nid)
 				continue;
 		}
+
+		/*
+		 * If this memory block spans multiple nodes, we only indicate
+		 * the last processed node.
+		 */
+		mem_blk->nid = nid;
+
 		ret = sysfs_create_link_nowarn(&node_devices[nid]->dev.kobj,
 					&mem_blk->dev.kobj,
 					kobject_name(&mem_blk->dev.kobj));
@@ -804,32 +809,18 @@ static int register_mem_sect_under_node(struct memory_block *mem_blk,
 }
 
 /*
- * Unregister memory block device under all nodes that it spans.
- * Has to be called with mem_sysfs_mutex held (due to unlinked_nodes).
+ * Unregister a memory block device under the node it spans. Memory blocks
+ * with multiple nodes cannot be offlined and therefore also never be removed.
  */
 void unregister_memory_block_under_nodes(struct memory_block *mem_blk)
 {
-	unsigned long pfn, sect_start_pfn, sect_end_pfn;
-	static nodemask_t unlinked_nodes;
-
-	nodes_clear(unlinked_nodes);
-	sect_start_pfn = section_nr_to_pfn(mem_blk->start_section_nr);
-	sect_end_pfn = section_nr_to_pfn(mem_blk->end_section_nr);
-	for (pfn = sect_start_pfn; pfn <= sect_end_pfn; pfn++) {
-		int nid;
+	if (mem_blk->nid == NUMA_NO_NODE)
+		return;
 
-		nid = get_nid_for_pfn(pfn);
-		if (nid < 0)
-			continue;
-		if (!node_online(nid))
-			continue;
-		if (node_test_and_set(nid, unlinked_nodes))
-			continue;
-		sysfs_remove_link(&node_devices[nid]->dev.kobj,
-			 kobject_name(&mem_blk->dev.kobj));
-		sysfs_remove_link(&mem_blk->dev.kobj,
-			 kobject_name(&node_devices[nid]->dev.kobj));
-	}
+	sysfs_remove_link(&node_devices[mem_blk->nid]->dev.kobj,
+			  kobject_name(&mem_blk->dev.kobj));
+	sysfs_remove_link(&mem_blk->dev.kobj,
+			  kobject_name(&node_devices[mem_blk->nid]->dev.kobj));
 }
 
 int link_mem_sections(int nid, unsigned long start_pfn, unsigned long end_pfn)
-- 
2.21.0

