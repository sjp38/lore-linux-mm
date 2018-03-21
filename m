Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0E9F56B0005
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 16:59:52 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id j25so2553373wmh.1
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 13:59:52 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w74sor1622943wmf.1.2018.03.21.13.59.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Mar 2018 13:59:50 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] memcg, thp: do not invoke oom killer on thp charges
Date: Wed, 21 Mar 2018 21:59:28 +0100
Message-Id: <20180321205928.22240-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

David has noticed that THP memcg charge can trigger the oom killer
since 2516035499b9 ("mm, thp: remove __GFP_NORETRY from khugepaged and
madvised allocations"). We have used an explicit __GFP_NORETRY
previously which ruled the OOM killer automagically.

Memcg charge path should be semantically compliant with the allocation
path and that means that if we do not trigger the OOM killer for costly
orders which should do the same in the memcg charge path as well.
Otherwise we are forcing callers to distinguish the two and use
different gfp masks which is both non-intuitive and bug prone. Not to
mention the maintenance burden.

Teach mem_cgroup_oom to bail out on costly order requests to fix the THP
issue as well as any other costly OOM eligible allocations to be added
in future.

Fixes: 2516035499b9 ("mm, thp: remove __GFP_NORETRY from khugepaged and madvised allocations")
Reported-by: David Rientjes <rientjes@google.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---

Hi,
this is an alternative patch to [1]. I strongly believe that using
different gfp masks for the allocation and memcg charging is to be
avoided as much as possible. There doesn't seem to be any good reason
why THP charges should be an exception here.

I would be tempted to mark this for stable even though we haven't seen
any unexpected memcg OOM killer reports since 4.8 which is quite some
time.

[1] http://lkml.kernel.org/r/alpine.DEB.2.20.1803191409420.124411@chino.kir.corp.google.com

 mm/memcontrol.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d1a917b5b7b7..08accbcd1a18 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1493,7 +1493,7 @@ static void memcg_oom_recover(struct mem_cgroup *memcg)
 
 static void mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int order)
 {
-	if (!current->memcg_may_oom)
+	if (!current->memcg_may_oom || order > PAGE_ALLOC_COSTLY_ORDER)
 		return;
 	/*
 	 * We are in the middle of the charge context here, so we
-- 
2.16.2
