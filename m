Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 26CCC440874
	for <linux-mm@kvack.org>; Wed, 12 Jul 2017 15:21:59 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 79so655288wmg.4
        for <linux-mm@kvack.org>; Wed, 12 Jul 2017 12:21:59 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id g7si3072289wme.130.2017.07.12.12.21.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jul 2017 12:21:57 -0700 (PDT)
Date: Wed, 12 Jul 2017 12:21:54 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] slub: make sure struct kmem_cache_node is initialized
 before publication
Message-Id: <20170712122154.f6bafdc86ccfd189fefbb0a3@linux-foundation.org>
In-Reply-To: <CAG_fn=WKtQhGfcTxvRgDYnAkOp1acGUmnLyoJRf6syvEL-Yysg@mail.gmail.com>
References: <20170707083408.40410-1-glider@google.com>
	<20170707132351.4f10cd778fc5eb58e9cc5513@linux-foundation.org>
	<alpine.DEB.2.20.1707071816560.20454@east.gentwo.org>
	<20170710133238.2afcda57ea28e020ca03c4f0@linux-foundation.org>
	<CAG_fn=WKtQhGfcTxvRgDYnAkOp1acGUmnLyoJRf6syvEL-Yysg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: Christoph Lameter <cl@linux.com>, Dmitriy Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Wed, 12 Jul 2017 16:11:28 +0200 Alexander Potapenko <glider@google.com> wrote:

> >> At creation time the kmem_cache structure is private and no one can run a
> >> free operation.
> I've double-checked the code path and this turned out to be a false
> positive caused by KMSAN not instrumenting the contents of mm/slub.c
> (i.e. the initialization of the spinlock remained unnoticed).
> Christoph is indeed right that kmem_cache_structure is private, so a
> race is not possible here.
> I am sorry for the false alarm.
> >> > Inviting a use-after-free?  I guess not, as there should be no way
> >> > to look up these items at this stage.
> >>
> >> Right.
> >
> > Still.   It looks bad, and other sites do these things in the other order.
> If the maintainers agree the initialization order needs to be fixed,
> we'll need to remove the (irrelevant) KMSAN report from the patch
> description.

Yup.  I did this:

From: Alexander Potapenko <glider@google.com>
Subject: slub: tidy up initialization ordering

- free_kmem_cache_nodes() frees the cache node before nulling out a
  reference to it

- init_kmem_cache_nodes() publishes the cache node before initializing it

Neither of these matter at runtime because the cache nodes cannot be
looked up by any other thread.  But it's neater and more consistent to
reorder these.

Link: http://lkml.kernel.org/r/20170707083408.40410-1-glider@google.com
Signed-off-by: Alexander Potapenko <glider@google.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/slub.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -puN mm/slub.c~slub-make-sure-struct-kmem_cache_node-is-initialized-before-publication mm/slub.c
--- a/mm/slub.c~slub-make-sure-struct-kmem_cache_node-is-initialized-before-publication
+++ a/mm/slub.c
@@ -3358,8 +3358,8 @@ static void free_kmem_cache_nodes(struct
 	struct kmem_cache_node *n;
 
 	for_each_kmem_cache_node(s, node, n) {
-		kmem_cache_free(kmem_cache_node, n);
 		s->node[node] = NULL;
+		kmem_cache_free(kmem_cache_node, n);
 	}
 }
 
@@ -3389,8 +3389,8 @@ static int init_kmem_cache_nodes(struct
 			return 0;
 		}
 
-		s->node[node] = n;
 		init_kmem_cache_node(n);
+		s->node[node] = n;
 	}
 	return 1;
 }
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
