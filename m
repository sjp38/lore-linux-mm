Date: Wed, 27 Feb 2008 11:55:09 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [2.6 patch] mm/slub.c: remove unneeded NULL check
In-Reply-To: <20080222195905.GM1409@cs181133002.pp.htv.fi>
Message-ID: <Pine.LNX.4.64.0802271150130.1790@schroedinger.engr.sgi.com>
References: <20080219224922.GO31955@cs181133002.pp.htv.fi>
 <6f8gTuy3.1203515564.2078250.penberg@cs.helsinki.fi>
 <20080222195905.GM1409@cs181133002.pp.htv.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adrian Bunk <bunk@kernel.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, mpm@selenic.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 22 Feb 2008, Adrian Bunk wrote:

> There's no reason for checking c->freelist for being NULL here (and we'd 
> anyway Oops below if it was).

Well we still need to check for the freelist being empty otherwise the 
counter for remote frees does not work as intended. The check was 
introduced at the time when page->end did not yet exist. At that time the 
NULL check made sense.


From: Christoph Lameter <clameter@sgi.com>
Subject: Fix check for remote frees

The check for remote frees must check is_end() instead of != NULL.

We execute the !is_end() section rarely so move the check in there. Just do it
once by relying on tail being 1 only the first time we enter the loop.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
dae2a3c60f258f3ad2522b85d79b735a89d702f0 diff --git a/mm/slub.c b/mm/slub.c
index 74c65af..072e0a6 100644
---
 mm/slub.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2008-02-27 11:48:11.000000000 -0800
+++ linux-2.6/mm/slub.c	2008-02-27 11:51:07.000000000 -0800
@@ -1404,8 +1404,6 @@ static void deactivate_slab(struct kmem_
 	struct page *page = c->page;
 	int tail = 1;
 
-	if (c->freelist)
-		stat(c, DEACTIVATE_REMOTE_FREES);
 	/*
 	 * Merge cpu freelist into freelist. Typically we get here
 	 * because both freelists are empty. So this is unlikely
@@ -1418,6 +1416,8 @@ static void deactivate_slab(struct kmem_
 	while (unlikely(!is_end(c->freelist))) {
 		void **object;
 
+		if (unlikely(tail))
+			stat(c, DEACTIVATE_REMOTE_FREES);
 		tail = 0;	/* Hot objects. Put the slab first */
 
 		/* Retrieve object from cpu_freelist */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
