Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E4ECC48BE2
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 10:35:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C55A52082C
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 10:35:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C55A52082C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 604076B0007; Thu, 20 Jun 2019 06:35:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5BF948E0002; Thu, 20 Jun 2019 06:35:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 42E9E8E0001; Thu, 20 Jun 2019 06:35:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1BF966B0006
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 06:35:49 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id e39so3008373qte.8
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 03:35:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=avoS6L2KoFWgEbuyJgNZwy6yIMSlaOGkc4g5/F0NbSw=;
        b=hGIcG/f3wkaWoyLnTjHHCr78ENpDi4CzXe6VLmRArPYKHiPCQc/bqQVo7AbLt1CvRf
         zeKKbyEZurnVMVAzAejbzYjzpMWkG82Dzh8UlHWnubVUTbJ37dOGGa3gnr9EP3fv4Kpf
         kIs/c42sPctZWWpgReuXo280Q/eIzE3ZZBOvMt07gdWiwL9jviFgPwWxgBW0110gWstz
         vfybiSxLXh7JgYQHNxeZwEP1dVn5eco0Z7Ufn5jSKnDAxBi60ggNSum414jca/rTeTd0
         M31y1F/KNi4Zf5Q11L2SxZMjkjmDcN01d2zyYS53sMrlUGHEMCmcvkUhhiGTRywlPJSN
         RgSQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU9F1My9zJwOdWAnIgbGXzaM51QnFbhVGMuuddI4+yQFrkuCtoG
	gUvnb6R5O1WtLnZ7XVIbTYM2we4l+q4ObabhHOKWWjvGGM8AxPggo59+fxAiv/Q5OnzV8YrmYFN
	smqkY3Khzs8cklQsStnEwEfhZ0Ry5P3KT+9rwRlSJuGMrHl974TZ6fgPXnD3gvpvP6w==
X-Received: by 2002:ac8:4982:: with SMTP id f2mr101469976qtq.213.1561026948878;
        Thu, 20 Jun 2019 03:35:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyDmNaCks25gUONJY1qNanyHZJeBgNGacNJHOwfPGE+xUaVhDd0/48MtfNqFI2fG9kuG+9F
X-Received: by 2002:ac8:4982:: with SMTP id f2mr101469902qtq.213.1561026947880;
        Thu, 20 Jun 2019 03:35:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561026947; cv=none;
        d=google.com; s=arc-20160816;
        b=BRVVw1y92WF3a27VtAnXwF++ECinV7jRlGcHcLIY/tFXyAHfj1fQr/idK9vPhkIfU3
         cX7UDC+Vm907o0uZo19y3+g3cmW69NwLuXZtTDVjfp+4Wkm6S8ci4v/ZlA5Tgf+yAkxx
         MmyUzFn7ZCLoGfofF1Lurx4jjLa9/KF2CI2tyNoD8hI27eHyCMcGwS9S3ybo1dApV6QB
         og8O+aP8c20utY3BE1opwaYJz2DeHpMJcshAQtu4nvx924jMAnjl8FB5cGeIdr6NcPgZ
         E5sQn/lnFb5S6Q+qvSbvXjdFs0EVOn/LD6d65gBmcsrx+3NMb1q2+MheJqqT253UDB9Z
         R7fQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=avoS6L2KoFWgEbuyJgNZwy6yIMSlaOGkc4g5/F0NbSw=;
        b=ifafUlU3V3wjcuMh2U5X0BC1S9Qx2QLDTnRGJv6jmxSpULaOy7fAz5XC76HOE5ZePe
         udVj2FGRkTO1et+o3dt/SBdQxzq2IkHAp6D9uJ6yvoI3bRKSOfhUir+kLCt3QC/wY3OE
         etU6fivW8PedwQ5hL+eAANQKViqI+Pb6sig7vVqE6TgvG4/M4R58FUS8P6azd7vMmhzA
         ts08V5S/oHaOO00ETRMtRztoW0a/TLUdq51n6AXIA++VUNyNttdNikGKwxUx2ROPSp9l
         KZDpoDSBTjybM1+qb6GTwjcOjjF1yCEpVpZpWTl5B1xAeUPEvl0IczMPp1EeDfBdnf2h
         sF3A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m14si8393qke.372.2019.06.20.03.35.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 03:35:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 074DF2E97C7;
	Thu, 20 Jun 2019 10:35:47 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-88.ams2.redhat.com [10.36.117.88])
	by smtp.corp.redhat.com (Postfix) with ESMTP id D445160600;
	Thu, 20 Jun 2019 10:35:41 +0000 (UTC)
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
Subject: [PATCH v2 2/6] drivers/base/memory: Use "unsigned long" for block ids
Date: Thu, 20 Jun 2019 12:35:16 +0200
Message-Id: <20190620103520.23481-3-david@redhat.com>
In-Reply-To: <20190620103520.23481-1-david@redhat.com>
References: <20190620103520.23481-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Thu, 20 Jun 2019 10:35:47 +0000 (UTC)
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
index 5947b5a5686d..c54e80fd25a8 100644
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
@@ -729,8 +729,8 @@ static void unregister_memory(struct memory_block *memory)
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
@@ -766,10 +766,10 @@ int create_memory_block_devices(unsigned long start, unsigned long size)
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

