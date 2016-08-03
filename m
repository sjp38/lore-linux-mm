Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2A2706B0005
	for <linux-mm@kvack.org>; Wed,  3 Aug 2016 08:34:58 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id m130so443905172ioa.1
        for <linux-mm@kvack.org>; Wed, 03 Aug 2016 05:34:58 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0100.outbound.protection.outlook.com. [104.47.1.100])
        by mx.google.com with ESMTPS id u7si4463294oia.50.2016.08.03.05.34.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 03 Aug 2016 05:34:57 -0700 (PDT)
Date: Wed, 3 Aug 2016 15:34:45 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH v3 1/3] mm: memcontrol: fix swap counter leak on swapout
 from offline cgroup
Message-ID: <20160803123445.GJ13263@esperanza>
References: <5336daa5c9a32e776067773d9da655d2dc126491.1470219853.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <5336daa5c9a32e776067773d9da655d2dc126491.1470219853.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: stable@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Aug 03, 2016 at 01:35:06PM +0300, Vladimir Davydov wrote:
> An offline memory cgroup might have anonymous memory or shmem left
> charged to it and no swap. Since only swap entries pin the id of an
> offline cgroup, such a cgroup will have no id and so an attempt to
> swapout its anon/shmem will not store memory cgroup info in the swap
> cgroup map. As a result, memcg->swap or memcg->memsw will never get
> uncharged from it and any of its ascendants.
> 
> Fix this by always charging swapout to the first ancestor cgroup that
> hasn't released its id yet.
> 
> [hannes@cmpxchg.org: add comment to mem_cgroup_swapout]
> Fixes: 73f576c04b941 ("mm: memcontrol: fix cgroup creation failure after many small jobs")
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Cc: <stable@vger.kernel.org>	[3.19+]

Andrew, could you please fold this in?

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 1c0aa59fd333..8c8e68becee9 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4044,7 +4044,7 @@ static struct mem_cgroup *mem_cgroup_id_get_online(struct mem_cgroup *memcg)
 		 * The root cgroup cannot be destroyed, so it's refcount must
 		 * always be >= 1.
 		 */
-		if (memcg == root_mem_cgroup) {
+		if (WARN_ON_ONCE(memcg == root_mem_cgroup)) {
 			VM_BUG_ON(1);
 			break;
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
