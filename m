Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2113CC04AB3
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 11:13:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CC4512146F
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 11:13:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CC4512146F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 734C96B027C; Mon, 27 May 2019 07:13:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 70D446B027D; Mon, 27 May 2019 07:13:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5FC9D6B027E; Mon, 27 May 2019 07:13:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 34BA46B027C
	for <linux-mm@kvack.org>; Mon, 27 May 2019 07:13:02 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id f30so5307125oij.3
        for <linux-mm@kvack.org>; Mon, 27 May 2019 04:13:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=e5EF8dpMsbDDNCAATVA9f1rm/c9fnhfqkSCcpFKc4do=;
        b=Y+gCV0klbNF/hB4Y6zbud5SBWTK4dY0w8HHaAYQ1F2yJWOtH+g0Oyq2IZwL4rXPMmD
         h8fbrE9jZTSkMEprIdsIpuvg/57C+9sD7z+UV3oJOi2u4d+lo7wO2dWU5Ap4gtH6zgNc
         kIJuPh+AYaL6H20S0nDpKwgqmACxeL+KbIYCAUj6NU9k19TNxh8cEqjijqsr9QuBILRX
         As7EbGGb5Y98nHFRolhOBlU1AcPNU9b6bx3OHEtCedhYPaaAfXK4wDXogfk6ndeQrfwF
         v5Lxqg4Um4oX86pAyZgklJVIItejGTGZm+KBuxUSMswDdIyj/n6rvTOp5Dt4N3GhyO7k
         rgag==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXZBPwsNNPsF7MQd1AbtZ97Ns2LS7LUJT3tk1UHIbavwxl2INGY
	ST4HD9DXRu+1yTNyVq4vk2FKkHG3ef3cLtECDkYCUe6xT024lEwoIoFtm7Fl6TWOaIIVLeWcflR
	jLY3ypbFE5GH5DrHlLJzyXbwkxZvXIgUxYF2QRBSO0Jowx7tpaiScXtWewhZJ0tW56A==
X-Received: by 2002:a05:6830:153:: with SMTP id j19mr802375otp.368.1558955581881;
        Mon, 27 May 2019 04:13:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzSvKPtq+ry79Po3MRGB/8D3rw83sZtqyMOMMnUQEnAZe5TGD1MJ5cnsR+s4cFK2A4UxubM
X-Received: by 2002:a05:6830:153:: with SMTP id j19mr802347otp.368.1558955581247;
        Mon, 27 May 2019 04:13:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558955581; cv=none;
        d=google.com; s=arc-20160816;
        b=XDfJIn9fFAXxX5GkBWJTOVz+Xeb5150VNr1fyxrUby6b5gQZB7/L9v9Hwu7k9VkHcZ
         he5a0+YrD1TWuHoTVNbuw024z6ApJgL/TDCvNoyPBGTSHrt6pxt+DnKBRTwaDJ/dMOPm
         aq4Q/6njTMKWw0nSZnLuUUwXobJPthTqhWlEHD407qSeMXNRO7Yn37mhz6sZHpehQ3XB
         WgaQDPLTTcVHiC/Sx9jQwFduB+ok3em6f26biVIrjDf5UTEvfgV3lognzXszzo7LzoFq
         KPVER8/2V56y5jA3er+HmgjJVBeJ3pFLxeEICgZPWgmpwcZFrO451GxB91mniPcakUJC
         Hefw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=e5EF8dpMsbDDNCAATVA9f1rm/c9fnhfqkSCcpFKc4do=;
        b=eTZcjHW+JBCHnvaY0de5pOud0TnbxTco5ljQagblpEuWQaxl4/KRgcA0Z/1F7yZMQk
         J33CNnaDV8yG2OHztB5p/n4pnY1FIu5I5xdB1kjIbbvET8V/VQ3YEFxWqSorYGjTAFGo
         lzjLqMPO9R3CDQqdNDflDvaPseifT0wM3lofNtB1lpX4/PRY66HHWlaFxzNx1Ru6QfsL
         ztGR1cn43EbJJseIo0xDy/fJ45RNqTQ12+JHq6GNzNtZUAeCwaubvLNEVug5Y1TLKZUs
         UJeBE5bgSAENMD5d2MOKv4kG4MOnLy+Q3fWk/F3yyEEGZc8xc88njafScHHubJVQXUlC
         XkpQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r5si6029933ota.107.2019.05.27.04.13.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 04:13:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 61501C002966;
	Mon, 27 May 2019 11:13:00 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-89.ams2.redhat.com [10.36.117.89])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 7440F19C7F;
	Mon, 27 May 2019 11:12:55 +0000 (UTC)
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
	"mike.travis@hpe.com" <mike.travis@hpe.com>,
	Andrew Banman <andrew.banman@hpe.com>,
	Ingo Molnar <mingo@kernel.org>,
	Alex Deucher <alexander.deucher@amd.com>,
	"David S. Miller" <davem@davemloft.net>,
	Mark Brown <broonie@kernel.org>,
	Chris Wilson <chris@chris-wilson.co.uk>,
	Oscar Salvador <osalvador@suse.de>,
	Jonathan Cameron <Jonathan.Cameron@huawei.com>,
	Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pavel.tatashin@microsoft.com>,
	Arun KS <arunks@codeaurora.org>,
	Mathieu Malaterre <malat@debian.org>
Subject: [PATCH v3 09/11] mm/memory_hotplug: Remove memory block devices before arch_remove_memory()
Date: Mon, 27 May 2019 13:11:50 +0200
Message-Id: <20190527111152.16324-10-david@redhat.com>
In-Reply-To: <20190527111152.16324-1-david@redhat.com>
References: <20190527111152.16324-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Mon, 27 May 2019 11:13:00 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Let's factor out removing of memory block devices, which is only
necessary for memory added via add_memory() and friends that created
memory block devices. Remove the devices before calling
arch_remove_memory().

This finishes factoring out memory block device handling from
arch_add_memory() and arch_remove_memory().

Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: David Hildenbrand <david@redhat.com>
Cc: "mike.travis@hpe.com" <mike.travis@hpe.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrew Banman <andrew.banman@hpe.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Alex Deucher <alexander.deucher@amd.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Mark Brown <broonie@kernel.org>
Cc: Chris Wilson <chris@chris-wilson.co.uk>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Jonathan Cameron <Jonathan.Cameron@huawei.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Pavel Tatashin <pavel.tatashin@microsoft.com>
Cc: Arun KS <arunks@codeaurora.org>
Cc: Mathieu Malaterre <malat@debian.org>
Reviewed-by: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 drivers/base/memory.c  | 37 ++++++++++++++++++-------------------
 drivers/base/node.c    | 11 ++++++-----
 include/linux/memory.h |  2 +-
 include/linux/node.h   |  6 ++----
 mm/memory_hotplug.c    |  5 +++--
 5 files changed, 30 insertions(+), 31 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 5a0370f0c506..f28efb0bf5c7 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -763,32 +763,31 @@ int create_memory_block_devices(unsigned long start, unsigned long size)
 	return ret;
 }
 
-void unregister_memory_section(struct mem_section *section)
+/*
+ * Remove memory block devices for the given memory area. Start and size
+ * have to be aligned to memory block granularity. Memory block devices
+ * have to be offline.
+ */
+void remove_memory_block_devices(unsigned long start, unsigned long size)
 {
+	const int start_block_id = pfn_to_block_id(PFN_DOWN(start));
+	const int end_block_id = pfn_to_block_id(PFN_DOWN(start + size));
 	struct memory_block *mem;
+	int block_id;
 
-	if (WARN_ON_ONCE(!present_section(section)))
+	if (WARN_ON_ONCE(!IS_ALIGNED(start, memory_block_size_bytes()) ||
+			 !IS_ALIGNED(size, memory_block_size_bytes())))
 		return;
 
 	mutex_lock(&mem_sysfs_mutex);
-
-	/*
-	 * Some users of the memory hotplug do not want/need memblock to
-	 * track all sections. Skip over those.
-	 */
-	mem = find_memory_block(section);
-	if (!mem)
-		goto out_unlock;
-
-	unregister_mem_sect_under_nodes(mem, __section_nr(section));
-
-	mem->section_count--;
-	if (mem->section_count == 0)
+	for (block_id = start_block_id; block_id != end_block_id; block_id++) {
+		mem = find_memory_block_by_id(block_id, NULL);
+		if (WARN_ON_ONCE(!mem))
+			continue;
+		mem->section_count = 0;
+		unregister_memory_block_under_nodes(mem);
 		unregister_memory(mem);
-	else
-		put_device(&mem->dev);
-
-out_unlock:
+	}
 	mutex_unlock(&mem_sysfs_mutex);
 }
 
diff --git a/drivers/base/node.c b/drivers/base/node.c
index 8598fcbd2a17..04fdfa99b8bc 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -801,9 +801,10 @@ int register_mem_sect_under_node(struct memory_block *mem_blk, void *arg)
 	return 0;
 }
 
-/* unregister memory section under all nodes that it spans */
-int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
-				    unsigned long phys_index)
+/*
+ * Unregister memory block device under all nodes that it spans.
+ */
+int unregister_memory_block_under_nodes(struct memory_block *mem_blk)
 {
 	NODEMASK_ALLOC(nodemask_t, unlinked_nodes, GFP_KERNEL);
 	unsigned long pfn, sect_start_pfn, sect_end_pfn;
@@ -816,8 +817,8 @@ int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
 		return -ENOMEM;
 	nodes_clear(*unlinked_nodes);
 
-	sect_start_pfn = section_nr_to_pfn(phys_index);
-	sect_end_pfn = sect_start_pfn + PAGES_PER_SECTION - 1;
+	sect_start_pfn = section_nr_to_pfn(mem_blk->start_section_nr);
+	sect_end_pfn = section_nr_to_pfn(mem_blk->end_section_nr);
 	for (pfn = sect_start_pfn; pfn <= sect_end_pfn; pfn++) {
 		int nid;
 
diff --git a/include/linux/memory.h b/include/linux/memory.h
index db3e8567f900..f26a5417ec5d 100644
--- a/include/linux/memory.h
+++ b/include/linux/memory.h
@@ -112,7 +112,7 @@ extern void unregister_memory_notifier(struct notifier_block *nb);
 extern int register_memory_isolate_notifier(struct notifier_block *nb);
 extern void unregister_memory_isolate_notifier(struct notifier_block *nb);
 int create_memory_block_devices(unsigned long start, unsigned long size);
-extern void unregister_memory_section(struct mem_section *);
+void remove_memory_block_devices(unsigned long start, unsigned long size);
 extern int memory_dev_init(void);
 extern int memory_notify(unsigned long val, void *v);
 extern int memory_isolate_notify(unsigned long val, void *v);
diff --git a/include/linux/node.h b/include/linux/node.h
index 1a557c589ecb..02a29e71b175 100644
--- a/include/linux/node.h
+++ b/include/linux/node.h
@@ -139,8 +139,7 @@ extern int register_cpu_under_node(unsigned int cpu, unsigned int nid);
 extern int unregister_cpu_under_node(unsigned int cpu, unsigned int nid);
 extern int register_mem_sect_under_node(struct memory_block *mem_blk,
 						void *arg);
-extern int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
-					   unsigned long phys_index);
+extern int unregister_memory_block_under_nodes(struct memory_block *mem_blk);
 
 extern int register_memory_node_under_compute_node(unsigned int mem_nid,
 						   unsigned int cpu_nid,
@@ -176,8 +175,7 @@ static inline int register_mem_sect_under_node(struct memory_block *mem_blk,
 {
 	return 0;
 }
-static inline int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
-						  unsigned long phys_index)
+static inline int unregister_memory_block_under_nodes(struct memory_block *mem_blk)
 {
 	return 0;
 }
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 9a92549ef23b..82136c5b4c5f 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -520,8 +520,6 @@ static void __remove_section(struct zone *zone, struct mem_section *ms,
 	if (WARN_ON_ONCE(!valid_section(ms)))
 		return;
 
-	unregister_memory_section(ms);
-
 	scn_nr = __section_nr(ms);
 	start_pfn = section_nr_to_pfn((unsigned long)scn_nr);
 	__remove_zone(zone, start_pfn);
@@ -1845,6 +1843,9 @@ void __ref __remove_memory(int nid, u64 start, u64 size)
 	memblock_free(start, size);
 	memblock_remove(start, size);
 
+	/* remove memory block devices before removing memory */
+	remove_memory_block_devices(start, size);
+
 	arch_remove_memory(nid, start, size, NULL);
 	__release_memory_resource(start, size);
 
-- 
2.20.1

