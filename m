Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 45A466B02F3
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 09:05:28 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id a186so14046404wmh.9
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 06:05:28 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id c19si18764963wre.235.2017.07.27.06.05.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jul 2017 06:05:27 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [PATCH 2/2] cgroup: revert fa06235b8eb0 ("cgroup: reset css on destruction")
Date: Thu, 27 Jul 2017 14:04:28 +0100
Message-ID: <20170727130428.28856-2-guro@fb.com>
In-Reply-To: <20170727130428.28856-1-guro@fb.com>
References: <20170726083017.3yzeucmi7lcj46qd@esperanza>
 <20170727130428.28856-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Roman Gushchin <guro@fb.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-mm@kvack.org

Commit fa06235b8eb0 ("cgroup: reset css on destruction") caused
css_reset callback to be called from the offlining path. Although
it solves the problem mentioned in the commit description
("For instance, memory cgroup needs to reset memory.low, otherwise
pages charged to a dead cgroup might never get reclaimed."),
generally speaking, it's not correct.

An offline cgroup can still be a resource domain, and we shouldn't
grant it more resources than it had before deletion.

For instance, if an offline memory cgroup has dirty pages, we should
still imply i/o limits during writeback.

The css_reset callback is designed to return the cgroup state
into the original state, that means reset all limits and counters.
It's spomething different from the offlining, and we shouldn't use
it from the offlining path. Instead, we should adjust necessary
settings from the per-controller css_offline callbacks (e.g. reset
memory.low).

Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: kernel-team@fb.com
Cc: cgroups@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 kernel/cgroup/cgroup.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/kernel/cgroup/cgroup.c b/kernel/cgroup/cgroup.c
index 29c36c075249..4e93482e066c 100644
--- a/kernel/cgroup/cgroup.c
+++ b/kernel/cgroup/cgroup.c
@@ -4499,9 +4499,6 @@ static void offline_css(struct cgroup_subsys_state *css)
 	if (!(css->flags & CSS_ONLINE))
 		return;
 
-	if (ss->css_reset)
-		ss->css_reset(css);
-
 	if (ss->css_offline)
 		ss->css_offline(css);
 
-- 
2.13.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
