Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 0E9046B006A
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 17:45:51 -0500 (EST)
Date: Thu, 21 Jan 2010 16:45:45 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: SLUB ia64 linux-next crash bisected to 756dee75
In-Reply-To: <20100121214749.GJ17684@ldl.fc.hp.com>
Message-ID: <alpine.DEB.2.00.1001211643020.20071@router.home>
References: <20100113002923.GF2985@ldl.fc.hp.com> <alpine.DEB.2.00.1001151358110.6590@router.home> <1263587721.20615.255.camel@useless.americas.hpqcorp.net> <alpine.DEB.2.00.1001151730350.10558@router.home> <alpine.DEB.2.00.1001191252370.25101@router.home>
 <20100119200228.GE11010@ldl.fc.hp.com> <alpine.DEB.2.00.1001191427370.26683@router.home> <20100119212935.GG11010@ldl.fc.hp.com> <alpine.DEB.2.00.1001191545170.26683@router.home> <20100121214749.GJ17684@ldl.fc.hp.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Alex Chiang <achiang@hp.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, penberg@cs.helsinki.fi, linux-ia64@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 21 Jan 2010, Alex Chiang wrote:

> Here is another dump of dmesg. I tried to trim it a little bit
> where it made sense.

Looks like percpu data is corrupted. One of my earlier fixes dimensioned
the kmem_cache_cpu array correctly. That is missing here.

Combined fix:

---
 mm/slub.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-01-21 16:39:26.000000000 -0600
+++ linux-2.6/mm/slub.c	2010-01-21 16:40:35.000000000 -0600
@@ -2086,7 +2086,7 @@ init_kmem_cache_node(struct kmem_cache_n
 #endif
 }

-static DEFINE_PER_CPU(struct kmem_cache_cpu, kmalloc_percpu[SLUB_PAGE_SHIFT]);
+static DEFINE_PER_CPU(struct kmem_cache_cpu, kmalloc_percpu[KMALLOC_CACHES]);

 static inline int alloc_kmem_cache_cpus(struct kmem_cache *s, gfp_t flags)
 {
@@ -2176,7 +2176,8 @@ static int init_kmem_cache_nodes(struct
 	int node;
 	int local_node;

-	if (slab_state >= UP)
+	if (slab_state >= UP && (s < kmalloc_caches ||
+			s > kmalloc_caches + KMALLOC_CACHES))
 		local_node = page_to_nid(virt_to_page(s));
 	else
 		local_node = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
