Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2CFEA6B0069
	for <linux-mm@kvack.org>; Wed, 27 Dec 2017 17:11:43 -0500 (EST)
Received: by mail-vk0-f69.google.com with SMTP id q143so20467864vkb.19
        for <linux-mm@kvack.org>; Wed, 27 Dec 2017 14:11:43 -0800 (PST)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [2001:558:fe21:29:69:252:207:44])
        by mx.google.com with ESMTPS id 9si10641591uac.138.2017.12.27.14.11.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Dec 2017 14:11:42 -0800 (PST)
Message-Id: <20171227220652.322991754@linux.com>
Date: Wed, 27 Dec 2017 16:06:38 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [RFC 2/8] slub: Add defrag_ratio field and sysfs support
References: <20171227220636.361857279@linux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=defrag_ratio
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, akpm@linux-foundation.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org, Rik van Riel <riel@redhat.com>, Dave Chinner <dchinner@redhat.com>, Christoph Hellwig <hch@lst.de>

"defrag_ratio" is used to set the threshold at which defragmentation
should be attempted on a slab page.

"defrag_ratio" is percentage in the range of 1 - 100. If more than
that percentage of slots in a slab page are unused the the slab page
will become subject to defragmentation.

Add a defrag ratio field and set it to 30% by default. A limit of 30% specifies
that less than 3 out of 10 available slots for objects need to be leftover
before slab defragmentation will be attempted on the remaining objects.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 Documentation/ABI/testing/sysfs-kernel-slab |   13 +++++++++++++
 include/linux/slub_def.h                    |    6 ++++++
 mm/slub.c                                   |   23 +++++++++++++++++++++++
 3 files changed, 42 insertions(+)

Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c
+++ linux/mm/slub.c
@@ -3613,6 +3613,7 @@ static int kmem_cache_open(struct kmem_c
 
 	set_cpu_partial(s);
 
+	s->defrag_ratio = 30;
 #ifdef CONFIG_NUMA
 	s->remote_node_defrag_ratio = 1000;
 #endif
@@ -5078,6 +5079,27 @@ static ssize_t reserved_show(struct kmem
 }
 SLAB_ATTR_RO(reserved);
 
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
+	err = kstrtoul(buf, 10, &ratio);
+	if (err)
+		return err;
+
+	if (ratio < 100)
+		s->defrag_ratio = ratio;
+	return length;
+}
+SLAB_ATTR(defrag_ratio);
+
 #ifdef CONFIG_SLUB_DEBUG
 static ssize_t slabs_show(struct kmem_cache *s, char *buf)
 {
@@ -5402,6 +5424,7 @@ static struct attribute *slab_attrs[] =
 	&validate_attr.attr,
 	&alloc_calls_attr.attr,
 	&free_calls_attr.attr,
+	&defrag_ratio_attr.attr,
 #endif
 #ifdef CONFIG_ZONE_DMA
 	&cache_dma_attr.attr,
Index: linux/Documentation/ABI/testing/sysfs-kernel-slab
===================================================================
--- linux.orig/Documentation/ABI/testing/sysfs-kernel-slab
+++ linux/Documentation/ABI/testing/sysfs-kernel-slab
@@ -180,6 +180,19 @@ Description:
 		list.  It can be written to clear the current count.
 		Available when CONFIG_SLUB_STATS is enabled.
 
+What:		/sys/kernel/slab/cache/defrag_ratio
+Date:		December 2017
+KernelVersion:	4.16
+Contact:	Christoph Lameter <cl@linux-foundation.org>
+		Pekka Enberg <penberg@cs.helsinki.fi>,
+Description:
+		The defrag_ratio files allows the control of how agressive
+		slab fragmentation reduction works at reclaiming objects from
+		sparsely populated slabs. This is a percentage. If a slab
+		has more than this percentage of available object then reclaim
+		will attempt to reclaim objects so that the whole slab
+		page can be freed. The default is 30%.
+
 What:		/sys/kernel/slab/cache/deactivate_to_tail
 Date:		February 2008
 KernelVersion:	2.6.25
Index: linux/include/linux/slub_def.h
===================================================================
--- linux.orig/include/linux/slub_def.h
+++ linux/include/linux/slub_def.h
@@ -104,6 +104,12 @@ struct kmem_cache {
 	int red_left_pad;	/* Left redzone padding size */
 	const char *name;	/* Name (only for display!) */
 	struct list_head list;	/* List of slab caches */
+	int defrag_ratio;	/*
+				 * Ratio used to check the percentage of
+				 * objects allocate in a slab page.
+				 * If less than this ratio is allocated
+				 * then reclaim attempts are made.
+				 */
 #ifdef CONFIG_SYSFS
 	struct kobject kobj;	/* For sysfs */
 	struct work_struct kobj_remove_work;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
