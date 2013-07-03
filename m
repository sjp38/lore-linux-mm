Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 25B346B0031
	for <linux-mm@kvack.org>; Wed,  3 Jul 2013 08:15:04 -0400 (EDT)
Received: by mail-bk0-f51.google.com with SMTP id ji1so29815bkc.24
        for <linux-mm@kvack.org>; Wed, 03 Jul 2013 05:15:02 -0700 (PDT)
From: Sedat Dilek <sedat.dilek@gmail.com>
Subject: [PATCH next-20130703] net: sock: Add ifdef CONFIG_MEMCG_KMEM for mem_cgroup_sockets_{init,destroy}
Date: Wed,  3 Jul 2013 14:14:53 +0200
Message-Id: <1372853693-15303-1-git-send-email-sedat.dilek@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, linux-next@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>, linux-mm <linux-mm@kvack.org>
Cc: Sedat Dilek <sedat.dilek@gmail.com>

When "CONFIG_MEMCG_KMEM=n" I see this in my build-log:
...
 LD      init/built-in.o
mm/built-in.o: In function `mem_cgroup_css_free':
memcontrol.c:(.text+0x5caa6): undefined reference to `mem_cgroup_sockets_destroy'
make[2]: *** [vmlinux] Error 1

Inspired by the ifdef for mem_cgroup_sockets_{init,destroy} here...

[ net/core/sock.c ]
...
int mem_cgroup_sockets_init()
...
void mem_cgroup_sockets_destroy()
...

...I did the the same for both in "include/net/sock.h".

This fixes the issue for me in next-20130703.

Signed-off-by: Sedat Dilek <sedat.dilek@gmail.com>
---
 include/net/sock.h | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index ea6206c..ad4bf7f 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -71,6 +71,7 @@
 struct cgroup;
 struct cgroup_subsys;
 #ifdef CONFIG_NET
+#ifdef CONFIG_MEMCG_KMEM
 int mem_cgroup_sockets_init(struct mem_cgroup *memcg, struct cgroup_subsys *ss);
 void mem_cgroup_sockets_destroy(struct mem_cgroup *memcg);
 #else
@@ -83,7 +84,8 @@ static inline
 void mem_cgroup_sockets_destroy(struct mem_cgroup *memcg)
 {
 }
-#endif
+#endif /* CONFIG_NET */
+#endif /* CONFIG_MEMCG_KMEM */
 /*
  * This structure really needs to be cleaned up.
  * Most of it is for TCP, and not used by any of
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
