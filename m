Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 1FCD96B0006
	for <linux-mm@kvack.org>; Fri, 18 Dec 2015 09:41:09 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id l126so68068431wml.1
        for <linux-mm@kvack.org>; Fri, 18 Dec 2015 06:41:09 -0800 (PST)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.134])
        by mx.google.com with ESMTPS id ek8si26031092wjd.115.2015.12.18.06.41.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Dec 2015 06:41:08 -0800 (PST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] memcg: fix SLOB build regression
Date: Fri, 18 Dec 2015 15:35:06 +0100
Message-ID: <13705081.IYJlPWfILN@wuerfel>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org

A recent cleanup broke the build when CONFIG_SLOB is used:

mm/memcontrol.c: In function 'memcg_update_kmem_limit':
mm/memcontrol.c:2974:9: error: implicit declaration of function 'memcg_online_kmem' [-Werror=implicit-function-declaration]
mm/memcontrol.c: In function 'mem_cgroup_css_alloc':
mm/memcontrol.c:4229:10: error: too many arguments to function 'memcg_propagate_kmem'
mm/memcontrol.c:2949:12: note: declared here

This fixes the memcg_propagate_kmem prototype to match the normal
implementation and adds the respective memcg_online_kmem helper
function that was needed.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: a5ed904c5039 ("mm: memcontrol: clean up alloc, online, offline, free functions")
---
This just showed up on ARM randconfig builds with linux-next, please apply
or fold into the original patch

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 48b22c3545b1..4637199e69d6 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2946,7 +2946,11 @@ static void memcg_free_kmem(struct mem_cgroup *memcg)
 	}
 }
 #else
-static int memcg_propagate_kmem(struct mem_cgroup *memcg)
+static int memcg_propagate_kmem(struct mem_cgroup *parent, struct mem_cgroup *memcg)
+{
+	return 0;
+}
+static int memcg_online_kmem(struct mem_cgroup *memcg)
 {
 	return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
