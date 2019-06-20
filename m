Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EA01EC43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 18:32:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B1BEF20675
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 18:32:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B1BEF20675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5AF5F8E0003; Thu, 20 Jun 2019 14:32:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 587836B000C; Thu, 20 Jun 2019 14:32:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 474878E0003; Thu, 20 Jun 2019 14:32:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 21EA56B000A
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 14:32:38 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id q26so4842770qtr.3
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 11:32:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Ua/1L85XXvxNpLU3txbB6eYF1WAK8cUWmLRonh+Cr9s=;
        b=RRkVkVZAyIEIPj3btc4gYGHxMhl1hGzwDTvS57Fv/SJXbTY++e38Ztw2zuSz6eJ7tO
         7iivTr/8UYYPUmrt6IxNOzGeT4tknDwqJcY8k7wO0ohRz14Ud5aB7sQpe68jE7pqRFo9
         O72ZV3jKc2g/6PZLng9zlp5pAtW9nk1xb/NDIkQjUx/GMGo8lnv/87RSX716aOM0/Gny
         6EJQgUK1rb/wKM0fdtDKm6ZraBhqYvajbJ31izjuNLmC7tDtBccqGtSYA3puy3VDtBPk
         mN6B3lWbwNJnWa3qVa8CbxoLtF4eOpb5RofhACon+cKAeBTi32oeEjjmOdGgnRHW8kbJ
         ZWaA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWJqSTJGeifiQWdg7RnrRyMpx7ikQbosszBjKjKUool6bFEDSps
	a6x/sRDhuDnpVCwx1mIgwBszDsjRtFw5ukTQXHav/iaf2RA95RNg2Z4tmXXTdC9gVL3sQNG0+tR
	lgqLxaBsyf1+69XEdLag/JszqKvL2bEjV0QP5uXs6cMTTscyVTYAqiQAXoabjoP6wDQ==
X-Received: by 2002:aed:24f4:: with SMTP id u49mr109457059qtc.8.1561055557904;
        Thu, 20 Jun 2019 11:32:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxVLVHj5MSs8xAjdg29ZO0PGtyqH+cYNHDziU/7+Iu+0khRKTVo/o/OWa2BW+f7kNoylp4Q
X-Received: by 2002:aed:24f4:: with SMTP id u49mr109456977qtc.8.1561055556824;
        Thu, 20 Jun 2019 11:32:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561055556; cv=none;
        d=google.com; s=arc-20160816;
        b=mE3NBE9PFBfggxf2KX8h/gXyVwfVGCCnejYu0nUhiXgDqKa4WJ2b4LtjFskJYUCPrY
         8ACv3uuYzy9qzH7eys2pewrmtNI19pyU4gm+bJIz0DRM3cypGK0n8xFjTN90+2YHHNi3
         2XX1jxpqcW3AjseAtEvvhjLmWjFFAoOw/XPwFfN06ezCl/k0Ut6NfwfQQeO7GYEb6C2N
         zNz9a8Hw68AA9NN1uE44eLVLJfXxCTaM02X/uR2q5kzK9diwrdehrcs5MwbpxirfWxI0
         nf1dXYpbjt8wH6X1cW6Nuq4hvQ2sAtl2rl4Xa5pwt6JF3KiOMAxBBTAdRNh3X0Lv03Ir
         jXsA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=Ua/1L85XXvxNpLU3txbB6eYF1WAK8cUWmLRonh+Cr9s=;
        b=vtKOw+P4Ayx7b6woOInnxo3wC42QeqVr1rQPoDi55eRzMThHfe4SZintFeaR5MmfcV
         7NwlEli0iN0rvPAUyVzwQc3LctAJr6wsZap1+wy9JmlVa1sHZvNDprKqRuWctHXJwNJT
         fSuLOFQ76YIG0ZoCdK4guD0YU8Paiz75UyStIp2vszlpInMAItdgGRrcfEIpbyFlvRL8
         +a1rY9hvG7PoEUh4h7ue6JygTF0qaZjraCdTp8fQ5MoMwCkZ1W9XnuFVENfgTzX70Li3
         bdQfjz1ohJMBj94eSgp4ZIUl7sjmnVATgUR3rUq7+WnDEXCn73BgbBJcuPYdKjWJnum3
         806A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p54si249823qtc.371.2019.06.20.11.32.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 11:32:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id CFED74E90E;
	Thu, 20 Jun 2019 18:32:31 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-116-71.ams2.redhat.com [10.36.116.71])
	by smtp.corp.redhat.com (Postfix) with ESMTP id EFF9419722;
	Thu, 20 Jun 2019 18:32:25 +0000 (UTC)
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
	"mike.travis@hpe.com" <mike.travis@hpe.com>
Subject: [PATCH v3 6/6] drivers/base/memory.c: Get rid of find_memory_block_hinted()
Date: Thu, 20 Jun 2019 20:31:39 +0200
Message-Id: <20190620183139.4352-7-david@redhat.com>
In-Reply-To: <20190620183139.4352-1-david@redhat.com>
References: <20190620183139.4352-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Thu, 20 Jun 2019 18:32:32 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

No longer needed, let's remove it. Also, drop the "hint" parameter
completely from "find_memory_block_by_id", as nobody needs it anymore.

Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: "mike.travis@hpe.com" <mike.travis@hpe.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 drivers/base/memory.c  | 37 +++++++++++--------------------------
 include/linux/memory.h |  2 --
 2 files changed, 11 insertions(+), 28 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 0204384b4d1d..195dbcb8e8a8 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -588,30 +588,13 @@ int __weak arch_get_memory_phys_device(unsigned long start_pfn)
 	return 0;
 }
 
-/*
- * A reference for the returned object is held and the reference for the
- * hinted object is released.
- */
-static struct memory_block *find_memory_block_by_id(unsigned long block_id,
-						    struct memory_block *hint)
+/* A reference for the returned memory block device is acquired. */
+static struct memory_block *find_memory_block_by_id(unsigned long block_id)
 {
-	struct device *hintdev = hint ? &hint->dev : NULL;
 	struct device *dev;
 
-	dev = subsys_find_device_by_id(&memory_subsys, block_id, hintdev);
-	if (hint)
-		put_device(&hint->dev);
-	if (!dev)
-		return NULL;
-	return to_memory_block(dev);
-}
-
-struct memory_block *find_memory_block_hinted(struct mem_section *section,
-					      struct memory_block *hint)
-{
-	unsigned long block_id = base_memory_block_id(__section_nr(section));
-
-	return find_memory_block_by_id(block_id, hint);
+	dev = subsys_find_device_by_id(&memory_subsys, block_id, NULL);
+	return dev ? to_memory_block(dev) : NULL;
 }
 
 /*
@@ -624,7 +607,9 @@ struct memory_block *find_memory_block_hinted(struct mem_section *section,
  */
 struct memory_block *find_memory_block(struct mem_section *section)
 {
-	return find_memory_block_hinted(section, NULL);
+	unsigned long block_id = base_memory_block_id(__section_nr(section));
+
+	return find_memory_block_by_id(block_id);
 }
 
 static struct attribute *memory_memblk_attrs[] = {
@@ -675,7 +660,7 @@ static int init_memory_block(struct memory_block **memory,
 	unsigned long start_pfn;
 	int ret = 0;
 
-	mem = find_memory_block_by_id(block_id, NULL);
+	mem = find_memory_block_by_id(block_id);
 	if (mem) {
 		put_device(&mem->dev);
 		return -EEXIST;
@@ -755,7 +740,7 @@ int create_memory_block_devices(unsigned long start, unsigned long size)
 		end_block_id = block_id;
 		for (block_id = start_block_id; block_id != end_block_id;
 		     block_id++) {
-			mem = find_memory_block_by_id(block_id, NULL);
+			mem = find_memory_block_by_id(block_id);
 			mem->section_count = 0;
 			unregister_memory(mem);
 		}
@@ -782,7 +767,7 @@ void remove_memory_block_devices(unsigned long start, unsigned long size)
 
 	mutex_lock(&mem_sysfs_mutex);
 	for (block_id = start_block_id; block_id != end_block_id; block_id++) {
-		mem = find_memory_block_by_id(block_id, NULL);
+		mem = find_memory_block_by_id(block_id);
 		if (WARN_ON_ONCE(!mem))
 			continue;
 		mem->section_count = 0;
@@ -882,7 +867,7 @@ int walk_memory_blocks(unsigned long start, unsigned long size,
 	int ret = 0;
 
 	for (block_id = start_block_id; block_id <= end_block_id; block_id++) {
-		mem = find_memory_block_by_id(block_id, NULL);
+		mem = find_memory_block_by_id(block_id);
 		if (!mem)
 			continue;
 
diff --git a/include/linux/memory.h b/include/linux/memory.h
index b3b388775a30..02e633f3ede0 100644
--- a/include/linux/memory.h
+++ b/include/linux/memory.h
@@ -116,8 +116,6 @@ void remove_memory_block_devices(unsigned long start, unsigned long size);
 extern int memory_dev_init(void);
 extern int memory_notify(unsigned long val, void *v);
 extern int memory_isolate_notify(unsigned long val, void *v);
-extern struct memory_block *find_memory_block_hinted(struct mem_section *,
-							struct memory_block *);
 extern struct memory_block *find_memory_block(struct mem_section *);
 typedef int (*walk_memory_blocks_func_t)(struct memory_block *, void *);
 extern int walk_memory_blocks(unsigned long start, unsigned long size,
-- 
2.21.0

