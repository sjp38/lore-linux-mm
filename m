Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3FBEDC31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 21:57:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6E1E820B7C
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 21:57:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6E1E820B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D81E36B000E; Wed, 12 Jun 2019 17:57:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D3AEF6B0010; Wed, 12 Jun 2019 17:57:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BF8D06B0010; Wed, 12 Jun 2019 17:57:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 85FE06B000D
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 17:57:17 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id e7so4745880plt.13
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 14:57:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=hjppE/WumFo4DDcjVHp53H+cJkxsiw3P9ewaFNh4A1w=;
        b=O353NqQgA6ALrq1hhpt0I2+eOoS73aJTm9SG3HAcKzOSSiKrGHIkuuWpZOvafVZoCe
         L+d1e5MCdQp9Di4J969dQZx0ybn8RVXZvtt+zjKuluWEwmnRymC9W8C+3SGjwq8NOBbF
         Y0T/N6Hp9zoA/jitfKvo1/vZ+d3bpWMQGF/FW2esY7fV5CZcTqRclZqw/XICv/mPg7KH
         6Fo2Hk6zXmsnqgOmowe1LoQmzPtT8IC4O8WGeIZ2C1sHgv0jc0MyPknpyG9s0HnEPKwV
         KL+o8HPQIyX4EG1leRAS6vTw6uUyE3+y6U6O3L0hxDlTBDDaCBdDEJ4wS2pcbIk0Vlix
         97Fw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWq4l3oylo/wrbYzorbuRoPaPTEUJOTGEz1x0YG+1rNPt4h6mnt
	Lr9ElM6b0gWf7UKPiNz7jIcf1V3O+zi0gLw0Yv8WyMBEYTtSg63XsKp6P5GyQDVmssVst1tcuY9
	jGO13nzN8M/0tIiXaeZE4jMWFjR0Fh6tKbiwotK4Dex4zvm77RH2MDmF5FuZ8OxWirA==
X-Received: by 2002:a17:902:21:: with SMTP id 30mr82687760pla.302.1560376637169;
        Wed, 12 Jun 2019 14:57:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyCZRiyiU+XEuEpqCIZWlcOr2OMNCFykgf3J+cp7fKU0XQzX29urRwV4RklYUVYsdAbzCpk
X-Received: by 2002:a17:902:21:: with SMTP id 30mr82687728pla.302.1560376636142;
        Wed, 12 Jun 2019 14:57:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560376636; cv=none;
        d=google.com; s=arc-20160816;
        b=ZpSyDfL9bAuHFs0Gcn7jJr22D5Y/5xGavEoC3+NFtiy4RoaRbIMpNr/IZxmo6EnxRg
         XycZxDg37r5is47zx+Xtr7tjQsLyWwZvwoxX84+6bhJAt3e9FA7bOWvyV6njyCATRMaJ
         jC+vojFt23t0c7qVFb7kfAkjmKVJ4S8XSHJgY887egSOuUXy2Pa3xKiD6b98FSIkJL6H
         BgRZg4Ayl+V8AgIHZg2MEu//HMcDtLv6nnJlZOCn+QjgfVQLhUqGpKBBlSzl29xRVdWY
         WqpyxGhH+7+ZNyufwial66Jf9hqqhJpDqF6Z0vsjeWxeEvvhapTgIOEOTKD4ErjCXg5O
         vawg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=hjppE/WumFo4DDcjVHp53H+cJkxsiw3P9ewaFNh4A1w=;
        b=RWJxRYIqyTTuYZqIeCsCn9aeO5XQK88iqAu8lxz6vSSThYeg6rY71VCeGCstezurpV
         Y835ucGet4dwwHYP/tKqV7ESt94p3ND4HfhocZQLrvchVo5A6e3rt5N306DLOH4YxAIv
         emEJ1gSJKk9RFpxMrv52CAmnmE85agfFX6jRGOgkKgSdG+slZGnp+jzlyv72EmrqXhF4
         hWYs86jtk5cy3yOKwjMNdueJVUubIwutwaNAuwap8Op8hKbP8KAbtgvDAixNugZuEIwi
         nZjGrA1TZa/W2r6Rz2qblzm3yhw9T5MfQ7C0P/l/s4uxgKGCCyOy5gJugNC2PbcIGIeS
         96tA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-56.freemail.mail.aliyun.com (out30-56.freemail.mail.aliyun.com. [115.124.30.56])
        by mx.google.com with ESMTPS id k7si712987pls.164.2019.06.12.14.57.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 14:57:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) client-ip=115.124.30.56;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R111e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07486;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=11;SR=0;TI=SMTPD_---0TU0Hbt._1560376624;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TU0Hbt._1560376624)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 13 Jun 2019 05:57:13 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: ktkhai@virtuozzo.com,
	kirill.shutemov@linux.intel.com,
	hannes@cmpxchg.org,
	mhocko@suse.com,
	hughd@google.com,
	shakeelb@google.com,
	rientjes@google.com,
	akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [v3 PATCH 0/4] Make deferred split shrinker memcg aware
Date: Thu, 13 Jun 2019 05:56:45 +0800
Message-Id: <1560376609-113689-1-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Currently THP deferred split shrinker is not memcg aware, this may cause
premature OOM with some configuration. For example the below test would
run into premature OOM easily:

$ cgcreate -g memory:thp
$ echo 4G > /sys/fs/cgroup/memory/thp/memory/limit_in_bytes
$ cgexec -g memory:thp transhuge-stress 4000

transhuge-stress comes from kernel selftest.

It is easy to hit OOM, but there are still a lot THP on the deferred
split queue, memcg direct reclaim can't touch them since the deferred
split shrinker is not memcg aware.

Convert deferred split shrinker memcg aware by introducing per memcg
deferred split queue.  The THP should be on either per node or per memcg
deferred split queue if it belongs to a memcg.  When the page is
immigrated to the other memcg, it will be immigrated to the target
memcg's deferred split queue too.

Reuse the second tail page's deferred_list for per memcg list since the
same THP can't be on multiple deferred split queues.

Make deferred split shrinker not depend on memcg kmem since it is not slab.
It doesn’t make sense to not shrink THP even though memcg kmem is disabled.

With the above change the test demonstrated above doesn’t trigger OOM even
though with cgroup.memory=nokmem.


Changelog:
v3: * Adopted the suggestion from Kirill Shutemov to move mem_cgroup_uncharge()
      out of __page_cache_release() in order to handle THP free properly. 
    * Adjusted the sequence of the patches per Kirill Shutemov. Dropped the
      patch 3/4 in v2.
    * Moved enqueuing THP onto "to" memcg deferred split queue after
      page->mem_cgroup is changed in memcg account move per Kirill Tkhai.
 
v2: * Adopted the suggestion from Krill Shutemov to extract deferred split
      fields into a struct to reduce code duplication (patch 1/4).  With this
      change, the lines of change is shrunk down to 198 from 278.
    * Removed memcg_deferred_list. Use deferred_list for both global and memcg.
      With the code deduplication, it doesn't make too much sense to keep it.
      Kirill Tkhai also suggested so.
    * Fixed typo for SHRINKER_NONSLAB.


Yang Shi (4):
      mm: thp: extract split_queue_* into a struct
      mm: move mem_cgroup_uncharge out of __page_cache_release()
      mm: shrinker: make shrinker not depend on memcg kmem
      mm: thp: make deferred split shrinker memcg aware

 include/linux/huge_mm.h    |  9 ++++++++
 include/linux/memcontrol.h |  4 ++++
 include/linux/mm_types.h   |  1 +
 include/linux/mmzone.h     | 12 ++++++++---
 include/linux/shrinker.h   |  3 +--
 mm/huge_memory.c           | 80 +++++++++++++++++++++++++++++++++++++++++++++-----------------------
 mm/memcontrol.c            | 24 +++++++++++++++++++++
 mm/page_alloc.c            |  9 +++++---
 mm/swap.c                  |  2 +-
 mm/vmscan.c                | 27 ++++++-----------------
 10 files changed, 114 insertions(+), 57 deletions(-)

