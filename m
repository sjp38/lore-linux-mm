Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8965CC282CE
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 10:12:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 37517208E3
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 10:12:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 37517208E3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D4D3A6B000A; Mon,  8 Apr 2019 06:12:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CFFE46B000C; Mon,  8 Apr 2019 06:12:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C12BA6B000D; Mon,  8 Apr 2019 06:12:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id A0D706B000A
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 06:12:49 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id h51so12104059qte.22
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 03:12:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=UYg4CDkqgf6qeILbS9c0D6NNoCDwZYVQCNp1g8vFy0k=;
        b=CdiZSVvGgh4Ou6pNyWx9RWtdZPI/8+BVGPZbtYGWMf9U/snpmcA/hcL8MpliYj7Ntg
         ixLt1fVqlzb01TFaCPadvFRGf0jh2DHcVO2IKoRCKkKd1rGEufNv44/qjGm3Ngrqexy9
         fauhyKhRPIDFBSYfvM6VoGjo9N99Y+yGaIieadqEbG6ZpeZuPrT09M9MK5rrZB8KMEUh
         s846+34d8DU0lfixG2i51pu+cruuOXEKQKCMfxmXLEsiSs1EJiroDvzVgtBDSav+ql20
         S/QB18DD2r0+5eoYlRiSqTeJYt5gTgYhiwW1O+54wFpalRGaUBeeT49YPZ7W+KGwD6qG
         DD+g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWdjoxC/4LHxCQUaPZ8BED4+xHYktn0T3fjVLwl077IYbOqQv0K
	oFy5qvXKyp65HMrQ6U6G2IT+/CLBcsoF/B3/1UvWHuGLyNgBIrYNIY1B2WQJYqHpfHLeURsdmeS
	Ahb23Px5sPWkEmFXQ0xQ1aavuUy+asJ0v70XGuDOgv9ldrRHTKFRJuc8szlvAFisPjA==
X-Received: by 2002:a0c:8864:: with SMTP id 33mr23088334qvm.155.1554718369424;
        Mon, 08 Apr 2019 03:12:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwRxBn3JcrG1G7UvPp392hWWB6MZ2jG8HL5MtZWPkc6msfRHCg2/gK4NnqYkWSVXFNtKZHI
X-Received: by 2002:a0c:8864:: with SMTP id 33mr23088209qvm.155.1554718366842;
        Mon, 08 Apr 2019 03:12:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554718366; cv=none;
        d=google.com; s=arc-20160816;
        b=MFrmpuan5D5nQqIufjN0X+SNjSOUnLboCwGsB8/pTXuNvGZi1JmLQSpbzVQ3qmXMiv
         vZBBdH0rWrm1xrGy25kudQdRI49YQ6FokyFtDO3qoHs/ZgBOZvzB8474vhZRZrK8xVAw
         s+V0wuM9pzH/gDVGZNwn2cjDKTQrxZaWZSb06Qa0elaI8VUFOs/AJnWaFhnoL/nMYlHQ
         dxqcPBbuDt3ONXbNRYKuwLnIUbVk7MzEZJTFGyOm8LEF03onUItRrLqJ08adlRrTN8Uv
         ZOWkLEt1ozgh0kzT6ixcoKISGQj5CVMrXH3liWHJHuwmZZuii1KTtfr++h71QBfCEFG+
         3zuw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=UYg4CDkqgf6qeILbS9c0D6NNoCDwZYVQCNp1g8vFy0k=;
        b=XN4XUcZeVVrFSgjOBTEPeM0xDhDp2i7Q/Pvm38PjYrBr95kc+2g5QK5qSTLmj96xfZ
         4oJohKFqXqX/0yaFYAgHia1sPOPZjgJVUpuopcOw+GAIuh/Qi0QUVu9a6Uejq5gs6N8c
         iwdtJLEApJY8QRmtA6lHHGb2iWJ5OonI8Qh4lwb9xNYxXAZIbiuSNsxFebLAzbfWBvUy
         PWbggprUkIdtOWDfqgKSYe63sO2ag6Ce4DK0CqAtsHESrDrTzcszWTxplk5IYs0SuIQ6
         zBqV4IOb9W+lF0dRDipTmeSrwtRA2e5zSnHqeTdwk02JXI/F9EfaIpSiwlYGHgKvyleM
         rpgg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u37si3136709qtb.220.2019.04.08.03.12.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Apr 2019 03:12:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id DE5BC88AAD;
	Mon,  8 Apr 2019 10:12:45 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-53.ams2.redhat.com [10.36.117.53])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 980FD1A90F;
	Mon,  8 Apr 2019 10:12:42 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J . Wysocki" <rafael@kernel.org>,
	Ingo Molnar <mingo@kernel.org>,
	Andrew Banman <andrew.banman@hpe.com>,
	mike.travis@hpe.com,
	Jonathan Cameron <Jonathan.Cameron@huawei.com>,
	Oscar Salvador <osalvador@suse.de>,
	Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pavel.tatashin@microsoft.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Qian Cai <cai@lca.pw>,
	Arun KS <arunks@codeaurora.org>,
	Mathieu Malaterre <malat@debian.org>,
	linux-mm@kvack.org,
	dan.j.williams@intel.com,
	David Hildenbrand <david@redhat.com>
Subject: [PATCH RFC 3/3] mm/memory_hotplug: Remove memory block devices before arch_remove_memory()
Date: Mon,  8 Apr 2019 12:12:26 +0200
Message-Id: <20190408101226.20976-4-david@redhat.com>
In-Reply-To: <20190408101226.20976-1-david@redhat.com>
References: <20190408101226.20976-1-david@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Mon, 08 Apr 2019 10:12:46 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Let's factor out removing of memory block devices, which is only
necessary for memory added via add_memory() and friends that created
memory block devices. Remove the devices before calling
arch_remove_memory().

TODO: We should try to get rid of the errors that could be reported by
unregister_memory_block_under_nodes(). Ignoring failures is not that
nice.

Signed-off-by: David Hildenbrand <david@redhat.com>
---
 drivers/base/memory.c  | 41 +++++++++++++++--------------------------
 drivers/base/node.c    |  7 +++----
 include/linux/memory.h |  2 +-
 include/linux/node.h   |  6 ++----
 mm/memory_hotplug.c    | 10 ++++------
 5 files changed, 25 insertions(+), 41 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 847b33061e2e..fd8940c37129 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -752,40 +752,29 @@ int hotplug_memory_register(unsigned long start, unsigned long size)
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
-static int remove_memory_section(struct mem_section *section)
+void hotplug_memory_unregister(unsigned long start, unsigned long size)
 {
+	unsigned long block_nr_pages = memory_block_size_bytes() >> PAGE_SHIFT;
+	unsigned long start_pfn = PFN_DOWN(start);
+	unsigned long end_pfn = start_pfn + (size >> PAGE_SHIFT);
 	struct memory_block *mem;
+	unsigned long pfn;
 
-	mutex_lock(&mem_sysfs_mutex);
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
+	BUG_ON(!IS_ALIGNED(start, memory_block_size_bytes()));
+	BUG_ON(!IS_ALIGNED(size, memory_block_size_bytes()));
 
-	mem->section_count--;
-	if (mem->section_count == 0)
+	mutex_lock(&mem_sysfs_mutex);
+	for (pfn = start_pfn; pfn != end_pfn; pfn += block_nr_pages) {
+		mem = find_memory_block(__pfn_to_section(pfn));
+		if (!mem)
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
-	return 0;
 }
 
-int unregister_memory_section(struct mem_section *section)
-{
-	if (!present_section(section))
-		return -EINVAL;
-
-	return remove_memory_section(section);
-}
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
 /* return true if the memory block is offlined, otherwise, return false */
diff --git a/drivers/base/node.c b/drivers/base/node.c
index 8598fcbd2a17..f9997770ac15 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -802,8 +802,7 @@ int register_mem_sect_under_node(struct memory_block *mem_blk, void *arg)
 }
 
 /* unregister memory section under all nodes that it spans */
-int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
-				    unsigned long phys_index)
+int unregister_memory_block_under_nodes(struct memory_block *mem_blk)
 {
 	NODEMASK_ALLOC(nodemask_t, unlinked_nodes, GFP_KERNEL);
 	unsigned long pfn, sect_start_pfn, sect_end_pfn;
@@ -816,8 +815,8 @@ int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
 		return -ENOMEM;
 	nodes_clear(*unlinked_nodes);
 
-	sect_start_pfn = section_nr_to_pfn(phys_index);
-	sect_end_pfn = sect_start_pfn + PAGES_PER_SECTION - 1;
+	sect_start_pfn = section_nr_to_pfn(mem_blk->start_section_nr);
+	sect_end_pfn = section_nr_to_pfn(mem_blk->end_section_nr);
 	for (pfn = sect_start_pfn; pfn <= sect_end_pfn; pfn++) {
 		int nid;
 
diff --git a/include/linux/memory.h b/include/linux/memory.h
index e275dc775834..414e43ab0881 100644
--- a/include/linux/memory.h
+++ b/include/linux/memory.h
@@ -113,7 +113,7 @@ extern int register_memory_isolate_notifier(struct notifier_block *nb);
 extern void unregister_memory_isolate_notifier(struct notifier_block *nb);
 int hotplug_memory_register(unsigned long start, unsigned long size);
 #ifdef CONFIG_MEMORY_HOTREMOVE
-extern int unregister_memory_section(struct mem_section *);
+void hotplug_memory_unregister(unsigned long start, unsigned long size);
 #endif
 extern int memory_dev_init(void);
 extern int memory_notify(unsigned long val, void *v);
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
index 13ee0a26e034..041b93c5eede 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -518,14 +518,9 @@ static int __remove_section(struct zone *zone, struct mem_section *ms,
 {
 	unsigned long start_pfn;
 	int scn_nr;
-	int ret = -EINVAL;
 
 	if (!valid_section(ms))
-		return ret;
-
-	ret = unregister_memory_section(ms);
-	if (ret)
-		return ret;
+		return -EINVAL;
 
 	scn_nr = __section_nr(ms);
 	start_pfn = section_nr_to_pfn((unsigned long)scn_nr);
@@ -1875,6 +1870,9 @@ void __ref __remove_memory(int nid, u64 start, u64 size)
 	memblock_free(start, size);
 	memblock_remove(start, size);
 
+	/* remove memory block devices before removing memory */
+	hotplug_memory_unregister(start, size);
+
 	arch_remove_memory(nid, start, size, NULL);
 
 	try_offline_node(nid);
-- 
2.17.2

