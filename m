Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AF762C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 13:44:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7748420823
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 13:44:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7748420823
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2139B6B0008; Thu, 28 Mar 2019 09:44:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C0FA6B000A; Thu, 28 Mar 2019 09:44:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 087B86B000C; Thu, 28 Mar 2019 09:44:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id AFFB66B0008
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 09:44:07 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id m31so8143374edm.4
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 06:44:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=VXzFbLAjAoJeKDf0Uc3Q0h+F3BUGkrW+aNvYoE6az7s=;
        b=VMarwHDeFMkM2Vrkw+6FutvszepzbBrO/1/HRAVPNqOsSDE1qLkcPtegnUjOXLfYw5
         QvmYAB44vCUygOHwJ+QQI1LCwRyZuF0ZdkAsDC/kWd7f3VCM0CO6jKtSX96H+ElDwYQU
         ZEr7C7xqGcBxKgIRP1PKSt1LS2irFuWeQQZd0RRonEV1+fFy+vaYfO75b0zL/HJIMLMF
         +7WKumw1qmeAYzDnFPgJv6EerqY1ifDUGpsSR1wnz8qPGPUlVJXE80Q7YAvi4pLksfKt
         6o9UXp6um8rzzOisRJufwxMUFm1N4EWvw74E7NGyPhbwJ4BoCWFE8f9CSDaGP1vFbeFi
         cb/g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAV3P4570J7J2aQAxAKZvPedUgOx52r8dOWbimGvpx99T5rz1rlk
	q/OAmnBZHTUUjAXF0fmWj0/Vs+lmFRwvbS9l7eWfncRs2N42soxHFGQ79lZ3ReBSVexG0zY1WnM
	Zml8+PNfyW9s+m4Ot+MpY0eIsuN6GP4v9oe1BxiD0Wi3zNHhIPIb+aWMOj7NtFnOE4Q==
X-Received: by 2002:a50:aa4e:: with SMTP id p14mr22258441edc.59.1553780647242;
        Thu, 28 Mar 2019 06:44:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxhAXrYG/gb1kbKb7zSHevW5+sk4rOAZdFxLeOeJGTqtWAFRZWnVLTwvA0ASjUO2ZPbDgvp
X-Received: by 2002:a50:aa4e:: with SMTP id p14mr22258402edc.59.1553780646402;
        Thu, 28 Mar 2019 06:44:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553780646; cv=none;
        d=google.com; s=arc-20160816;
        b=FzN7BCjCX6TdgmDpOwcPx6JcoYASIVYlvsupMVxJmfGmkd90vJBR3qSc8je2PdL/WK
         /eTRGcaDfvPNueqQ4+lNCUCEPvjacy2+brzh+Y+nmuLZNrzN3vRucBhx1aLGJ1/hlkCO
         1J7c6NFZ0WNSkCuAQI2N4tXufkDY46maCnj9+c4WmpE4dYAoGCNO8OwJidGniFLUUe3T
         yXieBmpyjVBV+z4tkl98DUHmIjRXB8QDSJqu4pH9Tuc7395rXrbqbsaPAf1yQPM2SAIE
         7rp0AvQQKvgC7VpDw7JbTUBBHjXh1KGAJgYOzoEXWTCN88WEbPRilF6087sNhhWYfA3P
         HASQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=VXzFbLAjAoJeKDf0Uc3Q0h+F3BUGkrW+aNvYoE6az7s=;
        b=iTWkQd+Pb+IQH3rUktP0tCGg/HYlLY7TgaRVViJOLU9FVlpyT24FDRhaskdL+pjH5d
         jwljd0/WE9PdS4XAtmL84hagKV+xRrbVIQJ36Lrf83XISrt/vrWeYmHwLB1Cb+BPf+Hf
         9Yxf/N0wW2uvhxq3fwAN9331Wah+Aa0z94Ou+5rafdk2Qrx3yuMVxhVF7wy5aYCg/nFF
         cx/px18uPzAIUyiAYcnf2mK0nk7OAi6OCLpePnmXAYtnwqnBQaSbmfuNlKyuvcxLSbNG
         p03JpIIAAPMNVB9WcxxPHYdSoZwk/Ymo+XMjqQypeEdoc7MS4gGebxeElfdsDxyVqYAY
         BR3w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id c9si1839298edk.312.2019.03.28.06.44.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 06:44:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) client-ip=195.135.221.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from emea4-mta.ukb.novell.com ([10.120.13.87])
	by smtp.nue.novell.com with ESMTP (TLS encrypted); Thu, 28 Mar 2019 14:44:05 +0100
Received: from d104.suse.de (nwb-a10-snat.microfocus.com [10.120.13.202])
	by emea4-mta.ukb.novell.com with ESMTP (NOT encrypted); Thu, 28 Mar 2019 13:43:31 +0000
From: Oscar Salvador <osalvador@suse.de>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com,
	david@redhat.com,
	dan.j.williams@intel.com,
	Jonathan.Cameron@huawei.com,
	anshuman.khandual@arm.com,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Oscar Salvador <osalvador@suse.de>
Subject: [PATCH 4/4] mm, sparse: rename kmalloc_section_memmap, __kfree_section_memmap
Date: Thu, 28 Mar 2019 14:43:20 +0100
Message-Id: <20190328134320.13232-5-osalvador@suse.de>
X-Mailer: git-send-email 2.13.7
In-Reply-To: <20190328134320.13232-1-osalvador@suse.de>
References: <20190328134320.13232-1-osalvador@suse.de>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Michal Hocko <mhocko@suse.com>

The sufix "kmalloc" is misleading.
Rename it to alloc_section_memmap/free_section_memmap which
better reflects the funcionality.

Signed-off-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 mm/sparse.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index 82c7b119eb1d..63c1d0bd4755 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -673,13 +673,13 @@ static void deferred_vmemmap_free(unsigned long start, unsigned long end)
 		free_deferred_vmemmap_range(start, end);
 }
 
-static inline struct page *kmalloc_section_memmap(unsigned long pnum, int nid,
+static inline struct page *alloc_section_memmap(unsigned long pnum, int nid,
 		struct vmem_altmap *altmap)
 {
 	/* This will make the necessary allocations eventually. */
 	return sparse_mem_map_populate(pnum, nid, altmap);
 }
-static void __kfree_section_memmap(struct page *memmap,
+static void free_section_memmap(struct page *memmap,
 		struct vmem_altmap *altmap)
 {
 	unsigned long start = (unsigned long)memmap;
@@ -723,13 +723,13 @@ static struct page *__kmalloc_section_memmap(void)
 	return ret;
 }
 
-static inline struct page *kmalloc_section_memmap(unsigned long pnum, int nid,
+static inline struct page *alloc_section_memmap(unsigned long pnum, int nid,
 		struct vmem_altmap *altmap)
 {
 	return __kmalloc_section_memmap();
 }
 
-static void __kfree_section_memmap(struct page *memmap,
+static void free_section_memmap(struct page *memmap,
 		struct vmem_altmap *altmap)
 {
 	if (is_vmalloc_addr(memmap))
@@ -794,12 +794,12 @@ int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
 	if (ret < 0 && ret != -EEXIST)
 		return ret;
 	ret = 0;
-	memmap = kmalloc_section_memmap(section_nr, nid, altmap);
+	memmap = alloc_section_memmap(section_nr, nid, altmap);
 	if (!memmap)
 		return -ENOMEM;
 	usemap = __kmalloc_section_usemap();
 	if (!usemap) {
-		__kfree_section_memmap(memmap, altmap);
+		free_section_memmap(memmap, altmap);
 		return -ENOMEM;
 	}
 
@@ -821,7 +821,7 @@ int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
 out:
 	if (ret < 0) {
 		kfree(usemap);
-		__kfree_section_memmap(memmap, altmap);
+		free_section_memmap(memmap, altmap);
 	}
 	return ret;
 }
@@ -872,7 +872,7 @@ static void free_section_usemap(struct page *memmap, unsigned long *usemap,
 	if (PageSlab(usemap_page) || PageCompound(usemap_page)) {
 		kfree(usemap);
 		if (memmap)
-			__kfree_section_memmap(memmap, altmap);
+			free_section_memmap(memmap, altmap);
 		return;
 	}
 
-- 
2.13.7

