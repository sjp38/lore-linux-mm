Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 53BC66B002B
	for <linux-mm@kvack.org>; Wed, 10 Oct 2012 02:32:39 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so287216pad.14
        for <linux-mm@kvack.org>; Tue, 09 Oct 2012 23:32:38 -0700 (PDT)
Date: Tue, 9 Oct 2012 23:32:35 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch for-linus] memcg, kmem: fix build error when CONFIG_INET is
 disabled
Message-ID: <alpine.DEB.2.00.1210092325500.9528@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Randy Dunlap <rdunlap@xenotime.net>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, "David S. Miller" <davem@davemloft.net>, "Eric W. Biederman" <ebiederm@xmission.com>, Eric Dumazet <eric.dumazet@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Commit e1aab161e013 ("socket: initial cgroup code.") causes a build error 
when CONFIG_INET is disabled in Linus' tree:

net/built-in.o: In function `sk_update_clone':
net/core/sock.c:1336: undefined reference to `sock_update_memcg'

sock_update_memcg() is only defined when CONFIG_INET is enabled, so fix it 
by defining the dummy function without this option.

Reported-by: Randy Dunlap <rdunlap@xenotime.net>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 Checking the logs, Randy reported this in an email to LKML on 
 September 24 and didn't get a response...

 include/linux/memcontrol.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -396,7 +396,7 @@ enum {
 };
 
 struct sock;
-#ifdef CONFIG_MEMCG_KMEM
+#if defined(CONFIG_INET) && defined(CONFIG_MEMCG_KMEM)
 void sock_update_memcg(struct sock *sk);
 void sock_release_memcg(struct sock *sk);
 #else
@@ -406,6 +406,6 @@ static inline void sock_update_memcg(struct sock *sk)
 static inline void sock_release_memcg(struct sock *sk)
 {
 }
-#endif /* CONFIG_MEMCG_KMEM */
+#endif /* CONFIG_INET && CONFIG_MEMCG_KMEM */
 #endif /* _LINUX_MEMCONTROL_H */
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
