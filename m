Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id A40ED6B0069
	for <linux-mm@kvack.org>; Sun, 30 Nov 2014 17:16:17 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id ey11so9706058pad.24
        for <linux-mm@kvack.org>; Sun, 30 Nov 2014 14:16:17 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id cc14si26097095pac.137.2014.11.30.14.16.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 30 Nov 2014 14:16:16 -0800 (PST)
Date: Mon, 1 Dec 2014 09:16:07 +1100
From: Paul Mackerras <paulus@samba.org>
Subject: [PATCH] slab: Fix nodeid bounds check for non-contiguous node IDs
Message-ID: <20141130221606.GA25929@iris.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>

The bounds check for nodeid in ____cache_alloc_node gives false
positives on machines where the node IDs are not contiguous, leading
to a panic at boot time.  For example, on a POWER8 machine the node
IDs are typically 0, 1, 16 and 17.  This means that num_online_nodes()
returns 4, so when ____cache_alloc_node is called with nodeid = 16 the
VM_BUG_ON triggers.

To fix this, we instead compare the nodeid with MAX_NUMNODES, and
additionally make sure it isn't negative (since nodeid is an int).
The check is there mainly to protect the array dereference in the
get_node() call in the next line, and the array being dereferenced is
of size MAX_NUMNODES.  If the nodeid is in range but invalid, the
BUG_ON in the next line will catch that.

Signed-off-by: Paul Mackerras <paulus@samba.org>
---
diff --git a/mm/slab.c b/mm/slab.c
index eb2b2ea..f34e053 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3076,7 +3076,7 @@ static void *____cache_alloc_node(struct kmem_cache *cachep, gfp_t flags,
 	void *obj;
 	int x;
 
-	VM_BUG_ON(nodeid > num_online_nodes());
+	VM_BUG_ON(nodeid < 0 || nodeid >= MAX_NUMNODES);
 	n = get_node(cachep, nodeid);
 	BUG_ON(!n);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
