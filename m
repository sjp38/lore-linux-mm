Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5AAC3C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 11:02:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E8E6C2084D
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 11:02:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E8E6C2084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6C90B6B0005; Fri,  9 Aug 2019 07:02:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 678DB6B0006; Fri,  9 Aug 2019 07:02:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5430D6B0007; Fri,  9 Aug 2019 07:02:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 302146B0005
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 07:02:10 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id d9so85166196qko.8
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 04:02:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=bxaOVSytLRnuSziHuTf9oFGBP8IjwxE4TcQnhP6lZ1s=;
        b=a0lhsEGrH8sfUo/Nz0JhIEpCmGxzSgfWJvorPxOFnAlTUZsBCGgkHU6yOmBRPeIz4X
         tNQqOY4JuQm1VO/FPo5pDpqUvHWCSOFr1s6Tu/nDPgXbX1zJv9pA4goBMjLwCaBLwmik
         vQsYOrYHNKfazOUyTdwWNyzQEI6sSQdD379yehtHXUzzWrqJbhgCL0xCnEZCFeOIswc9
         EfqUJEzOFeEkTTGzxnKh/VhtwzU19IqCDel5bjw835rebeOH3wt2zy6lEsuG1kasQuw7
         k52I63UXFMgYrq2Eg+A2brIVTwxrOzF9/Wj5ucofN142pDzu71MbhjWJ2Z17y9UFbdKZ
         qXcg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU2pdY6LyRlFSOjYB6GTukcxKEpyV+tcuD2woSbkWDRmDHHrcfU
	3n8cS+6Zrn3DIl1zML0kohefnYrFamamQTOkHQbOynVZQGiWkwvjipIDdORbmeicmUq0RAxBHO/
	+gQ4hwOzfaZTjVc6Shc1jAMI+8SyhDIbv0tRTY2HKqPfc9NvTMANqlzqC/yIwYD1xOw==
X-Received: by 2002:ac8:929:: with SMTP id t38mr17581818qth.287.1565348529924;
        Fri, 09 Aug 2019 04:02:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwor31jJMv0cRIhQZ5tManAKO2NjU1f5NnX1jEaeTZpObTZquKVPHRNSVxhrPBK8j/wbUYS
X-Received: by 2002:ac8:929:: with SMTP id t38mr17581722qth.287.1565348528660;
        Fri, 09 Aug 2019 04:02:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565348528; cv=none;
        d=google.com; s=arc-20160816;
        b=S5sVVYVtAC03lyeqHpX+c6bgsx9Po+ccyO1WQ1dOZqhYxRx1/nG/ts0AZk2/JJ9HTe
         aN9k5StFfuxVdKYDcZdcLixiYZuE3gsC4NmlPkxoUCVrUY/LIr+5MOtFnZ0AB11JKbV1
         8Ikbs0wey1GPNtpNR+vUyeeQ3KkAFBbeAOtTJk5M4Yj9WSZqeS7xtFddCk8zSc8c4fmR
         IcGvJoFRqIMr3GF8LxwEBrWOlYOYpjbLHOhRFPCknNFZZWFG+JzwNUdIDQFdFwVw4mYL
         uTNX7EgEme0WtTM9xuzyAYPjQr/bKrRY2lHkUVKIYR5km9+C7yINVgayXG1OLeAvnowe
         Rvjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=bxaOVSytLRnuSziHuTf9oFGBP8IjwxE4TcQnhP6lZ1s=;
        b=e80At9Wfdniem8gUld+r0ZInMEdU5/SdG68QIstQGaF+2uZ5iZBDySFGeViyY5NfCM
         IELaQCaNCl1ilkAoYFxkG+N0ZF0n7yfsDaYJN4t0Jz46pzUE3q+Ne5Bj9hmoUXt9+sL9
         wpVdWM1gDY0K9rxhLCEDKpFqAujUyAci96tA8Hjp2AIl70l1Vx6FLiA6Lo8H80ytS8tL
         dm41D4DrXNTXWLWmce5c1DOVy/9ohtSYZIK2Bz9OROTz7qiNTg2E/N10lycWvu6vk6zt
         lYCOf5k5DoNYgKJT3H6xvx8ldLM9tHU1VqMmYEV2RtVySc2800T+BUoM5oEmX6a0BFsr
         IZhQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i22si59040493qvh.223.2019.08.09.04.02.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 04:02:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A13D530941C4;
	Fri,  9 Aug 2019 11:02:07 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-120.ams2.redhat.com [10.36.117.120])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 8F06E60481;
	Fri,  9 Aug 2019 11:02:01 +0000 (UTC)
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
Subject: [PATCH v2] drivers/base/memory.c: Don't store end_section_nr in memory blocks
Date: Fri,  9 Aug 2019 13:02:00 +0200
Message-Id: <20190809110200.2746-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Fri, 09 Aug 2019 11:02:07 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Each memory block spans the same amount of sections/pages/bytes. The size
is determined before the first memory block is created. No need to store
what we can easily calculate - and the calculations even look simpler now.

Michal brought up the idea of variable-sized memory blocks. However, if
we ever implement something like this, we will need an API compatibility
switch and reworks at various places (most code assumes a fixed memory
block size). So let's cleanup what we have right now.

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

v1 -> v2:
- Drop the macro for calculating the pfns per memory block

---
 drivers/base/memory.c  |  1 -
 drivers/base/node.c    | 10 +++++-----
 include/linux/memory.h |  1 -
 mm/memory_hotplug.c    |  2 +-
 4 files changed, 6 insertions(+), 8 deletions(-)

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
index 840c95baa1d8..257449cf061f 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -756,13 +756,13 @@ static int __ref get_nid_for_pfn(unsigned long pfn)
 static int register_mem_sect_under_node(struct memory_block *mem_blk,
 					 void *arg)
 {
+	unsigned long memory_block_pfns = memory_block_size_bytes() / PAGE_SIZE;
+	unsigned long start_pfn = section_nr_to_pfn(mem_blk->start_section_nr);
+	unsigned long end_pfn = start_pfn + memory_block_pfns - 1;
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
index 02e633f3ede0..704215d7258a 100644
--- a/include/linux/memory.h
+++ b/include/linux/memory.h
@@ -25,7 +25,6 @@
 
 struct memory_block {
 	unsigned long start_section_nr;
-	unsigned long end_section_nr;
 	unsigned long state;		/* serialized by the dev->lock */
 	int section_count;		/* serialized by mem_sysfs_mutex */
 	int online_type;		/* for passing data to online routine */
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

