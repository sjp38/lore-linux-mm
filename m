Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C843C04AB3
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 11:12:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D3D0F2146F
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 11:12:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D3D0F2146F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 784346B0278; Mon, 27 May 2019 07:12:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 75AF36B0279; Mon, 27 May 2019 07:12:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5D4A46B027A; Mon, 27 May 2019 07:12:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3567E6B0278
	for <linux-mm@kvack.org>; Mon, 27 May 2019 07:12:32 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id r78so5294136oie.8
        for <linux-mm@kvack.org>; Mon, 27 May 2019 04:12:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=FNTktvj0kV+SOdLAQ71+yr15WutmVjJpnyIy6jk9OZM=;
        b=T70ZJfUlRpS3gc1fpb7E57bu3dfGlN6gZym3N7P3dkaUV/AApz0rnzrJpiS4rkTXXT
         t6ftgwy49R9v2O3ciGTJPc651aJq48uW+kX8DVxHR1gcwVbnSiuqfawicpT965DZVBNj
         j1dmYC1vlozZY+AdQglCGMYQrTsqlso9ftnEBzagLnBU6AWB3fd2kJKzR1hU4RMakexi
         Hs2/lgYHVD5DsBj1TL2ICBw731IesZyYbRZ0oin1dsvW/hNB/sqM7EE8i/X3Xyj+q9LE
         lAVGWPYQacGtFGchJRy2cKTGRNZD0d7kAltqLzTwUEDLJEJFxRxgQav6Q1voK6erZ7j5
         mUtw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWhEPI1sbGKD8e7qXVJomrazS9vTeAl7/oLIWg3xvaDFDCQmO33
	0MJ3xKm31E1XTIL1gwhpiSKW1anG+QA1ShdkI6PD/4XJeH+6l4Y7z9YCbd92q/6isrcLqlO3eNo
	3y+RfSXzLbXRytOW/gCPi702A+WrX5rMMF3xyhBvN3gh0QTjuE04bl6HZ3Hjhmch1aA==
X-Received: by 2002:a9d:6287:: with SMTP id x7mr22722402otk.287.1558955551913;
        Mon, 27 May 2019 04:12:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyZ8sQfhP38lV3aOH75A7pSjctcddeZX6MqBND8EnimWoK0gR469rsfPR2v4mMWZ5u1jiS6
X-Received: by 2002:a9d:6287:: with SMTP id x7mr22722368otk.287.1558955551350;
        Mon, 27 May 2019 04:12:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558955551; cv=none;
        d=google.com; s=arc-20160816;
        b=MDmPBaBQdPvSTgoIPAV0MN+Bz7znOXcBzQiF0TN6JjdV6cUMFblDp72H3zUxRvtw8p
         9IBnhkn4EtLfZBVs0paD9VAyZvBpavv+ae+5GSlIe6haq5joRZ+Ydlva4tTJ/dlhDSQu
         VSlfXA4wNUPvXCSpug9rLjTIqFkPYfL7S2MfQfOXUu9oWYNoZ5PLpmlxjOLHBXE+fJGm
         4pCClf1XXaS9hLUL3G77yTA/psV8OHdusG9oJUEQ63IpRtmCf6ys/6z3xSfnF8wKVesK
         UYZuWiUnviYPmJo1xATFj+33Wd9/oZeIR4eTvm2Zs6+6JSq1aSulTgXQm128SNwvg1fn
         xT4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=FNTktvj0kV+SOdLAQ71+yr15WutmVjJpnyIy6jk9OZM=;
        b=AKcdprAYQD+MtiakdtxOBf3Hhfe7kY/rf0sJs+ewv4kt9S1h5Djqthg4vEwjHYJD96
         JgU/O2qX1VlrnbR8ToEPYAUD7+2jQhfYs8vyVOpso/Ouqp6nZQGKH3J6uV27ghUtORuq
         diOWsdbQ63yVhPFONP/ihr0Ib9X3+64lg0MdsXBABK68GZYug/LM00pEnnSn5TtKn8YB
         8iIZESQu52G3ary/REh/YyWf5Ba4LpwcwKinZrCPgASEgP9F+XYX35vqWLZZvAqQ9HJs
         my9JnbJvxBaH6i0W/MZiSK/xoE0lzbJ1a8ix2flqz5Ct+sLy0Nl6AyoTleOvdJmyZ3nA
         Rx1g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r84si4664079oig.180.2019.05.27.04.12.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 04:12:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B17DE88319;
	Mon, 27 May 2019 11:12:30 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-89.ams2.redhat.com [10.36.117.89])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 0FD3919C7F;
	Mon, 27 May 2019 11:12:27 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	linux-ia64@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	akpm@linux-foundation.org,
	Dan Williams <dan.j.williams@intel.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Igor Mammedov <imammedo@redhat.com>,
	David Hildenbrand <david@redhat.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>
Subject: [PATCH v3 05/11] drivers/base/memory: Pass a block_id to init_memory_block()
Date: Mon, 27 May 2019 13:11:46 +0200
Message-Id: <20190527111152.16324-6-david@redhat.com>
In-Reply-To: <20190527111152.16324-1-david@redhat.com>
References: <20190527111152.16324-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Mon, 27 May 2019 11:12:30 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We'll rework hotplug_memory_register() shortly, so it no longer consumes
pass a section.

Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 drivers/base/memory.c | 15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index f180427e48f4..f914fa6fe350 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -651,21 +651,18 @@ int register_memory(struct memory_block *memory)
 	return ret;
 }
 
-static int init_memory_block(struct memory_block **memory,
-			     struct mem_section *section, unsigned long state)
+static int init_memory_block(struct memory_block **memory, int block_id,
+			     unsigned long state)
 {
 	struct memory_block *mem;
 	unsigned long start_pfn;
-	int scn_nr;
 	int ret = 0;
 
 	mem = kzalloc(sizeof(*mem), GFP_KERNEL);
 	if (!mem)
 		return -ENOMEM;
 
-	scn_nr = __section_nr(section);
-	mem->start_section_nr =
-			base_memory_block_id(scn_nr) * sections_per_block;
+	mem->start_section_nr = block_id * sections_per_block;
 	mem->end_section_nr = mem->start_section_nr + sections_per_block - 1;
 	mem->state = state;
 	start_pfn = section_nr_to_pfn(mem->start_section_nr);
@@ -694,7 +691,8 @@ static int add_memory_block(int base_section_nr)
 
 	if (section_count == 0)
 		return 0;
-	ret = init_memory_block(&mem, __nr_to_section(section_nr), MEM_ONLINE);
+	ret = init_memory_block(&mem, base_memory_block_id(base_section_nr),
+				MEM_ONLINE);
 	if (ret)
 		return ret;
 	mem->section_count = section_count;
@@ -707,6 +705,7 @@ static int add_memory_block(int base_section_nr)
  */
 int hotplug_memory_register(int nid, struct mem_section *section)
 {
+	int block_id = base_memory_block_id(__section_nr(section));
 	int ret = 0;
 	struct memory_block *mem;
 
@@ -717,7 +716,7 @@ int hotplug_memory_register(int nid, struct mem_section *section)
 		mem->section_count++;
 		put_device(&mem->dev);
 	} else {
-		ret = init_memory_block(&mem, section, MEM_OFFLINE);
+		ret = init_memory_block(&mem, block_id, MEM_OFFLINE);
 		if (ret)
 			goto out;
 		mem->section_count++;
-- 
2.20.1

