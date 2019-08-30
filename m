Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6EA46C41514
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 23:04:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2E92B23430
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 23:04:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="bQdyd/YR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2E92B23430
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DB8786B0266; Fri, 30 Aug 2019 19:04:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D68296B0269; Fri, 30 Aug 2019 19:04:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C61016B026A; Fri, 30 Aug 2019 19:04:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0127.hostedemail.com [216.40.44.127])
	by kanga.kvack.org (Postfix) with ESMTP id 9F99E6B0266
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 19:04:55 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 5900A824CA3A
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 23:04:55 +0000 (UTC)
X-FDA: 75880626150.29.fifth47_2af08ae6b5c0f
X-HE-Tag: fifth47_2af08ae6b5c0f
X-Filterd-Recvd-Size: 3492
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf04.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 23:04:54 +0000 (UTC)
Received: from localhost.localdomain (c-73-231-172-41.hsd1.ca.comcast.net [73.231.172.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id BCADB23717;
	Fri, 30 Aug 2019 23:04:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1567206294;
	bh=uq+0YlqozihjED4a3KLUxZE+u/uOVJc8vabqrHjbEXc=;
	h=Date:From:To:Subject:From;
	b=bQdyd/YRDRLxxtbZBWyh1CZOR+ETPZD8idirZ0Xjeta5yTssKTboI2U352gRnkfSg
	 4fndrl1+zmb3vmaJaUuCfWlJTnOXiAcb7WOXQ9saFMu2WwjJ3h1Sb46T9Q2XGEA52G
	 T6KqJsgbLDoBWx6cn9WYuk2lSEZZOOvCBq7Zs95c=
Date: Fri, 30 Aug 2019 16:04:53 -0700
From: akpm@linux-foundation.org
To: akpm@linux-foundation.org, guro@fb.com, hannes@cmpxchg.org,
 linux-mm@kvack.org, mhocko@suse.com, mm-commits@vger.kernel.org,
 shakeelb@google.com, stable@vger.kernel.org,
 torvalds@linux-foundation.org, vdavydov.dev@gmail.com
Subject:  [patch 7/7] mm: memcontrol: fix percpu vmstats and
 vmevents flush
Message-ID: <20190830230453.ZwLpvQ0hX%akpm@linux-foundation.org>
User-Agent: s-nail v14.8.16
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Shakeel Butt <shakeelb@google.com>
Subject: mm: memcontrol: fix percpu vmstats and vmevents flush

Instead of using raw_cpu_read() use per_cpu() to read the actual data of
the corresponding cpu otherwise we will be reading the data of the current
cpu for the number of online CPUs.

Link: http://lkml.kernel.org/r/20190829203110.129263-1-shakeelb@google.com
Fixes: bb65f89b7d3d ("mm: memcontrol: flush percpu vmevents before releasing memcg")
Fixes: c350a99ea2b1 ("mm: memcontrol: flush percpu vmstats before releasing memcg")
Signed-off-by: Shakeel Butt <shakeelb@google.com>
Acked-by: Roman Gushchin <guro@fb.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: <stable@vger.kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/memcontrol.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

--- a/mm/memcontrol.c~mm-memcontrol-fix-percpu-vmstats-and-vmevents-flush
+++ a/mm/memcontrol.c
@@ -3278,7 +3278,7 @@ static void memcg_flush_percpu_vmstats(s
 
 	for_each_online_cpu(cpu)
 		for (i = min_idx; i < max_idx; i++)
-			stat[i] += raw_cpu_read(memcg->vmstats_percpu->stat[i]);
+			stat[i] += per_cpu(memcg->vmstats_percpu->stat[i], cpu);
 
 	for (mi = memcg; mi; mi = parent_mem_cgroup(mi))
 		for (i = min_idx; i < max_idx; i++)
@@ -3296,8 +3296,8 @@ static void memcg_flush_percpu_vmstats(s
 
 		for_each_online_cpu(cpu)
 			for (i = min_idx; i < max_idx; i++)
-				stat[i] += raw_cpu_read(
-					pn->lruvec_stat_cpu->count[i]);
+				stat[i] += per_cpu(
+					pn->lruvec_stat_cpu->count[i], cpu);
 
 		for (pi = pn; pi; pi = parent_nodeinfo(pi, node))
 			for (i = min_idx; i < max_idx; i++)
@@ -3316,8 +3316,8 @@ static void memcg_flush_percpu_vmevents(
 
 	for_each_online_cpu(cpu)
 		for (i = 0; i < NR_VM_EVENT_ITEMS; i++)
-			events[i] += raw_cpu_read(
-				memcg->vmstats_percpu->events[i]);
+			events[i] += per_cpu(memcg->vmstats_percpu->events[i],
+					     cpu);
 
 	for (mi = memcg; mi; mi = parent_mem_cgroup(mi))
 		for (i = 0; i < NR_VM_EVENT_ITEMS; i++)
_

