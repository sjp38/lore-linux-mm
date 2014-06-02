Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f45.google.com (mail-qa0-f45.google.com [209.85.216.45])
	by kanga.kvack.org (Postfix) with ESMTP id 4AD616B0036
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 11:53:54 -0400 (EDT)
Received: by mail-qa0-f45.google.com with SMTP id hw13so2902363qab.4
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 08:53:54 -0700 (PDT)
Received: from qmta09.emeryville.ca.mail.comcast.net (qmta09.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:96])
        by mx.google.com with ESMTP id l31si17955327qgl.92.2014.06.02.08.53.53
        for <linux-mm@kvack.org>;
        Mon, 02 Jun 2014 08:53:53 -0700 (PDT)
Date: Mon, 2 Jun 2014 10:53:51 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH 4/4] slab: Use for_each_kmem_cache_node function
In-Reply-To: <alpine.DEB.2.10.1406021043160.2987@gentwo.org>
Message-ID: <alpine.DEB.2.10.1406021052300.2987@gentwo.org>
References: <20140530182753.191965442@linux.com> <20140530182801.678250467@linux.com> <20140602051254.GD17964@js1304-P5Q-DELUXE> <alpine.DEB.2.10.1406021043160.2987@gentwo.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>

Additional use cases for kmem_cache_node:



Subject: slab: use for_each_kmem_cache_node instead of for_each_online_node

Some use cases. There could be more work done to clean this up and use
for_each_kmem_cache_node in more places but the structure of some of these
functions may have to be changed a bit.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/slab.c
===================================================================
--- linux.orig/mm/slab.c	2014-05-30 13:23:24.879105040 -0500
+++ linux/mm/slab.c	2014-06-02 10:50:26.631319986 -0500
@@ -1632,14 +1632,10 @@ slab_out_of_memory(struct kmem_cache *ca
 	printk(KERN_WARNING "  cache: %s, object size: %d, order: %d\n",
 		cachep->name, cachep->size, cachep->gfporder);

-	for_each_online_node(node) {
+	for_each_kmem_cache_node(cachep, node, n) {
 		unsigned long active_objs = 0, num_objs = 0, free_objects = 0;
 		unsigned long active_slabs = 0, num_slabs = 0;

-		n = cachep->node[node];
-		if (!n)
-			continue;
-
 		spin_lock_irqsave(&n->list_lock, flags);
 		list_for_each_entry(page, &n->slabs_full, lru) {
 			active_objs += cachep->num;
@@ -4040,10 +4036,7 @@ void get_slabinfo(struct kmem_cache *cac

 	active_objs = 0;
 	num_slabs = 0;
-	for_each_online_node(node) {
-		n = get_node(cachep, node);
-		if (!n)
-			continue;
+	for_each_kmem_cache_node(cachep, node, n) {

 		check_irq_on();
 		spin_lock_irq(&n->list_lock);
@@ -4277,10 +4270,7 @@ static int leaks_show(struct seq_file *m

 	x[1] = 0;

-	for_each_online_node(node) {
-		n = get_node(cachep, node);
-		if (!n)
-			continue;
+	for_each_kmem_cache_node(cachep, node, n) {

 		check_irq_on();
 		spin_lock_irq(&n->list_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
