Message-Id: <20080216004632.324567564@sgi.com>
References: <20080216004526.763643520@sgi.com>
Date: Fri, 15 Feb 2008 16:45:29 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 03/17] SLUB: Replace ctor field with ops field in /sys/slab/*
Content-Disposition: inline; filename=0049-SLUB-Replace-ctor-field-with-ops-field-in-sys-slab.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org
List-ID: <linux-mm.kvack.org>

Create an ops field in /sys/slab/*/ops to contain all the operations defined
on a slab. This will be used to display the additional operations that will
be defined soon.

Reviewed-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 mm/slub.c |   16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2008-02-15 15:31:53.958427919 -0800
+++ linux-2.6/mm/slub.c	2008-02-15 15:32:00.654444198 -0800
@@ -3862,16 +3862,18 @@ static ssize_t order_show(struct kmem_ca
 }
 SLAB_ATTR(order);
 
-static ssize_t ctor_show(struct kmem_cache *s, char *buf)
+static ssize_t ops_show(struct kmem_cache *s, char *buf)
 {
-	if (s->ctor) {
-		int n = sprint_symbol(buf, (unsigned long)s->ctor);
+	int x = 0;
 
-		return n + sprintf(buf + n, "\n");
+	if (s->ctor) {
+		x += sprintf(buf + x, "ctor : ");
+		x += sprint_symbol(buf + x, (unsigned long)s->ops->ctor);
+		x += sprintf(buf + x, "\n");
 	}
-	return 0;
+	return x;
 }
-SLAB_ATTR_RO(ctor);
+SLAB_ATTR_RO(ops);
 
 static ssize_t aliases_show(struct kmem_cache *s, char *buf)
 {
@@ -4186,7 +4188,7 @@ static struct attribute *slab_attrs[] = 
 	&slabs_attr.attr,
 	&partial_attr.attr,
 	&cpu_slabs_attr.attr,
-	&ctor_attr.attr,
+	&ops_attr.attr,
 	&aliases_attr.attr,
 	&align_attr.attr,
 	&sanity_checks_attr.attr,

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
