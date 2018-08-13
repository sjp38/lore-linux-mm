Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id AF1D06B0007
	for <linux-mm@kvack.org>; Mon, 13 Aug 2018 02:58:16 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id w8-v6so3039812lfe.15
        for <linux-mm@kvack.org>; Sun, 12 Aug 2018 23:58:16 -0700 (PDT)
Received: from forwardcorp1g.cmail.yandex.net (forwardcorp1g.cmail.yandex.net. [2a02:6b8:0:1465::fd])
        by mx.google.com with ESMTPS id p16-v6si6927774lji.224.2018.08.12.23.58.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 12 Aug 2018 23:58:14 -0700 (PDT)
Subject: [PATCH RFC 2/3] proc/kpagecgroup: report also inode numbers of
 offline cgroups
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Mon, 13 Aug 2018 09:58:10 +0300
Message-ID: <153414348994.737150.10057219558779418929.stgit@buzz>
In-Reply-To: <153414348591.737150.14229960913953276515.stgit@buzz>
References: <153414348591.737150.14229960913953276515.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>

By default this interface reports inode number of closest online ancestor
if cgroups is offline (removed). Information about real owner is required
for detecting which pages keep removed cgroup.

This patch adds per-file mode which is changed by writing 64-bit flags
into opened /proc/kpagecgroup. For now only first bit is used.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 Documentation/admin-guide/mm/pagemap.rst |    3 +++
 fs/proc/page.c                           |   24 ++++++++++++++++++++++--
 include/linux/memcontrol.h               |    2 +-
 mm/memcontrol.c                          |    5 +++--
 mm/memory-failure.c                      |    2 +-
 5 files changed, 30 insertions(+), 6 deletions(-)

diff --git a/Documentation/admin-guide/mm/pagemap.rst b/Documentation/admin-guide/mm/pagemap.rst
index 577af85beb41..b39d841ac560 100644
--- a/Documentation/admin-guide/mm/pagemap.rst
+++ b/Documentation/admin-guide/mm/pagemap.rst
@@ -80,6 +80,9 @@ There are four components to pagemap:
    memory cgroup each page is charged to, indexed by PFN. Only available when
    CONFIG_MEMCG is set.
 
+   For offline (removed) cgroup this returnes inode number of closest online
+   ancestor. Write 64-bit flag 1 into opened file for getting real owners.
+
 Short descriptions to the page flags
 ====================================
 
diff --git a/fs/proc/page.c b/fs/proc/page.c
index 792c78a49174..337f526fcc27 100644
--- a/fs/proc/page.c
+++ b/fs/proc/page.c
@@ -248,6 +248,7 @@ static const struct file_operations proc_kpageflags_operations = {
 static ssize_t kpagecgroup_read(struct file *file, char __user *buf,
 				size_t count, loff_t *ppos)
 {
+	unsigned long flags = (unsigned long)file->private_data;
 	u64 __user *out = (u64 __user *)buf;
 	struct page *ppage;
 	unsigned long src = *ppos;
@@ -267,7 +268,7 @@ static ssize_t kpagecgroup_read(struct file *file, char __user *buf,
 			ppage = NULL;
 
 		if (ppage)
-			ino = page_cgroup_ino(ppage);
+			ino = page_cgroup_ino(ppage, !(flags & 1));
 		else
 			ino = 0;
 
@@ -289,9 +290,28 @@ static ssize_t kpagecgroup_read(struct file *file, char __user *buf,
 	return ret;
 }
 
+static ssize_t kpagecgroup_write(struct file *file, const char __user *buf,
+				 size_t count, loff_t *ppos)
+{
+	u64 flags;
+
+	if (count != 8)
+		return -EINVAL;
+
+	if (get_user(flags, buf))
+		return -EFAULT;
+
+	if (flags > 1)
+		return -EINVAL;
+
+	file->private_data = (void *)(unsigned long)flags;
+	return count;
+}
+
 static const struct file_operations proc_kpagecgroup_operations = {
 	.llseek = mem_lseek,
 	.read = kpagecgroup_read,
+	.write = kpagecgroup_write,
 };
 #endif /* CONFIG_MEMCG */
 
@@ -300,7 +320,7 @@ static int __init proc_page_init(void)
 	proc_create("kpagecount", S_IRUSR, NULL, &proc_kpagecount_operations);
 	proc_create("kpageflags", S_IRUSR, NULL, &proc_kpageflags_operations);
 #ifdef CONFIG_MEMCG
-	proc_create("kpagecgroup", S_IRUSR, NULL, &proc_kpagecgroup_operations);
+	proc_create("kpagecgroup", 0600, NULL, &proc_kpagecgroup_operations);
 #endif
 	return 0;
 }
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 6c6fb116e925..a7c40522bef0 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -444,7 +444,7 @@ static inline bool mm_match_cgroup(struct mm_struct *mm,
 }
 
 struct cgroup_subsys_state *mem_cgroup_css_from_page(struct page *page);
-ino_t page_cgroup_ino(struct page *page);
+ino_t page_cgroup_ino(struct page *page, bool online);
 
 static inline bool mem_cgroup_online(struct mem_cgroup *memcg)
 {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 19a4348974a4..7ef6ea9d5e4a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -333,6 +333,7 @@ struct cgroup_subsys_state *mem_cgroup_css_from_page(struct page *page)
 /**
  * page_cgroup_ino - return inode number of the memcg a page is charged to
  * @page: the page
+ * @online: return closest online ancestor
  *
  * Look up the closest online ancestor of the memory cgroup @page is charged to
  * and return its inode number or 0 if @page is not charged to any cgroup. It
@@ -343,14 +344,14 @@ struct cgroup_subsys_state *mem_cgroup_css_from_page(struct page *page)
  * after page_cgroup_ino() returns, so it only should be used by callers that
  * do not care (such as procfs interfaces).
  */
-ino_t page_cgroup_ino(struct page *page)
+ino_t page_cgroup_ino(struct page *page, bool online)
 {
 	struct mem_cgroup *memcg;
 	unsigned long ino = 0;
 
 	rcu_read_lock();
 	memcg = READ_ONCE(page->mem_cgroup);
-	while (memcg && !(memcg->css.flags & CSS_ONLINE))
+	while (memcg && online && !(memcg->css.flags & CSS_ONLINE))
 		memcg = parent_mem_cgroup(memcg);
 	if (memcg)
 		ino = cgroup_ino(memcg->css.cgroup);
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 9d142b9b86dc..bd09c447e0ec 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -139,7 +139,7 @@ static int hwpoison_filter_task(struct page *p)
 	if (!hwpoison_filter_memcg)
 		return 0;
 
-	if (page_cgroup_ino(p) != hwpoison_filter_memcg)
+	if (page_cgroup_ino(p, true) != hwpoison_filter_memcg)
 		return -EINVAL;
 
 	return 0;
