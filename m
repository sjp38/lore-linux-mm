Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 7561F6B003C
	for <linux-mm@kvack.org>; Fri, 26 Sep 2014 10:51:16 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id y10so1196645pdj.41
        for <linux-mm@kvack.org>; Fri, 26 Sep 2014 07:51:16 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id r15si9803723pdj.62.2014.09.26.07.51.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Sep 2014 07:51:15 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH 4/4] slub: fix cpuset check in get_any_partial
Date: Fri, 26 Sep 2014 18:50:55 +0400
Message-ID: <a3dcb3264b41f6eeea64241f6959735a1fbf0e96.1411741632.git.vdavydov@parallels.com>
In-Reply-To: <cover.1411741632.git.vdavydov@parallels.com>
References: <cover.1411741632.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Li Zefan <lizefan@huawei.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

If we fail to allocate from the current node's stock, we look for free
objects on other nodes before calling the page allocator (see
get_any_partial). While checking other nodes we respect cpuset
constraints by calling cpuset_zone_allowed. We enforce hardwall check.
As a result, we will fallback to the page allocator even if there are
some pages cached on other nodes, but the current cpuset doesn't have
them set. However, the page allocator uses softwall check for kernel
allocations, so it may allocate from one of the other nodes in this
case.

Therefore we should use softwall cpuset check in get_any_partial to
conform with the cpuset check in the page allocator.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/slub.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 1bf4e59fea45..70cfdfcb1a75 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1672,8 +1672,7 @@ static void *get_any_partial(struct kmem_cache *s, gfp_t flags,
 
 			n = get_node(s, zone_to_nid(zone));
 
-			if (n && cpuset_zone_allowed(zone,
-						     flags | __GFP_HARDWALL) &&
+			if (n && cpuset_zone_allowed(zone, flags) &&
 					n->nr_partial > s->min_partial) {
 				object = get_partial_node(s, n, c, flags);
 				if (object) {
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
