Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 404D16B005A
	for <linux-mm@kvack.org>; Fri,  3 Aug 2012 09:45:52 -0400 (EDT)
Date: Fri, 3 Aug 2012 08:45:49 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Common [01/19] slub: Add debugging to verify correct cache use
 on kmem_cache_free()
In-Reply-To: <alpine.DEB.2.00.1208021346130.5454@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1208030845060.2332@router.home>
References: <20120802201506.266817615@linux.com> <20120802201530.921218259@linux.com> <alpine.DEB.2.00.1208021334350.5454@chino.kir.corp.google.com> <alpine.DEB.2.00.1208021540590.32229@router.home>
 <alpine.DEB.2.00.1208021346130.5454@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>

On Thu, 2 Aug 2012, David Rientjes wrote:

> On Thu, 2 Aug 2012, Christoph Lameter wrote:
>
> > This condition is pretty serious. The free action will be skipped
> > and we will be continually leaking memory. I think its best to keep on
> > logging this until someohne does something about the problem.
> >
>
> Dozens of lines will be emitted to the kernel log because a stack trace is
> printed every time a bogus kmem_cache_free() is called, perhaps change the
> WARN_ON(1) to at least a WARN_ON_ONCE(1)?

Ok,

Subject: Only warn once

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-08-03 08:43:34.772602802 -0500
+++ linux-2.6/mm/slub.c	2012-08-03 08:44:36.021655892 -0500
@@ -2610,7 +2610,7 @@ void kmem_cache_free(struct kmem_cache *
 	if (kmem_cache_debug(s) && page->slab != s) {
 		printk("kmem_cache_free: Wrong slab cache. %s but object"
 			" is from  %s\n", page->slab->name, s->name);
-		WARN_ON(1);
+		WARN_ON_ONCE(1);
 		return;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
