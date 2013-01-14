Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 0B75C6B006E
	for <linux-mm@kvack.org>; Mon, 14 Jan 2013 09:46:18 -0500 (EST)
Date: Mon, 14 Jan 2013 14:46:17 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: REN2 [09/13] Common function to create the kmalloc array
In-Reply-To: <20130111072355.GA2346@lge.com>
Message-ID: <0000013c39866dac-afa62e0a-2958-49a2-b757-571d65393f24-000000@email.amazonses.com>
References: <20130110190027.780479755@linux.com> <0000013c25e08975-f7fd7592-7d64-409c-874d-d00ea2106f2e-000000@email.amazonses.com> <20130111072355.GA2346@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, elezegarcia@gmail.com

On Fri, 11 Jan 2013, Joonsoo Kim wrote:

> In case of the SLUB, create_kmalloc_cache with @NULL break the system
> if slub_debug is used.
>
> Call flow is like as below.
> create_kmalloc_cache -> create_boot_cache -> __kmem_cache_create ->
> kmem_cache_open -> kmem_cache_flag.
> In kmem_cache_flag, strncmp is excecuted with name, that is, NULL.

Hmmm.. yes and we also need to be able to match a name there.

Subject: Fix: Always provide a name to create_boot_cache even during early boot.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/slab_common.c
===================================================================
--- linux.orig/mm/slab_common.c	2013-01-14 08:40:18.085808641 -0600
+++ linux/mm/slab_common.c	2013-01-14 08:42:36.987689598 -0600
@@ -313,7 +313,7 @@ struct kmem_cache *__init create_kmalloc
 	if (!s)
 		panic("Out of memory when creating slab %s\n", name);

-	create_boot_cache(s, name, size, flags);
+	create_boot_cache(s ? s : "kmalloc", name, size, flags);
 	list_add(&s->list, &slab_caches);
 	s->refcount = 1;
 	return s;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
