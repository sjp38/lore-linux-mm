Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 0D5496B0070
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 09:59:21 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v2 0/2] common entry point for kmem_cache_free
Date: Wed, 24 Oct 2012 17:59:16 +0400
Message-Id: <1351087158-8524-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>

The goal of this patchset is to provide a single entry point for
kmem_cache_free. Other functions, such as the allocation itself, and kmalloc
could easily follow.

The main problem here, is that if we keep the allocator-specific functions
in their .c file, we lose the ability to inline their fast paths. Being this
such a critical path, we would like to keep doing so.

During the last discussion around this (https://lkml.org/lkml/2012/10/22/639),
JoonSoo Kim suggested that we could achieve this by just including the
allocator-specific .c files in slab_common.c, a suggestion I considered but
quickly disregarding fearing a quite ugly end result.

Turns out it doesn't look so bad. So please let me know what you think.

Thanks

Glauber Costa (2):
  kmem_cache: include allocators code directly into slab_common
  slab: move kmem_cache_free to common code

 mm/Makefile      |  3 ---
 mm/slab.c        | 23 ++---------------------
 mm/slab_common.c | 50 ++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/slob.c        | 11 ++++-------
 mm/slub.c        |  5 +----
 5 files changed, 57 insertions(+), 35 deletions(-)

-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
