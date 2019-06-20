Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 20C9BC48BE1
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 10:36:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DE794206E0
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 10:36:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DE794206E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8EAC78E0006; Thu, 20 Jun 2019 06:36:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 872898E0002; Thu, 20 Jun 2019 06:36:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 713DC8E0006; Thu, 20 Jun 2019 06:36:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 498408E0002
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 06:36:04 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id c4so3016895qkd.16
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 03:36:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=DoTahoElNd51FKBs5W52n2Aegfmsf/gprGY01Gxnd1k=;
        b=JMy2qVpcKGO/R0LrZlzECXjfefYkhiQ5kLgMHOP1bKhpo/lkiCcfW9lx682HnV+z1f
         z1EqvlTLS40Q9UI/utrPb+1y50mNmFIcjAPofgDEc8jk/4IZMtFoe9I46ux4HNtXOa5S
         4yXFv3M+MLIwOyUd+j4f7m8/i1Rtc8aaaBW4EeCx9FiRawZ/m6A5bSv4GKrn3bhBMmlO
         MBxWH6nNelXpiYM2u8tbu3znRaUHbWuMHeBTqxnDKKDAwi7rcwtpgj10Xxlb6xPpoQX6
         TXaglMzXsmvnmsgVwX4O4a26Hj//0Jh7R6olf8cwCrxbpvsg70Dwx6xQiOslgez/phdz
         Uo0A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUF8Es8AJF2HWdm2b/uSVx3UFfj3Y3iO0+eiOHEM3teUNXTaKVD
	h1e1Th/mHekBhG6Js3fIymgmtulohIzEAuDJgaxpNB4JK8P2H0F05sEVe9pC12mt3w0+y/6hFbZ
	8FT0a0GE8Nd32KH4QFcjOwlkTfu0pWwMjThwKltVV1X3+/Q2+hUv2DF/JSquadm/CfQ==
X-Received: by 2002:ac8:3932:: with SMTP id s47mr112367173qtb.264.1561026964042;
        Thu, 20 Jun 2019 03:36:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx3VSOgZbEdKrqkaxsaRLCVk4MHsZm1qv9Ah0MMPdqFEhlsJsWILnlMcr9tYXOhir3X/BQf
X-Received: by 2002:ac8:3932:: with SMTP id s47mr112367108qtb.264.1561026963137;
        Thu, 20 Jun 2019 03:36:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561026963; cv=none;
        d=google.com; s=arc-20160816;
        b=ph84ztAzI1tO01fTrcRfYZGi3z8yIWZBqgR3BRq3QPsPWTkUPsefv18U0Y+ynxeJPm
         niQc0zl6NfBkEny/TtxWSsLr1/iPeTYJk0cK+55EfKqhroyc4XVrSF7TPke5Hmrz4SL8
         qkVT852201KeRZR6FeTHN8NQMRxdDyGOxPwTlQMIIGOpqCwCIy8j0QAqFt+tq33LJgUs
         8ulPuCt1hQrJHVdJ+fGSX0XY8sZ+OVE6UNx9yi7uqz+C4bLoygVEph0xh5dcYSzdHt1Q
         ihpBe4k/lvAaB+GgdUJK5GpP2EDSqk9x7wDyjtKmQ77SM6gzIE2ez9ssP6WE1L54BbYP
         CkVQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=DoTahoElNd51FKBs5W52n2Aegfmsf/gprGY01Gxnd1k=;
        b=NUwXgxECHKVlh+zo3CujOKx+7fLsPoTNsF2KojD7FJ/2mAdc3XISTM6mNmtZE1zXRF
         whrBRdfT6d4zQe5kcGzbHYuP2vWulBuKXXED3SbgD/PiI7dhWl8ozkENoinlAb5FqMMJ
         4nunWLQGxbnu0f4wH5zJ92ED/u3UCB/bYIV2Rx1UCuhg6vjayFCjsiuk+t55g6md67qL
         mxj4dPLqQRGOjXl2bbE6KIKfHPiq+y4QQNWZ3mj7VK33IdVU+lzN5v6EBvdmSmNsON2b
         k5yXzgf9PzmtkSMxURd7nn3HIVa+EpsIlklkXYjj0pqCRV+YgX3FqKAUanNfahgeb7Wd
         CNiw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k23si15303426qke.240.2019.06.20.03.36.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 03:36:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 3AF3386663;
	Thu, 20 Jun 2019 10:36:02 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-88.ams2.redhat.com [10.36.117.88])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 628215C66B;
	Thu, 20 Jun 2019 10:35:59 +0000 (UTC)
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
Subject: [PATCH v2 6/6] drivers/base/memory.c: Get rid of find_memory_block_hinted()
Date: Thu, 20 Jun 2019 12:35:20 +0200
Message-Id: <20190620103520.23481-7-david@redhat.com>
In-Reply-To: <20190620103520.23481-1-david@redhat.com>
References: <20190620103520.23481-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Thu, 20 Jun 2019 10:36:02 +0000 (UTC)
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
 drivers/base/memory.c  | 32 ++++++++++----------------------
 include/linux/memory.h |  2 --
 2 files changed, 10 insertions(+), 24 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 0204384b4d1d..fefb64d3588e 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -592,26 +592,12 @@ int __weak arch_get_memory_phys_device(unsigned long start_pfn)
  * A reference for the returned object is held and the reference for the
  * hinted object is released.
  */
-static struct memory_block *find_memory_block_by_id(unsigned long block_id,
-						    struct memory_block *hint)
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
@@ -624,7 +610,9 @@ struct memory_block *find_memory_block_hinted(struct mem_section *section,
  */
 struct memory_block *find_memory_block(struct mem_section *section)
 {
-	return find_memory_block_hinted(section, NULL);
+	unsigned long block_id = base_memory_block_id(__section_nr(section));
+
+	return find_memory_block_by_id(block_id);
 }
 
 static struct attribute *memory_memblk_attrs[] = {
@@ -675,7 +663,7 @@ static int init_memory_block(struct memory_block **memory,
 	unsigned long start_pfn;
 	int ret = 0;
 
-	mem = find_memory_block_by_id(block_id, NULL);
+	mem = find_memory_block_by_id(block_id);
 	if (mem) {
 		put_device(&mem->dev);
 		return -EEXIST;
@@ -755,7 +743,7 @@ int create_memory_block_devices(unsigned long start, unsigned long size)
 		end_block_id = block_id;
 		for (block_id = start_block_id; block_id != end_block_id;
 		     block_id++) {
-			mem = find_memory_block_by_id(block_id, NULL);
+			mem = find_memory_block_by_id(block_id);
 			mem->section_count = 0;
 			unregister_memory(mem);
 		}
@@ -782,7 +770,7 @@ void remove_memory_block_devices(unsigned long start, unsigned long size)
 
 	mutex_lock(&mem_sysfs_mutex);
 	for (block_id = start_block_id; block_id != end_block_id; block_id++) {
-		mem = find_memory_block_by_id(block_id, NULL);
+		mem = find_memory_block_by_id(block_id);
 		if (WARN_ON_ONCE(!mem))
 			continue;
 		mem->section_count = 0;
@@ -882,7 +870,7 @@ int walk_memory_blocks(unsigned long start, unsigned long size,
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

