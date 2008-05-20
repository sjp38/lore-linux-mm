Date: Tue, 20 May 2008 09:52:59 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] nommu: Push kobjsize() slab-specific logic down to
 ksize().
In-Reply-To: <2373.1211296724@redhat.com>
Message-ID: <Pine.LNX.4.64.0805200944210.6135@schroedinger.engr.sgi.com>
References: <20080520095935.GB18633@linux-sh.org> <2373.1211296724@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Howells <dhowells@redhat.com>
Cc: Paul Mundt <lethal@linux-sh.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 20 May 2008, David Howells wrote:

> Paul Mundt <lethal@linux-sh.org> wrote:
> 
> > Moving the existing logic in to SLAB's ksize() and simply wrapping in to
> > ksize() directly seems to do the right thing in all cases, and allows me
> > to boot with any of the slab allocators enabled, rather than simply SLAB
> > by itself.
> > 
> > I've done the same !PageSlab() test in SLAB as SLUB does in its ksize(),
> > which also seems to produce the correct results. Hopefully someone more
> > familiar with the history of kobjsize()/ksize() interaction can scream if
> > this is the wrong thing to do. :-)
> 
> That seems reasonable.  I can't test it until I get back to the UK next week.

Hmm. That means we are sanctioning using ksize on arbitrary objects? SLUB 
supports that but SLAB wont and neither will SLOB. I think we need to stay 
with the strict definition that is needed by SLOB.

It seems also that the existing kobjsize function is wrong:

1. For compound pages the head page needs to be determined.

So do a virt_to_head_page() instead of a virt_to_page().

2. Why is page->index take as the page order?

Use compound_order instead?

I think the following patch will work for all allocators (can 
virt_to_page() really return NULL if the addr is invalid if so we may
have to fix virt_to_head_page()?):

---
 mm/nommu.c |    8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

Index: linux-2.6/mm/nommu.c
===================================================================
--- linux-2.6.orig/mm/nommu.c	2008-05-20 09:50:25.686495370 -0700
+++ linux-2.6/mm/nommu.c	2008-05-20 09:50:51.797745535 -0700
@@ -109,16 +109,14 @@ unsigned int kobjsize(const void *objp)
 	 * If the object we have should not have ksize performed on it,
 	 * return size of 0
 	 */
-	if (!objp || (unsigned long)objp >= memory_end || !((page = virt_to_page(objp))))
+	if (!objp || (unsigned long)objp >= memory_end ||
+				!((page = virt_to_head_page(objp))))
 		return 0;
 
 	if (PageSlab(page))
 		return ksize(objp);
 
-	BUG_ON(page->index < 0);
-	BUG_ON(page->index >= MAX_ORDER);
-
-	return (PAGE_SIZE << page->index);
+	return PAGE_SIZE << compound_order(page);
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
