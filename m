Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 75E216B0069
	for <linux-mm@kvack.org>; Sun, 30 Nov 2014 19:42:38 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id rd3so9933678pab.21
        for <linux-mm@kvack.org>; Sun, 30 Nov 2014 16:42:38 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id um5si3679088pab.81.2014.11.30.16.42.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 30 Nov 2014 16:42:37 -0800 (PST)
Date: Mon, 1 Dec 2014 11:42:10 +1100
From: Paul Mackerras <paulus@samba.org>
Subject: Re: [PATCH] slab: Fix nodeid bounds check for non-contiguous node IDs
Message-ID: <20141201004210.GA11234@drongo>
References: <20141130221606.GA25929@iris.ozlabs.ibm.com>
 <547BB2F0.5040708@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <547BB2F0.5040708@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@kernel.org>, linuxppc-dev@ozlabs.org, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Mon, Dec 01, 2014 at 09:14:40AM +0900, Yasuaki Ishimatsu wrote:
> (2014/12/01 7:16), Paul Mackerras wrote:
> >The bounds check for nodeid in ____cache_alloc_node gives false
> >positives on machines where the node IDs are not contiguous, leading
> >to a panic at boot time.  For example, on a POWER8 machine the node
> >IDs are typically 0, 1, 16 and 17.  This means that num_online_nodes()
> >returns 4, so when ____cache_alloc_node is called with nodeid = 16 the
> >VM_BUG_ON triggers.
> 
> Do you have the call trace? If you have it, please add it in the description.

I can get it easily enough.

> >To fix this, we instead compare the nodeid with MAX_NUMNODES, and
> >additionally make sure it isn't negative (since nodeid is an int).
> >The check is there mainly to protect the array dereference in the
> >get_node() call in the next line, and the array being dereferenced is
> >of size MAX_NUMNODES.  If the nodeid is in range but invalid, the
> >BUG_ON in the next line will catch that.
> >
> >Signed-off-by: Paul Mackerras <paulus@samba.org>
> 
> Do you need to backport it into -stable kernels?

It does need to go to stable, yes, for 3.10 and later.

> >---
> >diff --git a/mm/slab.c b/mm/slab.c
> >index eb2b2ea..f34e053 100644
> >--- a/mm/slab.c
> >+++ b/mm/slab.c
> >@@ -3076,7 +3076,7 @@ static void *____cache_alloc_node(struct kmem_cache *cachep, gfp_t flags,
> >  	void *obj;
> >  	int x;
> >
> 
> >-	VM_BUG_ON(nodeid > num_online_nodes());
> >+	VM_BUG_ON(nodeid < 0 || nodeid >= MAX_NUMNODES);
> 
> How about use:
> 	VM_BUG_ON(!node_online(nodeid));

That would not be better, since node_online() doesn't bounds-check its
argument.

> When allocating the memory, the node of the memory being allocated must be
> online. But your code cannot check the condition.

The following two lines:

> >  	n = get_node(cachep, nodeid);
> >  	BUG_ON(!n);

effectively check that condition already, as I tried to explain in the
commit message.

Regards,
Paul.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
