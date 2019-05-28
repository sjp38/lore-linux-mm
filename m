Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5180BC04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 12:44:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 115322133F
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 12:44:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 115322133F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A0A0C6B0274; Tue, 28 May 2019 08:44:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9BA4E6B0276; Tue, 28 May 2019 08:44:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8A9A46B027C; Tue, 28 May 2019 08:44:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 621E16B0274
	for <linux-mm@kvack.org>; Tue, 28 May 2019 08:44:58 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id d62so7918713otb.4
        for <linux-mm@kvack.org>; Tue, 28 May 2019 05:44:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=cfm0fgsx2LSeqfQT76otvmyknMDUcjNhuweWOizWcVA=;
        b=AZDxHIOfgu5gkpqGdM5XcdDYwTNBR+qw97yHJAg58TD2qyOpfnMXeE7kohXNdJR+6I
         L8+loBtNOxLjsAnyinUYioa/z2TB0qBKv+mu1PpaoNyvYdoP9jEhwlLXoiS0Ac/vnnVY
         nARdyT+YGQe8XGh2PpwZ/QuGZ3dVBfw8Jpd2rydZx0vSzUOnnuce2J2Cx+qU52qsVUX3
         nwvGrZyiFiY5KX7FSF07Gc0JDITae9ZO2uakS/syz3IqCWJpQPgSFxX2h2QsEnAUdn31
         VzeReIOc1rvrpmW/8ybdl1h3jQrC+1Q5YThr4GnpRqHnKKIlNeMz0YnotUs6UTTxAv8Q
         u97Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.44 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAXDaRZxTebuPBGmkdL+6Y9xrIOKEtGk4a4sDVtFrI6Gp2oBFPiS
	YRGjwUDz6/rg6neWz0Cfpii0L/pJ1d2CSXViIoO0d0E9CloozFONCMAXgw8u0vmkF9wB7JgXaPa
	6J8piYeUctEyEI4KP9C8g9WIKB/aih7yYWgU1RgBLM58Odq97eoE3r487Qj3U/u+85g==
X-Received: by 2002:a9d:77c1:: with SMTP id w1mr22426917otl.269.1559047497917;
        Tue, 28 May 2019 05:44:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyo2Gj8roGoikkhkiAPTImgbmhB7Ax8E9Gd3+f+qiypsYcfdWGFHhISeTTeGsMhq+88NCLy
X-Received: by 2002:a9d:77c1:: with SMTP id w1mr22426885otl.269.1559047497280;
        Tue, 28 May 2019 05:44:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559047497; cv=none;
        d=google.com; s=arc-20160816;
        b=LXoNwrgLRPzKjAcCQg7EIjP7lhrtpPZkxWJNgtuUQwF3WJDv8qPh/goSiIesz9oZHH
         09LcatkWkukPf8mwvG7gBGWKl7eOprVNikMe8QQ760v+EGpW1ff9p0zQidP6dUslXjFd
         6DNoeDoyjOoRVPhRkwCe17jWB1RPCpEfw7wAaIu+LY4CNdP589KTJRVKZGh7p/4VPiUd
         SXVf8tbzjW+q+iY7OV+RN34pTpArBnaZzAgZfBtH8oRadGqEAaixw0VWI+420+lR4cNb
         5iwx8ad/+u15cqL4ua2FC1XcW3CJWplOOflZARtkyMRiJhE51QNxDdJ6pdJJCQ7V/vRG
         rS4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=cfm0fgsx2LSeqfQT76otvmyknMDUcjNhuweWOizWcVA=;
        b=YU0fIhmg8vUTM5GTYt/kIFbPkILUuJNwWHutfYISvLlpbVyYEEozEk1jRWZ3t1iLVc
         92cd418zh09SFtq6GWSp8TbcFwCza9AOIebxPgyQRsmVt8OP5eFavgBQ/pzCN4eY82QJ
         Vvd/90fEFKTuCeCo3pAxFZv2kOcGIa0DQCkh86oO55lbeYyM3JnVKXUU26JpvibfwK9w
         7hX96Bsq9jhnZE5fz43mIBdF2mDdWoCptmXEDZPJNAfxtHat0qyun3CvrxIZYEuoTSDF
         9qHGkvdjCg22ofVI63jURynYGbVu1UYDUxG6tXfn2ZEOFR+TI1D6zwNkrAMO9WySf/wH
         ZDeg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.44 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-44.freemail.mail.aliyun.com (out30-44.freemail.mail.aliyun.com. [115.124.30.44])
        by mx.google.com with ESMTPS id q21si7225939oic.266.2019.05.28.05.44.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 05:44:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.44 as permitted sender) client-ip=115.124.30.44;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.44 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R151e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e01422;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=10;SR=0;TI=SMTPD_---0TStMl0v_1559047475;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TStMl0v_1559047475)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 28 May 2019 20:44:42 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: ktkhai@virtuozzo.com,
	hannes@cmpxchg.org,
	mhocko@suse.com,
	kirill.shutemov@linux.intel.com,
	hughd@google.com,
	shakeelb@google.com,
	akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [RFC PATCH 0/3] Make deferred split shrinker memcg aware
Date: Tue, 28 May 2019 20:44:21 +0800
Message-Id: <1559047464-59838-1-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


I got some reports from our internal application team about memcg OOM.
Even though the application has been killed by oom killer, there are
still a lot THPs reside, page reclaim doesn't reclaim them at all.

Some investigation shows they are on deferred split queue, memcg direct
reclaim can't shrink them since THP deferred split shrinker is not memcg
aware, this may cause premature OOM in memcg.  The issue can be
reproduced easily by the below test:

$ cgcreate -g memory:thp
$ echo 4G > /sys/fs/cgroup/memory/thp/memory/limit_in_bytes
$ cgexec -g memory:thp ./transhuge-stress 4000

transhuge-stress comes from kernel selftest.

It is easy to hit OOM, but there are still a lot THP on the deferred split
queue, memcg direct reclaim can't touch them since the deferred split
shrinker is not memcg aware.

Convert deferred split shrinker memcg aware by introducing per memcg deferred
split queue.  The THP should be on either per node or per memcg deferred
split queue if it belongs to a memcg.  When the page is immigrated to the
other memcg, it will be immigrated to the target memcg's deferred split queue
too.

And, move deleting THP from deferred split queue in page free before memcg
uncharge so that the page's memcg information is available.

Reuse the second tail page's deferred_list for per memcg list since the same
THP can't be on multiple deferred split queues at the same time.

Remove THP specific destructor since it is not used anymore with memcg aware
THP shrinker (Please see the commit log of patch 2/3 for the details).

Make deferred split shrinker not depend on memcg kmem since it is not slab.
It doesn't make sense to not shrink THP even though memcg kmem is disabled.

With the above change the test demonstrated above doesn't trigger OOM anymore
even though with cgroup.memory=nokmem.


Yang Shi (3):
      mm: thp: make deferred split shrinker memcg aware
      mm: thp: remove THP destructor
      mm: shrinker: make shrinker not depend on memcg kmem

 include/linux/huge_mm.h    |  24 +++++++++
 include/linux/memcontrol.h |   6 +++
 include/linux/mm.h         |   3 --
 include/linux/mm_types.h   |   7 ++-
 include/linux/shrinker.h   |   3 +-
 mm/huge_memory.c           | 181 ++++++++++++++++++++++++++++++++++++++++++++++++-------------------
 mm/memcontrol.c            |  20 ++++++++
 mm/page_alloc.c            |   3 --
 mm/swap.c                  |   4 ++
 mm/vmscan.c                |  27 +++-------
 10 files changed, 198 insertions(+), 80 deletions(-)

