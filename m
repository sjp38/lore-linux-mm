Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 7E83E6B0071
	for <linux-mm@kvack.org>; Tue, 19 Jan 2010 13:53:18 -0500 (EST)
Date: Tue, 19 Jan 2010 12:53:08 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: SLUB ia64 linux-next crash bisected to 756dee75
In-Reply-To: <alpine.DEB.2.00.1001151730350.10558@router.home>
Message-ID: <alpine.DEB.2.00.1001191252370.25101@router.home>
References: <20100113002923.GF2985@ldl.fc.hp.com>  <alpine.DEB.2.00.1001151358110.6590@router.home> <1263587721.20615.255.camel@useless.americas.hpqcorp.net> <alpine.DEB.2.00.1001151730350.10558@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Alex Chiang <achiang@hp.com>, penberg@cs.helsinki.fi, linux-ia64@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 15 Jan 2010, Christoph Lameter wrote:

> An allocated kmem_cache structure is definitely not in the range of the
> kmalloc_caches array. This is basically checking if s is pointing to the
> static kmalloc array.

Check was wrong.. Sigh...

---
 mm/slub.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-01-19 12:50:20.000000000 -0600
+++ linux-2.6/mm/slub.c	2010-01-19 12:51:30.000000000 -0600
@@ -2148,7 +2148,8 @@ static int init_kmem_cache_nodes(struct
 	int node;
 	int local_node;

-	if (slab_state >= UP)
+	if (slab_state >= UP && (s < kmalloc_caches ||
+			s > kmalloc_caches + KMALLOC_CACHES))
 		local_node = page_to_nid(virt_to_page(s));
 	else
 		local_node = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
