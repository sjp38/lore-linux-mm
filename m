Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 1DFE28D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 14:35:12 -0400 (EDT)
Date: Tue, 19 Apr 2011 13:35:06 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v3] mm: make expand_downwards symmetrical to
 expand_upwards
In-Reply-To: <1303237217.3171.39.camel@mulgrave.site>
Message-ID: <alpine.DEB.2.00.1104191325470.19358@router.home>
References: <20110415135144.GE8828@tiehlicka.suse.cz>  <alpine.LSU.2.00.1104171952040.22679@sister.anvils>  <20110418100131.GD8925@tiehlicka.suse.cz>  <20110418135637.5baac204.akpm@linux-foundation.org>  <20110419111004.GE21689@tiehlicka.suse.cz>
 <1303228009.3171.18.camel@mulgrave.site>  <BANLkTimYrD_Sby_u-fPSwn-RJJyEVavU5w@mail.gmail.com>  <1303233088.3171.26.camel@mulgrave.site>  <alpine.DEB.2.00.1104191213120.17888@router.home>  <1303235306.3171.33.camel@mulgrave.site>
 <alpine.DEB.2.00.1104191254300.19358@router.home> <1303237217.3171.39.camel@mulgrave.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-parisc@vger.kernel.org, David Rientjes <rientjes@google.com>

On Tue, 19 Apr 2011, James Bottomley wrote:

> > }
> >
> > How in the world did you get a zone setup in node 1 with a !NUMA config?
>
> I told you ... I forced an allocation into the first discontiguous
> region.  That will return 1 for page_to_nid().

How? The kernel has no concept of a node 1 without CONFIG_NUMA and so you
cannot tell the page allocator to allocate from node 1.

zone_to_nid is used as a fallback mechanism for page_to_nid() and as shown
will always return 0 for !NUMA configs.

page_to_nid(x) == zone_to_nid(page_zone(x)) must hold true. It is not
here.

> > The problem seems to be that the kernel seems to allow a
> > definition of a page_to_nid() function that returns non zero in the !NUMA
> > case.
>
> This is called reality, yes.

There you have the bug. Fix that and things will work fine.

> right, that's what I told you: slub is broken because it's making a
> wrong assumption.  Look in asm-generic/memory_model.h it shows how the
> page_to_nid() is used in finding the pfn array.  DISCONTIGMEM uses some
> of the numa properties (including assigning zones to the discontiguous
> regions).

Bitrotted code? If it uses numa properties then it must use a zone field
in struct zone. So DISCONTIGMEM seems to require CONFIG_NUMA.

> > If you think that is broken then we have brokenness all over the kernel
> > whenever we determine the node from a page and use that to do a lookup.
>
> Not really.  The rest of the kernel uses the proper macros.  in
> DISCONTIGMEM but !NUMA configs, the numa macros expand correctly.
> You've cut across that with all the CONFIG_NUMA checks in slub.

What are "the proper macros"? AFAICT page_to_nid() is the proper way to
access the node of a page. If page_to_nid() returns 1 then you have a zone
that the kernel knows of as being in node 0 having a page on a different
node.

We can likely force page_to_nid to ignore the node information that have
been erroneously placed there but this looks like something deeper is
wrong here. The node field in struct page is not only used for the Linux
support of a NUMA node but also for blocks of memory. Those should be
separate things.

---
 include/linux/mm.h |    4 ++++
 1 file changed, 4 insertions(+)

Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h	2011-04-19 13:20:20.092521248 -0500
+++ linux-2.6/include/linux/mm.h	2011-04-19 13:21:05.962521196 -0500
@@ -665,6 +665,7 @@ static inline int zone_to_nid(struct zon
 #endif
 }

+#ifdef CONFIG_NUMA
 #ifdef NODE_NOT_IN_PAGE_FLAGS
 extern int page_to_nid(struct page *page);
 #else
@@ -673,6 +674,9 @@ static inline int page_to_nid(struct pag
 	return (page->flags >> NODES_PGSHIFT) & NODES_MASK;
 }
 #endif
+#else
+#define page_to_nid(x) 0
+#endif

 static inline struct zone *page_zone(struct page *page)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
