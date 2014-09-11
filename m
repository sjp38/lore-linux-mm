Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f52.google.com (mail-qa0-f52.google.com [209.85.216.52])
	by kanga.kvack.org (Postfix) with ESMTP id 2DEC96B0035
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 17:50:59 -0400 (EDT)
Received: by mail-qa0-f52.google.com with SMTP id m5so3089066qaj.25
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 14:50:58 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t89si3163111qge.30.2014.09.11.14.50.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Sep 2014 14:50:58 -0700 (PDT)
Date: Thu, 11 Sep 2014 17:50:41 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH] slab: fix for_each_kmem_cache_node
In-Reply-To: <20140911143357.43ece13ce88eec413c3004b1@linux-foundation.org>
Message-ID: <alpine.LRH.2.02.1409111746320.14676@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1409051155001.5269@file01.intranet.prod.int.rdu2.redhat.com> <540AD4B4.3010403@iki.fi> <alpine.DEB.2.11.1409080916230.20388@gentwo.org> <20140911143357.43ece13ce88eec413c3004b1@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@iki.fi>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On Thu, 11 Sep 2014, Andrew Morton wrote:

> On Mon, 8 Sep 2014 09:16:34 -0500 (CDT) Christoph Lameter <cl@linux.com> wrote:
> 
> > 
> > Acked-by: Christoph Lameter <cl@linux.com>
> 
> I suspect the original patch got eaten by the linux-foundation.org DNS
> outage, and whoever started this thread didn't cc any mailing lists. 
> So I have no patch and no way of finding it.
> 
> Full resend with appropriate cc's please, after adding all the
> acked-bys and reviewed-bys.

This patch fixes a bug (discovered with kmemcheck) in
for_each_kmem_cache_node. The for loop reads the array "node" before
verifying that the index is within the range. This results in kmemcheck
warning.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
Reviewed-by: Pekka Enberg <penberg@kernel.org>
Acked-by: Christoph Lameter <cl@linux.com>

---
 mm/slab.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: linux-2.6/mm/slab.h
===================================================================
--- linux-2.6.orig/mm/slab.h	2014-09-04 23:04:31.000000000 +0200
+++ linux-2.6/mm/slab.h	2014-09-04 23:23:37.000000000 +0200
@@ -303,8 +303,8 @@ static inline struct kmem_cache_node *ge
  * a kmem_cache_node structure allocated (which is true for all online nodes)
  */
 #define for_each_kmem_cache_node(__s, __node, __n) \
-	for (__node = 0; __n = get_node(__s, __node), __node < nr_node_ids; __node++) \
-		 if (__n)
+	for (__node = 0; __node < nr_node_ids; __node++) \
+		 if ((__n = get_node(__s, __node)))
 
 #endif
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
