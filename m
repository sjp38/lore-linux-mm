Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id ADF926B027A
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 13:17:06 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id o4so4375174itf.5
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 10:17:06 -0800 (PST)
Received: from resqmta-po-03v.sys.comcast.net (resqmta-po-03v.sys.comcast.net. [2001:558:fe16:19:96:114:154:162])
        by mx.google.com with ESMTPS id r129si2531142itc.79.2018.01.16.10.17.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jan 2018 10:17:05 -0800 (PST)
Date: Tue, 16 Jan 2018 12:17:01 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: kmem_cache_attr (was Re: [PATCH 04/36] usercopy: Prepare for
 usercopy whitelisting)
In-Reply-To: <alpine.DEB.2.20.1801161205590.1771@nuc-kabylake>
Message-ID: <alpine.DEB.2.20.1801161215500.2945@nuc-kabylake>
References: <1515531365-37423-1-git-send-email-keescook@chromium.org> <1515531365-37423-5-git-send-email-keescook@chromium.org> <alpine.DEB.2.20.1801101219390.7926@nuc-kabylake> <20180114230719.GB32027@bombadil.infradead.org> <alpine.DEB.2.20.1801160913260.3908@nuc-kabylake>
 <20180116160525.GF30073@bombadil.infradead.org> <alpine.DEB.2.20.1801161049320.5162@nuc-kabylake> <20180116174315.GA10461@bombadil.infradead.org> <alpine.DEB.2.20.1801161205590.1771@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, David Windsor <dave@nullcore.net>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-xfs@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>, Christoph Hellwig <hch@infradead.org>, "David S. Miller" <davem@davemloft.net>, Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Dave Kleikamp <dave.kleikamp@oracle.com>, Jan Kara <jack@suse.cz>, Luis de Bethencourt <luisbg@kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Rik van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, linux-fsdevel@vger.kernel.org, linux-arch@vger.kernel.org, netdev@vger.kernel.org, kernel-hardening@lists.openwall.com

Draft patch of how the data structs could change. kmem_cache_attr is read
only.

Index: linux/include/linux/slab.h
===================================================================
--- linux.orig/include/linux/slab.h
+++ linux/include/linux/slab.h
@@ -135,9 +135,17 @@ struct mem_cgroup;
 void __init kmem_cache_init(void);
 bool slab_is_available(void);

-struct kmem_cache *kmem_cache_create(const char *, size_t, size_t,
-			slab_flags_t,
-			void (*)(void *));
+typedef kmem_cache_ctor void (*ctor)(void *);
+
+struct kmem_cache_attr {
+	char name[16];
+	unsigned int size;
+	unsigned int align;
+	slab_flags_t flags;
+	kmem_cache_ctor ctor;
+}
+
+struct kmem_cache *kmem_cache_create(const kmem_cache_attr *);
 void kmem_cache_destroy(struct kmem_cache *);
 int kmem_cache_shrink(struct kmem_cache *);

Index: linux/include/linux/slab_def.h
===================================================================
--- linux.orig/include/linux/slab_def.h
+++ linux/include/linux/slab_def.h
@@ -10,6 +10,7 @@

 struct kmem_cache {
 	struct array_cache __percpu *cpu_cache;
+	struct kmem_cache_attr *attr;

 /* 1) Cache tunables. Protected by slab_mutex */
 	unsigned int batchcount;
@@ -35,14 +36,9 @@ struct kmem_cache {
 	struct kmem_cache *freelist_cache;
 	unsigned int freelist_size;

-	/* constructor func */
-	void (*ctor)(void *obj);
-
 /* 4) cache creation/removal */
-	const char *name;
 	struct list_head list;
 	int refcount;
-	int object_size;
 	int align;

 /* 5) statistics */
Index: linux/include/linux/slub_def.h
===================================================================
--- linux.orig/include/linux/slub_def.h
+++ linux/include/linux/slub_def.h
@@ -83,9 +83,9 @@ struct kmem_cache {
 	struct kmem_cache_cpu __percpu *cpu_slab;
 	/* Used for retriving partial slabs etc */
 	slab_flags_t flags;
+	struct kmem_cache_attr *attr;
 	unsigned long min_partial;
 	int size;		/* The size of an object including meta data */
-	int object_size;	/* The size of an object without meta data */
 	int offset;		/* Free pointer offset. */
 #ifdef CONFIG_SLUB_CPU_PARTIAL
 	int cpu_partial;	/* Number of per cpu partial objects to keep around */
@@ -97,12 +97,10 @@ struct kmem_cache {
 	struct kmem_cache_order_objects min;
 	gfp_t allocflags;	/* gfp flags to use on each alloc */
 	int refcount;		/* Refcount for slab cache destroy */
-	void (*ctor)(void *);
 	int inuse;		/* Offset to metadata */
 	int align;		/* Alignment */
 	int reserved;		/* Reserved bytes at the end of slabs */
 	int red_left_pad;	/* Left redzone padding size */
-	const char *name;	/* Name (only for display!) */
 	struct list_head list;	/* List of slab caches */
 #ifdef CONFIG_SYSFS
 	struct kobject kobj;	/* For sysfs */
Index: linux/mm/slab.h
===================================================================
--- linux.orig/mm/slab.h
+++ linux/mm/slab.h
@@ -18,13 +18,11 @@
  * SLUB is no longer needed.
  */
 struct kmem_cache {
-	unsigned int object_size;/* The original size of the object */
+	struct kmem_cache_attr *attr
 	unsigned int size;	/* The aligned/padded/added on size  */
 	unsigned int align;	/* Alignment as calculated */
 	slab_flags_t flags;	/* Active flags on the slab */
-	const char *name;	/* Slab name for sysfs */
 	int refcount;		/* Use counter */
-	void (*ctor)(void *);	/* Called on object slot creation */
 	struct list_head list;	/* List of all slab caches on the system */
 };

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
