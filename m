Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 286F06B002B
	for <linux-mm@kvack.org>; Tue, 25 Dec 2012 10:27:48 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id bg2so4531653pad.32
        for <linux-mm@kvack.org>; Tue, 25 Dec 2012 07:27:47 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH] slub: assign refcount for kmalloc_caches
Date: Wed, 26 Dec 2012 00:24:42 +0900
Message-Id: <1356449082-3016-1-git-send-email-js1304@gmail.com>
In-Reply-To: <CAAvDA15U=KCOujRYA5k3YkvC9Z=E6fcG5hopPUJNgULYj_MAJw@mail.gmail.com>
References: <CAAvDA15U=KCOujRYA5k3YkvC9Z=E6fcG5hopPUJNgULYj_MAJw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Paul Hargrove <phhargrove@lbl.gov>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>, Christoph Lameter <cl@linux.com>

commit cce89f4f6911286500cf7be0363f46c9b0a12ce0('Move kmem_cache
refcounting to common code') moves some refcount manipulation code to
common code. Unfortunately, it also removed refcount assignment for
kmalloc_caches. So, kmalloc_caches's refcount is initially 0.
This makes errornous situation.

Paul Hargrove report that when he create a 8-byte kmem_cache and
destory it, he encounter below message.
'Objects remaining in kmalloc-8 on kmem_cache_close()'

8-byte kmem_cache merge with 8-byte kmalloc cache and refcount is
increased by one. So, resulting refcount is 1. When destory it, it hit
refcount = 0, then kmem_cache_close() is executed and error message is
printed.

This patch assign initial refcount 1 to kmalloc_caches, so fix this
errornous situtation.

Cc: <stable@vger.kernel.org> # v3.7
Cc: Christoph Lameter <cl@linux.com>
Reported-by: Paul Hargrove <phhargrove@lbl.gov>
Signed-off-by: Joonsoo Kim <js1304@gmail.com>

diff --git a/mm/slub.c b/mm/slub.c
index a0d6984..321afab 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3279,6 +3279,7 @@ static struct kmem_cache *__init create_kmalloc_cache(const char *name,
 	if (kmem_cache_open(s, flags))
 		goto panic;
 
+	s->refcount = 1;
 	list_add(&s->list, &slab_caches);
 	return s;
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
