Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id EE29F6B0024
	for <linux-mm@kvack.org>; Thu, 12 May 2011 12:44:21 -0400 (EDT)
Date: Thu, 12 May 2011 11:44:18 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [Slub cleanup6 4/5] slub: Move node determination out of
 hotpath
In-Reply-To: <alpine.DEB.2.00.1105111255130.9346@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1105121142370.27324@router.home>
References: <20110415194811.810587216@linux.com> <20110415194831.991653328@linux.com> <alpine.DEB.2.00.1105111255130.9346@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org

On Wed, 11 May 2011, David Rientjes wrote:

> I'd much prefer to just add a
>
> 	c->node = page_to_nid(page);
>
> rather than the new label and goto into a conditional.
>
> >  	}
> >  	if (!(gfpflags & __GFP_NOWARN) && printk_ratelimit())
> >  		slab_out_of_memory(s, gfpflags, node);
>

Hmmm... Looks like we also missed to use the label.


Subject: slub: Fix control flow in slab_alloc

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-05-12 11:41:44.000000000 -0500
+++ linux-2.6/mm/slub.c	2011-05-12 11:42:25.000000000 -0500
@@ -1833,7 +1833,6 @@ new_slab:
 	page = get_partial(s, gfpflags, node);
 	if (page) {
 		stat(s, ALLOC_FROM_PARTIAL);
-load_from_page:
 		c->node = page_to_nid(page);
 		c->page = page;
 		goto load_freelist;
@@ -1856,6 +1855,7 @@ load_from_page:

 		slab_lock(page);
 		__SetPageSlubFrozen(page);
+		c->node = page_to_nid(page);
 		c->page = page;
 		goto load_freelist;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
