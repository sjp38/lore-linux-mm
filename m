Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 4355C900015
	for <linux-mm@kvack.org>; Thu, 19 Feb 2015 09:34:56 -0500 (EST)
Received: by pabrd3 with SMTP id rd3so133930pab.4
        for <linux-mm@kvack.org>; Thu, 19 Feb 2015 06:34:56 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id bd2si8042146pbc.44.2015.02.19.06.34.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Feb 2015 06:34:54 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH 1/2] cgroup: call cgroup_subsys->bind on cgroup subsys initialization
Date: Thu, 19 Feb 2015 17:34:46 +0300
Message-ID: <131af5f5ee0eec55d0f94a785db4be04baf01f51.1424356325.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Currently, we call cgroup_subsys->bind only on unmount, remount, and
when creating a new root on mount. Since the default hierarchy root is
created in cgroup_init, we will not call cgroup_subsys->bind if the
default hierarchy is freshly mounted. As a result, some controllers will
behave incorrectly (most notably, the "memory" controller will not
enable hierarchy support). Fix this by calling cgroup_subsys->bind right
after initializing a cgroup subsystem.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 kernel/cgroup.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 29a7b2cc593e..21a4b6d61e21 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -5040,6 +5040,9 @@ int __init cgroup_init(void)
 			WARN_ON(cgroup_add_dfl_cftypes(ss, ss->dfl_cftypes));
 			WARN_ON(cgroup_add_legacy_cftypes(ss, ss->legacy_cftypes));
 		}
+
+		if (ss->bind)
+			ss->bind(init_css_set.subsys[ssid]);
 	}
 
 	cgroup_kobj = kobject_create_and_add("cgroup", fs_kobj);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
