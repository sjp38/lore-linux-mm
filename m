Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1EA18C7618F
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 20:25:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D207421851
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 20:25:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D207421851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0B4B06B0007; Wed, 17 Jul 2019 16:25:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F341F6B000A; Wed, 17 Jul 2019 16:25:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CE8CA8E0001; Wed, 17 Jul 2019 16:25:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id AD5D96B0007
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 16:25:35 -0400 (EDT)
Received: by mail-vk1-f200.google.com with SMTP id j63so11682046vkc.13
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 13:25:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=8l1yD18FgMCNHAuwCMb8dBirbWqz0p44kpnGc3Oqgw8=;
        b=P56gS56VgNqiz5pbkc/baUgZF4RJFo96vkSVTrqmr2fpix36O4y/VAHM7kY54vHhru
         a8zTSV+MDzP8lPbnFk09KbDeiWyb6CwgNO8KzpsSLiLb7R52b6KtKZ9IOo4p4iJ5dhI+
         qkvN7aYMQtXa1FpC+YFH2WZng4K9LHgWds4gb5misnrfAOqdRbW4axo16WVCTKg10IR6
         sWhY65Wr0kCuMwidNI9dOkutu3tokqEcVoFFUZFDAUuqdH7W58rfy/o9VKxMiPvkXVkw
         d4DzTMdMj3CvseCMBj5ud6O5vIWbcwtjjjYB+ps2Ncy97rDRQ+dHSzj2otwRTOSCnkEI
         yyug==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXilkwQOmlmr4l7Ff/CwDhXOJPxGyvdOVC2aOzjaVolwQhvNwtj
	6lc1FLsx2FSCJ0gHhM9T2rhjGz1jGGNDh8suFAOpIygIamnEtp5VJiHA6OrluvQjn4WAG6KR57I
	o8b55fzYiT0saKKi5KCca3vKfaoz+FeVUXUex+xmfM2446hpRaobCaO7rD1NZyyWHCg==
X-Received: by 2002:a67:f899:: with SMTP id h25mr25106217vso.159.1563395135494;
        Wed, 17 Jul 2019 13:25:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwKmhnCmqePNOrp8lpxmH8Vz0MeVFy2LCdYCyPv9uNsNYwYxFLMv07qBWi9CAnnFBTqLpUc
X-Received: by 2002:a67:f899:: with SMTP id h25mr25106141vso.159.1563395134872;
        Wed, 17 Jul 2019 13:25:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563395134; cv=none;
        d=google.com; s=arc-20160816;
        b=MId3xPdkM1CfYNh4acr6Eyn0n49H0gjic2BaOoVfnvkgsuIHiMpPPv1n1MA7+gdd84
         UQMQSSdtxyvwwlHbcme01SjlCgTl0S11b4O0SPLhVS0SY0sxpX2lXNRlmm5gNdensaZ8
         MEqx4sNCOFmI8EyRHmxOZkjSi1OqBRoWYsDDT1esDiJ6U53N4IUHtOAWm8cCEPmnlFvC
         up2qgR4Mwg3usOut8+YYk0/HYXLm/h5vhXCYWeglUVifvIt40X62GkSio5VDLLd+KYJW
         6R14jE8d7Nl2P9I1T8LryPtjUOeeQEi41pzAv6xiQ7aB6IN/hi936LjNAIyPm1BxRAIB
         jtWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=8l1yD18FgMCNHAuwCMb8dBirbWqz0p44kpnGc3Oqgw8=;
        b=pvReLOOCTYfCR2D/DhYloc3WDD2KniRe2CxWxR2caJYA2VXWKkNC+Ym0T0ikV8fEvm
         K42y7zZjX+DUZIoNiHs+Xyo+A9UKaSKJU3KxO/Y+74ZgA4DqDU5w43USNut0bQ5pF2Kw
         M04T1RtA9dTKGKkbGO+OBLMa2G+1CSz1AnlcprRs+cY+9m/T3RmSOPKjT+ACVICh60DK
         oqxvkcHcwYJEVIGq+/5h7vO+0/XNzID/OJsUUsoO2Ug1eCeqe3HDyjoUscsMxB0/6vbo
         KEXTVQejQnw+XpaH+XFdYPqiPSC/GGh9r9dTSuf9AqA0WME9q/kwfLrsKGJBTu8HYQU6
         /cVA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g39si9159203uah.54.2019.07.17.13.25.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 13:25:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0C66030842A0;
	Wed, 17 Jul 2019 20:25:34 +0000 (UTC)
Received: from llong.com (dhcp-17-160.bos.redhat.com [10.18.17.160])
	by smtp.corp.redhat.com (Postfix) with ESMTP id AB95B5C260;
	Wed, 17 Jul 2019 20:25:31 +0000 (UTC)
From: Waiman Long <longman@redhat.com>
To: Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Michal Hocko <mhocko@kernel.org>,
	Roman Gushchin <guro@fb.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Shakeel Butt <shakeelb@google.com>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Waiman Long <longman@redhat.com>
Subject: [PATCH v2 2/2] mm, slab: Show last shrink time in us when slab/shrink is read
Date: Wed, 17 Jul 2019 16:24:13 -0400
Message-Id: <20190717202413.13237-3-longman@redhat.com>
In-Reply-To: <20190717202413.13237-1-longman@redhat.com>
References: <20190717202413.13237-1-longman@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Wed, 17 Jul 2019 20:25:34 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The show method of /sys/kernel/slab/<slab>/shrink sysfs file currently
returns nothing. This is now modified to show the time of the last
cache shrink operation in us.

CONFIG_SLUB_DEBUG depends on CONFIG_SYSFS. So the new shrink_us field
is always available to the shrink methods.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 Documentation/ABI/testing/sysfs-kernel-slab |  2 ++
 include/linux/slub_def.h                    |  1 +
 mm/slub.c                                   | 12 +++++++++---
 3 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/Documentation/ABI/testing/sysfs-kernel-slab b/Documentation/ABI/testing/sysfs-kernel-slab
index 94ffd47fc8d7..9869a3f57dc3 100644
--- a/Documentation/ABI/testing/sysfs-kernel-slab
+++ b/Documentation/ABI/testing/sysfs-kernel-slab
@@ -437,6 +437,8 @@ Description:
 		write for shrinking the cache. Other input values are
 		considered invalid.  If it is a root cache, all the
 		child memcg caches will also be shrunk, if available.
+		When read, the time in us of the last cache shrink
+		operation is shown.
 
 What:		/sys/kernel/slab/cache/slab_size
 Date:		May 2007
diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index d2153789bd9f..055474197e83 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -113,6 +113,7 @@ struct kmem_cache {
 	/* For propagation, maximum size of a stored attr */
 	unsigned int max_attr_size;
 #ifdef CONFIG_SYSFS
+	unsigned int shrink_us;	/* Cache shrink time in us */
 	struct kset *memcg_kset;
 #endif
 #endif
diff --git a/mm/slub.c b/mm/slub.c
index 9736eb10dcb8..77d67a55ce43 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -34,6 +34,7 @@
 #include <linux/prefetch.h>
 #include <linux/memcontrol.h>
 #include <linux/random.h>
+#include <linux/sched/clock.h>
 
 #include <trace/events/kmem.h>
 
@@ -5287,16 +5288,21 @@ SLAB_ATTR(failslab);
 
 static ssize_t shrink_show(struct kmem_cache *s, char *buf)
 {
-	return 0;
+	return sprintf(buf, "%u\n", s->shrink_us);
 }
 
 static ssize_t shrink_store(struct kmem_cache *s,
 			const char *buf, size_t length)
 {
-	if (buf[0] == '1')
+	if (buf[0] == '1') {
+		u64 start = sched_clock();
+
 		kmem_cache_shrink_all(s);
-	else
+		s->shrink_us = (unsigned int)div_u64(sched_clock() - start,
+						     NSEC_PER_USEC);
+	} else {
 		return -EINVAL;
+	}
 	return length;
 }
 SLAB_ATTR(shrink);
-- 
2.18.1

