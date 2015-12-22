Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id 5B0F76B0260
	for <linux-mm@kvack.org>; Tue, 22 Dec 2015 12:24:52 -0500 (EST)
Received: by mail-ig0-f174.google.com with SMTP id to4so64447212igc.0
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 09:24:52 -0800 (PST)
Received: from resqmta-ch2-10v.sys.comcast.net (resqmta-ch2-10v.sys.comcast.net. [2001:558:fe21:29:69:252:207:42])
        by mx.google.com with ESMTPS id n9si7264773igv.82.2015.12.22.09.24.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 22 Dec 2015 09:24:51 -0800 (PST)
Date: Tue, 22 Dec 2015 11:24:50 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [kernel-hardening] [RFC][PATCH 6/7] mm: Add Kconfig option for
 slab sanitization
In-Reply-To: <567986E7.50107@intel.com>
Message-ID: <alpine.DEB.2.20.1512221124230.14335@east.gentwo.org>
References: <1450755641-7856-1-git-send-email-laura@labbott.name> <1450755641-7856-7-git-send-email-laura@labbott.name> <567964F3.2020402@intel.com> <alpine.DEB.2.20.1512221023550.2748@east.gentwo.org> <567986E7.50107@intel.com>
Content-Type: multipart/mixed; BOUNDARY=------------020001080303010705010207
Content-ID: <alpine.DEB.2.20.1512221124231.14335@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: kernel-hardening@lists.openwall.com, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Laura Abbott <laura@labbott.name>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kees Cook <keescook@chromium.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--------------020001080303010705010207
Content-Type: text/plain; CHARSET=US-ASCII
Content-ID: <alpine.DEB.2.20.1512221124232.14335@east.gentwo.org>

On Tue, 22 Dec 2015, Dave Hansen wrote:

> Or are you just saying that we should use the poisoning *code* that we
> already have in slub?  Using the _code_ looks like a really good idea,
> whether we're using it to write POISON_FREE, or 0's.  Something like the
> attached patch?

Why would you use zeros? The point is just to clear the information right?
The regular poisoning does that.

--------------020001080303010705010207
Content-Type: text/x-patch; NAME=slub-poison-zeros.patch
Content-ID: <alpine.DEB.2.20.1512221124233.14335@east.gentwo.org>
Content-Description: 
Content-Disposition: ATTACHMENT; FILENAME=slub-poison-zeros.patch



---

 b/mm/slub.c |   12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff -puN mm/slub.c~slub-poison-zeros mm/slub.c
--- a/mm/slub.c~slub-poison-zeros	2015-12-22 09:18:30.585371985 -0800
+++ b/mm/slub.c	2015-12-22 09:21:23.754174731 -0800
@@ -177,6 +177,7 @@ static inline bool kmem_cache_has_cpu_pa
 /* Internal SLUB flags */
 #define __OBJECT_POISON		0x80000000UL /* Poison object */
 #define __CMPXCHG_DOUBLE	0x40000000UL /* Use cmpxchg_double */
+#define __OBJECT_POISON_ZERO	0x20000000UL /* Poison with zeroes */
 
 #ifdef CONFIG_SMP
 static struct notifier_block slab_notifier;
@@ -678,7 +679,10 @@ static void init_object(struct kmem_cach
 	u8 *p = object;
 
 	if (s->flags & __OBJECT_POISON) {
-		memset(p, POISON_FREE, s->object_size - 1);
+		if (s->flags & __OBJECT_POISON_ZERO) {
+			memset(p, POISON_FREE, s->object_size - 1);
+		else
+			memset(p, 0, s->object_size - 1);
 		p[s->object_size - 1] = POISON_END;
 	}
 
@@ -2495,7 +2499,8 @@ redo:
 		stat(s, ALLOC_FASTPATH);
 	}
 
-	if (unlikely(gfpflags & __GFP_ZERO) && object)
+	if (unlikely(gfpflags & __GFP_ZERO) && object &&
+	    !(s->flags & __OBJECT_POISON_ZERO)) {
 		memset(object, 0, s->object_size);
 
 	slab_post_alloc_hook(s, gfpflags, object);
@@ -2839,7 +2844,8 @@ bool kmem_cache_alloc_bulk(struct kmem_c
 	local_irq_enable();
 
 	/* Clear memory outside IRQ disabled fastpath loop */
-	if (unlikely(flags & __GFP_ZERO)) {
+	if (unlikely(flags & __GFP_ZERO) &&
+	    !(s->flags & __OBJECT_POISON_ZERO)) {
 		int j;
 
 		for (j = 0; j < i; j++)
_

--------------020001080303010705010207--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
