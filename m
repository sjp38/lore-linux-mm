Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 8ED356B0254
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 06:13:26 -0500 (EST)
Received: by mail-pf0-f179.google.com with SMTP id 124so49461106pfg.0
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 03:13:26 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id qe4si49841814pab.195.2016.03.01.03.13.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Mar 2016 03:13:25 -0800 (PST)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH 2/2] cgroup: reset css on destruction
Date: Tue, 1 Mar 2016 14:13:13 +0300
Message-ID: <92b11b89791412df49e73597b87912e8f143a3f7.1456830735.git.vdavydov@virtuozzo.com>
In-Reply-To: <69629961aefc48c021b895bb0c8297b56c11a577.1456830735.git.vdavydov@virtuozzo.com>
References: <69629961aefc48c021b895bb0c8297b56c11a577.1456830735.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

An associated css can be around for quite a while after a cgroup
directory has been removed. In general, it makes sense to reset it to
defaults so as not to worry about any remnants. For instance, memory
cgroup needs to reset memory.low, otherwise pages charged to a dead
cgroup might never get reclaimed. There's ->css_reset callback, which
would fit perfectly for the purpose. Currently, it's only called when a
subsystem is disabled in the unified hierarchy and there are other
subsystems dependant on it. Let's call it on css destruction as well.

Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 kernel/cgroup.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index cc40463e7b69..2ef78912c996 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -5138,6 +5138,8 @@ static void kill_css(struct cgroup_subsys_state *css)
 	 * See seq_css() for details.
 	 */
 	css_clear_dir(css, NULL);
+	if (css->ss->css_reset)
+		css->ss->css_reset(css);
 
 	/*
 	 * Killing would put the base ref, but we need to keep it alive
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
