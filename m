Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A186CC10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 12:48:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E9972183E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 12:48:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Lyq/6LL/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E9972183E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0B6556B0008; Thu, 18 Apr 2019 08:48:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 065DB6B000A; Thu, 18 Apr 2019 08:48:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EBE746B000C; Thu, 18 Apr 2019 08:48:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id B99696B0008
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 08:48:47 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id e20so1339315pfn.8
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 05:48:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=Us+svWaeNHdKG5ZAI4/Uc7cIe1kfHBuE1Cz//sXnbCg=;
        b=YlbkNscmIWFsNcxfoW9EwtNavsQ/Z8VJ5ykk1Jf4CNt1XDURwFb3OMKFCQCpbJxWAL
         47T9xR/UHd3LkhsQ14NDZgqZJeaMAKth6A6DmCU7tiw/6p1RzbKJmWLgOQM/VbWIciSL
         MrN0cvdm9ZUZc3DtyJx2FrH8wZwCzp+6ms5iO+o1KywXCvZ7OxOnOfvAauuT+nX+EaAV
         KVWvNpvC+lCozYftteN8VQtGVG+zrvU8McmSlJfE2bdsecTNPOyoQK0l/Kngx8F2R6KM
         Yr8wY8BrNPkP4ahBQs62MfqrNuPiWjPw2YEWPypkDjWUF3yr6x/XTzHmmK6bLoOueRqo
         zh2A==
X-Gm-Message-State: APjAAAWfzfO0VztKasb3ujGLF0HV0gRbq1XjQnbUJmH1XWTyvgv4pIPK
	7UHW/K8mg44eL3FlS2+/FSrqWnuACkXCLIPB9EOI2qqPU8hDqXUj+1zXN/V3iesyuL/AF9MgvfH
	hlpid1wr7aGo02KTacXjjvZjPWxta7IJ5CuX2K7toORf8Y/aV2qKLjYcstQQv/C5o6g==
X-Received: by 2002:a63:d709:: with SMTP id d9mr85048700pgg.38.1555591727308;
        Thu, 18 Apr 2019 05:48:47 -0700 (PDT)
X-Received: by 2002:a63:d709:: with SMTP id d9mr85048585pgg.38.1555591725492;
        Thu, 18 Apr 2019 05:48:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555591725; cv=none;
        d=google.com; s=arc-20160816;
        b=VxCkiRjR8lO+LjovCsLrU3YgsntR31f1zNlzm+LfXJejgshScAfEfmuR87+rGQgYe/
         /MEsMhxt1qhwpcZtKK5ClhFlVi4ZEyTmqHHJf0jFHQ2Z1+JeROV457dyAOzNnezHnNA9
         TGl+PLt3vnAWlOidMo8VaKpqEqbZ3hvKC4kuEU0e7dZdt5jt8mbQ5JfH34oZi9wIvbOK
         RpQW3NtK/NszQsc0fhoy7jC/s7oRkcy8Itvk+/8ys8GtZ1HIGIFV1lrIOdw8dMPy/6bb
         INvsW7j7U5D87v9la2xtNxiZOc38rHNKzapZI8dxyLxmW3V/0bf0OMlLD5OmH4ig0VzI
         91tA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=Us+svWaeNHdKG5ZAI4/Uc7cIe1kfHBuE1Cz//sXnbCg=;
        b=f6MZjlMDvgwLalm2z91mvRXR+jD/MxK/OKNXfvZltNZzgY0kitO4eWWjLrcIGC2OX8
         JZjb1uqqS+mQDQszBWI+cQeoqSKFsV4PmnF7a5eBCp8qKLStXvokiUPOJsY23wgVg2Uj
         T/TYpNEW2GkSq8bh9WKpWY/DNNBiihKm6ruKl/5HjWR0hrAfTfw7EeEcWpxH0hgVwwbY
         E0BMcw6Bxn+etyoSBVHlOoj4kaM3eRbVoBqd6WmVJT2DDnPOCb6LyK4rJpbRGf6kz0Ip
         7qOmgTV/VV3sDb7RM/EkjR/WPvKqvLoZwHKWJ0mZsa9SkHxNiA58gvSRZJbegbbKOLv9
         +mJw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="Lyq/6LL/";
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z64sor2147883pfz.2.2019.04.18.05.48.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Apr 2019 05:48:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="Lyq/6LL/";
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=Us+svWaeNHdKG5ZAI4/Uc7cIe1kfHBuE1Cz//sXnbCg=;
        b=Lyq/6LL/vm9/9CntnBe3jua+7oE3/LUJep8Bx/8sZpNC2pD54b80smXs13QdfMnU+Z
         6W/5IqvwTpg8qqIosDyVuqtpm6W5OdYolIn19T0vRy2UfnCkzkPXe0ZMMPrMQQFs98O0
         dAvSzJS2UoYH8dC+uA4BJWLqBKE/pfbeESxlV49veF6uLBTDJYyk6dHdxiNTC/aQg1y5
         HbEil4I9OvsYqco+aRRzcvPFvwdXXX4XlukRcLC28Cqa4yRYinfZrYUULKItOExi4m1X
         SvWKCCXy9LzCwscNE8zEfiAt3NsdiazHf+2xRSAvedFouvYAzWElY8mC+9h56UfP89Qz
         GIFQ==
X-Google-Smtp-Source: APXvYqxSfPUDUJej9maChFxjvAQYyJ117+2VbYYM/a6x4Gh0h2McSHy+5zLEI59Yj3sE0U+qZTHekQ==
X-Received: by 2002:a62:7591:: with SMTP id q139mr82209903pfc.14.1555591725235;
        Thu, 18 Apr 2019 05:48:45 -0700 (PDT)
Received: from localhost.localdomain ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id v12sm2908790pfe.148.2019.04.18.05.48.42
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 05:48:44 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
To: mhocko@suse.com,
	vbabka@suse.cz,
	akpm@linux-foundation.org
Cc: linux-mm@kvack.org,
	shaoyafang@didiglobal.com,
	Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH] mm/page_alloc: remove unnecessary parameter in rmqueue_pcplist
Date: Thu, 18 Apr 2019 20:48:29 +0800
Message-Id: <1555591709-11744-1-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Because rmqueue_pcplist() is only called when order is 0,
we don't need to use order as a parameter.

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
---
 mm/page_alloc.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f752025..25518bf 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3096,9 +3096,8 @@ static struct page *__rmqueue_pcplist(struct zone *zone, int migratetype,
 
 /* Lock and remove page from the per-cpu list */
 static struct page *rmqueue_pcplist(struct zone *preferred_zone,
-			struct zone *zone, unsigned int order,
-			gfp_t gfp_flags, int migratetype,
-			unsigned int alloc_flags)
+			struct zone *zone, gfp_t gfp_flags,
+			int migratetype, unsigned int alloc_flags)
 {
 	struct per_cpu_pages *pcp;
 	struct list_head *list;
@@ -3110,7 +3109,7 @@ static struct page *rmqueue_pcplist(struct zone *preferred_zone,
 	list = &pcp->lists[migratetype];
 	page = __rmqueue_pcplist(zone,  migratetype, alloc_flags, pcp, list);
 	if (page) {
-		__count_zid_vm_events(PGALLOC, page_zonenum(page), 1 << order);
+		__count_zid_vm_events(PGALLOC, page_zonenum(page), 1);
 		zone_statistics(preferred_zone, zone);
 	}
 	local_irq_restore(flags);
@@ -3130,8 +3129,8 @@ struct page *rmqueue(struct zone *preferred_zone,
 	struct page *page;
 
 	if (likely(order == 0)) {
-		page = rmqueue_pcplist(preferred_zone, zone, order,
-				gfp_flags, migratetype, alloc_flags);
+		page = rmqueue_pcplist(preferred_zone, zone, gfp_flags,
+					migratetype, alloc_flags);
 		goto out;
 	}
 
-- 
1.8.3.1

