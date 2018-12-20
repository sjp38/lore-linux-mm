Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id BD8268E0001
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 14:21:58 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id d196so2914695qkb.6
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 11:21:58 -0800 (PST)
Received: from a9-35.smtp-out.amazonses.com (a9-35.smtp-out.amazonses.com. [54.240.9.35])
        by mx.google.com with ESMTPS id u13si2533036qvp.212.2018.12.20.11.21.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 20 Dec 2018 11:21:58 -0800 (PST)
Message-ID: <01000167cd113a49-ada7b71e-0fa9-4897-b324-b7a2e1bd0f1c-000000@email.amazonses.com>
Date: Thu, 20 Dec 2018 19:21:57 +0000
From: Christoph Lameter <cl@linux.com>
Subject: [RFC 2/7] slub: Add defrag_ratio field and sysfs support
References: <20181220192145.023162076@linux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=defrag_ratio
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>, akpm@linux-foundation.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org, Rik van Riel <riel@redhat.com>, Dave Chinner <dchinner@redhat.com>, Christoph Hellwig <hch@lst.de>, Michal Hocko <mhocko@suse.com>, Mike Kravetz <mike.kravetz@oracle.com>

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
@@ -3628,6 +3628,7 @@ static int kmem_cache_open(struct kmem_c
 
 	set_cpu_partial(s);
 
+	s->defrag_ratio = 30;
 #ifdef CONFIG_NUMA
 	s->remote_node_defrag_ratio = 1000;
 #endif
@@ -5113,6 +5114,27 @@ static ssize_t destroy_by_rcu_show(struc
 }
 SLAB_ATTR_RO(destroy_by_rcu);
 
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
@@ -5437,6 +5459,7 @@ static struct attribute *slab_attrs[] =
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
+Date:		December 2018
+KernelVersion:	4.18
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
 	unsigned int red_left_pad;	/* Left redzone padding size */
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
