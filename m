Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
	by kanga.kvack.org (Postfix) with ESMTP id E9A4C6B0031
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 10:58:57 -0400 (EDT)
Received: by mail-qc0-f171.google.com with SMTP id w7so8732228qcr.30
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 07:58:57 -0700 (PDT)
Received: from qmta15.emeryville.ca.mail.comcast.net (qmta15.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:228])
        by mx.google.com with ESMTP id 79si29866191qgc.45.2014.07.01.07.58.56
        for <linux-mm@kvack.org>;
        Tue, 01 Jul 2014 07:58:56 -0700 (PDT)
Date: Tue, 1 Jul 2014 09:58:52 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: mm: slub: invalid memory access in setup_object
In-Reply-To: <alpine.DEB.2.02.1406301500410.13545@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.11.1407010956470.5353@gentwo.org>
References: <53AAFDF7.2010607@oracle.com> <alpine.DEB.2.11.1406251228130.29216@gentwo.org> <alpine.DEB.2.02.1406301500410.13545@chino.kir.corp.google.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Wei Yang <weiyang@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>

On Mon, 30 Jun 2014, David Rientjes wrote:

> It's not at all clear to me that that patch is correct.  Wei?

Looks ok to me. But I do not like the convoluted code in new_slab() which
Wei's patch does not make easier to read. Makes it difficult for the
reader to see whats going on.

Lets drop the use of the variable named "last".


Subject: slub: Only call setup_object once for each object

Modify the logic for object initialization to be less convoluted
and initialize an object only once.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2014-07-01 09:50:02.486846653 -0500
+++ linux/mm/slub.c	2014-07-01 09:52:07.918802585 -0500
@@ -1409,7 +1409,6 @@ static struct page *new_slab(struct kmem
 {
 	struct page *page;
 	void *start;
-	void *last;
 	void *p;
 	int order;

@@ -1432,15 +1431,11 @@ static struct page *new_slab(struct kmem
 	if (unlikely(s->flags & SLAB_POISON))
 		memset(start, POISON_INUSE, PAGE_SIZE << order);

-	last = start;
 	for_each_object(p, s, start, page->objects) {
-		setup_object(s, page, last);
-		set_freepointer(s, last, p);
-		last = p;
+		setup_object(s, page, p);
+		set_freepointer(s, p, p + s->size);
 	}
-	setup_object(s, page, last);
-	set_freepointer(s, last, NULL);
-
+	set_freepointer(s, start + (page->objects - 1) * s->size, NULL);
 	page->freelist = start;
 	page->inuse = page->objects;
 	page->frozen = 1;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
