Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61E36C43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 10:36:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 12631206E0
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 10:36:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 12631206E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A24188E0005; Thu, 20 Jun 2019 06:36:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9AA878E0002; Thu, 20 Jun 2019 06:36:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 873158E0005; Thu, 20 Jun 2019 06:36:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5FC638E0002
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 06:36:01 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id l16so3050098qkk.9
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 03:36:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=xosbEIjLFiGE08Kfhn6doMeJLReGW2/GZVrriI9jhUA=;
        b=hJT6FVfJKT4y/gUGINvC0lR9F8jFUrJ6Bp8dQDZQtlE1346TOx952qvReuzn2bpqj1
         5tst+LxeMuJH9x2z64yUe8RaiSzWcHfZCZlwEUitd6xhFK5PeaWwROsro6i5rqlsR9J6
         sWyU3BRo+O4T5wZJqSoFy6ElflBZTuhTM6g2xHhPfxSrRs4xkuFDHeWPHoi0W2AHzjbC
         Jri2Bj3pA1QwDol9MI8HrFYQjAZxvKh0SrovBBAIU/egN/o1WQkDhnBI3ELOmXpIOisd
         dDx9OuvYCxqzS2j1Vvqmv8ZTDOVNy1LAy33vnk05/1AB48rBOG3eic2Kav87vVQ4ZzxX
         B52w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUx3onZr/rxlIjWy1/+3pisaXz5CrRe2bIxK2DalmrQI8qGYugb
	rG0pmTYh7y8UDsOyh4Whh6a/wQ5IWgGL2FJVvTW+OoKtxg95Qr/hSNqSO/7127xsf1yIJP+w/H/
	cz0TJEHqfvreTnH1T5RnvQRSK5hw/XpTQHyNeMyMSkFwF9SQhYGHSSFoGb2oUdiwNeQ==
X-Received: by 2002:ac8:24f5:: with SMTP id t50mr107916218qtt.285.1561026961154;
        Thu, 20 Jun 2019 03:36:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwfPJbipuYeODWitIl5RMt0xnNydnPLi5jt27NoeGUfXsT9HftaT+EQh/XnTZyBX9EnaBY+
X-Received: by 2002:ac8:24f5:: with SMTP id t50mr107916151qtt.285.1561026960020;
        Thu, 20 Jun 2019 03:36:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561026960; cv=none;
        d=google.com; s=arc-20160816;
        b=arLlApyuUR8otr238LeeaPco7EuulCZJtz7Y6JiwCZ/mXccf2qNDFeZqOPR/dBVcHh
         9pnyZGl54U+gAvONmG0vGMyfat1NP6Dc43UwhNWJHTMx2cARoATNRV6AsTq8QycUQ36S
         8vaMhz15CRba0YUlmShdAXGZVGAGqrwdyyrHcCT9QSm/JB6hrZc8BMj9UGvcFI58TbsJ
         jBMUSvJ7CC4wCpS1Yc7+gTO8H/JzzfV3kenIsaCJjHRbOU4gkpTJCIsIJGJulLV6qa9C
         ONhFMxnmOV9Bps0oj7WyW1RwApys138fuUUcif+DuMQGdO+1fiCa31N33WJmRPMTqapD
         G+2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=xosbEIjLFiGE08Kfhn6doMeJLReGW2/GZVrriI9jhUA=;
        b=BZlzeMr0+7qsC7DLEC9RlwRTQi61OwR0/cA5TQ+BezQEFCw6r9QL2wfNoVbPbYGtkk
         T55Nt1Q2G+Cgrl4u0hIw2XXLEjJZ+Mo5HtOefTCPG5h5JwwTrv9Cl+jCnN7sI02WXE3m
         KY3HbwmP1H1resUGA8PXz7FjDlfhori1GejIMdfwZo71ORR8HbnPDMi1uOuaKNCdqLvz
         +h4dtnH0pNWaFA72qvjhJdGPTZ7yux7Jbw9ty7QEnijyLzGOhv6mDNG3lp4KT2ygOeA/
         1ZroGrldfpoFcJKsK35FThHBZqdWPFO2VBx+N4O4pFMGXW523OJqHi+aJD/GAvthbo4L
         efsg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j3si4471438qtq.155.2019.06.20.03.35.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 03:36:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 11F6230BC57F;
	Thu, 20 Jun 2019 10:35:59 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-88.ams2.redhat.com [10.36.117.88])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 72834608A7;
	Thu, 20 Jun 2019 10:35:55 +0000 (UTC)
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
Subject: [PATCH v2 5/6] mm/memory_hotplug: Move and simplify walk_memory_blocks()
Date: Thu, 20 Jun 2019 12:35:19 +0200
Message-Id: <20190620103520.23481-6-david@redhat.com>
In-Reply-To: <20190620103520.23481-1-david@redhat.com>
References: <20190620103520.23481-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Thu, 20 Jun 2019 10:35:59 +0000 (UTC)
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

