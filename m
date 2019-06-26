Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4BB66C48BD5
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 00:03:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0CF1F208E3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 00:03:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0CF1F208E3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 968D86B0008; Tue, 25 Jun 2019 20:03:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9194C8E0003; Tue, 25 Jun 2019 20:03:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 855C38E0002; Tue, 25 Jun 2019 20:03:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 66F436B0008
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 20:03:18 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id j18so434133ioj.4
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 17:03:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=j2T6Z6GStMozyoIjnJSv0+rob734Xas/MIGPYHN+kUg=;
        b=ZUMaSbBYb8Tvmw3Kikl7qbCXBi3+a4aImspTXB2tU8xKY5iVjLN8X2QZmD7gBOYtDD
         I7SgCkT2eZSqFy404pekCVIALNudc1OmPq4kqUmi6DNg+qkQalUFJQFf3iwImUBmCHwu
         /wW9rfYfyDwHTwV4x1wQ2T9pMGvYTxZ/qbTk7ocz45ZBBA4a1rV6HjRCABO/fm/aiM9h
         hWHygoicbPVb9ArUCji05e9v/o0Aolosr8W6u6KDZfh9TmlsoXm8EE5H41h7i3AcsP0J
         kSgmYCTj9a+VdlDR/mBKT2Aftfdu4Zad4jPqwI5VUzK4tu9mxq21u7RooZWj0U1RHRua
         JbIg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAX9NcGqEcKyZKtnkxreHRKzwnE+RuArtt+8AT0/j5kKRwXq4WZd
	d7DaTQgJRTWdrpLtSfN6w7jSAJGPikhuV9Se0Q1tLa9Cnd+JyHMfQtAKAfoGkkKlSwbyI/vqm33
	6wKA8TkqZJL7I0ZOrm10RQzbIAdi0eKj1EwuNdrdmLbYQQa3PBxucmGnsJcFrrA2gww==
X-Received: by 2002:a6b:fb0f:: with SMTP id h15mr1681257iog.266.1561507398180;
        Tue, 25 Jun 2019 17:03:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxmOQuSGubNTvY9fAPjvKCNpmT6avCvZUArgUdBY1nC6bFnZez51I76+ZDSE83/6i2uwg9O
X-Received: by 2002:a6b:fb0f:: with SMTP id h15mr1681160iog.266.1561507396958;
        Tue, 25 Jun 2019 17:03:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561507396; cv=none;
        d=google.com; s=arc-20160816;
        b=mY/1DfMQGVhtO4HTioI92spWG2zvrOoKTz6ae46sKFbhWzUksDqvr5lUO8AJ8uywpj
         XzAdasY84FjV+HyDbUr8zf790wRlsc8WN89kAyIuU0hQREvB1mkvGkOlMb5sdIUVPvm9
         fKnBO/6KyLvr86wSmlDrla9Uuj5FoaRbJMjAyOMCwAbGXdspV+HYvpuBc2EDr74aJfBB
         yA0PeOx+HqR4yH07cFQn2Xp7kuQHNmUXpSWWCPrcNbp+NMPrB7uKQxoO8G0BWi3OEHN6
         zh+yi2cgeae7UmVwARM7p3Rs77emxvkn5aLiuppw7S/qAFR4542L0b5gbB7csJcqcnHh
         g0KQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=j2T6Z6GStMozyoIjnJSv0+rob734Xas/MIGPYHN+kUg=;
        b=n42FpRphZ8Gmd01bXkHH9q3g+mvvH8PKEr8txN9G12ddBQKlbgLGOwlMIxMkRHtZgd
         S5yDjPiGl9oZEEwzcYXjQbkLRpg0dRgyVEHnr4P2VR6lejKfn5Tex854fBKfcRJGH/Ip
         AKzo3mqAPHSVLdPPMrDswztlkdr6DsufDbd2kmRhvuOy4A4wbyvFRoELo2SavNDSqMrm
         kmAm6dyRReyLaCV1cnk14yQaU/wjphuC2peNiAKUadx2PmnAcZuHrwYFAfvFgvHm2Mz6
         hYZGrcKFCMsPjnBKeezaWrN71DRnKBi+moo9SLKdFgFR+UgcAYselFTgT1dCKa0aIRKC
         Q71A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id d71si23017411jab.10.2019.06.25.17.03.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 17:03:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) client-ip=115.124.30.132;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R151e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04423;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=11;SR=0;TI=SMTPD_---0TVCYVJX_1561507375;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TVCYVJX_1561507375)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 26 Jun 2019 08:03:02 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: kirill.shutemov@linux.intel.com,
	ktkhai@virtuozzo.com,
	hannes@cmpxchg.org,
	mhocko@suse.com,
	hughd@google.com,
	shakeelb@google.com,
	rientjes@google.com,
	akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [v4 PATCH 0/4] Make deferred split shrinker memcg aware
Date: Wed, 26 Jun 2019 08:02:37 +0800
Message-Id: <1561507361-59349-1-git-send-email-yang.shi@linux.alibaba.com>
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
v4: * Replace list_del() to list_del_init() per Andrew.
    * Fixed the build failure for different kconfig combo and tested the
      below combo:
          MEMCG + TRANSPARENT_HUGEPAGE
          !MEMCG + TRANSPARENT_HUGEPAGE
          MEMCG + !TRANSPARENT_HUGEPAGE
          !MEMCG + !TRANSPARENT_HUGEPAGE
    * Added Acked-by from Kirill Shutemov. 
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

 include/linux/huge_mm.h    |  9 +++++++
 include/linux/memcontrol.h |  4 +++
 include/linux/mm_types.h   |  1 +
 include/linux/mmzone.h     | 12 ++++++---
 include/linux/shrinker.h   |  3 ++-
 mm/huge_memory.c           | 98 ++++++++++++++++++++++++++++++++++++++++++++++++++------------------
 mm/memcontrol.c            | 24 +++++++++++++++++
 mm/page_alloc.c            |  9 ++++---
 mm/swap.c                  |  2 +-
 mm/vmscan.c                | 36 +++++++++++++------------
 10 files changed, 147 insertions(+), 51 deletions(-)

