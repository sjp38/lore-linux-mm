Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 2DFAE6B0031
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 12:33:37 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id p10so9083918pdj.4
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 09:33:36 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id s7si1141001pae.69.2014.01.14.09.33.35
        for <linux-mm@kvack.org>;
        Tue, 14 Jan 2014 09:33:35 -0800 (PST)
Message-ID: <52D5746F.2040604@intel.com>
Date: Tue, 14 Jan 2014 09:31:27 -0800
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [slub] WARNING: CPU: 0 PID: 0 at mm/slub.c:1511 __kmem_cache_create()
References: <20140114131915.GA26942@localhost>
In-Reply-To: <20140114131915.GA26942@localhost>
Content-Type: multipart/mixed;
 boundary="------------030204070704050609000201"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This is a multi-part message in MIME format.
--------------030204070704050609000201
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

> https://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/commit/?id=c65c1877bd6826ce0d9713d76e30a7bed8e49f38

I think the assert is just bogus at least in the early case.
early_kmem_cache_node_alloc() says:
 * No kmalloc_node yet so do it by hand. We know that this is the first
 * slab on the node for this slabcache. There are no concurrent accesses
 * possible.

Should we do something like the attached patch?  (very lightly tested)

--------------030204070704050609000201
Content-Type: text/x-patch;
 name="slub-lockdep-workaround.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="slub-lockdep-workaround.patch"



---

 b/mm/slub.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff -puN mm/slub.c~slub-lockdep-workaround mm/slub.c
--- a/mm/slub.c~slub-lockdep-workaround	2014-01-14 09:19:22.418942641 -0800
+++ b/mm/slub.c	2014-01-14 09:29:55.441297460 -0800
@@ -2890,7 +2890,13 @@ static void early_kmem_cache_node_alloc(
 	init_kmem_cache_node(n);
 	inc_slabs_node(kmem_cache_node, node, page->objects);
 
+	/*
+	 * the lock is for lockdep's sake, not for any actual
+	 * race protection
+	 */
+	spin_lock(&n->list_lock);
 	add_partial(n, page, DEACTIVATE_TO_HEAD);
+	spin_unlock(&n->list_lock);
 }
 
 static void free_kmem_cache_nodes(struct kmem_cache *s)
_

--------------030204070704050609000201--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
