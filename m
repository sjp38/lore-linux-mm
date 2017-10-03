Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id C16EF6B0038
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 22:15:35 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id y192so18814967pgd.0
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 19:15:35 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s59sor2187486plb.104.2017.10.02.19.15.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 02 Oct 2017 19:15:34 -0700 (PDT)
From: Shakeel Butt <shakeelb@google.com>
Subject: [PATCH] epoll: account epitem and eppoll_entry to kmemcg
Date: Mon,  2 Oct 2017 19:15:19 -0700
Message-Id: <20171003021519.23907-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Shakeel Butt <shakeelb@google.com>

The user space application can directly trigger the allocations
from eventpoll_epi and eventpoll_pwq slabs. A buggy or malicious
application can consume a significant amount of system memory by
triggering such allocations. Indeed we have seen in production
where a buggy application was leaking the epoll references and
causing a burst of eventpoll_epi and eventpoll_pwq slab
allocations. This patch opt-in the charging of eventpoll_epi
and eventpoll_pwq slabs.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
---
 fs/eventpoll.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/eventpoll.c b/fs/eventpoll.c
index 2fabd19cdeea..a45360444895 100644
--- a/fs/eventpoll.c
+++ b/fs/eventpoll.c
@@ -2329,11 +2329,11 @@ static int __init eventpoll_init(void)
 
 	/* Allocates slab cache used to allocate "struct epitem" items */
 	epi_cache = kmem_cache_create("eventpoll_epi", sizeof(struct epitem),
-			0, SLAB_HWCACHE_ALIGN | SLAB_PANIC, NULL);
+			0, SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_ACCOUNT, NULL);
 
 	/* Allocates slab cache used to allocate "struct eppoll_entry" */
 	pwq_cache = kmem_cache_create("eventpoll_pwq",
-			sizeof(struct eppoll_entry), 0, SLAB_PANIC, NULL);
+		sizeof(struct eppoll_entry), 0, SLAB_PANIC|SLAB_ACCOUNT, NULL);
 
 	return 0;
 }
-- 
2.14.2.822.g60be5d43e6-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
