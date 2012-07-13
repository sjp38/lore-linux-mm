Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 50B3B6B005C
	for <linux-mm@kvack.org>; Fri, 13 Jul 2012 19:12:09 -0400 (EDT)
Message-ID: <1342221125.17464.8.camel@lorien2>
Subject: [PATCH TRIVIAL] mm: Fix build warning in kmem_cache_create()
From: Shuah Khan <shuah.khan@hp.com>
Reply-To: shuah.khan@hp.com
Date: Fri, 13 Jul 2012 17:12:05 -0600
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, glommer@parallels.com, js1304@gmail.com
Cc: shuahkhan@gmail.com, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

The label oops is used in CONFIG_DEBUG_VM ifdef block and is defined
outside ifdef CONFIG_DEBUG_VM block. This results in the following
build warning when built with CONFIG_DEBUG_VM disabled. Fix to move 
label oops definition to inside a CONFIG_DEBUG_VM block.

mm/slab_common.c: In function a??kmem_cache_createa??:
mm/slab_common.c:101:1: warning: label a??oopsa?? defined but not used
[-Wunused-label]

Signed-off-by: Shuah Khan <shuah.khan@hp.com>
---
 mm/slab_common.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 12637ce..aa3ca5b 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -98,7 +98,9 @@ struct kmem_cache *kmem_cache_create(const char *name, size_t size, size_t align
 
 	s = __kmem_cache_create(name, size, align, flags, ctor);
 
+#ifdef CONFIG_DEBUG_VM
 oops:
+#endif
 	mutex_unlock(&slab_mutex);
 	put_online_cpus();
 
-- 
1.7.9.5



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
