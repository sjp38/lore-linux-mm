Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1B8A46B1B01
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 12:26:54 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id z14-v6so33639315wrh.23
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 09:26:54 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 59-v6sor25733094wro.34.2018.11.19.09.26.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 19 Nov 2018 09:26:52 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v11 02/24] kasan, slub: handle pointer tags in early_kmem_cache_node_alloc
Date: Mon, 19 Nov 2018 18:26:18 +0100
Message-Id: <14a68774683e15692615600c47bba53506a1c8ef.1542648335.git.andreyknvl@google.com>
In-Reply-To: <cover.1542648335.git.andreyknvl@google.com>
References: <cover.1542648335.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org
Cc: Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>, Andrey Konovalov <andreyknvl@google.com>

The previous patch updated KASAN hooks signatures and their usage in SLAB
and SLUB code, except for the early_kmem_cache_node_alloc function. This
patch handles that function separately, as it requires to reorder some of
the initialization code to correctly propagate a tagged pointer in case a
tag is assigned by kasan_kmalloc.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/slub.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index fdd4a86aa882..8561a32910dd 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3364,16 +3364,16 @@ static void early_kmem_cache_node_alloc(int node)
 
 	n = page->freelist;
 	BUG_ON(!n);
-	page->freelist = get_freepointer(kmem_cache_node, n);
-	page->inuse = 1;
-	page->frozen = 0;
-	kmem_cache_node->node[node] = n;
 #ifdef CONFIG_SLUB_DEBUG
 	init_object(kmem_cache_node, n, SLUB_RED_ACTIVE);
 	init_tracking(kmem_cache_node, n);
 #endif
-	kasan_kmalloc(kmem_cache_node, n, sizeof(struct kmem_cache_node),
+	n = kasan_kmalloc(kmem_cache_node, n, sizeof(struct kmem_cache_node),
 		      GFP_KERNEL);
+	page->freelist = get_freepointer(kmem_cache_node, n);
+	page->inuse = 1;
+	page->frozen = 0;
+	kmem_cache_node->node[node] = n;
 	init_kmem_cache_node(n);
 	inc_slabs_node(kmem_cache_node, node, page->objects);
 
-- 
2.19.1.1215.g8438c0b245-goog
