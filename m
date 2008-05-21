Date: Wed, 21 May 2008 20:13:35 +0300 (EEST)
From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: Re: [PATCH] nommu: Push kobjsize() slab-specific logic down to
 ksize().
In-Reply-To: <20080520095935.GB18633@linux-sh.org>
Message-ID: <Pine.LNX.4.64.0805212009001.20700@sbz-30.cs.Helsinki.FI>
References: <20080520095935.GB18633@linux-sh.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mundt <lethal@linux-sh.org>
Cc: David Howells <dhowells@redhat.com>, Christoph Lameter <clameter@sgi.com>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi!

On Tue, 20 May 2008, Paul Mundt wrote:
> Moving the existing logic in to SLAB's ksize() and simply wrapping in to
> ksize() directly seems to do the right thing in all cases, and allows me
> to boot with any of the slab allocators enabled, rather than simply SLAB
> by itself.
> 
> I've done the same !PageSlab() test in SLAB as SLUB does in its ksize(),
> which also seems to produce the correct results. Hopefully someone more
> familiar with the history of kobjsize()/ksize() interaction can scream if
> this is the wrong thing to do. :-)

As pointed out by Christoph, it. ksize() works with SLUB and SLOB 
accidentally because they do page allocator pass-through and thus need to 
deal with non-PageSlab pages. SLAB, however, does not do that which is why 
all pages passed to it must have PageSlab set (we ought to add a WARN_ON() 
there btw).

So I suggest we fix up kobjsize() instead. Paul, does the following 
untested patch work for you?

			Pekka

diff --git a/mm/nommu.c b/mm/nommu.c
index ef8c62c..a573aeb 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -115,10 +115,7 @@ unsigned int kobjsize(const void *objp)
 	if (PageSlab(page))
 		return ksize(objp);
 
-	BUG_ON(page->index < 0);
-	BUG_ON(page->index >= MAX_ORDER);
-
-	return (PAGE_SIZE << page->index);
+	return PAGE_SIZE << compound_order(page);
 }
 
 /*
diff --git a/mm/slab.c b/mm/slab.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
