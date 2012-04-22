Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id B11C46B00E9
	for <linux-mm@kvack.org>; Sun, 22 Apr 2012 19:56:58 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH 14/23] slub: provide kmalloc_no_account
Date: Sun, 22 Apr 2012 20:53:31 -0300
Message-Id: <1335138820-26590-3-git-send-email-glommer@parallels.com>
In-Reply-To: <1334959051-18203-1-git-send-email-glommer@parallels.com>
References: <1334959051-18203-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, fweisbec@gmail.com, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Glauber Costa <glommer@parallels.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>

Some allocations need to be accounted to the root memcg regardless
of their context. One trivial example, is the allocations we do
during the memcg slab cache creation themselves. Strictly speaking,
they could go to the parent, but it is way easier to bill them to
the root cgroup.

Only generic kmalloc allocations are allowed to be bypassed.

The function is not exported, because drivers code should always
be accounted.

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Christoph Lameter <cl@linux.com>
CC: Pekka Enberg <penberg@cs.helsinki.fi>
CC: Michal Hocko <mhocko@suse.cz>
CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
CC: Johannes Weiner <hannes@cmpxchg.org>
CC: Suleiman Souhlal <suleiman@google.com>
---
 include/linux/slub_def.h |    1 +
 mm/slub.c                |   21 +++++++++++++++++++++
 2 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 5f5e942..9a8000a 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -221,6 +221,7 @@ static __always_inline struct kmem_cache *kmalloc_slab(size_t size)
 }
 
 void *kmem_cache_alloc(struct kmem_cache *, gfp_t);
+void *kmalloc_no_account(size_t size, gfp_t);
 void *__kmalloc(size_t size, gfp_t flags);
 
 static __always_inline void *
diff --git a/mm/slub.c b/mm/slub.c
index 2285a96..d754b06 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3359,6 +3359,27 @@ void *__kmalloc(size_t size, gfp_t flags)
 }
 EXPORT_SYMBOL(__kmalloc);
 
+void *kmalloc_no_account(size_t size, gfp_t flags)
+{
+	struct kmem_cache *s;
+	void *ret;
+
+	if (unlikely(size > SLUB_MAX_SIZE))
+		return kmalloc_large(size, flags);
+
+	s = get_slab(size, flags);
+
+	if (unlikely(ZERO_OR_NULL_PTR(s)))
+		return s;
+
+	ret = slab_alloc(s, flags, NUMA_NO_NODE, _RET_IP_);
+
+	trace_kmalloc(_RET_IP_, ret, size, s->size, flags);
+
+	return ret;
+}
+EXPORT_SYMBOL(kmalloc_no_account);
+
 #ifdef CONFIG_NUMA
 static void *kmalloc_large_node(size_t size, gfp_t flags, int node)
 {
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
