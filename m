Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 838BEC07542
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 11:12:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3A8BE2146F
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 11:12:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3A8BE2146F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D292D6B027A; Mon, 27 May 2019 07:12:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D00666B027B; Mon, 27 May 2019 07:12:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C15C86B027C; Mon, 27 May 2019 07:12:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 985B16B027A
	for <linux-mm@kvack.org>; Mon, 27 May 2019 07:12:53 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id x7so3543470oic.16
        for <linux-mm@kvack.org>; Mon, 27 May 2019 04:12:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=+dZlDd1tAev3dLme2rjfCh5W1xubYN61UESP9inHmTk=;
        b=kghC06VAAGfDXOC7FQtwj/VM27cOI+5A2BJkB4kcbzPFvrBnPVloYC1mxVMMg6HgJ0
         ilmxDxtG+7v2j+MXTpNP5OybpPnJjhtSiGQ6pF1Sgmkq4l7mFJA2WoBdLsNFWEzIeaJ0
         Sxqtcq2/ykXU+3vrSO9VYuv7PTH+CLkzrlwAmQnbgFdBnE1nGDDEFl3h930oCMTjALzD
         4DwgV0Z1EBnxsFNsAHu3u+Tea8grY7Ka5NlMgPJP0q9x8MbINPG7eunun67HK81D4LIv
         7U8pjwN9d919CJaJkwZT9cvvYEKjjyRR920cxAOjlLkLhlhM4UOP2Zud9pD60kqbKByd
         WnvA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXzuDQvgo3PDyhXulE1ue4VjsNec3SoRTePtvs1nSjjx/Lh2v+F
	t4w7K8fgwpi/zXZlDifbwMXrVu4dADO7wBtIgzy8lk6THZf/KxmcIyZMJGZapJDw10/iTXneT8l
	EEBXnwHv+rZmsUXZDsXg7kEt9xBo0XWJTcL4nhcSGec029/d72NWR2mk4EtQXS3QFig==
X-Received: by 2002:a9d:7cc3:: with SMTP id r3mr28319181otn.256.1558955573320;
        Mon, 27 May 2019 04:12:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyx+YFyIJ6WSPKRdkF4xYWkAG4t+MguDeTDmIU6yWy/x3DWsWA7xR8xYm56wqdG6HpE0hyp
X-Received: by 2002:a9d:7cc3:: with SMTP id r3mr28319114otn.256.1558955572081;
        Mon, 27 May 2019 04:12:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558955572; cv=none;
        d=google.com; s=arc-20160816;
        b=IHGY1ZbwbvDNeO3NH6innUiS8up7O2xQZYQjn8xD8Ph/oTBPNGrcc7EqsmkS/SzlAr
         DZcbbwlVVR40BkbCjtFd31KNbId/RVGWoAqtAPI5nb8X2mPh9C2oHFYl9F9ZLcN4EjpU
         NuHXhuZ47okBzsLsKfuHTqhN+av7uZs8QeYAkbUlP3pQJecHxb5V0QIt6ri5nZLgI0Rk
         zZeO+Fl2OLt+6rjLiLfn6sMw62UHQUUUNEl/7qaBlFDmxFcvt5brVFzguun6bYu9+j0i
         qmNxj92gkqGUAVPzHWEifCwpL7SwCLz6carDRNWFL26YNEp4p3prF2S+GHjuKgDPfZGS
         F2Vw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=+dZlDd1tAev3dLme2rjfCh5W1xubYN61UESP9inHmTk=;
        b=IDP+AP3qUWpbNlI0lGvkVj0bHA6KOIGjD8MQr/55cU+urqrzH6fEfEN12yCXohuoYh
         u5vStwu8GCc1XLd+11B7m9HIa0Us95pugKB4PzkoYv2PrL5BtmP26D0od5A0BMMr3ttR
         7zLQdb8M1UHpzF4b4f43MtDqGFd+khZ5OMDzEV0xQCB+OlAct+Vrpot+4OeH35B0GxnN
         kebbO7TED7TblrzbFmoVB6FwU/TqC8yO/tMzUA1l1W0VGVrRWGeTgi/wdmpvFjj4+eYV
         YSHSEUB9w/rpocAopP+FXQIKLIk9Tjzl7nVAoqZhZ90IGA/bEZulxvzeGKix4JbQ4CeN
         lxcw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c127si5767572oib.127.2019.05.27.04.12.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 04:12:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 48FDA3086214;
	Mon, 27 May 2019 11:12:51 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-89.ams2.redhat.com [10.36.117.89])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 3CE8B19C7F;
	Mon, 27 May 2019 11:12:43 +0000 (UTC)
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
	Ingo Molnar <mingo@kernel.org>,
	Andrew Banman <andrew.banman@hpe.com>,
	Oscar Salvador <osalvador@suse.de>,
	Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Qian Cai <cai@lca.pw>,
	Arun KS <arunks@codeaurora.org>,
	Mathieu Malaterre <malat@debian.org>
Subject: [PATCH v3 07/11] mm/memory_hotplug: Create memory block devices after arch_add_memory()
Date: Mon, 27 May 2019 13:11:48 +0200
Message-Id: <20190527111152.16324-8-david@redhat.com>
In-Reply-To: <20190527111152.16324-1-david@redhat.com>
References: <20190527111152.16324-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Mon, 27 May 2019 11:12:51 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Only memory to be added to the buddy and to be onlined/offlined by
user space using /sys/devices/system/memory/... needs (and should have!)
memory block devices.

Factor out creation of memory block devices. Create all devices after
arch_add_memory() succeeded. We can later drop the want_memblock parameter,
because it is now effectively stale.

Only after memory block devices have been added, memory can be onlined
by user space. This implies, that memory is not visible to user space at
all before arch_add_memory() succeeded.

While at it
- use WARN_ON_ONCE instead of BUG_ON in moved unregister_memory()
- introduce find_memory_block_by_id() to search via block id
- Use find_memory_block_by_id() in init_memory_block() to catch
  duplicates

Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: David Hildenbrand <david@redhat.com>
Cc: "mike.travis@hpe.com" <mike.travis@hpe.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Andrew Banman <andrew.banman@hpe.com>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Qian Cai <cai@lca.pw>
Cc: Wei Yang <richard.weiyang@gmail.com>
Cc: Arun KS <arunks@codeaurora.org>
Cc: Mathieu Malaterre <malat@debian.org>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 drivers/base/memory.c  | 82 +++++++++++++++++++++++++++---------------
 include/linux/memory.h |  2 +-
 mm/memory_hotplug.c    | 15 ++++----
 3 files changed, 63 insertions(+), 36 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index ac17c95a5f28..5a0370f0c506 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -39,6 +39,11 @@ static inline int base_memory_block_id(int section_nr)
 	return section_nr / sections_per_block;
 }
 
+static inline int pfn_to_block_id(unsigned long pfn)
+{
+	return base_memory_block_id(pfn_to_section_nr(pfn));
+}
+
 static int memory_subsys_online(struct device *dev);
 static int memory_subsys_offline(struct device *dev);
 
@@ -582,10 +587,9 @@ int __weak arch_get_memory_phys_device(unsigned long start_pfn)
  * A reference for the returned object is held and the reference for the
  * hinted object is released.
  */
-struct memory_block *find_memory_block_hinted(struct mem_section *section,
-					      struct memory_block *hint)
+static struct memory_block *find_memory_block_by_id(int block_id,
+						    struct memory_block *hint)
 {
-	int block_id = base_memory_block_id(__section_nr(section));
 	struct device *hintdev = hint ? &hint->dev : NULL;
 	struct device *dev;
 
@@ -597,6 +601,14 @@ struct memory_block *find_memory_block_hinted(struct mem_section *section,
 	return to_memory_block(dev);
 }
 
+struct memory_block *find_memory_block_hinted(struct mem_section *section,
+					      struct memory_block *hint)
+{
+	int block_id = base_memory_block_id(__section_nr(section));
+
+	return find_memory_block_by_id(block_id, hint);
+}
+
 /*
  * For now, we have a linear search to go find the appropriate
  * memory_block corresponding to a particular phys_index. If
@@ -658,6 +670,11 @@ static int init_memory_block(struct memory_block **memory, int block_id,
 	unsigned long start_pfn;
 	int ret = 0;
 
+	mem = find_memory_block_by_id(block_id, NULL);
+	if (mem) {
+		put_device(&mem->dev);
+		return -EEXIST;
+	}
 	mem = kzalloc(sizeof(*mem), GFP_KERNEL);
 	if (!mem)
 		return -ENOMEM;
@@ -699,44 +716,53 @@ static int add_memory_block(int base_section_nr)
 	return 0;
 }
 
+static void unregister_memory(struct memory_block *memory)
+{
+	if (WARN_ON_ONCE(memory->dev.bus != &memory_subsys))
+		return;
+
+	/* drop the ref. we got via find_memory_block() */
+	put_device(&memory->dev);
+	device_unregister(&memory->dev);
+}
+
 /*
- * need an interface for the VM to add new memory regions,
- * but without onlining it.
+ * Create memory block devices for the given memory area. Start and size
+ * have to be aligned to memory block granularity. Memory block devices
+ * will be initialized as offline.
  */
-int hotplug_memory_register(int nid, struct mem_section *section)
+int create_memory_block_devices(unsigned long start, unsigned long size)
 {
-	int block_id = base_memory_block_id(__section_nr(section));
-	int ret = 0;
+	const int start_block_id = pfn_to_block_id(PFN_DOWN(start));
+	int end_block_id = pfn_to_block_id(PFN_DOWN(start + size));
 	struct memory_block *mem;
+	unsigned long block_id;
+	int ret = 0;
 
-	mutex_lock(&mem_sysfs_mutex);
+	if (WARN_ON_ONCE(!IS_ALIGNED(start, memory_block_size_bytes()) ||
+			 !IS_ALIGNED(size, memory_block_size_bytes())))
+		return -EINVAL;
 
-	mem = find_memory_block(section);
-	if (mem) {
-		mem->section_count++;
-		put_device(&mem->dev);
-	} else {
+	mutex_lock(&mem_sysfs_mutex);
+	for (block_id = start_block_id; block_id != end_block_id; block_id++) {
 		ret = init_memory_block(&mem, block_id, MEM_OFFLINE);
 		if (ret)
-			goto out;
-		mem->section_count++;
+			break;
+		mem->section_count = sections_per_block;
+	}
+	if (ret) {
+		end_block_id = block_id;
+		for (block_id = start_block_id; block_id != end_block_id;
+		     block_id++) {
+			mem = find_memory_block_by_id(block_id, NULL);
+			mem->section_count = 0;
+			unregister_memory(mem);
+		}
 	}
-
-out:
 	mutex_unlock(&mem_sysfs_mutex);
 	return ret;
 }
 
-static void
-unregister_memory(struct memory_block *memory)
-{
-	BUG_ON(memory->dev.bus != &memory_subsys);
-
-	/* drop the ref. we got via find_memory_block() */
-	put_device(&memory->dev);
-	device_unregister(&memory->dev);
-}
-
 void unregister_memory_section(struct mem_section *section)
 {
 	struct memory_block *mem;
diff --git a/include/linux/memory.h b/include/linux/memory.h
index 474c7c60c8f2..db3e8567f900 100644
--- a/include/linux/memory.h
+++ b/include/linux/memory.h
@@ -111,7 +111,7 @@ extern int register_memory_notifier(struct notifier_block *nb);
 extern void unregister_memory_notifier(struct notifier_block *nb);
 extern int register_memory_isolate_notifier(struct notifier_block *nb);
 extern void unregister_memory_isolate_notifier(struct notifier_block *nb);
-int hotplug_memory_register(int nid, struct mem_section *section);
+int create_memory_block_devices(unsigned long start, unsigned long size);
 extern void unregister_memory_section(struct mem_section *);
 extern int memory_dev_init(void);
 extern int memory_notify(unsigned long val, void *v);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 4b9d2974f86c..b1fde90bbf19 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -259,13 +259,7 @@ static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
 		return -EEXIST;
 
 	ret = sparse_add_one_section(nid, phys_start_pfn, altmap);
-	if (ret < 0)
-		return ret;
-
-	if (!want_memblock)
-		return 0;
-
-	return hotplug_memory_register(nid, __pfn_to_section(phys_start_pfn));
+	return ret < 0 ? ret : 0;
 }
 
 /*
@@ -1107,6 +1101,13 @@ int __ref add_memory_resource(int nid, struct resource *res)
 	if (ret < 0)
 		goto error;
 
+	/* create memory block devices after memory was added */
+	ret = create_memory_block_devices(start, size);
+	if (ret) {
+		arch_remove_memory(nid, start, size, NULL);
+		goto error;
+	}
+
 	if (new_node) {
 		/* If sysfs file of new node can't be created, cpu on the node
 		 * can't be hot-added. There is no rollback way now.
-- 
2.20.1

