Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id C0F226B0038
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 12:39:06 -0500 (EST)
Received: by wghk14 with SMTP id k14so35003520wgh.3
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 09:39:06 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id ky9si23672395wjc.33.2015.03.02.09.39.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Mar 2015 09:39:04 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] memcg: disable hierarchy support if bound to the legacy cgroup hierarchy
Date: Mon,  2 Mar 2015 12:38:59 -0500
Message-Id: <1425317939-13305-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

From: Vladimir Davydov <vdavydov@parallels.com>

If the memory cgroup controller is initially mounted in the scope of the
default cgroup hierarchy and then remounted to a legacy hierarchy, it
will still have hierarchy support enabled, which is incorrect. We should
disable hierarchy support if bound to the legacy cgroup hierarchy.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

Andrew, could you please pick this up for 4.0?  I don't think it's
urgent enough for -stable, though.  Thanks!

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 0c86945bcc9a..68d4890fc4bd 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5238,7 +5238,9 @@ static void mem_cgroup_bind(struct cgroup_subsys_state *root_css)
 	 * on for the root memcg is enough.
 	 */
 	if (cgroup_on_dfl(root_css->cgroup))
-		mem_cgroup_from_css(root_css)->use_hierarchy = true;
+		root_mem_cgroup->use_hierarchy = true;
+	else
+		root_mem_cgroup->use_hierarchy = false;
 }
 
 static u64 memory_current_read(struct cgroup_subsys_state *css,
-- 
2.3.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
