Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 5D8C528035A
	for <linux-mm@kvack.org>; Sun, 19 Jul 2015 08:31:45 -0400 (EDT)
Received: by pdbnt7 with SMTP id nt7so16643862pdb.0
        for <linux-mm@kvack.org>; Sun, 19 Jul 2015 05:31:45 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id nl1si28646231pdb.196.2015.07.19.05.31.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 Jul 2015 05:31:44 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v9 1/8] memcg: add page_cgroup_ino helper
Date: Sun, 19 Jul 2015 15:31:10 +0300
Message-ID: <aa0190b76489260b4d1b65cdfa65221f4e6390f5.1437303956.git.vdavydov@parallels.com>
In-Reply-To: <cover.1437303956.git.vdavydov@parallels.com>
References: <cover.1437303956.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andres Lagar-Cavilla <andreslc@google.com>, Minchan Kim <minchan@kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

This function returns the inode number of the closest online ancestor of
the memory cgroup a page is charged to. It is required for exporting
information about which page is charged to which cgroup to userspace,
which will be introduced by a following patch.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Reviewed-by: Andres Lagar-Cavilla <andreslc@google.com>
---
 include/linux/memcontrol.h |  1 +
 mm/memcontrol.c            | 23 +++++++++++++++++++++++
 2 files changed, 24 insertions(+)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index d92b80b63c5c..99b0e43cac45 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -345,6 +345,7 @@ static inline bool mm_match_cgroup(struct mm_struct *mm,
 }
 
 struct cgroup_subsys_state *mem_cgroup_css_from_page(struct page *page);
+unsigned long page_cgroup_ino(struct page *page);
 
 static inline bool mem_cgroup_disabled(void)
 {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 1def8810880a..a91bc1ee964c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -441,6 +441,29 @@ struct cgroup_subsys_state *mem_cgroup_css_from_page(struct page *page)
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
