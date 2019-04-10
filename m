Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28D76C10F11
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 19:14:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DEA01205ED
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 19:14:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DEA01205ED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1BF066B0006; Wed, 10 Apr 2019 15:14:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1701B6B0008; Wed, 10 Apr 2019 15:14:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 053CE6B000A; Wed, 10 Apr 2019 15:14:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id CA74A6B0006
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 15:14:01 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id d139so2878117qke.20
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 12:14:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=DBnRKe3YvnMxKXTvsMS+Ndxzgp3NvLrWe0H5kgMgy5M=;
        b=VTXdtt27h6qClaHOcfsA/BqQSayBZ9AMXl6bK2m2qY5Dpi/XYBabb3WGxuxpaO4hvG
         z7DJLtj8fYqQM1Jj7MvF2zxj5WLhjn/D8FrOABZRaV7JaeufYIXZZpaeeqeMdyBR0Jrp
         7QPkLDh2WINM4f56jLpblNdK4DtJniasDP2AY5EQk1iKwjQhiOEOSwQL60OqwMAMKq5z
         MyQulOYIO69JcJJYzoCk19ubdGXEx282F9Arelj+hli9eQ3Hv85ImC+H4a18qaRsJNhI
         2yspAJXs3z/QmfbQk8wy2eWin3sc2IeECMphNl11my06D3GlT+sCBjd4LwDXW78Q3wIA
         8mJQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXcFyX5UztY4rB367w7nw+X6/wAb5DDnMQIgFV9BLFZLcaSF/Gp
	o6dKmLud/gWyuwLD8O7oXb804Hm2B3rX6BG6flnZx75enz3CoBY2q2aamPii4QTjhA2gmCzDsPn
	nDeEsvr+1LjMyJSfA3a47ad4iCuyjWjlLedBuKJjypYZUUcdfbdO1EN3S4fu2toszGw==
X-Received: by 2002:a05:620a:1266:: with SMTP id b6mr34709002qkl.83.1554923641587;
        Wed, 10 Apr 2019 12:14:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx/s7uyOls447ca8vNRL7f7BrNFdRRjPIqZ3n25Ncxolo8AAUHZLx4ofjTXdrLKsxY4ZMG1
X-Received: by 2002:a05:620a:1266:: with SMTP id b6mr34708917qkl.83.1554923640430;
        Wed, 10 Apr 2019 12:14:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554923640; cv=none;
        d=google.com; s=arc-20160816;
        b=VuZCQpiwOReEzaFEgI4o/PovqbSO0t4IzZ1ypZN9dYwl+GG64uVM9Cds8uRwo05ppc
         ckWJSbDPpmYZeK9K/Iz9KhjfA4ITpLZT0OoZU3o9vMU9ycednzgt4wJnDUC0Xlu+tXTI
         whO3ANXCXkra3DIkv8XuO/Do5LS4W0sf80dCSfic4s58f/d21El+HxH+LvzGfY1WsUTu
         vrII30rol+K4PklWh2yGzDxDA5i96jLWnY9PI3N25eoBWxt7/L/fEZQNYKlHAj2OrPyr
         KonEqO4dMwwgcnpkpaQirMI5r7bXOBJYOeHewcelxgoYO6uW5PX7vzNd/1WSbg+JHuZS
         Bbiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=DBnRKe3YvnMxKXTvsMS+Ndxzgp3NvLrWe0H5kgMgy5M=;
        b=CeuGfVL4ODAzQQzFJ1YGPHJPMpD6ThETMmqX87LNrLydT8Bm2o6CZ2YzXc2b3n6uGd
         tQzn6oZdwzVKB+cmUKaP6ERWBkAgWk2vUNjd6GxqSXwJFqOdaMmnQiJI/ETlh5+pqc60
         e+dQZ8dthhP1Bo4qHg5AiqosA8mXwyKBuX40ih1H2zqQhTOfZXQxT2mjcJYtX1hzspeY
         9O7+ItZbyae+gbwUsbEIOgHrixjuVeDb2UMNFeL6618cKvrt7TdeMmFa9oASeACd5+Ja
         WByi1laXdPzjZeIDDBN5uo331ASK7di1GWj+UraEV6mTpyLU5jlVwSF6fI+BSJzdKIMH
         l4Hg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x13si3258230qtr.192.2019.04.10.12.14.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 12:14:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6E7063086225;
	Wed, 10 Apr 2019 19:13:59 +0000 (UTC)
Received: from llong.com (ovpn-120-189.rdu2.redhat.com [10.10.120.189])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 8F2FD600CC;
	Wed, 10 Apr 2019 19:13:57 +0000 (UTC)
From: Waiman Long <longman@redhat.com>
To: Tejun Heo <tj@kernel.org>,
	Li Zefan <lizefan@huawei.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Jonathan Corbet <corbet@lwn.net>,
	Michal Hocko <mhocko@kernel.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: linux-kernel@vger.kernel.org,
	cgroups@vger.kernel.org,
	linux-doc@vger.kernel.org,
	linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>,
	Shakeel Butt <shakeelb@google.com>,
	Kirill Tkhai <ktkhai@virtuozzo.com>,
	Aaron Lu <aaron.lu@intel.com>,
	Waiman Long <longman@redhat.com>
Subject: [RFC PATCH 2/2] mm/memcontrol: Add a new MEMCG_SUBSET_HIGH event
Date: Wed, 10 Apr 2019 15:13:21 -0400
Message-Id: <20190410191321.9527-3-longman@redhat.com>
In-Reply-To: <20190410191321.9527-1-longman@redhat.com>
References: <20190410191321.9527-1-longman@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Wed, 10 Apr 2019 19:13:59 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

A new MEMCG_SUBSET_HIGH event is added to record the number of times
subset.high value is exceeded.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 include/linux/memcontrol.h | 1 +
 mm/memcontrol.c            | 6 +++++-
 2 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 1baf3e4a9eeb..4498db61507a 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -52,6 +52,7 @@ enum memcg_memory_event {
 	MEMCG_LOW,
 	MEMCG_HIGH,
 	MEMCG_MAX,
+	MEMCG_SUBSET_HIGH,
 	MEMCG_OOM,
 	MEMCG_OOM_KILL,
 	MEMCG_SWAP_MAX,
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 7e52adea60d9..feba8b9c55b3 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2150,8 +2150,10 @@ static void reclaim_high(struct mem_cgroup *memcg,
 	/*
 	 * Try memory reclaim if subset_high is exceeded.
 	 */
-	if (mtype && (memcg_page_state(memcg, mtype) > memcg->subset_high))
+	if (mtype && (memcg_page_state(memcg, mtype) > memcg->subset_high)) {
+		memcg_memory_event(memcg, MEMCG_SUBSET_HIGH);
 		try_to_free_mem_cgroup_pages(memcg, nr_pages, gfp_mask, true);
+	}
 
 	do {
 		if (page_counter_read(&memcg->memory) <= memcg->high)
@@ -5603,6 +5605,8 @@ static int memory_events_show(struct seq_file *m, void *v)
 		   atomic_long_read(&memcg->memory_events[MEMCG_HIGH]));
 	seq_printf(m, "max %lu\n",
 		   atomic_long_read(&memcg->memory_events[MEMCG_MAX]));
+	seq_printf(m, "subset_high %lu\n",
+		   atomic_long_read(&memcg->memory_events[MEMCG_SUBSET_HIGH]));
 	seq_printf(m, "oom %lu\n",
 		   atomic_long_read(&memcg->memory_events[MEMCG_OOM]));
 	seq_printf(m, "oom_kill %lu\n",
-- 
2.18.1

