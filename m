Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97727C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 18:40:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4ABEA2075C
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 18:40:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="BbmaOVrT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4ABEA2075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E0E258E0004; Wed, 13 Mar 2019 14:40:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DBDD88E0001; Wed, 13 Mar 2019 14:40:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C86D38E0004; Wed, 13 Mar 2019 14:40:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 853038E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 14:40:02 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id d10so3135511pgv.23
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 11:40:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=lGCmHLKJA9/EYdLy/6HPhjPsvA0XaSLq0sCYMk41rjQ=;
        b=fukiQJ0fpbSRU4oRMbJi3XJctI4K0sDffHXqe1GMEqSnxMQcZPIPHso3+MV6TZBrU8
         +HobKztU2sp7uyqiNiQDtjJhpbwr40U5GGfi8nPxdjJwXy+1WnGeLATAMIy3M6XvkXua
         AUYXY+YIhzduOOc4hNDbhpH3OSE3yIw2ltGDuNhD2lIb1MF3hu8SpnhXa16CX4At5Aru
         +Kj9MpfrjZWRNdxewBRXSH0Hxs25J2g3WOGIKc6wCN7Quzh6fvkh0JW7WUG4xNKGibym
         195LdN1L3hVEeFc23cCJDLCTR409FFegvAOjOtywgPQaN651xDHsaPsbMixwlyZEpJ+g
         iiaQ==
X-Gm-Message-State: APjAAAWeFnoc3EP1aCS9ZjLQmiTA8XQ5IFH03Nk7k+7TgECinKf7KROM
	jHClLchGLDBjwiFmJqqdX2njvssDLyzF/+AOnibDbcGyCF5MAsQ73eRO61QEcEAVxpKM02kPX4k
	kH9w/LJLNCfhgquhWbc4cIbC5OIzPILW2j65P2MApxl5HmZHXL6P8s0gaHW7QybougyYn8grJvg
	0ELJw0Qbe+bccLETEQRl6q5eF5BIUlr1THycpSCtlGykZdyVDAbwET7H0ewjYi5cYcpglV4k/qA
	zg1SCKewmBRpNJFIyvB88Jo4d6AkBZlMiw0Go9KzcJrdiwzuBGeplKSVHMqz69MnGcjvvQa3Urd
	iWxng7CPmMP5aRBG7AgtC45TKUIqCbY5mArL9CD62ouydfx2Em1LzJQYI38Z+YPCRQffcm/yYQz
	O
X-Received: by 2002:a17:902:f01:: with SMTP id 1mr46196079ply.41.1552502402080;
        Wed, 13 Mar 2019 11:40:02 -0700 (PDT)
X-Received: by 2002:a17:902:f01:: with SMTP id 1mr46196016ply.41.1552502400903;
        Wed, 13 Mar 2019 11:40:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552502400; cv=none;
        d=google.com; s=arc-20160816;
        b=MGMs3echh21kX25P115JheHC4Gt+8DBXubKZYGfs27RCOjy01mumlvP0OLWbRozXz7
         8yR2E84ww+zZo7Zq1c/Y3ORN+oQcwqWM77Wxw9RIzwVw5mFhCt+/gMWKG/kVi72e52uG
         o88U3zVW7IALGJN+z5/aTrsVFBVJ3FaLEfRnJb2hu37zJClRpitD7JrIVeHF9hd0jUjw
         eH4W+9eTzs+XKWNIhMdh4HX3qokKAo4lNxP4JCKpXvufzkc27bjeRYDPjwbBxAkomyj+
         EAs2+B22e+dtWzWXex+gyUXMXU6JmpXSiv+FlKt+rDzu+xqh9pKs+flNYVbytPjRDzZz
         bmzg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=lGCmHLKJA9/EYdLy/6HPhjPsvA0XaSLq0sCYMk41rjQ=;
        b=1CfjiQhdz6hmL4oKolA+0ub3bXr9EB2thWAhXylD3Abrm0ZG2oZHV3wteUDcgEwjLX
         XRxDjducs0uQi+5PBXos8S1RkChGIsRFkCxrtbAC2ODQrofasSJomwXOUHbq1Ep1xyKC
         2b+wKm2iW+DHHhDtSDQY5UNgWDE5p3Rvqx0WxvDIm/J9ne5uRg4c6P3XOeFGANDMlBmH
         +MU4Gv60qwVLJ77qPFBK+PcuJk+hKMHvZCgQeokoHRu6zySA9JNcar/mL1ChCFnziFxS
         mEH0jygeGpFhsTz2H2tWvq78s9d/YfUZAjmq6pQnSY4p/mYfnuDjZ7Dtk3P/FW6ufV1l
         lGww==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=BbmaOVrT;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d8sor19310323pgc.51.2019.03.13.11.40.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Mar 2019 11:40:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=BbmaOVrT;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=lGCmHLKJA9/EYdLy/6HPhjPsvA0XaSLq0sCYMk41rjQ=;
        b=BbmaOVrTTrfPLRHgBCJK3fvZxYO5/ln++Ubzs451/+vYsxNPdWwBbSHUAv/FxKjuFD
         Mf+xGTJBljqOzIsg8dAa9TKqpwh+H9DRemPztnU5TnsNKAzMzvFkodrueROckXzhzK1o
         3I0SjuMQMX54hGSu9vG52ZWNFs9dyKGdAewCsDpK+NGOlCIvkGQBqPTCkWFGhLtr9oQf
         IDU6EZ5XyvVpGezq8qb6dA3DlgAHHVZems5b6lDtfub+q/2uJCpBRVWzzXMWiGFOx9up
         Y2VDMo4J6umdKSt14jrMvHkdLLMaHxOqFxj/0OAFT8srX5agSdjiugfRlcmwJNK9yNDM
         xV2w==
X-Google-Smtp-Source: APXvYqzdI6qgHAAwU5a2Vf/gu7NwWbBAvf44GvpOocbzEDCRQK42dGNNnvbR4MBLHpoDMPFq7Zhgxg==
X-Received: by 2002:a63:204d:: with SMTP id r13mr15642250pgm.63.1552502400062;
        Wed, 13 Mar 2019 11:40:00 -0700 (PDT)
Received: from castle.hsd1.ca.comcast.net ([2603:3024:1704:3e00::d657])
        by smtp.gmail.com with ESMTPSA id i13sm15792562pgq.17.2019.03.13.11.39.58
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Mar 2019 11:39:58 -0700 (PDT)
From: Roman Gushchin <guroan@gmail.com>
X-Google-Original-From: Roman Gushchin <guro@fb.com>
To: linux-mm@kvack.org,
	kernel-team@fb.com
Cc: linux-kernel@vger.kernel.org,
	Tejun Heo <tj@kernel.org>,
	Rik van Riel <riel@surriel.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@kernel.org>,
	Roman Gushchin <guro@fb.com>
Subject: [PATCH v3 0/6] mm: reduce the memory footprint of dying memory cgroups
Date: Wed, 13 Mar 2019 11:39:47 -0700
Message-Id: <20190313183953.17854-1-guro@fb.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

A cgroup can remain in the dying state for a long time, being pinned in the
memory by any kernel object. It can be pinned by a page, shared with other
cgroup (e.g. mlocked by a process in the other cgroup). It can be pinned
by a vfs cache object, etc.

Mostly because of percpu data, the size of a memcg structure in the kernel
memory is quite large. Depending on the machine size and the kernel config,
it can easily reach hundreds of kilobytes per cgroup.

Depending on the memory pressure and the reclaim approach (which is a separate
topic), it looks like several hundreds (if not single thousands) of dying
cgroups is a typical number. On a moderately sized machine the overall memory
footprint is measured in hundreds of megabytes.

So if we can't completely get rid of dying cgroups, let's make them smaller.
This patchset aims to reduce the size of a dying memory cgroup by the premature
release of percpu data during the cgroup removal, and use of atomic counterparts
instead. Currently it covers per-memcg vmstat_percpu, per-memcg per-node
lruvec_stat_cpu. The same approach can be further applied to other percpu data.

Results on my test machine (32 CPUs, singe node):

  With the patchset:              Originally:

  nr_dying_descendants 0
  Slab:              66640 kB	  Slab:              67644 kB
  Percpu:             6912 kB	  Percpu:             6912 kB

  nr_dying_descendants 1000
  Slab:              85912 kB	  Slab:              84704 kB
  Percpu:            26880 kB	  Percpu:            64128 kB

So one dying cgroup went from 75 kB to 39 kB, which is almost twice smaller.
The difference will be even bigger on a bigger machine
(especially, with NUMA).

To test the patchset, I used the following script:
  CG=/sys/fs/cgroup/percpu_test/

  mkdir ${CG}
  echo "+memory" > ${CG}/cgroup.subtree_control

  cat ${CG}/cgroup.stat | grep nr_dying_descendants
  cat /proc/meminfo | grep -e Percpu -e Slab

  for i in `seq 1 1000`; do
      mkdir ${CG}/${i}
      echo $$ > ${CG}/${i}/cgroup.procs
      dd if=/dev/urandom of=/tmp/test-${i} count=1 2> /dev/null
      echo $$ > /sys/fs/cgroup/cgroup.procs
      rmdir ${CG}/${i}
  done

  cat /sys/fs/cgroup/cgroup.stat | grep nr_dying_descendants
  cat /proc/meminfo | grep -e Percpu -e Slab

  rmdir ${CG}

v3:
  - replaced get_cpu_mask() with cpumask_of() (by Johannes)

v2:
  - several renamings suggested by Johannes Weiner
  - added a patch, which merges cpu offlining and percpu flush code


Roman Gushchin (6):
  mm: prepare to premature release of memcg->vmstats_percpu
  mm: prepare to premature release of per-node lruvec_stat_cpu
  mm: release memcg percpu data prematurely
  mm: release per-node memcg percpu data prematurely
  mm: flush memcg percpu stats and events before releasing
  mm: refactor memcg_hotplug_cpu_dead() to use
    memcg_flush_offline_percpu()

 include/linux/memcontrol.h |  66 ++++++++++----
 mm/memcontrol.c            | 179 ++++++++++++++++++++++++++++---------
 2 files changed, 186 insertions(+), 59 deletions(-)

-- 
2.20.1

