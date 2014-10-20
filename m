Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id EF33C6B006E
	for <linux-mm@kvack.org>; Mon, 20 Oct 2014 14:59:47 -0400 (EDT)
Received: by mail-wg0-f47.google.com with SMTP id x13so6179771wgg.30
        for <linux-mm@kvack.org>; Mon, 20 Oct 2014 11:59:46 -0700 (PDT)
Received: from mail-wi0-x232.google.com (mail-wi0-x232.google.com. [2a00:1450:400c:c05::232])
        by mx.google.com with ESMTPS id wt4si11575561wjc.61.2014.10.20.11.59.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 20 Oct 2014 11:59:46 -0700 (PDT)
Received: by mail-wi0-f178.google.com with SMTP id r20so103273wiv.5
        for <linux-mm@kvack.org>; Mon, 20 Oct 2014 11:59:45 -0700 (PDT)
Date: Mon, 20 Oct 2014 20:59:44 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] mm: memcontrol: micro-optimize
 mem_cgroup_update_page_stat()
Message-ID: <20141020185944.GC505@dhcp22.suse.cz>
References: <1413818259-10913-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1413818259-10913-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon 20-10-14 11:17:39, Johannes Weiner wrote:
> Do not look up the page_cgroup when the memory controller is
> runtime-disabled, but do assert that the locking protocol is followed
> under DEBUG_VM regardless.  Also remove the unused flags variable.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.cz>

mem_cgroup_split_huge_fixup is following the same pattern and might be
folded into this one. I can send a separate patch if you prefer, though.
---
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 3a203c7ec6c7..544e32292c7f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3167,7 +3167,7 @@ static inline void memcg_unregister_all_caches(struct mem_cgroup *memcg)
  */
 void mem_cgroup_split_huge_fixup(struct page *head)
 {
-	struct page_cgroup *head_pc = lookup_page_cgroup(head);
+	struct page_cgroup *head_pc;
 	struct page_cgroup *pc;
 	struct mem_cgroup *memcg;
 	int i;
@@ -3175,6 +3175,8 @@ void mem_cgroup_split_huge_fixup(struct page *head)
 	if (mem_cgroup_disabled())
 		return;
 
+	head_pc = lookup_page_cgroup(head);
+
 	memcg = head_pc->mem_cgroup;
 	for (i = 1; i < HPAGE_PMD_NR; i++) {
 		pc = head_pc + i;
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
