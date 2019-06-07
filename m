Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 73C9DC46470
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 06:08:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3023A208C3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 06:08:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3023A208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C0DB26B026B; Fri,  7 Jun 2019 02:08:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BC6A36B0271; Fri,  7 Jun 2019 02:08:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A854E6B0272; Fri,  7 Jun 2019 02:08:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6CA8F6B0271
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 02:08:26 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id e69so737527pgc.7
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 23:08:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=kobkxat34d1e9l/huh9zUhqEVZBstZvmQBkA4UmXIeg=;
        b=IvFydUUd56Os7BfSmmO1wUQM4AKC+FF+lRY1tpw9wTqHK6/1tBR2PB2fXoBxcTFYyP
         Om8d1cKmuq/e10KqM/wjbSucZLZgg99RxTkw66DPaXdm+smw4TN+IjoA87Sv3Hvw+9RU
         z4um/miaWIV0bybcCtTOwRqIVRRNye0FySHVH2PvoMrv1HuNZlbzVxQoev2IN+c+LlMU
         V55d6Mtcq+R4BONo5QMGOyAZxhFLv+HCiaJXesahA4ncWCH9C6LJDtVJe4SFYdNUnGhW
         11VTxxT+BPjH1f2rCrgbDYriKWu7XJppbap2E9RfqoIpcdaH2amIKOOpcdGBM/CCpxLl
         9rpQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAX3DS0OFb1wX7R39DZv4m53eH6VhraO2svaoP2ya5JlXLTBeqsL
	lG+8BWItzcxUPbz9C997aKigD2amsOoZ9iQaYlT7Vudavb3wl0SQD9NAcLsgKuPNW63hdOwqWfV
	Tf61CqaFiF22dJuYfEPrmjDii8uvOb6L3qJbu/icEWvuNdyZuVKvljY6fsehIoz1r/Q==
X-Received: by 2002:a62:2c8e:: with SMTP id s136mr12418487pfs.3.1559887705947;
        Thu, 06 Jun 2019 23:08:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz8Td262Zpr78K3Q7MGb+4jdse42uZe2ZwnC3yJzH+bVOV9OE6WZNHQhwz8CYIbTciEo63H
X-Received: by 2002:a62:2c8e:: with SMTP id s136mr12418406pfs.3.1559887705063;
        Thu, 06 Jun 2019 23:08:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559887705; cv=none;
        d=google.com; s=arc-20160816;
        b=Tz9dR7M7YDGEbxVkech/fUIqQEVwiEpI3oFzL8bY+T2/CKXAGLSa594wn2JVSERKHB
         jS1zcBp9tcgvS5Xe6FXTaQClNv9P4CQPCrJfw2puyVGsDbnsxW0qHLmmTJBp26LMFaKV
         E/rz0xoq7oL7oTK3Itn22dIdD8FQOwOpYYWT40376bL4a6M+L0TygOV99JqCxeGE2AAf
         JiL/9gwpgcXZq4CIDBc6+nhtgqI9FxMmHuI05nGLd8tQ+UXaBwQqdcjVEWru7W/gBwF5
         CBsLxpAWWt2P2b3nkROvyFEG/5UXEES1Y1SVENQjfY71+9fszPWKeDK6q52synaGwHQ+
         5c3A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=kobkxat34d1e9l/huh9zUhqEVZBstZvmQBkA4UmXIeg=;
        b=YPlUpHTn1WaJ2StO/T1PFjxJ6dqFTnnkYfWM66C097WtAX4U8TYW28lF7769fHkTS7
         dW16StqxmjD3pACLGpXVmVqmPVMd2ylBxP0JX+otgMv9JjS5qNdewx67IxJqG2BBeztf
         1ZQv3I8h6zHwuayOQGhI6ueFk3yMB4ue8/Dcl1fDlt+3D5QEJKSWRPZrXKSjYtZ/Wghj
         xaHqS4O5APz/HzBVXSCLbSi8B4ml/smB7S7wJZO51RKIMj3JLPa2UfSw365kFIuWKVAL
         HDIHNBGGqi4wMbKNI98cJJJpmdbT6xJxdrxq1BdeZgF0h2zHb5X7KF2QRCF0OJIf91+M
         ymeA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id l6si929299pjq.81.2019.06.06.23.08.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 23:08:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) client-ip=47.88.44.37;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R201e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e01422;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=11;SR=0;TI=SMTPD_---0TTcZLUN_1559887677;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TTcZLUN_1559887677)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 07 Jun 2019 14:08:09 +0800
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
Subject: [v2 PATCH 0/4] Make deferred split shrinker memcg aware
Date: Fri,  7 Jun 2019 14:07:35 +0800
Message-Id: <1559887659-23121-1-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
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

And, move deleting THP from deferred split queue in page free before
memcg uncharge so that the page's memcg information is available.

Reuse the second tail page's deferred_list for per memcg list since the
same THP can't be on multiple deferred split queues.

Remove THP specific destructor since it is not used anymore with memcg
aware THP shrinker (Please see the commit log of patch 3/4 for the details).

Make deferred split shrinker not depend on memcg kmem since it is not slab.
It doesn't make sense to not shrink THP even though memcg kmem is disabled.

With the above change the test demonstrated above doesn't trigger OOM even
though with cgroup.memory=nokmem.


Changelog:
v2: * Adopted the suggestion from Krill Shutemov to extract deferred split
      fields into a struct to reduce code duplication (patch 1/4).  With this
      change, the lines of change is shrunk down to 198 from 278.
    * Removed memcg_deferred_list. Use deferred_list for both global and memcg.
      With the code deduplication, it doesn't make too much sense to keep it.
      Kirill Tkhai also suggested so.
    * Fixed typo for SHRINKER_NONSLAB.


Yang Shi (4):
      mm: thp: extract split_queue_* into a struct
      mm: thp: make deferred split shrinker memcg aware
      mm: thp: remove THP destructor
      mm: shrinker: make shrinker not depend on memcg kmem

 include/linux/huge_mm.h    | 15 +++++++++++
 include/linux/memcontrol.h |  4 +++
 include/linux/mm.h         |  3 ---
 include/linux/mm_types.h   |  1 +
 include/linux/mmzone.h     | 12 ++++++---
 include/linux/shrinker.h   |  3 +--
 mm/huge_memory.c           | 99 ++++++++++++++++++++++++++++++++++++++++++++------------------------
 mm/memcontrol.c            | 19 +++++++++++++
 mm/page_alloc.c            | 11 ++++----
 mm/swap.c                  |  4 +++
 mm/vmscan.c                | 27 +++++--------------
 11 files changed, 129 insertions(+), 69 deletions(-)

