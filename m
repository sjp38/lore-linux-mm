Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id E66BC6B0032
	for <linux-mm@kvack.org>; Wed, 10 Dec 2014 12:37:59 -0500 (EST)
Received: by mail-ig0-f179.google.com with SMTP id r2so3326697igi.0
        for <linux-mm@kvack.org>; Wed, 10 Dec 2014 09:37:59 -0800 (PST)
Received: from resqmta-po-05v.sys.comcast.net ([2001:558:fe16:19:250:56ff:feb0:2995])
        by mx.google.com with ESMTPS id cj5si3660583igc.29.2014.12.10.09.37.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 10 Dec 2014 09:37:58 -0800 (PST)
Date: Wed, 10 Dec 2014 11:37:56 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 3/7] slub: Do not use c->page on free
In-Reply-To: <CAOJsxLH4BGT9rGgg_4nxUMgW3sdEzLrmX2WtM8Ld3aytdR5e8g@mail.gmail.com>
Message-ID: <alpine.DEB.2.11.1412101136520.6639@gentwo.org>
References: <20141210163017.092096069@linux.com> <20141210163033.717707217@linux.com> <CAOJsxLFEN_w7q6NvbxkH2KTujB9auLkQgskLnGtN9iBQ4hV9sw@mail.gmail.com> <alpine.DEB.2.11.1412101107350.6291@gentwo.org>
 <CAOJsxLH4BGT9rGgg_4nxUMgW3sdEzLrmX2WtM8Ld3aytdR5e8g@mail.gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: akpm <akpm@linuxfoundation.org>, Steven Rostedt <rostedt@goodmis.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, iamjoonsoo@lge.com, Jesper Dangaard Brouer <brouer@redhat.com>

On Wed, 10 Dec 2014, Pekka Enberg wrote:

> I'm fine with the optimization:
>
> Reviewed-by: Pekka Enberg <penberg@kernel.org>

There were some other issues so its now:


Subject: slub: Do not use c->page on free

Avoid using the page struct address on free by just doing an
address comparison. That is easily doable now that the page address
is available in the page struct and we already have the page struct
address of the object to be freed calculated.

Reviewed-by: Pekka Enberg <penberg@kernel.org>
Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2014-12-10 11:35:32.538563734 -0600
+++ linux/mm/slub.c	2014-12-10 11:36:39.032447807 -0600
@@ -2625,6 +2625,17 @@ slab_empty:
 	discard_slab(s, page);
 }

+static bool is_pointer_to_page(struct page *page, void *p)
+{
+	long d = p - page->address;
+
+	/*
+	 * Do a comparison for a MAX_ORDER page first before using
+	 * compound_order() to determine the actual page size.
+	 */
+	return d >= 0 && d < (1 << MAX_ORDER) && d < (compound_order(page) << PAGE_SHIFT);
+}
+
 /*
  * Fastpath with forced inlining to produce a kfree and kmem_cache_free that
  * can perform fastpath freeing without additional function calls.
@@ -2658,7 +2669,7 @@ redo:
 	tid = c->tid;
 	preempt_enable();

-	if (likely(page == c->page)) {
+	if (likely(is_pointer_to_page(page, c->freelist))) {
 		set_freepointer(s, object, c->freelist);

 		if (unlikely(!this_cpu_cmpxchg_double(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
