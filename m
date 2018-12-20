Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9A4CB8E0001
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 14:21:57 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id t18so2992152qtj.3
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 11:21:57 -0800 (PST)
Received: from a9-30.smtp-out.amazonses.com (a9-30.smtp-out.amazonses.com. [54.240.9.30])
        by mx.google.com with ESMTPS id o5si1091733qkc.148.2018.12.20.11.21.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 20 Dec 2018 11:21:56 -0800 (PST)
Message-ID: <01000167cd113509-2c85d8a3-8e0e-4cb6-a745-88733e448471-000000@email.amazonses.com>
Date: Thu, 20 Dec 2018 19:21:56 +0000
From: Christoph Lameter <cl@linux.com>
Subject: [RFC 1/7] slub: Replace ctor field with ops field in /sys/slab/*
References: <20181220192145.023162076@linux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=ctor_to_ops
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>, akpm@linux-foundation.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org, Rik van Riel <riel@redhat.com>, Dave Chinner <dchinner@redhat.com>, Christoph Hellwig <hch@lst.de>, Michal Hocko <mhocko@suse.com>, Mike Kravetz <mike.kravetz@oracle.com>

Create an ops field in /sys/slab/*/ops to contain all the callback
operations defined for a slab cache. This will be used to display
the additional callbacks that will be defined soon to enable
defragmentation.

Display the existing ctor callback in the ops fields contents.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |   16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c
+++ linux/mm/slub.c
@@ -4994,13 +4994,18 @@ static ssize_t cpu_partial_store(struct
 }
 SLAB_ATTR(cpu_partial);
 
-static ssize_t ctor_show(struct kmem_cache *s, char *buf)
+static ssize_t ops_show(struct kmem_cache *s, char *buf)
 {
+	int x = 0;
+
 	if (!s->ctor)
 		return 0;
-	return sprintf(buf, "%pS\n", s->ctor);
+
+	if (s->ctor)
+		x += sprintf(buf + x, "ctor : %pS\n", s->ctor);
+	return x;
 }
-SLAB_ATTR_RO(ctor);
+SLAB_ATTR_RO(ops);
 
 static ssize_t aliases_show(struct kmem_cache *s, char *buf)
 {
@@ -5413,7 +5418,7 @@ static struct attribute *slab_attrs[] =
 	&objects_partial_attr.attr,
 	&partial_attr.attr,
 	&cpu_slabs_attr.attr,
-	&ctor_attr.attr,
+	&ops_attr.attr,
 	&aliases_attr.attr,
 	&align_attr.attr,
 	&hwcache_align_attr.attr,
