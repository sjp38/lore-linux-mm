Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7FF5CC282CE
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 10:25:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2D50F218B0
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 10:25:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D50F218B0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C725E6B000D; Wed, 24 Apr 2019 06:25:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C21386B000E; Wed, 24 Apr 2019 06:25:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AE9506B0010; Wed, 24 Apr 2019 06:25:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8B8E26B000D
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 06:25:57 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id t67so10206549qkd.15
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 03:25:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=B1Kd+1vGze1HjX/yglunSURjRhlNiu1tUGyDV/OWBKI=;
        b=RJ/lzcTFWHAmlOtqIH9NKM4ME6teyc82TJyoq7H7+inoFCZSybt5eAO4nAsspWEhtC
         Zn7kEEfLsMynrJPCWjgrbvhTc+nmdcIq5m8l+bvGctI5NdFTKiXuP3UiqXUBy/bQIuAG
         CXQwJTajczGWPbLqgpyqccujmU2FnWVP0jTy+xWD9oEuFBApCEBbw4FXqiA7UIHEayjo
         gmXWCCRvg/nmzxAdv2WBHwTSBSMFHZ9rMb7dy0u4+Mh52CGvUp9tQbwjYekijPUpAeYB
         8Fy/0ZVZh/5mtUvQEfBWKxXeQENHGsYbM402lwqbrcN8OzH0QGHiw0w89j8G7b4RL5O5
         512A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVkgvjURa2ysc1F72802cOs7FCyjM8+9TEtBKNakp8yoU1tqKRu
	vr4ksajLb9zItqI9SFLcovgm9C5WlgSoCm7jNO6JpzvRhCFTP0TvNnr5qukH91EE+SbuQZ9ZCQ3
	NID0RwFWz8A4m0cxjsjxoE6Bv3K5cBY3dCFkcOroof89km1COVsCkv2Z0pkL8Ioal1Q==
X-Received: by 2002:ac8:2a51:: with SMTP id l17mr24943470qtl.76.1556101557304;
        Wed, 24 Apr 2019 03:25:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyTmBPm2rPlwzWygiy13iuU13fi9TUkzREZd4HBk4Rh0X0l7QkhVjEFaTxlO+T0+Qvm4G+y
X-Received: by 2002:ac8:2a51:: with SMTP id l17mr24943399qtl.76.1556101556066;
        Wed, 24 Apr 2019 03:25:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556101556; cv=none;
        d=google.com; s=arc-20160816;
        b=Q02zxo/cW8H7iKZqIvHZiUtRtSStN71zZzxwMdiIjet3CVISJ7gP7+ydMDn3qxM1XO
         3KsvbzSQnhtkOQDHE4v/T0sjTvoGkMghgbvZ1mbeM8GAQAaQpEksg3knCvt3dXsJThV5
         dfkH9eamnfmQeA+g/8JiWZRETRoR+84w7ljx9f89lvUFHK6ZD2Lk9sPl1mIuRQ/Hrw5z
         C0eo0FJLiEbf5875nD2VsV6nR1fVZiNEuZtSnG/FgU/cqSQwPcETfxwihvjTtSIYklE7
         IrEZG2fFHsQyO6Oioikgb7FBh+uULAPhOx+0y040Tc+y31/IluHf/MGcxEPxQph6qWJm
         30BQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=B1Kd+1vGze1HjX/yglunSURjRhlNiu1tUGyDV/OWBKI=;
        b=yas9/rQxtHkNlbxhVlsBHwdmB7UgDP4871/m0LCnoidqslFiVGVUmyKAUursYPluNX
         j4qmSfnAhe/EciGQ4Ig6gpTvbTb4SqZyU+LFZSwOiLn+SUzc0+qfSR8wofTBf9mAIs+a
         1RlNvo9AAo1v+DPYmZqajTzM0BomOSET8sKQsm9taliG0lVj70XcGcqqfFiJErmQP9/U
         rQ8gV0Ne2mtm6tigIs6TGDvrah7VcOwjpJm/UiPi0SjbUiBN4EhZ6WQUfe4wNmw5plFc
         WLEekrQmRJ4/uKT3kt80A5T8vL8DCY8UhC5sc7JFmFKqMqy/c9e7YT0kZtuz/DR6gge/
         gJOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 31si1681000qto.242.2019.04.24.03.25.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 03:25:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 21AB530A818B;
	Wed, 24 Apr 2019 10:25:55 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-116-45.ams2.redhat.com [10.36.116.45])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 5D0EA600C4;
	Wed, 24 Apr 2019 10:25:51 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	linux-ia64@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org,
	akpm@linux-foundation.org,
	Dan Williams <dan.j.williams@intel.com>,
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
	Wei Yang <richard.weiyang@gmail.com>,
	Arun KS <arunks@codeaurora.org>,
	Mathieu Malaterre <malat@debian.org>
Subject: [PATCH v1 4/7] mm/memory_hotplug: Create memory block devices after arch_add_memory()
Date: Wed, 24 Apr 2019 12:25:08 +0200
Message-Id: <20190424102511.29318-5-david@redhat.com>
In-Reply-To: <20190424102511.29318-1-david@redhat.com>
References: <20190424102511.29318-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Wed, 24 Apr 2019 10:25:55 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Only memory to be added to the buddy and to be onlined/offlined by
user space using memory block devices needs (and should have!) memory
block devices.

Factor out creation of memory block devices Create all devices after
arch_add_memory() succeeded. We can later drop the want_memblock parameter,
because it is now effectively stale.

Only after memory block devices have been added, memory can be onlined
by user space. This implies, that memory is not visible to user space at
all before arch_add_memory() succeeded.

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
 drivers/base/memory.c  | 70 ++++++++++++++++++++++++++----------------
 include/linux/memory.h |  2 +-
 mm/memory_hotplug.c    | 15 ++++-----
 3 files changed, 53 insertions(+), 34 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 6e0cb4fda179..862c202a18ca 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -701,44 +701,62 @@ static int add_memory_block(int base_section_nr)
 	return 0;
 }
 
+static void unregister_memory(struct memory_block *memory)
+{
+	BUG_ON(memory->dev.bus != &memory_subsys);
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
+int hotplug_memory_register(unsigned long start, unsigned long size)
 {
-	int ret = 0;
+	unsigned long block_nr_pages = memory_block_size_bytes() >> PAGE_SHIFT;
+	unsigned long start_pfn = PFN_DOWN(start);
+	unsigned long end_pfn = start_pfn + (size >> PAGE_SHIFT);
+	unsigned long pfn;
 	struct memory_block *mem;
+	int ret = 0;
 
-	mutex_lock(&mem_sysfs_mutex);
+	BUG_ON(!IS_ALIGNED(start, memory_block_size_bytes()));
+	BUG_ON(!IS_ALIGNED(size, memory_block_size_bytes()));
 
-	mem = find_memory_block(section);
-	if (mem) {
-		mem->section_count++;
-		put_device(&mem->dev);
-	} else {
-		ret = init_memory_block(&mem, section, MEM_OFFLINE);
+	mutex_lock(&mem_sysfs_mutex);
+	for (pfn = start_pfn; pfn != end_pfn; pfn += block_nr_pages) {
+		mem = find_memory_block(__pfn_to_section(pfn));
+		if (mem) {
+			WARN_ON_ONCE(false);
+			put_device(&mem->dev);
+			continue;
+		}
+		ret = init_memory_block(&mem, __pfn_to_section(pfn),
+					MEM_OFFLINE);
 		if (ret)
-			goto out;
-		mem->section_count++;
+			break;
+		mem->section_count = memory_block_size_bytes() /
+				     MIN_MEMORY_BLOCK_SIZE;
+	}
+	if (ret) {
+		end_pfn = pfn;
+		for (pfn = start_pfn; pfn != end_pfn; pfn += block_nr_pages) {
+			mem = find_memory_block(__pfn_to_section(pfn));
+			if (!mem)
+				continue;
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
-void unregister_memory_section(struct mem_section *section)
+static int remove_memory_section(struct mem_section *section)
 {
 	struct memory_block *mem;
 
diff --git a/include/linux/memory.h b/include/linux/memory.h
index 474c7c60c8f2..95505fbb5f85 100644
--- a/include/linux/memory.h
+++ b/include/linux/memory.h
@@ -111,7 +111,7 @@ extern int register_memory_notifier(struct notifier_block *nb);
 extern void unregister_memory_notifier(struct notifier_block *nb);
 extern int register_memory_isolate_notifier(struct notifier_block *nb);
 extern void unregister_memory_isolate_notifier(struct notifier_block *nb);
-int hotplug_memory_register(int nid, struct mem_section *section);
+int hotplug_memory_register(unsigned long start, unsigned long size);
 extern void unregister_memory_section(struct mem_section *);
 extern int memory_dev_init(void);
 extern int memory_notify(unsigned long val, void *v);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 7b5439839d67..e1637c8a0723 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -258,13 +258,7 @@ static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
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
@@ -1106,6 +1100,13 @@ int __ref add_memory_resource(int nid, struct resource *res)
 	if (ret < 0)
 		goto error;
 
+	/* create memory block devices after memory was added */
+	ret = hotplug_memory_register(start, size);
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

