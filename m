Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 623876B0038
	for <linux-mm@kvack.org>; Fri, 12 Jun 2015 05:52:46 -0400 (EDT)
Received: by pdjm12 with SMTP id m12so21643106pdj.3
        for <linux-mm@kvack.org>; Fri, 12 Jun 2015 02:52:46 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id h16si4630833pde.217.2015.06.12.02.52.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jun 2015 02:52:44 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v6 1/6] memcg: add page_cgroup_ino helper
Date: Fri, 12 Jun 2015 12:52:21 +0300
Message-ID: <d582e15ceeb2097fde2796e091e507f5a2bb19f0.1434102076.git.vdavydov@parallels.com>
In-Reply-To: <cover.1434102076.git.vdavydov@parallels.com>
References: <cover.1434102076.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

This function returns the inode number of the closest online ancestor of
the memory cgroup a page is charged to. It is required for exporting
information about which page is charged to which cgroup to userspace,
which will be introduced by a following patch.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/memcontrol.h |  1 +
 mm/memcontrol.c            | 23 +++++++++++++++++++++++
 2 files changed, 24 insertions(+)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 73b02b0a8f60..50069abebc3c 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -116,6 +116,7 @@ static inline bool mm_match_cgroup(struct mm_struct *mm,
 
 extern struct cgroup_subsys_state *mem_cgroup_css(struct mem_cgroup *memcg);
 extern struct cgroup_subsys_state *mem_cgroup_css_from_page(struct page *page);
+extern unsigned long page_cgroup_ino(struct page *page);
 
 struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *,
 				   struct mem_cgroup *,
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index acb93c554f6e..894dc2169979 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -631,6 +631,29 @@ struct cgroup_subsys_state *mem_cgroup_css_from_page(struct page *page)
 	return &memcg->css;
 }
 
+/**
+ * page_cgroup_ino - return inode number of the memcg a page is charged to
+ * @page: the page
+ *
+ * Look up the closest online ancestor of the memory cgroup @page is charged to
+ * and return its inode number or 0 if @page is not charged to any cgroup. It
+ * is safe to call this function without holding a reference to @page.
+ */
+unsigned long page_cgroup_ino(struct page *page)
+{
+	struct mem_cgroup *memcg;
+	unsigned long ino = 0;
+
+	rcu_read_lock();
+	memcg = READ_ONCE(page->mem_cgroup);
+	while (memcg && !(memcg->css.flags & CSS_ONLINE))
+		memcg = parent_mem_cgroup(memcg);
+	if (memcg)
+		ino = cgroup_ino(memcg->css.cgroup);
+	rcu_read_unlock();
+	return ino;
+}
+
 static struct mem_cgroup_per_zone *
 mem_cgroup_page_zoneinfo(struct mem_cgroup *memcg, struct page *page)
 {
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
