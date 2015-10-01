Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f178.google.com (mail-qk0-f178.google.com [209.85.220.178])
	by kanga.kvack.org (Postfix) with ESMTP id 0D06582F87
	for <linux-mm@kvack.org>; Thu,  1 Oct 2015 18:10:18 -0400 (EDT)
Received: by qkcf65 with SMTP id f65so35697409qkc.3
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 15:10:17 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id a12si7582230qkj.82.2015.10.01.15.10.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Oct 2015 15:10:17 -0700 (PDT)
Date: Thu, 1 Oct 2015 15:10:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [MM PATCH V4.1 5/6] slub: support for bulk free with SLUB
 freelists
Message-Id: <20151001151015.c59a1360c7720a257f655578@linux-foundation.org>
In-Reply-To: <20150930114255.13505.2618.stgit@canyon>
References: <560ABE86.9050508@gmail.com>
	<20150930114255.13505.2618.stgit@canyon>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Alexander Duyck <alexander.duyck@gmail.com>, Pekka Enberg <penberg@kernel.org>, netdev@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>

On Wed, 30 Sep 2015 13:44:19 +0200 Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> Make it possible to free a freelist with several objects by adjusting
> API of slab_free() and __slab_free() to have head, tail and an objects
> counter (cnt).
> 
> Tail being NULL indicate single object free of head object.  This
> allow compiler inline constant propagation in slab_free() and
> slab_free_freelist_hook() to avoid adding any overhead in case of
> single object free.
> 
> This allows a freelist with several objects (all within the same
> slab-page) to be free'ed using a single locked cmpxchg_double in
> __slab_free() and with an unlocked cmpxchg_double in slab_free().
> 
> Object debugging on the free path is also extended to handle these
> freelists.  When CONFIG_SLUB_DEBUG is enabled it will also detect if
> objects don't belong to the same slab-page.
> 
> These changes are needed for the next patch to bulk free the detached
> freelists it introduces and constructs.
> 
> Micro benchmarking showed no performance reduction due to this change,
> when debugging is turned off (compiled with CONFIG_SLUB_DEBUG).
> 

checkpatch says

WARNING: Avoid crashing the kernel - try using WARN_ON & recovery code rather than BUG() or BUG_ON()
#205: FILE: mm/slub.c:2888:
+       BUG_ON(!size);


Linus will get mad at you if he finds out, and we wouldn't want that.

--- a/mm/slub.c~slub-optimize-bulk-slowpath-free-by-detached-freelist-fix
+++ a/mm/slub.c
@@ -2885,7 +2885,8 @@ static int build_detached_freelist(struc
 /* Note that interrupts must be enabled when calling this function. */
 void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
 {
-	BUG_ON(!size);
+	if (WARN_ON(!size))
+		return;
 
 	do {
 		struct detached_freelist df;
_


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
