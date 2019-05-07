Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED585C04AAD
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 18:38:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A3C00206BF
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 18:38:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A3C00206BF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 76C696B000A; Tue,  7 May 2019 14:38:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 71C166B000C; Tue,  7 May 2019 14:38:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 60AC76B000D; Tue,  7 May 2019 14:38:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3E74A6B000A
	for <linux-mm@kvack.org>; Tue,  7 May 2019 14:38:44 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id s46so9789233qtj.4
        for <linux-mm@kvack.org>; Tue, 07 May 2019 11:38:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=B1Kd+1vGze1HjX/yglunSURjRhlNiu1tUGyDV/OWBKI=;
        b=dLJUAZ7p030rjL0d0Q6/jfOQbVzDz6d2+21QAjs9B8jYGtg6aW5vDqqBkoKYvl3DXG
         /coKW/nUoKxK+ntcVANanxdpvZF/L7Uo+cZpC8I5iK3PiChavxVqpApmI8wzTxKNS9XO
         bCDzVEnaozBbzOfIcq9swuhAzUkZgfH62MixDSLH+z26w+olk/wT+DM1wL7/X9DkEa2y
         wtFnWV1Z4zdf077dVp9w8fmPZlv1O8RNw6R+dgFPbr4mG92j6WqEvD0CMd18iAzHMAU7
         jl+ByPpEa04J1akV0dt0SIXdBaATPUUlXQTbaYgMcCUpp7q9Yxj3N01UoEF1lYwQA8UE
         rGTg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW7cuopNeHV+OntQb810Qeu2KV4MrrrLEQj4FkYPEAqHnlC8N34
	7wuvRdorC7iNxnyUv4Hfe3WVvdCimEbm8sjHzC6tjR7NPZ3I4AFJxKM5hX8Tlt28U34eN6SXsSn
	wiHlepK+0VLL6BFFPglLUgJUW9h3T2OUYB1BB1KEI+2yNJL19A6/dyNZaPcLA/Cp7BA==
X-Received: by 2002:a37:52c1:: with SMTP id g184mr17747007qkb.338.1557254324005;
        Tue, 07 May 2019 11:38:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwMK2RywF8wQdSkZ1VIl0mdWxfWqn9MDNfaFGryd0NL4mHo8tiplMnHo4k2fJiUNcfVFSrg
X-Received: by 2002:a37:52c1:: with SMTP id g184mr17746942qkb.338.1557254322827;
        Tue, 07 May 2019 11:38:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557254322; cv=none;
        d=google.com; s=arc-20160816;
        b=LRgRK60FSTTcHvlOCn1j7BVScKooBM0G0YSZv2iFi7wFe8C1Hn2EWbkd33roEg5Gf2
         TMtguzRVhtA27/tSwMn8+K8E2YeRI5zPEU31X8LMNRSFAGESYnUmPmbC8cmKEt36dFIw
         0so10Z5zfnKJOIaLdnPwJCYFhWnf91a5EC8w6Ohf63r5PDmSrDxV9H0wTqTOyq25gl0s
         FjLuqrEQzXUQ2QoUolQi0odXOpLCNa+UmqzucdblCkvg4GGGBgxwDuxXC8u6krnQLp4e
         vsO+kKJAJwgwbb1ep1cHMpK9gdE4rDzsiGlCkfXIzjo6626kD9K5bBAsDKRFpXS9LhT/
         BKgQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=B1Kd+1vGze1HjX/yglunSURjRhlNiu1tUGyDV/OWBKI=;
        b=Bf3wtZbRQhGsSxAbWgtaf8Hgu/Ay6+piYzemUtIorn0tTQiAThgdAPD6M792lQXr4r
         ROBqQ8wTmPHh7T4iUpa2JkSg94vzDnRUjuwELq9XPePIfg9itTc/Vn4Jqy/EKjLfol26
         u2zfj9G/odD0fPstASjgbRZr1muAzkjqxeHA9pDk9eX+Z5cL7lAvw7tnWJEcNJwrPr9i
         SJhxy2xM6pYzIiDPq+1dD20wFwdA+q0guxCzpYkogToX/i1sNY/cYIgyDgs+Eg9UXbeX
         EbMVT2Ni0UN49uWrt8pepFkbopm+UjRnM/evf1X0SpL6i1PgjOMNPjdPEpYGRdtvwDMQ
         t0uQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q26si3262160qte.68.2019.05.07.11.38.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 11:38:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id BAEE5300180F;
	Tue,  7 May 2019 18:38:41 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-116-95.ams2.redhat.com [10.36.116.95])
	by smtp.corp.redhat.com (Postfix) with ESMTP id E8CB58162;
	Tue,  7 May 2019 18:38:37 +0000 (UTC)
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
Subject: [PATCH v2 4/8] mm/memory_hotplug: Create memory block devices after arch_add_memory()
Date: Tue,  7 May 2019 20:38:00 +0200
Message-Id: <20190507183804.5512-5-david@redhat.com>
In-Reply-To: <20190507183804.5512-1-david@redhat.com>
References: <20190507183804.5512-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Tue, 07 May 2019 18:38:42 +0000 (UTC)
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

