Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 3C2F76B00FA
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 17:58:11 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH 02/23] slub: always get the cache from its page in kfree
Date: Fri, 20 Apr 2012 18:57:10 -0300
Message-Id: <1334959051-18203-3-git-send-email-glommer@parallels.com>
In-Reply-To: <1334959051-18203-1-git-send-email-glommer@parallels.com>
References: <1334959051-18203-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Glauber Costa <glommer@parallels.com>

struct page already have this information. If we start chaining
caches, this information will always be more trustworthy than
whatever is passed into the function

Signed-off-by: Glauber Costa <glommer@parallels.com>
---
 mm/slub.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index af8cee9..2652e7c 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2600,7 +2600,7 @@ void kmem_cache_free(struct kmem_cache *s, void *x)
 
 	page = virt_to_head_page(x);
 
-	slab_free(s, page, x, _RET_IP_);
+	slab_free(page->slab, page, x, _RET_IP_);
 
 	trace_kmem_cache_free(_RET_IP_, x);
 }
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
