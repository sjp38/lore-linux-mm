Date: Tue, 8 Apr 2008 21:55:05 +0300 (EEST)
From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: Re: [patch 01/18] SLUB: Add defrag_ratio field and sysfs support.
In-Reply-To: <20080407231052.eb37a8fd.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0804082154180.8437@sbz-30.cs.Helsinki.FI>
References: <20080404230158.365359425@sgi.com> <20080404230225.862960359@sgi.com>
 <20080407231052.eb37a8fd.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, 04 Apr 2008 16:01:59 -0700 Christoph Lameter <clameter@sgi.com> wrote:
> > +static ssize_t defrag_ratio_store(struct kmem_cache *s,
> > +				const char *buf, size_t length)
> > +{
> > +	int n = simple_strtoul(buf, NULL, 10);

On Mon, 7 Apr 2008, Andrew Morton wrote:
> WARNING: consider using strict_strtoul in preference to simple_strtoul
> #99: FILE: mm/slub.c:4038:
> +       int n = simple_strtoul(buf, NULL, 10);
> 
> total: 0 errors, 1 warnings, 49 lines checked
> 
> 
> It speaketh truth.

I fixed that up, thanks!

			Pekka

From: Christoph Lameter <clameter@sgi.com>
Subject: [PATCH] SLUB: Add defrag_ratio field and sysfs support.

The defrag_ratio is used to set the threshold at which defragmentation
should be run on a slabcache.

The allocation ratio is measured in the percentage of the available slots
allocated. The percentage will be lower for slabs that are more fragmented.

Add a defrag ratio field and set it to 30% by default. A limit of 30% specified
that less than 3 out of 10 available slots for objects are in use before
slab defragmeentation runs.

Reviewed-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
---
 include/linux/slub_def.h |    7 +++++++
 mm/slub.c                |   18 ++++++++++++++++++
 2 files changed, 25 insertions(+), 0 deletions(-)

Index: slab-2.6/include/linux/slub_def.h
===================================================================
--- slab-2.6.orig/include/linux/slub_def.h	2008-04-08 21:43:24.000000000 +0300
+++ slab-2.6/include/linux/slub_def.h	2008-04-08 21:44:03.000000000 +0300
@@ -88,6 +88,13 @@
 	void (*ctor)(struct kmem_cache *, void *);
 	int inuse;		/* Offset to metadata */
 	int align;		/* Alignment */
+	int defrag_ratio;	/*
+				 * Ratio used to check the percentage of
+				 * objects allocate in a slab page.
+				 * If less than this ratio is allocated
+				 * then reclaim attempts are made.
+				 */
+
 	const char *name;	/* Name (only for display!) */
 	struct list_head list;	/* List of slab caches */
 #ifdef CONFIG_SLUB_DEBUG
Index: slab-2.6/mm/slub.c
===================================================================
--- slab-2.6.orig/mm/slub.c	2008-04-08 21:43:37.000000000 +0300
+++ slab-2.6/mm/slub.c	2008-04-08 21:51:43.000000000 +0300
@@ -2332,6 +2332,7 @@
 		goto error;
 
 	s->refcount = 1;
+	s->defrag_ratio = 30;
 #ifdef CONFIG_NUMA
 	s->remote_node_defrag_ratio = 100;
 #endif
@@ -4025,6 +4026,27 @@
 }
 SLAB_ATTR_RO(free_calls);
 
+static ssize_t defrag_ratio_show(struct kmem_cache *s, char *buf)
+{
+	return sprintf(buf, "%d\n", s->defrag_ratio);
+}
+
+static ssize_t defrag_ratio_store(struct kmem_cache *s,
+				const char *buf, size_t length)
+{
+	unsigned long ratio;
+	int err;
+
+	err = strict_strtoul(buf, 10, &ratio);
+	if (err)
+		return err;
+
+	if (ratio < 100)
+		s->defrag_ratio = ratio;
+	return length;
+}
+SLAB_ATTR(defrag_ratio);
+
 #ifdef CONFIG_NUMA
 static ssize_t remote_node_defrag_ratio_show(struct kmem_cache *s, char *buf)
 {
@@ -4126,6 +4148,7 @@
 	&shrink_attr.attr,
 	&alloc_calls_attr.attr,
 	&free_calls_attr.attr,
+	&defrag_ratio_attr.attr,
 #ifdef CONFIG_ZONE_DMA
 	&cache_dma_attr.attr,
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
