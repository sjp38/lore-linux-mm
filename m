Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 7E7916B0071
	for <linux-mm@kvack.org>; Mon, 20 Oct 2014 07:50:57 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id ft15so4843443pdb.31
        for <linux-mm@kvack.org>; Mon, 20 Oct 2014 04:50:57 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id kp4si7552089pdb.195.2014.10.20.04.50.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Oct 2014 04:50:56 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH RESEND 4/4] slub: fix cpuset check in get_any_partial
Date: Mon, 20 Oct 2014 15:50:32 +0400
Message-ID: <0b246d9b370c21fd2223e996b514be55b80a4637.1413804554.git.vdavydov@parallels.com>
In-Reply-To: <cover.1413804554.git.vdavydov@parallels.com>
References: <cover.1413804554.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Zefan Li <lizefan@huawei.com>, Christoph Lameter <cl@linux.com>, Pekka
 Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo
 Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

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
Acked-by: Zefan Li <lizefan@huawei.com>
---
 mm/slub.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 7d12f51d9bac..32ec8fd91bb3 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1662,8 +1662,7 @@ static void *get_any_partial(struct kmem_cache *s, gfp_t flags,
 
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
