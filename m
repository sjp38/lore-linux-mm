Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E8C4FC43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 18:32:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B368320675
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 18:32:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B368320675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4C5406B0008; Thu, 20 Jun 2019 14:32:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 49B828E0003; Thu, 20 Jun 2019 14:32:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 389C38E0002; Thu, 20 Jun 2019 14:32:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 150376B0008
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 14:32:33 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id n190so4818492qkd.5
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 11:32:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=xosbEIjLFiGE08Kfhn6doMeJLReGW2/GZVrriI9jhUA=;
        b=jtbm2N7gIiTCg5Pw8Try/e9q98Xgi5VBj39gd069GoT7e6L2NgBo1POyt+munqfoFC
         ozBL6yui5brYP0M4UbGnjZdtdvTSQPy/2Rd6/ys8UGgWzrIgKvVGVBxK4UrqVHe1+hJ0
         DjV0/bO5DGe2q76SWtOKTdGIBUKRisxW0k/HpqkPcWKjW0K7zZJjVhi96aw57KkKwDUR
         b6C9KP0LJsf2KhGWUr8/tw/+jWG/8coLCj5jFOu2fP2uMkStdfSnQ6jBX0yGUAd3Puwy
         +N9oWR4aNP2UCPPHv1tcyIMQhDUao4q4xPMDAzCbddQxQffbGPBXO9fNguVn3ACCnHjL
         DoXA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX+ErGuDUGIM262fyGZjU9M1JPEtboEwobSKD4VHQjTD1CYS2V8
	7CZif/JtVVt8jozqjZ3mrtfHMwWMNkRkXtyUUCVrPS9dKUZVdAHXjSp33EwyuSSG8itamLHPpBZ
	8EI/P0njStb4t9lJ9+JlqMC1WYLjkIctwa7flzl+Pj7mW1H/HKUv2C9Dnq1kq7muHXg==
X-Received: by 2002:ae9:e887:: with SMTP id a129mr13284393qkg.347.1561055552823;
        Thu, 20 Jun 2019 11:32:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyfR6iW1TkylbJeQoyDaByD8/3egF9lbtWXrBLTaDlcCy9OtJ5meMO17e4xi7d1yuGy8scM
X-Received: by 2002:ae9:e887:: with SMTP id a129mr13284308qkg.347.1561055551829;
        Thu, 20 Jun 2019 11:32:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561055551; cv=none;
        d=google.com; s=arc-20160816;
        b=wD6iyXGZzvt238aWDhgolwkFduqEDGcpWQLs5Hz97iWtZWaTYhata2H92QyT5dbVCJ
         SAt0OwNA3JZuJlF+tq+oInO7mU3l/9jXIbadbLsFu5LxXR6rdFVp6p/khREpQF+ZnzVq
         gVJBVdsw2p+n2vgstodsWRN03OkJowuKUf/8ZhYfdtKYSLWSPmnAejzzFtdfAbwiTtQq
         t/GjxmcPPm5SoqL3JB0EQQPRjRtrtSB4q97ZbBMeT8uhbgtid5xvYdaq8Z6D05q/oqXe
         wkxtk0as0sgwfriAih+jATx3efS1Rua5BEtXWVatmT6s45kgdCrjZKmWhh3X2Gg131LD
         iCdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=xosbEIjLFiGE08Kfhn6doMeJLReGW2/GZVrriI9jhUA=;
        b=dUre4+fWpbiOMlzHyu98bZPyFQ0JPPq/KmlHEtf4uZIV2/Ua8Rg7T2aWzn/quBmyki
         DFNNyJk42WCOcZbGBjEEGjQr0j25/YFaGWB2pQ0ViwBNnblaZgkFcKB71qchv4zVovXu
         uciJEge16yf+k3DbLRildaHlI8aKaLLxws5eqo6qKQI6XiPWW4JEnqWWIiVgAuaRIQaU
         Fl6/3JfRLgIK6BUhmoNKqimBTTUt23i54GF4j1pOJNyqabKdwM6DsvVs2WUmsSb4FpFg
         FlfIN02mrjSiOeS0Vjhwz44pb4ABEBYNY1JQYe1dYUqUs68ONSOtHzuogNIcoq7n57Dk
         U68Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l28si260041qtc.376.2019.06.20.11.32.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 11:32:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A07DD3092667;
	Thu, 20 Jun 2019 18:32:25 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-116-71.ams2.redhat.com [10.36.116.71])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 3FEDF19C4F;
	Thu, 20 Jun 2019 18:32:21 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: Dan Williams <dan.j.williams@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linuxppc-dev@lists.ozlabs.org,
	linux-acpi@vger.kernel.org,
	linux-mm@kvack.org,
	David Hildenbrand <david@redhat.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Andrew Banman <andrew.banman@hpe.com>,
	"mike.travis@hpe.com" <mike.travis@hpe.com>,
	Oscar Salvador <osalvador@suse.com>,
	Michal Hocko <mhocko@suse.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Arun KS <arunks@codeaurora.org>,
	Qian Cai <cai@lca.pw>
Subject: [PATCH v3 5/6] mm/memory_hotplug: Move and simplify walk_memory_blocks()
Date: Thu, 20 Jun 2019 20:31:38 +0200
Message-Id: <20190620183139.4352-6-david@redhat.com>
In-Reply-To: <20190620183139.4352-1-david@redhat.com>
References: <20190620183139.4352-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Thu, 20 Jun 2019 18:32:26 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Let's move walk_memory_blocks() to the place where memory block logic
resides and simplify it. While at it, add a type for the callback function.

Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: David Hildenbrand <david@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Andrew Banman <andrew.banman@hpe.com>
Cc: "mike.travis@hpe.com" <mike.travis@hpe.com>
Cc: Oscar Salvador <osalvador@suse.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Wei Yang <richard.weiyang@gmail.com>
Cc: Arun KS <arunks@codeaurora.org>
Cc: Qian Cai <cai@lca.pw>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 drivers/base/memory.c          | 42 ++++++++++++++++++++++++++
 include/linux/memory.h         |  3 ++
 include/linux/memory_hotplug.h |  2 --
 mm/memory_hotplug.c            | 55 ----------------------------------
 4 files changed, 45 insertions(+), 57 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index c54e80fd25a8..0204384b4d1d 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -44,6 +44,11 @@ static inline unsigned long pfn_to_block_id(unsigned long pfn)
 	return base_memory_block_id(pfn_to_section_nr(pfn));
 }
 
+static inline unsigned long phys_to_block_id(unsigned long phys)
+{
+	return pfn_to_block_id(PFN_DOWN(phys));
+}
+
 static int memory_subsys_online(struct device *dev);
 static int memory_subsys_offline(struct device *dev);
 
@@ -851,3 +856,40 @@ int __init memory_dev_init(void)
 		printk(KERN_ERR "%s() failed: %d\n", __func__, ret);
 	return ret;
 }
+
+/**
+ * walk_memory_blocks - walk through all present memory blocks overlapped
+ *			by the range [start, start + size)
+ *
+ * @start: start address of the memory range
+ * @size: size of the memory range
+ * @arg: argument passed to func
+ * @func: callback for each memory section walked
+ *
+ * This function walks through all present memory blocks overlapped by the
+ * range [start, start + size), calling func on each memory block.
+ *
+ * In case func() returns an error, walking is aborted and the error is
+ * returned.
+ */
+int walk_memory_blocks(unsigned long start, unsigned long size,
+		       void *arg, walk_memory_blocks_func_t func)
+{
+	const unsigned long start_block_id = phys_to_block_id(start);
+	const unsigned long end_block_id = phys_to_block_id(start + size - 1);
+	struct memory_block *mem;
+	unsigned long block_id;
+	int ret = 0;
+
+	for (block_id = start_block_id; block_id <= end_block_id; block_id++) {
+		mem = find_memory_block_by_id(block_id, NULL);
+		if (!mem)
+			continue;
+
+		ret = func(mem, arg);
+		put_device(&mem->dev);
+		if (ret)
+			break;
+	}
+	return ret;
+}
diff --git a/include/linux/memory.h b/include/linux/memory.h
index f26a5417ec5d..b3b388775a30 100644
--- a/include/linux/memory.h
+++ b/include/linux/memory.h
@@ -119,6 +119,9 @@ extern int memory_isolate_notify(unsigned long val, void *v);
 extern struct memory_block *find_memory_block_hinted(struct mem_section *,
 							struct memory_block *);
 extern struct memory_block *find_memory_block(struct mem_section *);
+typedef int (*walk_memory_blocks_func_t)(struct memory_block *, void *);
+extern int walk_memory_blocks(unsigned long start, unsigned long size,
+			      void *arg, walk_memory_blocks_func_t func);
 #define CONFIG_MEM_BLOCK_SIZE	(PAGES_PER_SECTION<<PAGE_SHIFT)
 #endif /* CONFIG_MEMORY_HOTPLUG_SPARSE */
 
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index d9fffc34949f..475aff8efbf8 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -340,8 +340,6 @@ static inline void __remove_memory(int nid, u64 start, u64 size) {}
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
 extern void __ref free_area_init_core_hotplug(int nid);
-extern int walk_memory_blocks(unsigned long start, unsigned long size,
-		void *arg, int (*func)(struct memory_block *, void *));
 extern int __add_memory(int nid, u64 start, u64 size);
 extern int add_memory(int nid, u64 start, u64 size);
 extern int add_memory_resource(int nid, struct resource *resource);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 122a7d31efdd..fc558e9ff939 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1661,62 +1661,7 @@ int offline_pages(unsigned long start_pfn, unsigned long nr_pages)
 {
 	return __offline_pages(start_pfn, start_pfn + nr_pages);
 }
-#endif /* CONFIG_MEMORY_HOTREMOVE */
 
-/**
- * walk_memory_blocks - walk through all present memory blocks overlapped
- *			by the range [start, start + size)
- *
- * @start: start address of the memory range
- * @size: size of the memory range
- * @arg: argument passed to func
- * @func: callback for each memory block walked
- *
- * This function walks through all present memory blocks overlapped by the
- * range [start, start + size), calling func on each memory block.
- *
- * Returns the return value of func.
- */
-int walk_memory_blocks(unsigned long start, unsigned long size,
-		void *arg, int (*func)(struct memory_block *, void *))
-{
-	const unsigned long start_pfn = PFN_DOWN(start);
-	const unsigned long end_pfn = PFN_UP(start + size - 1);
-	struct memory_block *mem = NULL;
-	struct mem_section *section;
-	unsigned long pfn, section_nr;
-	int ret;
-
-	for (pfn = start_pfn; pfn < end_pfn; pfn += PAGES_PER_SECTION) {
-		section_nr = pfn_to_section_nr(pfn);
-		if (!present_section_nr(section_nr))
-			continue;
-
-		section = __nr_to_section(section_nr);
-		/* same memblock? */
-		if (mem)
-			if ((section_nr >= mem->start_section_nr) &&
-			    (section_nr <= mem->end_section_nr))
-				continue;
-
-		mem = find_memory_block_hinted(section, mem);
-		if (!mem)
-			continue;
-
-		ret = func(mem, arg);
-		if (ret) {
-			kobject_put(&mem->dev.kobj);
-			return ret;
-		}
-	}
-
-	if (mem)
-		kobject_put(&mem->dev.kobj);
-
-	return 0;
-}
-
-#ifdef CONFIG_MEMORY_HOTREMOVE
 static int check_memblock_offlined_cb(struct memory_block *mem, void *arg)
 {
 	int ret = !is_memblock_offlined(mem);
-- 
2.21.0

