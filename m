Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90EFCC32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 12:22:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 50CBD20693
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 12:22:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 50CBD20693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C2BF78E0007; Wed, 31 Jul 2019 08:22:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BDCD68E0001; Wed, 31 Jul 2019 08:22:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ACAC38E0007; Wed, 31 Jul 2019 08:22:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 87D508E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:22:25 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id f28so61427008qtg.2
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 05:22:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=nYqQ+jsLvDXNHVY5FfBTpjue3zmxOsntcicDPkopix8=;
        b=pBbEWh+COWxxcTFYPb9wMwUw6kWUWRwGTWYStdmmWjkZMChFgUIB/V+eu6YU605h3b
         azlA0vjF8ys/VWiuFCvw+qfUiYwkPdy3iUkAPbgGg1zCkJvHe5tz30trnvZzTv4Vj63x
         0exGvsZH8A3vbAXVcvTB+Qew1ey5/ZPioccGZLFbOTEJ5Aj5Tev6OZDJt8MSIWZdEj2Z
         XLupdpeVvkzQBkntjh7grhwJzdDDAGoNf8tuOZJ0MvadfJ1wvEBu7WTtjvIH9Z+ZUPWP
         fIVwbnhFgR9jhmyvHmos1RZ3WohuPVHZC2PROAGc4EqfXVlGl0C1muUePmWSM4IvOTF6
         VM9A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUixAR+CpOZYEA1DZJX7EmoKaWI/n1NDSEuGL8lB6POJn22S+7X
	ETDQ0fw7Ca1zs5Qr617AysMiWBzO2QsQ/CNydc/csv+01iPdszzGVu65Rx1BfRrh943MKOn1hPu
	YBrp3sJQjmjap93NG0LCX0gG7wb9kDWm6VUWXAjU41+GbYGPfGfthRgT7aRvnzBu91w==
X-Received: by 2002:ac8:21b7:: with SMTP id 52mr83301637qty.59.1564575745281;
        Wed, 31 Jul 2019 05:22:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw+X/W5y7M1L3RRiZRNMfhIYH4VhLrNCCXRe6Z+n4zDi058uGK2CsXsdQHxHhR0MXG6cg8w
X-Received: by 2002:ac8:21b7:: with SMTP id 52mr83301568qty.59.1564575744099;
        Wed, 31 Jul 2019 05:22:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564575744; cv=none;
        d=google.com; s=arc-20160816;
        b=vEuBXrNeahRlntFEFTBxYplGvM2Xptyl2dfXifz9lXZKDY16cUMecn0G+ldCYAu//F
         OMieFkrZM3j2iwcmNMopok7zRK+okloXVln83Tvv91soJ5UbYzDox8cTXBoH7j+2rU7+
         cJRGHSI/nZxyTtRRoQMbm3umIOeBELEvLQp+vE4T0MLjPh4dGiH1A9/4unydzhfm531k
         45E70kQeZTTTHPbFvE+rm83Iv+EFlHHIljUt2DPvh9iBlpqRe2C20PVRHMjwW0rveEXT
         avXIdMVSQh3C2V6mN/W9j8/85BRry1ip9VN21LEtznLrY8DSnbJw8WRHbh2qok+ASgy/
         17bA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=nYqQ+jsLvDXNHVY5FfBTpjue3zmxOsntcicDPkopix8=;
        b=ITYoh2h3PK7xJZioSv5V5v10XxRPXqMwI5fMCsi2uUQMCvmQ67iMPJ+O5uTmS6LVoA
         t6bi5Z60eit2uoESmDn4M9gg0R88zkqlUowaHDTeB3Ks6TRUGcuBqoiT6+sVyS5gMAWp
         fUHvzeAvlXvht8ihuyl8rMX6AniUHB2AVyGzsTA1gUoqOtmrHaJym6pN+3mMcb1UD+1Q
         SDjR1mw5zHdLj8Ybg+3nP+Iffqs+HkQXgoj1dE4aq0WcJtFQUtzQ0MlsRSNIwY80KHuf
         mrYygb/wVnMv+yRsHFLbpqSOXIxNpit3p4dBtNJ+ShiDDrjoob3BmDWX29v1DrDJxbhy
         gcdQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h21si37684825qkj.164.2019.07.31.05.22.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 05:22:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 357FE81DF1;
	Wed, 31 Jul 2019 12:22:23 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-240.ams2.redhat.com [10.36.117.240])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 4E07060BF7;
	Wed, 31 Jul 2019 12:22:14 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	David Hildenbrand <david@redhat.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Michal Hocko <mhocko@suse.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Oscar Salvador <osalvador@suse.de>
Subject: [PATCH v1] drivers/base/memory.c: Don't store end_section_nr in memory blocks
Date: Wed, 31 Jul 2019 14:22:13 +0200
Message-Id: <20190731122213.13392-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Wed, 31 Jul 2019 12:22:23 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Each memory block spans the same amount of sections/pages/bytes. The size
is determined before the first memory block is created. No need to store
what we can easily calculate - and the calculations even look simpler now.

While at it, fix the variable naming in register_mem_sect_under_node() -
we no longer talk about a single section.

Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Oscar Salvador <osalvador@suse.de>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 drivers/base/memory.c  | 1 -
 drivers/base/node.c    | 9 ++++-----
 include/linux/memory.h | 3 ++-
 mm/memory_hotplug.c    | 2 +-
 4 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 154d5d4a0779..cb80f2bdd7de 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -670,7 +670,6 @@ static int init_memory_block(struct memory_block **memory,
 		return -ENOMEM;
 
 	mem->start_section_nr = block_id * sections_per_block;
-	mem->end_section_nr = mem->start_section_nr + sections_per_block - 1;
 	mem->state = state;
 	start_pfn = section_nr_to_pfn(mem->start_section_nr);
 	mem->phys_device = arch_get_memory_phys_device(start_pfn);
diff --git a/drivers/base/node.c b/drivers/base/node.c
index 840c95baa1d8..e9a504e7c8c2 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -756,13 +756,12 @@ static int __ref get_nid_for_pfn(unsigned long pfn)
 static int register_mem_sect_under_node(struct memory_block *mem_blk,
 					 void *arg)
 {
+	unsigned long start_pfn = section_nr_to_pfn(mem_blk->start_section_nr);
+	unsigned long end_pfn = start_pfn + PAGES_PER_MEMORY_BLOCK - 1;
 	int ret, nid = *(int *)arg;
-	unsigned long pfn, sect_start_pfn, sect_end_pfn;
+	unsigned long pfn;
 
-	sect_start_pfn = section_nr_to_pfn(mem_blk->start_section_nr);
-	sect_end_pfn = section_nr_to_pfn(mem_blk->end_section_nr);
-	sect_end_pfn += PAGES_PER_SECTION - 1;
-	for (pfn = sect_start_pfn; pfn <= sect_end_pfn; pfn++) {
+	for (pfn = start_pfn; pfn <= end_pfn; pfn++) {
 		int page_nid;
 
 		/*
diff --git a/include/linux/memory.h b/include/linux/memory.h
index 02e633f3ede0..16d2c0979976 100644
--- a/include/linux/memory.h
+++ b/include/linux/memory.h
@@ -25,7 +25,6 @@
 
 struct memory_block {
 	unsigned long start_section_nr;
-	unsigned long end_section_nr;
 	unsigned long state;		/* serialized by the dev->lock */
 	int section_count;		/* serialized by mem_sysfs_mutex */
 	int online_type;		/* for passing data to online routine */
@@ -40,6 +39,8 @@ int arch_get_memory_phys_device(unsigned long start_pfn);
 unsigned long memory_block_size_bytes(void);
 int set_memory_block_size_order(unsigned int order);
 
+#define PAGES_PER_MEMORY_BLOCK (memory_block_size_bytes() / PAGE_SIZE)
+
 /* These states are exposed to userspace as text strings in sysfs */
 #define	MEM_ONLINE		(1<<0) /* exposed to userspace */
 #define	MEM_GOING_OFFLINE	(1<<1) /* exposed to userspace */
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 9a82e12bd0e7..db33a0ffcb1f 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1650,7 +1650,7 @@ static int check_memblock_offlined_cb(struct memory_block *mem, void *arg)
 		phys_addr_t beginpa, endpa;
 
 		beginpa = PFN_PHYS(section_nr_to_pfn(mem->start_section_nr));
-		endpa = PFN_PHYS(section_nr_to_pfn(mem->end_section_nr + 1))-1;
+		endpa = beginpa + memory_block_size_bytes() - 1;
 		pr_warn("removing memory fails, because memory [%pa-%pa] is onlined\n",
 			&beginpa, &endpa);
 
-- 
2.21.0

