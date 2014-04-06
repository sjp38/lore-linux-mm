Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com [209.85.217.178])
	by kanga.kvack.org (Postfix) with ESMTP id 4D2B56B0038
	for <linux-mm@kvack.org>; Sun,  6 Apr 2014 11:34:06 -0400 (EDT)
Received: by mail-lb0-f178.google.com with SMTP id s7so3911043lbd.37
        for <linux-mm@kvack.org>; Sun, 06 Apr 2014 08:34:05 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id y8si10116331lae.70.2014.04.06.08.34.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 06 Apr 2014 08:34:05 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 2/3] lockdep: mark rwsem_acquire_read as recursive
Date: Sun, 6 Apr 2014 19:33:51 +0400
Message-ID: <8c6473e959a4557d8622a6d7ff24888cb3f7512d.1396779337.git.vdavydov@parallels.com>
In-Reply-To: <cover.1396779337.git.vdavydov@parallels.com>
References: <cover.1396779337.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>

rw_semaphore implementation allows recursing calls to down_read, but
lockdep thinks that it doesn't. As a result, it will complain
false-positively, e.g. if we do not observe some predefined locking
order when taking an rw semaphore for reading and a mutex.

This patch makes lockdep think rw semaphore is read-recursive, just like
rw spin lock.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>
---
 include/linux/lockdep.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/lockdep.h b/include/linux/lockdep.h
index 008388f920d7..4b95fe85375e 100644
--- a/include/linux/lockdep.h
+++ b/include/linux/lockdep.h
@@ -500,7 +500,7 @@ static inline void print_irqtrace_events(struct task_struct *curr)
 
 #define rwsem_acquire(l, s, t, i)		lock_acquire_exclusive(l, s, t, NULL, i)
 #define rwsem_acquire_nest(l, s, t, n, i)	lock_acquire_exclusive(l, s, t, n, i)
-#define rwsem_acquire_read(l, s, t, i)		lock_acquire_shared(l, s, t, NULL, i)
+#define rwsem_acquire_read(l, s, t, i)		lock_acquire_shared_recursive(l, s, t, NULL, i)
 #define rwsem_release(l, n, i)			lock_release(l, n, i)
 
 #define lock_map_acquire(l)			lock_acquire_exclusive(l, 0, 0, NULL, _THIS_IP_)
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
