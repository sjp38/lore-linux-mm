Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5C4906B025E
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 12:26:56 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id g18so1821643lfg.2
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 09:26:56 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id i76si5922887wmc.31.2016.06.17.09.26.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jun 2016 09:26:55 -0700 (PDT)
Date: Fri, 17 Jun 2016 12:24:27 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 2/3] cgroup: remove unnecessary 0 check from css_from_id()
Message-ID: <20160617162427.GC19084@cmpxchg.org>
References: <20160616034244.14839-1-hannes@cmpxchg.org>
 <20160616200617.GD3262@mtj.duckdns.org>
 <20160617162310.GA19084@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160617162310.GA19084@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@suse.cz>, Li Zefan <lizefan@huawei.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

css_idr allocation starts at 1, so index 0 will never point to an
item. css_from_id() currently filters that before asking idr_find(),
but idr_find() would also just return NULL, so this is not needed.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 kernel/cgroup.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 36fc0ff506c3..78f6d18ff0af 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -6162,7 +6162,7 @@ struct cgroup_subsys_state *css_tryget_online_from_dir(struct dentry *dentry,
 struct cgroup_subsys_state *css_from_id(int id, struct cgroup_subsys *ss)
 {
 	WARN_ON_ONCE(!rcu_read_lock_held());
-	return id > 0 ? idr_find(&ss->css_idr, id) : NULL;
+	return idr_find(&ss->css_idr, id);
 }
 
 /**
-- 
2.8.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
