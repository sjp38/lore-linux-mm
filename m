Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 672B5C3A5A5
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 17:50:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 27C902133F
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 17:50:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 27C902133F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C3C056B0349; Thu, 22 Aug 2019 13:50:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BCA056B034A; Thu, 22 Aug 2019 13:50:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A6C9B6B034B; Thu, 22 Aug 2019 13:50:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0205.hostedemail.com [216.40.44.205])
	by kanga.kvack.org (Postfix) with ESMTP id 7A6AE6B0349
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 13:50:47 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 24E508248AA7
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 17:50:47 +0000 (UTC)
X-FDA: 75850804134.28.duck57_23ad2b846944c
X-HE-Tag: duck57_23ad2b846944c
X-Filterd-Recvd-Size: 4920
Received: from out30-45.freemail.mail.aliyun.com (out30-45.freemail.mail.aliyun.com [115.124.30.45])
	by imf22.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 17:50:44 +0000 (UTC)
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R201e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07487;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=12;SR=0;TI=SMTPD_---0Ta9PNTk_1566496230;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0Ta9PNTk_1566496230)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 23 Aug 2019 01:50:36 +0800
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
Subject: [v6 PATCH 0/4] Make deferred split shrinker memcg aware
Date: Fri, 23 Aug 2019 01:50:23 +0800
Message-Id: <1566496227-84952-1-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
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

Make deferred split shrinker not depend on memcg kmem since it is not sla=
b.
It doesn=E2=80=99t make sense to not shrink THP even though memcg kmem is=
 disabled.

With the above change the test demonstrated above doesn=E2=80=99t trigger=
 OOM even
though with cgroup.memory=3Dnokmem.


Changelog:
v6: * Added comments about SHRINKER_NONSLAB per Kirill Tkhai (patch 3/4).
    * Simplified deferred split queue dereference per Kirill Tkhai (patch=
 4/4).
    * Collected Reviewed-by tag from Kirill Tkhai.
v5: * Fixed the issue reported by Qian Cai, folded the fix in.
    * Squashed build fix patches in.
v4: * Replace list_del() to list_del_init() per Andrew.
    * Fixed the build failure for different kconfig combo and tested the
      below combo:
          MEMCG + TRANSPARENT_HUGEPAGE
          !MEMCG + TRANSPARENT_HUGEPAGE
          MEMCG + !TRANSPARENT_HUGEPAGE
          !MEMCG + !TRANSPARENT_HUGEPAGE
    * Added Acked-by from Kirill Shutemov.=20
v3: * Adopted the suggestion from Kirill Shutemov to move mem_cgroup_unch=
arge()
      out of __page_cache_release() in order to handle THP free properly.=
=20
    * Adjusted the sequence of the patches per Kirill Shutemov. Dropped t=
he
      patch 3/4 in v2.
    * Moved enqueuing THP onto "to" memcg deferred split queue after
      page->mem_cgroup is changed in memcg account move per Kirill Tkhai.
=20
v2: * Adopted the suggestion from Krill Shutemov to extract deferred spli=
t
      fields into a struct to reduce code duplication (patch 1/4).  With =
this
      change, the lines of change is shrunk down to 198 from 278.
    * Removed memcg_deferred_list. Use deferred_list for both global and =
memcg.
      With the code deduplication, it doesn't make too much sense to keep=
 it.
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
 mm/huge_memory.c           | 111 +++++++++++++++++++++++++++++++++++++++=
+++++++++++----------------
 mm/memcontrol.c            |  33 +++++++++++++++-----
 mm/page_alloc.c            |   9 ++++--
 mm/swap.c                  |   2 +-
 mm/vmscan.c                |  66 +++++++++++++++++++--------------------
 10 files changed, 186 insertions(+), 83 deletions(-)


