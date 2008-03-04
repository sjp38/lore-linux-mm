Date: Tue, 4 Mar 2008 11:56:42 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [BUG] 2.6.25-rc3-mm1 kernel panic while bootup on powerpc ()
In-Reply-To: <84144f020803041141x5bb55832r495d7fde92356e27@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0803041151360.18160@schroedinger.engr.sgi.com>
References: <20080304011928.e8c82c0c.akpm@linux-foundation.org>
 <47CD4AB3.3080409@linux.vnet.ibm.com>  <20080304103636.3e7b8fdd.akpm@linux-foundation.org>
  <47CDA081.7070503@cs.helsinki.fi> <20080304193532.GC9051@csn.ul.ie>
 <84144f020803041141x5bb55832r495d7fde92356e27@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>, linuxppc-dev@ozlabs.org, Andy Whitcroft <apw@shadowen.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 4 Mar 2008, Pekka Enberg wrote:

> >  > I suspect the WARN_ON() is bogus although I really don't know that part
> >  > of the code all too well. Mel?
> >  >
> >
> >  The warn-on is valid. A situation should not exist that allows both flags to
> >  be set. I suspect  if remove-set_migrateflags.patch was reverted from -mm
> >  the warning would not trigger. Christoph, would it be reasonable to always
> >  clear __GFP_MOVABLE when __GFP_RECLAIMABLE is set for SLAB_RECLAIM_ACCOUNT.

Slab allocations should never be passed these flags since the slabs do 
their own thing there.

The following patch would clear these in slub:

---
 mm/slub.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6.25-rc3-mm1/mm/slub.c
===================================================================
--- linux-2.6.25-rc3-mm1.orig/mm/slub.c	2008-03-04 11:53:47.600342756 -0800
+++ linux-2.6.25-rc3-mm1/mm/slub.c	2008-03-04 11:55:40.153855150 -0800
@@ -1033,8 +1033,8 @@ static struct page *allocate_slab(struct
 	struct page *page;
 	int pages = 1 << s->order;
 
+	flags &= ~GFP_MOVABLE_MASK;
 	flags |= s->allocflags;
-
 	page = alloc_slab_page(flags | __GFP_NOWARN | __GFP_NORETRY,
 								node, s->order);
 	if (unlikely(!page)) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
