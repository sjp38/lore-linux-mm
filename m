Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3AAFE6B0253
	for <linux-mm@kvack.org>; Mon,  8 Aug 2016 16:03:23 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id s207so302300924oie.1
        for <linux-mm@kvack.org>; Mon, 08 Aug 2016 13:03:23 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0127.outbound.protection.outlook.com. [104.47.0.127])
        by mx.google.com with ESMTPS id w7si9305060ota.241.2016.08.08.13.03.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 08 Aug 2016 13:03:22 -0700 (PDT)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH] mm: memcontrol: only mark charged pages with PageKmemcg
Date: Mon, 8 Aug 2016 23:03:12 +0300
Message-ID: <1470686593-31943-1-git-send-email-vdavydov@virtuozzo.com>
In-Reply-To: <20160808183754.GE1983@esperanza>
References: <20160808183754.GE1983@esperanza>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: stable@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

To distinguish non-slab pages charged to kmemcg we mark them PageKmemcg,
which sets page->_mapcount to -512. Currently, we set/clear PageKmemcg in
__alloc_pages_nodemask()/free_pages_prepare() for any page allocated
with __GFP_ACCOUNT, including those that aren't actually charged to any
cgroup, i.e. allocated from the root cgroup context. To avoid overhead
in case cgroups are not used, we only do that if memcg_kmem_enabled() is
true. The latter is set iff there are kmem-enabled memory cgroups
(online or offline). The root cgroup is not considered kmem-enabled.

As a result, if a page is allocated with __GFP_ACCOUNT for the root
cgroup when there are kmem-enabled memory cgroups and is freed after all
kmem-enabled memory cgroups were removed, e.g.

  # no memory cgroups has been created yet, create one
  mkdir /sys/fs/cgroup/memory/test
  # run something allocating pages with __GFP_ACCOUNT, e.g.
  # a program using pipe
  dmesg | tail
  # remove the memory cgroup
  rmdir /sys/fs/cgroup/memory/test

we'll get bad page state bug complaining about page->_mapcount != -1:

  BUG: Bad page state in process swapper/0  pfn:1fd945c
  page:ffffea007f651700 count:0 mapcount:-511 mapping:          (null) index:0x0
  flags: 0x1000000000000000()

To avoid that, let's mark with PageKmemcg only those pages that are
actually charged to and hence pin a non-root memory cgroup.

Fixes: 4949148ad433 ("mm: charge/uncharge kmemcg from generic page allocator paths")
Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: <stable@vger.kernel.org>	[4.7+]
---
 fs/pipe.c       |  4 +---
 mm/memcontrol.c | 14 ++++++++++++--
 mm/page_alloc.c | 14 +++++---------
 3 files changed, 18 insertions(+), 14 deletions(-)

diff --git a/fs/pipe.c b/fs/pipe.c
index 4b32928f5426..4ebe6b2e5217 100644
--- a/fs/pipe.c
+++ b/fs/pipe.c
@@ -144,10 +144,8 @@ static int anon_pipe_buf_steal(struct pipe_inode_info *pipe,
 	struct page *page = buf->page;
 
 	if (page_count(page) == 1) {
-		if (memcg_kmem_enabled()) {
+		if (memcg_kmem_enabled())
 			memcg_kmem_uncharge(page, 0);
-			__ClearPageKmemcg(page);
-		}
 		__SetPageLocked(page);
 		return 0;
 	}
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 1c0aa59fd333..7c9c0bd475f0 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2308,8 +2308,11 @@ int memcg_kmem_charge(struct page *page, gfp_t gfp, int order)
 		return 0;
 
 	memcg = get_mem_cgroup_from_mm(current->mm);
-	if (!mem_cgroup_is_root(memcg))
+	if (!mem_cgroup_is_root(memcg)) {
 		ret = memcg_kmem_charge_memcg(page, gfp, order, memcg);
+		if (!ret)
+			__SetPageKmemcg(page);
+	}
 	css_put(&memcg->css);
 	return ret;
 }
@@ -2336,6 +2339,11 @@ void memcg_kmem_uncharge(struct page *page, int order)
 		page_counter_uncharge(&memcg->memsw, nr_pages);
 
 	page->mem_cgroup = NULL;
+
+	/* slab pages do not have PageKmemcg flag set */
+	if (PageKmemcg(page))
+		__ClearPageKmemcg(page);
+
 	css_put_many(&memcg->css, nr_pages);
 }
 #endif /* !CONFIG_SLOB */
@@ -5533,8 +5541,10 @@ static void uncharge_list(struct list_head *page_list)
 			else
 				nr_file += nr_pages;
 			pgpgout++;
-		} else
+		} else {
 			nr_kmem += 1 << compound_order(page);
+			__ClearPageKmemcg(page);
+		}
 
 		page->mem_cgroup = NULL;
 	} while (next != page_list);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ee5a4b20daf4..3a7d3a1fb6a0 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1009,10 +1009,8 @@ static __always_inline bool free_pages_prepare(struct page *page,
 	}
 	if (PageMappingFlags(page))
 		page->mapping = NULL;
-	if (memcg_kmem_enabled() && PageKmemcg(page)) {
+	if (memcg_kmem_enabled() && PageKmemcg(page))
 		memcg_kmem_uncharge(page, order);
-		__ClearPageKmemcg(page);
-	}
 	if (check_free)
 		bad += free_pages_check(page);
 	if (bad)
@@ -3788,12 +3786,10 @@ no_zone:
 	}
 
 out:
-	if (memcg_kmem_enabled() && (gfp_mask & __GFP_ACCOUNT) && page) {
-		if (unlikely(memcg_kmem_charge(page, gfp_mask, order))) {
-			__free_pages(page, order);
-			page = NULL;
-		} else
-			__SetPageKmemcg(page);
+	if (memcg_kmem_enabled() && (gfp_mask & __GFP_ACCOUNT) && page &&
+	    unlikely(memcg_kmem_charge(page, gfp_mask, order) != 0)) {
+		__free_pages(page, order);
+		page = NULL;
 	}
 
 	if (kmemcheck_enabled && page)
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
