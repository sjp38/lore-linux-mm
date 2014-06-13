Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id 941846B0031
	for <linux-mm@kvack.org>; Fri, 13 Jun 2014 12:02:43 -0400 (EDT)
Received: by mail-qc0-f180.google.com with SMTP id r5so693188qcx.11
        for <linux-mm@kvack.org>; Fri, 13 Jun 2014 09:02:43 -0700 (PDT)
Received: from qmta05.emeryville.ca.mail.comcast.net (qmta05.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:48])
        by mx.google.com with ESMTP id m2si4873458qag.32.2014.06.13.09.02.42
        for <linux-mm@kvack.org>;
        Fri, 13 Jun 2014 09:02:42 -0700 (PDT)
Date: Fri, 13 Jun 2014 11:02:39 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH 2/3] slub: Use new node functions
In-Reply-To: <alpine.DEB.2.02.1406111610130.27885@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.10.1406131055590.913@gentwo.org>
References: <20140611191510.082006044@linux.com> <20140611191519.070677452@linux.com> <alpine.DEB.2.02.1406111610130.27885@chino.kir.corp.google.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Wed, 11 Jun 2014, David Rientjes wrote:

> > +	for_each_kmem_cache_node(s, node, n) {
> >
> >  		free_partial(s, n);
> >  		if (n->nr_partial || slabs_node(s, node))
>
> Newline not removed?

Ok got through the file and removed all the lines after
for_each_kmem_cache_node.

>
> > @@ -3407,11 +3401,7 @@ int __kmem_cache_shrink(struct kmem_cach
> >  		return -ENOMEM;
> >
> >  	flush_all(s);
> > -	for_each_node_state(node, N_NORMAL_MEMORY) {
> > -		n = get_node(s, node);
> > -
> > -		if (!n->nr_partial)
> > -			continue;
> > +	for_each_kmem_cache_node(s, node, n) {
> >
> >  		for (i = 0; i < objects; i++)
> >  			INIT_LIST_HEAD(slabs_by_inuse + i);
>
> Is there any reason not to keep the !n->nr_partial check to avoid taking
> n->list_lock unnecessarily?

No this was simply a mistake the check needs to be preserved.


Subject: slub: Fix up earlier patch

Signed-off-by: Christoph Lameter <cl@linux.com>


Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2014-06-13 10:59:01.815583306 -0500
+++ linux/mm/slub.c	2014-06-13 10:58:45.444109563 -0500
@@ -3216,7 +3216,6 @@ static inline int kmem_cache_close(struc
 	flush_all(s);
 	/* Attempt to free all objects */
 	for_each_kmem_cache_node(s, node, n) {
-
 		free_partial(s, n);
 		if (n->nr_partial || slabs_node(s, node))
 			return 1;
@@ -3402,6 +3401,8 @@ int __kmem_cache_shrink(struct kmem_cach

 	flush_all(s);
 	for_each_kmem_cache_node(s, node, n) {
+		if (!n->nr_partial)
+			continue;

 		for (i = 0; i < objects; i++)
 			INIT_LIST_HEAD(slabs_by_inuse + i);
@@ -4334,7 +4335,6 @@ static ssize_t show_slab_objects(struct
 		struct kmem_cache_node *n;

 		for_each_kmem_cache_node(s, node, n) {
-
 			if (flags & SO_TOTAL)
 				x = count_partial(n, count_total);
 			else if (flags & SO_OBJECTS)
@@ -5324,7 +5324,6 @@ void get_slabinfo(struct kmem_cache *s,
 	struct kmem_cache_node *n;

 	for_each_kmem_cache_node(s, node, n) {
-
 		nr_slabs += node_nr_slabs(n);
 		nr_objs += node_nr_objs(n);
 		nr_free += count_partial(n, count_free);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
