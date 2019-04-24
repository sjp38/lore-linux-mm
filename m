Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 87336C282CE
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 10:25:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4F890218B0
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 10:25:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4F890218B0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 45AC46B0007; Wed, 24 Apr 2019 06:25:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 40C836B0008; Wed, 24 Apr 2019 06:25:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2AD666B000C; Wed, 24 Apr 2019 06:25:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0C1496B0007
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 06:25:42 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id p26so17238637qtq.21
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 03:25:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=X3Se80q1dKdim+vPqx/FPGIOapUfHtVIBKJDjYe8V8k=;
        b=QjbP70HAIyzVPochIxS7B32gcF4un4fcd4JqiB3e+JJsXUMpQolaL3o/mwe1+B1VDN
         E6IkgBJY1Al3FPwcEwUrDel/cmXFoaRnb/FqAQHvtoDGB64Vb0J9mT6Ial88pYxuhieq
         gcEO5wjgoZGTZu5tYunFRiF4rwY8ukJira4DKL9nXMUin4vDvGowX+6VTSS5EvZ+7Lq9
         zCO3SCQ8TDo5/nIka75kI4Vhf9Dw69tu8BP0306RE04p2fR1c3KHfgpNFXYtGRb2ZzOD
         YzxDJlvYBNSOj6W7gGF2XUkGx+uEiJNJJ3SFmSoFI7T89Tj9gJHRYbGUpWBnW8s0NAhG
         kL/w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUGJ8r9k8bJEFTlY8uWRr9RTaToX4ETUVUt8SAx9fOx20/FtEOk
	GloT2iTIWH1XRMD+3+58vZVias3lk8WkUwZXINMHLPon3jA/3XFiGeqf1hag5S8IhcSIIEWVBGJ
	oP7HwtS1d9ybOfgdrcDl0mSSzIDAJyNsIaQiqXxl9320SGRJQUTZ1P757uozWOQ9Rlw==
X-Received: by 2002:a05:6214:162:: with SMTP id y2mr5270025qvs.157.1556101541825;
        Wed, 24 Apr 2019 03:25:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz1M3V8eS4QwXdPjVL12zypdmXXxd9zWHJSLSB87matZkh/mYtaMph02DAB4fbI9iXMENJl
X-Received: by 2002:a05:6214:162:: with SMTP id y2mr5269977qvs.157.1556101540980;
        Wed, 24 Apr 2019 03:25:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556101540; cv=none;
        d=google.com; s=arc-20160816;
        b=HHWJ+Q9oDlgGvujWU+crFYq24zRmJdW5eBct+TBe3u+xRbw2+QjglCcgrWaCBt9cQi
         MMalsp1CTkv1/GDaKxdkdr7KtvuRQ1KJghKEbyst2Xr0MdNIQ3FOYpGEkHqp2oGhsY+8
         uYCDmMJQH9Kw9eFDUrPTuYbbUgfba4hEBaImRtNufS5/TTRkqi3dxMJFfBQj8y2lVBOI
         aypfM9PNIjRcdmgsfWqJGRe+M9pGYfYAIPqNm10xNhFYZtCGQw7F1nzwDQUAMTtlW0PL
         vX0nG4nu0y+74b5UxIS79QDHtfQR8P56m6A8Z9nTa6B5t4BPxjO9Uxlc4uo51SLse6If
         e3cA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=X3Se80q1dKdim+vPqx/FPGIOapUfHtVIBKJDjYe8V8k=;
        b=lncWN2VEWVkdkl/C1XNeXa9pSnSOGjYF1x1KL/rAaqTGD1/7Vcl80MOEgWyTLmUNeo
         /9R9yUTY8JZ6VN80JkRF5TiFD9uV/6gckyMpYtXqdrcK4Zi2nsa1ZuuAtQJwyEVxeIXA
         zX9MWQcbWJX2NADYUJZdJUw4YPVXMsQ14+pAQUep+dxo4gyl2boqM33OoYkjppsjrVzc
         UYQS9syvmJXEQdlH1gmHSSZyr5OqOJ8KFR89AQk3PMqP5bZI8JCsmYvgzGuTHwealPdA
         7xCkj8IGRfUSYbhQ+K2fp6Wu5sw7uhmMMcNib0tIIjP4YGyoVM0uPSHd6GwRt1235vQK
         WlpA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b5si1182817qtr.404.2019.04.24.03.25.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 03:25:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 10061308FB9D;
	Wed, 24 Apr 2019 10:25:39 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-116-45.ams2.redhat.com [10.36.116.45])
	by smtp.corp.redhat.com (Postfix) with ESMTP id F03CD600C1;
	Wed, 24 Apr 2019 10:25:33 +0000 (UTC)
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
	Oscar Salvador <osalvador@suse.de>,
	Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Qian Cai <cai@lca.pw>,
	Wei Yang <richard.weiyang@gmail.com>,
	Arun KS <arunks@codeaurora.org>,
	Mathieu Malaterre <malat@debian.org>
Subject: [PATCH v1 1/7] mm/memory_hotplug: Simplify and fix check_hotplug_memory_range()
Date: Wed, 24 Apr 2019 12:25:05 +0200
Message-Id: <20190424102511.29318-2-david@redhat.com>
In-Reply-To: <20190424102511.29318-1-david@redhat.com>
References: <20190424102511.29318-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Wed, 24 Apr 2019 10:25:39 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

By converting start and size to page granularity, we actually ignore
unaligned parts within a page instead of properly bailing out with an
error.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Michal Hocko <mhocko@suse.com>
Cc: David Hildenbrand <david@redhat.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Qian Cai <cai@lca.pw>
Cc: Wei Yang <richard.weiyang@gmail.com>
Cc: Arun KS <arunks@codeaurora.org>
Cc: Mathieu Malaterre <malat@debian.org>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 mm/memory_hotplug.c | 11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 328878b6799d..202febe88b58 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1050,16 +1050,11 @@ int try_online_node(int nid)
 
 static int check_hotplug_memory_range(u64 start, u64 size)
 {
-	unsigned long block_sz = memory_block_size_bytes();
-	u64 block_nr_pages = block_sz >> PAGE_SHIFT;
-	u64 nr_pages = size >> PAGE_SHIFT;
-	u64 start_pfn = PFN_DOWN(start);
-
 	/* memory range must be block size aligned */
-	if (!nr_pages || !IS_ALIGNED(start_pfn, block_nr_pages) ||
-	    !IS_ALIGNED(nr_pages, block_nr_pages)) {
+	if (!size || !IS_ALIGNED(start, memory_block_size_bytes()) ||
+	    !IS_ALIGNED(size, memory_block_size_bytes())) {
 		pr_err("Block size [%#lx] unaligned hotplug range: start %#llx, size %#llx",
-		       block_sz, start, size);
+		       memory_block_size_bytes(), start, size);
 		return -EINVAL;
 	}
 
-- 
2.20.1

