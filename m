Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 437BB280292
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 09:54:44 -0400 (EDT)
Received: by pdbqm3 with SMTP id qm3so25580446pdb.0
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 06:54:44 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id tk2si7710144pac.116.2015.07.15.06.54.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jul 2015 06:54:43 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v8 2/7] hwpoison: use page_cgroup_ino for filtering by memcg
Date: Wed, 15 Jul 2015 16:54:06 +0300
Message-ID: <5c4d3594a5b0a79248fffae67ea677d54d06aacf.1436967694.git.vdavydov@parallels.com>
In-Reply-To: <cover.1436967694.git.vdavydov@parallels.com>
References: <cover.1436967694.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andres Lagar-Cavilla <andreslc@google.com>, Minchan Kim <minchan@kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Hwpoison allows to filter pages by memory cgroup ino. Currently, it
calls try_get_mem_cgroup_from_page to obtain the cgroup from a page and
then its ino using cgroup_ino, but now we have an apter method for that,
page_cgroup_ino, so use it instead.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/hwpoison-inject.c |  5 +----
 mm/memory-failure.c  | 16 ++--------------
 2 files changed, 3 insertions(+), 18 deletions(-)

diff --git a/mm/hwpoison-inject.c b/mm/hwpoison-inject.c
index bf73ac17dad4..5015679014c1 100644
--- a/mm/hwpoison-inject.c
+++ b/mm/hwpoison-inject.c
@@ -45,12 +45,9 @@ static int hwpoison_inject(void *data, u64 val)
 	/*
 	 * do a racy check with elevated page count, to make sure PG_hwpoison
 	 * will only be set for the targeted owner (or on a free page).
-	 * We temporarily take page lock for try_get_mem_cgroup_from_page().
 	 * memory_failure() will redo the check reliably inside page lock.
 	 */
-	lock_page(hpage);
 	err = hwpoison_filter(hpage);
-	unlock_page(hpage);
 	if (err)
 		goto put_out;
 
@@ -126,7 +123,7 @@ static int pfn_inject_init(void)
 	if (!dentry)
 		goto fail;
 
-#ifdef CONFIG_MEMCG_SWAP
+#ifdef CONFIG_MEMCG
 	dentry = debugfs_create_u64("corrupt-filter-memcg", 0600,
 				    hwpoison_dir, &hwpoison_filter_memcg);
 	if (!dentry)
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 1cf7f2988422..97005396a507 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -130,27 +130,15 @@ static int hwpoison_filter_flags(struct page *p)
  * can only guarantee that the page either belongs to the memcg tasks, or is
  * a freed page.
  */
-#ifdef	CONFIG_MEMCG_SWAP
+#ifdef CONFIG_MEMCG
 u64 hwpoison_filter_memcg;
 EXPORT_SYMBOL_GPL(hwpoison_filter_memcg);
 static int hwpoison_filter_task(struct page *p)
 {
-	struct mem_cgroup *mem;
-	struct cgroup_subsys_state *css;
-	unsigned long ino;
-
 	if (!hwpoison_filter_memcg)
 		return 0;
 
-	mem = try_get_mem_cgroup_from_page(p);
-	if (!mem)
-		return -EINVAL;
-
-	css = mem_cgroup_css(mem);
-	ino = cgroup_ino(css->cgroup);
-	css_put(css);
-
-	if (ino != hwpoison_filter_memcg)
+	if (page_cgroup_ino(p) != hwpoison_filter_memcg)
 		return -EINVAL;
 
 	return 0;
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
