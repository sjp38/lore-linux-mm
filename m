Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id AE85F6B0033
	for <linux-mm@kvack.org>; Thu, 28 Dec 2017 09:59:25 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id g81so33528194ioa.14
        for <linux-mm@kvack.org>; Thu, 28 Dec 2017 06:59:25 -0800 (PST)
Received: from resqmta-ch2-02v.sys.comcast.net (resqmta-ch2-02v.sys.comcast.net. [2001:558:fe21:29:69:252:207:34])
        by mx.google.com with ESMTPS id g137si4859227ioe.172.2017.12.28.06.59.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Dec 2017 06:59:24 -0800 (PST)
Date: Thu, 28 Dec 2017 08:57:21 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [RFC 0/8] Xarray object migration V1
In-Reply-To: <d54a8261-75f0-a9c8-d86d-e20b3b492ef9@infradead.org>
Message-ID: <alpine.DEB.2.20.1712280856260.30955@nuc-kabylake>
References: <20171227220636.361857279@linux.com> <d54a8261-75f0-a9c8-d86d-e20b3b492ef9@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, akpm@linux-foundation.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org, Rik van Riel <riel@redhat.com>, Dave Chinner <dchinner@redhat.com>, Christoph Hellwig <hch@lst.de>

On Wed, 27 Dec 2017, Randy Dunlap wrote:

> > To test apply this patchset on top of Matthew Wilcox Xarray code
> > from Dec 11th (See infradead github).
>
> linux-mm archive is missing patch 1/8 and so am I.
>
> https://marc.info/?l=linux-mm

Duh. How can you troubleshoot that one?

First patch:

Subject: slub: Replace ctor field with ops field in /sys/slab/*

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
@@ -4959,13 +4959,18 @@ static ssize_t cpu_partial_store(struct
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
@@ -5377,7 +5382,7 @@ static struct attribute *slab_attrs[] =
 	&objects_partial_attr.attr,
 	&partial_attr.attr,
 	&cpu_slabs_attr.attr,
-	&ctor_attr.attr,
+	&ops_attr.attr,
 	&aliases_attr.attr,
 	&align_attr.attr,
 	&hwcache_align_attr.attr,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
