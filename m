Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4BE28C31E40
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 02:18:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CB192217D9
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 02:18:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CB192217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 550CB6B0288; Tue,  6 Aug 2019 22:18:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4DA746B0284; Tue,  6 Aug 2019 22:18:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 352606B0286; Tue,  6 Aug 2019 22:18:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id F22016B027E
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 22:18:16 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id w5so56092366pgs.5
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 19:18:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=QppKY+xZ8yMGO89aq9usA2MJy7roMddgBB2xkgfz4Kk=;
        b=rQq2nHIFYM3MLB4CE5YbIOUchzLGTptwmqqUOU3Jd69lluzhNiUFcXUq8tmVbpo6AJ
         Bxnov6GT9njDyjUQURr6m6j8AnEsLE9AfzXyxvvDB7IZW18PFIksLU6O95+68BuMV9Bu
         5Mk3qOI8Q2prDHXxO9KTTE4yHPHyfBmDY/qHr8tyZP8Efal2HW9FDFkg858O7oiN+0y3
         uReddzt5UXHONdLkHD3HFE1KZrsd3rFnzPdFRr74xcU3yn0ZrT4LeCYKBfH1nvVeXdv/
         DtqpzCTzaXDxaGSX5Daeel6oRKlSwpg+eFoE9Ela/Du3V4ckrB1VxvV/tbau+8/AuE9u
         DKmQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.133 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUNhq79KZtNDiGUVCQXkDrEEpIp77Mj72k0yRX1D9aQi/0yoPgh
	TQNIpblAmiat+XaCYjWi5qDsdpInt6HLojjYxy8+LRDL5lHUgMApyZJsbbFGsWAjfBCOZx+XBKy
	0aZmjNS0DkfMLFYImCSvsIWnKraWaC3jRK9n8V21E2HsLitavQ7ihzFFx0pj4sZiWTw==
X-Received: by 2002:a62:35c6:: with SMTP id c189mr6921163pfa.96.1565144296617;
        Tue, 06 Aug 2019 19:18:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx77KC1uT+VHbEy1kKlE5ZV9q7ixIU6lEX6bEsoou1mUHD8ZsbzVLKmfzS54Pfkjez5O5a1
X-Received: by 2002:a62:35c6:: with SMTP id c189mr6921092pfa.96.1565144295145;
        Tue, 06 Aug 2019 19:18:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565144295; cv=none;
        d=google.com; s=arc-20160816;
        b=Sbpr9RjFWP84K29LIuHvzyf3BfA2VhMfN0xZfRcDrAAC0bvLPXONqcNQPboG4yzClf
         ur6wW54+eqCHaBG3VTgFnIeBKYiZTyXSetS8i4sMC464BcUaT5ttep1K/+wOo4Zx2hZO
         Ypy+gd4buzgtkjtRCqSJqNpuReBIiszxbTiD0d7m6CNaTlqKEfT7t+GAJkDBBEY48gy5
         X6m2bQYpxuwXg90zAg7Z3WSCq7WIy4R54US+fegzJkWz4klPnwUq1B3C3PmVn3ffmHJJ
         PPtrlTtdux+ZEpoK6ZK9YJCK0lFG0ehysCoHJnMnNPmQIIqimDvNvJ4+oYbIiyJNydPC
         kDnQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=QppKY+xZ8yMGO89aq9usA2MJy7roMddgBB2xkgfz4Kk=;
        b=pmrfcFWHY7Gp7Tf8SKxhlIfw6ViJB3fBQOpoFjORVQgvGciCRRa8Vlpl6VgeUwiAvQ
         1OIJKteU9qeMVgtbktUkQMOhNQTmvYqlm/hxELL2+eTtD04F1ED+yJO90ZKbZeCPxrtl
         cxbYB+nKV6cm1J+Z6G15Bp7jyN5HsaL5tBcKCPW6OeEUqNwTTzerhDdL3olKPy+zLKos
         NfqGYDEyWcgHT/SvcNOunyk7s7DffePxEzXzvLQj/67XlgHUP4uTBg1FcecDVuWxgTZj
         ZpqcRdqdfWF4VyeymQhsz25ze08jiR1m9TogmIfKctZ0YSB5MuWH/DQJJJbflCLw5Qzy
         aACQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.133 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-133.freemail.mail.aliyun.com (out30-133.freemail.mail.aliyun.com. [115.124.30.133])
        by mx.google.com with ESMTPS id bf7si43610425plb.216.2019.08.06.19.18.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 19:18:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.133 as permitted sender) client-ip=115.124.30.133;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.133 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R341e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04446;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=12;SR=0;TI=SMTPD_---0TYr3obk_1565144286;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TYr3obk_1565144286)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 07 Aug 2019 10:18:12 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: kirill.shutemov@linux.intel.com,
	ktkhai@virtuozzo.com,
	hannes@cmpxchg.org,
	mhocko@suse.com,
	hughd@google.com,
	shakeelb@google.com,
	rientjes@google.com,
	cai@lca.pw,
	akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [v5 PATCH 0/4] Make deferred split shrinker memcg aware
Date: Wed,  7 Aug 2019 10:17:53 +0800
Message-Id: <1565144277-36240-1-git-send-email-yang.shi@linux.alibaba.com>
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
v5: * Fixed the issue reported by Qian Cai, folded the fix in.
    * Squashed build fix patches in.
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

 include/linux/huge_mm.h    |   9 ++++++
 include/linux/memcontrol.h |  23 +++++++++-----
 include/linux/mm_types.h   |   1 +
 include/linux/mmzone.h     |  12 ++++++--
 include/linux/shrinker.h   |   3 +-
 mm/huge_memory.c           | 111 ++++++++++++++++++++++++++++++++++++++++++++++++++----------------
 mm/memcontrol.c            |  33 +++++++++++++++-----
 mm/page_alloc.c            |   9 ++++--
 mm/swap.c                  |   2 +-
 mm/vmscan.c                |  66 +++++++++++++++++++--------------------
 10 files changed, 186 insertions(+), 83 deletions(-)

