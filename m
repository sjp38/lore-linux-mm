Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BF33BC31E57
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 14:22:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 659B42084B
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 14:22:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 659B42084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF7568E0005; Mon, 17 Jun 2019 10:22:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C806B8E0001; Mon, 17 Jun 2019 10:22:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B6EB18E0005; Mon, 17 Jun 2019 10:22:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 92E8A8E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 10:22:27 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id k13so9275227qkj.4
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 07:22:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=OMCFDKJ/PXSeyP5g47QkodI+3vzdKTKciS2UuWyXoHc=;
        b=AB9n8lTKTVTgWRhtHIAH998ZGiJCIa5hE9pr5/0J+dk6KCYTlsWFv4cA5kjsjcGOcO
         7GyYRXxYuDi7CTbEXNEU8XLSzWCi9kMMAl9pEcJwqexeyQ/448pT2W+sMZmbXrnmVOJ6
         YhYwte20EwQ+d6kUB+EWtFMf8Hd0ZyI6A6ET8iZpM+Fhvi9hoc5HsFZZ48zRZc8aKchN
         gqv1n+Zcczqqeit9RygD9hFRHjXUry19L8tNv0aGw5aFMNUBLM7SuqcPzeOJuekrEECd
         7tXgzSLO28XPtQDTRhBPGius52tx7Aw15wWNRjonInvDHXjfcQr/ktKMY8AO+sd5TbMt
         HjaQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWhoVQkDhrEUisbViBO34PXA1Mv+W+K0gPRdpgDxNsKB+DO/MmE
	eH502z+08XIS5uMXrLt6pl15Qi3gSKVSXGHALdwKTjt2yolxfgPK6+y7TOq0GtuaXDowZW/lOmT
	66rIKSwCjDj6mi/8/SlmWWM79pzRxoN2MnZ1K0NY09kW//fAEfFRQOD50rWmvxCHR/w==
X-Received: by 2002:a0c:8722:: with SMTP id 31mr21466421qvh.164.1560781347386;
        Mon, 17 Jun 2019 07:22:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyh+CifzPsNPz7hskBFaXXpjLyp2Rw6aSolSqsT1ZCKVC/Di721dIMp2ZdkNUsmyiEzfqeq
X-Received: by 2002:a0c:8722:: with SMTP id 31mr21466355qvh.164.1560781346575;
        Mon, 17 Jun 2019 07:22:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560781346; cv=none;
        d=google.com; s=arc-20160816;
        b=gQcAupT7pQjwKVLx5rneciegP9U2dt5p38auGy2sha6MVfYorlMzBzuKQcLpAAZxue
         851lQSmF/ehKALWgLF2bz6wsH/pBMMekpZzvLc5Piz4Y3K55TDDuqevH0wm4EOfrTpZc
         DhojPHrg8oKrAvcHdR88uZDpaZIqKfZn3/vwqytF2qHtV+WkVr/7GoHlo3pmOyZmL8l5
         xJaCK0BX7DTZSk56aiT4eAJbskVO9VxqN3Z1kLL3LLlz5vpzjqzzkfLD5PhumdDZgfm/
         FYksjFY0+/WQtd1Dc2yzVTXriJLdr3+VbjS3Li9qBAFxtKOCtZjkGKyHWBLBz7JbpC8j
         jdGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=OMCFDKJ/PXSeyP5g47QkodI+3vzdKTKciS2UuWyXoHc=;
        b=DDC+izRH4uiUd7zZlNVsqN7I/u4OQ4NPAF9ehjBipt2OTgmaGaV284g+q6vXWxo87K
         DzsHSOkRrFezEfIlXFQMC3IPXmcFBMPbKLaZw5E61XDnWj0PWzj6D8T36DQpi9gWBbty
         pp34b4v7CB4ZhKiKohq2g2WtP035fSdc9LBLoGFBHGjVBNlbjMjktblbURXfv63K3jna
         q4MzDXQ2OKR7pHksYq17ndSOfN9R7YbcAZlpMF+gXgSgH+AEcwbSbAgY41tn+HypdyW8
         1fPN9Wy1m8hpTwVh/AOe218XT+rRCzPTbPy/id7PSd34nPqWbx+3FfgUQ/itEWHBZQje
         gEYA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f22si7467327qkg.139.2019.06.17.07.22.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 07:22:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6FB8A30C31B7;
	Mon, 17 Jun 2019 14:22:15 +0000 (UTC)
Received: from llong.com (dhcp-17-85.bos.redhat.com [10.18.17.85])
	by smtp.corp.redhat.com (Postfix) with ESMTP id DFB457E5CA;
	Mon, 17 Jun 2019 14:22:02 +0000 (UTC)
From: Waiman Long <longman@redhat.com>
To: Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Roman Gushchin <guro@fb.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Shakeel Butt <shakeelb@google.com>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Waiman Long <longman@redhat.com>
Subject: [PATCH] mm, memcg: Report number of memcg caches in slabinfo
Date: Mon, 17 Jun 2019 10:21:49 -0400
Message-Id: <20190617142149.5245-1-longman@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Mon, 17 Jun 2019 14:22:25 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

There are concerns about memory leaks from extensive use of memory
cgroups as each memory cgroup creates its own set of kmem caches. There
is a possiblity that the memcg kmem caches may remain even after the
memory cgroup removal.

Therefore, it will be useful to show how many memcg caches are present
for each of the kmem caches. As slabinfo reporting code has to iterate
through all the memcg caches to get the final numbers anyway, there is
no additional cost in reporting the number of memcg caches available.

The slabinfo version is bumped up to 2.2 as a new "<num_caches>" column
is added at the end.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 mm/slab_common.c | 24 ++++++++++++++++--------
 1 file changed, 16 insertions(+), 8 deletions(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 58251ba63e4a..c7aa47a99b2b 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1308,13 +1308,13 @@ static void print_slabinfo_header(struct seq_file *m)
 	 * without _too_ many complaints.
 	 */
 #ifdef CONFIG_DEBUG_SLAB
-	seq_puts(m, "slabinfo - version: 2.1 (statistics)\n");
+	seq_puts(m, "slabinfo - version: 2.2 (statistics)\n");
 #else
-	seq_puts(m, "slabinfo - version: 2.1\n");
+	seq_puts(m, "slabinfo - version: 2.2\n");
 #endif
 	seq_puts(m, "# name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab>");
 	seq_puts(m, " : tunables <limit> <batchcount> <sharedfactor>");
-	seq_puts(m, " : slabdata <active_slabs> <num_slabs> <sharedavail>");
+	seq_puts(m, " : slabdata <active_slabs> <num_slabs> <sharedavail> <num_caches>");
 #ifdef CONFIG_DEBUG_SLAB
 	seq_puts(m, " : globalstat <listallocs> <maxobjs> <grown> <reaped> <error> <maxfreeable> <nodeallocs> <remotefrees> <alienoverflow>");
 	seq_puts(m, " : cpustat <allochit> <allocmiss> <freehit> <freemiss>");
@@ -1338,14 +1338,18 @@ void slab_stop(struct seq_file *m, void *p)
 	mutex_unlock(&slab_mutex);
 }
 
-static void
+/*
+ * Return number of memcg caches.
+ */
+static unsigned int
 memcg_accumulate_slabinfo(struct kmem_cache *s, struct slabinfo *info)
 {
 	struct kmem_cache *c;
 	struct slabinfo sinfo;
+	unsigned int cnt = 0;
 
 	if (!is_root_cache(s))
-		return;
+		return 0;
 
 	for_each_memcg_cache(c, s) {
 		memset(&sinfo, 0, sizeof(sinfo));
@@ -1356,17 +1360,20 @@ memcg_accumulate_slabinfo(struct kmem_cache *s, struct slabinfo *info)
 		info->shared_avail += sinfo.shared_avail;
 		info->active_objs += sinfo.active_objs;
 		info->num_objs += sinfo.num_objs;
+		cnt++;
 	}
+	return cnt;
 }
 
 static void cache_show(struct kmem_cache *s, struct seq_file *m)
 {
 	struct slabinfo sinfo;
+	unsigned int nr_memcg_caches;
 
 	memset(&sinfo, 0, sizeof(sinfo));
 	get_slabinfo(s, &sinfo);
 
-	memcg_accumulate_slabinfo(s, &sinfo);
+	nr_memcg_caches = memcg_accumulate_slabinfo(s, &sinfo);
 
 	seq_printf(m, "%-17s %6lu %6lu %6u %4u %4d",
 		   cache_name(s), sinfo.active_objs, sinfo.num_objs, s->size,
@@ -1374,8 +1381,9 @@ static void cache_show(struct kmem_cache *s, struct seq_file *m)
 
 	seq_printf(m, " : tunables %4u %4u %4u",
 		   sinfo.limit, sinfo.batchcount, sinfo.shared);
-	seq_printf(m, " : slabdata %6lu %6lu %6lu",
-		   sinfo.active_slabs, sinfo.num_slabs, sinfo.shared_avail);
+	seq_printf(m, " : slabdata %6lu %6lu %6lu %3u",
+		   sinfo.active_slabs, sinfo.num_slabs, sinfo.shared_avail,
+		   nr_memcg_caches);
 	slabinfo_show_stats(m, s);
 	seq_putc(m, '\n');
 }
-- 
2.18.1

