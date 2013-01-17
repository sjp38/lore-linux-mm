Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id E2FFA6B0006
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 16:28:23 -0500 (EST)
Date: Thu, 17 Jan 2013 21:28:22 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH] slub: Check for page NULL before doing the node_match
 check
In-Reply-To: <1358447864.23211.34.camel@gandalf.local.home>
Message-ID: <0000013c4a69a2cf-1a19a6f6-e6a3-4f06-99a4-10fdd4b9aca2-000000@email.amazonses.com>
References: <1358446258.23211.32.camel@gandalf.local.home> <1358447864.23211.34.camel@gandalf.local.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Thomas Gleixner <tglx@linutronix.de>, RT <linux-rt-users@vger.kernel.org>, Clark Williams <clark@redhat.com>, John Kacur <jkacur@gmail.com>, "Luis Claudio R. Goncalves" <lgoncalv@redhat.com>

On Thu, 17 Jan 2013, Steven Rostedt wrote:

> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -2399,7 +2399,7 @@ redo:
> >
> >  	object = c->freelist;
> >  	page = c->page;
> > -	if (unlikely(!object || !node_match(page, node)))
> > +	if (unlikely(!object || !page || !node_match(page, node)))
>
> I'm still trying to see if c->freelist != NULL and c->page == NULL isn't
> a bug. The cmpxchg_doubles are a little confusing. If it's not expected
> that page is NULL but freelist isn't than we need to figure out why it
> happened.

hmmm.. We may want to change the sequence of updates to c->page and
c->freelist. Update c->freelist to be NULL first so that we always enter
the slow path for these cases where we can do more expensive
synchronization.

Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2013-01-15 10:42:08.490183607 -0600
+++ linux/mm/slub.c	2013-01-17 15:27:48.973051155 -0600
@@ -1993,8 +1993,8 @@ static inline void flush_slab(struct kme
 	deactivate_slab(s, c->page, c->freelist);

 	c->tid = next_tid(c->tid);
-	c->page = NULL;
 	c->freelist = NULL;
+	c->page = NULL;
 }

 /*
@@ -2227,8 +2227,8 @@ redo:
 	if (unlikely(!node_match(page, node))) {
 		stat(s, ALLOC_NODE_MISMATCH);
 		deactivate_slab(s, page, c->freelist);
-		c->page = NULL;
 		c->freelist = NULL;
+		c->page = NULL;
 		goto new_slab;
 	}

@@ -2239,8 +2239,8 @@ redo:
 	 */
 	if (unlikely(!pfmemalloc_match(page, gfpflags))) {
 		deactivate_slab(s, page, c->freelist);
-		c->page = NULL;
 		c->freelist = NULL;
+		c->page = NULL;
 		goto new_slab;
 	}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
