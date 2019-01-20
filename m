Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id EF9F78E0001
	for <linux-mm@kvack.org>; Sun, 20 Jan 2019 18:16:13 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id z6so19119465qtj.21
        for <linux-mm@kvack.org>; Sun, 20 Jan 2019 15:16:13 -0800 (PST)
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id l15sor107011993qtr.63.2019.01.20.15.16.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 20 Jan 2019 15:16:12 -0800 (PST)
Date: Sun, 20 Jan 2019 15:15:51 -0800
In-Reply-To: <CAHbLzkoRGk9nE6URO9xJKaAQ+8HDPJQosJuPyR1iYuaUBroDMg@mail.gmail.com>
Message-Id: <20190120231551.213847-1-shakeelb@google.com>
Mime-Version: 1.0
References: <CAHbLzkoRGk9nE6URO9xJKaAQ+8HDPJQosJuPyR1iYuaUBroDMg@mail.gmail.com>
Subject: memory cgroup pagecache and inode problem
From: Shakeel Butt <shakeelb@google.com>
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <shy828301@gmail.com>, Fam Zheng <zhengfeiran@bytedance.com>
Cc: cgroups@vger.kernel.org, Linux MM <linux-mm@kvack.org>, tj@kernel.org, Johannes Weiner <hannes@cmpxchg.org>, lizefan@huawei.com, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, duanxiongchun@bytedance.com, =?UTF-8?q?=E5=BC=A0=E6=B0=B8=E8=82=83?= <zhangyongsu@bytedance.com>, liuxiaozhou@bytedance.com, Shakeel Butt <shakeelb@google.com>

On Wed, Jan 16, 2019 at 9:07 PM Yang Shi <shy828301@gmail.com> wrote:
...
> > > You mean it solves the problem by retrying more times?  Actually, I'm
> > > not sure if you have swap setup in your test, but force_empty does do
> > > swap if swap is on. This may cause it can't reclaim all the page cache
> > > in 5 retries.  I have a patch within that series to skip swap.
> >
> > Basically yes, retrying solves the problem. But compared to immediate retries, a scheduled retry in a few seconds is much more effective.
>
> This may suggest doing force_empty in a worker is more effective in
> fact. Not sure if this is good enough to convince Johannes or not.
>

>From what I understand what we actually want is to force_empty an
offlined memcg. How about we change the semantics of force_empty on
root_mem_cgroup? Currently force_empty on root_mem_cgroup returns
-EINVAL. Rather than that, let's do force_empty on all offlined memcgs
if user does force_empty on root_mem_cgroup. Something like following.

---
 mm/memcontrol.c | 22 +++++++++++++++-------
 1 file changed, 15 insertions(+), 7 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index a4ac554be7e8..51daa2935c41 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2898,14 +2898,16 @@ static inline bool memcg_has_children(struct mem_cgroup *memcg)
  *
  * Caller is responsible for holding css reference for memcg.
  */
-static int mem_cgroup_force_empty(struct mem_cgroup *memcg)
+static int mem_cgroup_force_empty(struct mem_cgroup *memcg, bool online)
 {
 	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
 
 	/* we call try-to-free pages for make this cgroup empty */
-	lru_add_drain_all();
 
-	drain_all_stock(memcg);
+	if (online) {
+		lru_add_drain_all();
+		drain_all_stock(memcg);
+	}
 
 	/* try to free all pages in this cgroup */
 	while (nr_retries && page_counter_read(&memcg->memory)) {
@@ -2915,7 +2917,7 @@ static int mem_cgroup_force_empty(struct mem_cgroup *memcg)
 			return -EINTR;
 
 		progress = try_to_free_mem_cgroup_pages(memcg, 1,
-							GFP_KERNEL, true);
+							GFP_KERNEL, online);
 		if (!progress) {
 			nr_retries--;
 			/* maybe some writeback is necessary */
@@ -2932,10 +2934,16 @@ static ssize_t mem_cgroup_force_empty_write(struct kernfs_open_file *of,
 					    loff_t off)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(of_css(of));
+	struct mem_cgroup *mi;
 
-	if (mem_cgroup_is_root(memcg))
-		return -EINVAL;
-	return mem_cgroup_force_empty(memcg) ?: nbytes;
+	if (mem_cgroup_is_root(memcg)) {
+		for_each_mem_cgroup_tree(mi, memcg) {
+			if (!mem_cgroup_online(mi))
+				mem_cgroup_force_empty(mi, false);
+		}
+		return 0;
+	}
+	return mem_cgroup_force_empty(memcg, true) ?: nbytes;
 }
 
 static u64 mem_cgroup_hierarchy_read(struct cgroup_subsys_state *css,
-- 
2.20.1.321.g9e740568ce-goog
