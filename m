Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id CC45C6B039F
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 12:17:37 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id y15so6887565lfd.7
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 09:17:37 -0700 (PDT)
Received: from mail-lf0-f66.google.com (mail-lf0-f66.google.com. [209.85.215.66])
        by mx.google.com with ESMTPS id a65si517842lfl.321.2017.08.11.09.17.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Aug 2017 09:17:36 -0700 (PDT)
Received: by mail-lf0-f66.google.com with SMTP id t128so2600306lff.3
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 09:17:35 -0700 (PDT)
From: Alexander Popov <alex.popov@linux.com>
Subject: [linux-next][PATCH v2] mm/slub.c: add a naive detection of double free or corruption
Date: Fri, 11 Aug 2017 19:17:26 +0300
Message-Id: <1502468246-1262-1-git-send-email-alex.popov@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Paul E McKenney <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Tejun Heo <tj@kernel.org>, Andy Lutomirski <luto@kernel.org>, Nicolas Pitre <nicolas.pitre@linaro.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Tycho Andersen <tycho@docker.com>, Alexander Popov <alex.popov@linux.com>, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

Add an assertion similar to "fasttop" check in GNU C Library allocator
as a part of SLAB_FREELIST_HARDENED feature. An object added to a singly
linked freelist should not point to itself. That helps to detect some
double free errors (e.g. CVE-2017-2636) without slub_debug and KASAN.

Signed-off-by: Alexander Popov <alex.popov@linux.com>
---
 mm/slub.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/slub.c b/mm/slub.c
index b9c7f1a..77b2781 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -290,6 +290,10 @@ static inline void set_freepointer(struct kmem_cache *s, void *object, void *fp)
 {
 	unsigned long freeptr_addr = (unsigned long)object + s->offset;
 
+#ifdef CONFIG_SLAB_FREELIST_HARDENED
+	BUG_ON(object == fp); /* naive detection of double free or corruption */
+#endif
+
 	*(void **)freeptr_addr = freelist_ptr(s, fp, freeptr_addr);
 }
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
