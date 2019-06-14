Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6C62C31E4B
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 10:02:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6AA1A21773
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 10:02:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6AA1A21773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 110FA6B0269; Fri, 14 Jun 2019 06:02:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EF2326B026A; Fri, 14 Jun 2019 06:02:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D1DA06B026B; Fri, 14 Jun 2019 06:02:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id A952A6B0269
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 06:02:05 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id s9so1645430qtn.14
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 03:02:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=2BnEF5DjEUXKUN68Cu5GloZzc1NrCiCe4crz0f6bDtE=;
        b=W/1+s2jjiVS4d9LRLSG9Wi8nSI/4LSHraUVnU91wOgIEqApdN0pY+dSgpqH9bFDGpQ
         rAbGlvFd390uJxKT7uRV1J8AsFZjst8cNKLjhsmCWnk/yjVOHyeyNxc/A+qaZZNcQcLr
         /odXb68eAUWxWgC/TU90SCmu1DeES2Ufn799n2y7NFXPxQ/2b/CL3grJiX8jKMgq+P9p
         W5F7dF86vJh7uBYGq7Hy8Fpb+Rs8g+cknOMv7J/EPffDDRwVnKSF3zvkjg1Sy9t3C0EP
         ON9DRk/zNh0bNTeEs9PKBJ08PuQDHzakMmpOTcAgNAO51qW9pXFxeAWagBdnGK7yq8E6
         y7Dg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXHvj/i4Zt0xPV4He3CYKNI3lWy9KX18Ah8JvsGYbNdUScl9OwU
	lmiyKa2vrMe2aiaSnz+KSZmxGQp6ttoQyF3YoWIHcXVGcICNEkTS86pQPXX7//YTFsShUm0fbaH
	aw3LpMiNXir7/upu9F8vIwIJQTVOg6dvEMN5OCX+CI6GMolwag1Ewz6tmGuczGQb+4Q==
X-Received: by 2002:a37:9481:: with SMTP id w123mr56257242qkd.319.1560506525473;
        Fri, 14 Jun 2019 03:02:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwkUe1aKaehd6oTTSVpFE3Cpze1E0sEbyj70rFWsafJpZW56EZJirytFNqhJNELfRDMOO+I
X-Received: by 2002:a37:9481:: with SMTP id w123mr56257096qkd.319.1560506523979;
        Fri, 14 Jun 2019 03:02:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560506523; cv=none;
        d=google.com; s=arc-20160816;
        b=GHr9X69atB4knkjMrbbjU43hTTjC2nNhxxTtTGF1/86t093lQdsMKguXaRu5NEieDv
         GIniSzwCYTBpYfvPuo+fp//diiJbIAHhPItSRaIdWoEDf4TcSiisW/kH4Rt1oiQeTZDz
         gUYtVKnci9NA6I3d1oKHirjbYH2Bp/cxKVYV4FE4fb/KFwzQPVmpkTZ4tHZ53UmrR6iy
         qd8tfyIMHf/gyVfVy5baUJgPx0Aws3TRGkpRlnmBN6qQxwkAZjm8nn51Dpwmx84agmuw
         iy99oGkGrIq1kkkCDDn2alNMUq4prgQutKF7K5a3AJZGssXS83N7Lpw9tuZK+HJD/c1o
         f+UQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=2BnEF5DjEUXKUN68Cu5GloZzc1NrCiCe4crz0f6bDtE=;
        b=0O/NUJ8l71UgWkFqKOREh70Hxz25zj9UX+DISbL7UnPZg5z5pueyGx8liABUb8EzfU
         WIBzhm9WfPXRKtisvJJ6T/BTU1+Hh8+547X5i+jnv2+468OYsEPjSfWCSdKXFG4CZCEn
         VecpkUZ3nmCS8ZU0ZGyTNSkiVENGm+Hdipo7UKN4NQ2Y9+QJEE1UYClOz+TnEAjUglVX
         1xOWF0CG7xGdCGpRPc2tK69DY1hUMqYm/zbkVq+58tTyS4bsTyd/GcJxToD5Z/V2Mzy6
         gGIFDOTDApj0/ItXP1rm0dOaGO2hzbaD2Q73CUVdtScns6ezxTrg/9vWDzXX13y/rERK
         rXlA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e6si1468964qkg.171.2019.06.14.03.02.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 03:02:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A926B308FF30;
	Fri, 14 Jun 2019 10:01:47 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-116-252.ams2.redhat.com [10.36.116.252])
	by smtp.corp.redhat.com (Postfix) with ESMTP id B7A305D9D2;
	Fri, 14 Jun 2019 10:01:42 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: Dan Williams <dan.j.williams@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linuxppc-dev@lists.ozlabs.org,
	linux-acpi@vger.kernel.org,
	linux-mm@kvack.org,
	David Hildenbrand <david@redhat.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>
Subject: [PATCH v1 2/6] drivers/base/memory: Use "unsigned long" for block ids
Date: Fri, 14 Jun 2019 12:01:10 +0200
Message-Id: <20190614100114.311-3-david@redhat.com>
In-Reply-To: <20190614100114.311-1-david@redhat.com>
References: <20190614100114.311-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Fri, 14 Jun 2019 10:01:52 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Block ids are just shifted section numbers, so let's also use
"unsigned long" for them, too.

Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 drivers/base/memory.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 5b3a2fd250ba..3ed08e67e64f 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -34,12 +34,12 @@ static DEFINE_MUTEX(mem_sysfs_mutex);
 
 static int sections_per_block;
 
-static inline int base_memory_block_id(unsigned long section_nr)
+static inline unsigned long base_memory_block_id(unsigned long section_nr)
 {
 	return section_nr / sections_per_block;
 }
 
-static inline int pfn_to_block_id(unsigned long pfn)
+static inline unsigned long pfn_to_block_id(unsigned long pfn)
 {
 	return base_memory_block_id(pfn_to_section_nr(pfn));
 }
@@ -587,7 +587,7 @@ int __weak arch_get_memory_phys_device(unsigned long start_pfn)
  * A reference for the returned object is held and the reference for the
  * hinted object is released.
  */
-static struct memory_block *find_memory_block_by_id(int block_id,
+static struct memory_block *find_memory_block_by_id(unsigned long block_id,
 						    struct memory_block *hint)
 {
 	struct device *hintdev = hint ? &hint->dev : NULL;
@@ -604,7 +604,7 @@ static struct memory_block *find_memory_block_by_id(int block_id,
 struct memory_block *find_memory_block_hinted(struct mem_section *section,
 					      struct memory_block *hint)
 {
-	int block_id = base_memory_block_id(__section_nr(section));
+	unsigned long block_id = base_memory_block_id(__section_nr(section));
 
 	return find_memory_block_by_id(block_id, hint);
 }
@@ -663,8 +663,8 @@ int register_memory(struct memory_block *memory)
 	return ret;
 }
 
-static int init_memory_block(struct memory_block **memory, int block_id,
-			     unsigned long state)
+static int init_memory_block(struct memory_block **memory,
+			     unsigned long block_id, unsigned long state)
 {
 	struct memory_block *mem;
 	unsigned long start_pfn;
@@ -730,8 +730,8 @@ static void unregister_memory(struct memory_block *memory)
  */
 int create_memory_block_devices(unsigned long start, unsigned long size)
 {
-	const int start_block_id = pfn_to_block_id(PFN_DOWN(start));
-	int end_block_id = pfn_to_block_id(PFN_DOWN(start + size));
+	const unsigned long start_block_id = pfn_to_block_id(PFN_DOWN(start));
+	unsigned long end_block_id = pfn_to_block_id(PFN_DOWN(start + size));
 	struct memory_block *mem;
 	unsigned long block_id;
 	int ret = 0;
@@ -767,10 +767,10 @@ int create_memory_block_devices(unsigned long start, unsigned long size)
  */
 void remove_memory_block_devices(unsigned long start, unsigned long size)
 {
-	const int start_block_id = pfn_to_block_id(PFN_DOWN(start));
-	const int end_block_id = pfn_to_block_id(PFN_DOWN(start + size));
+	const unsigned long start_block_id = pfn_to_block_id(PFN_DOWN(start));
+	const unsigned long end_block_id = pfn_to_block_id(PFN_DOWN(start + size));
 	struct memory_block *mem;
-	int block_id;
+	unsigned long block_id;
 
 	if (WARN_ON_ONCE(!IS_ALIGNED(start, memory_block_size_bytes()) ||
 			 !IS_ALIGNED(size, memory_block_size_bytes())))
-- 
2.21.0

