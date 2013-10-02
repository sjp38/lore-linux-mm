Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 10E896B003A
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 11:57:15 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id p10so1074004pdj.32
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 08:57:15 -0700 (PDT)
Date: Wed, 2 Oct 2013 15:57:12 +0000
From: Christoph Lameter <cl@linux.com>
Subject: RE: [PATCH] slub: Proper kmemleak tracking if CONFIG_SLUB_DEBUG
 disabled
In-Reply-To: <F5184659D418E34EA12B1903EE5EF5FD8538E86615@seldmbx02.corpusers.net>
Message-ID: <0000014179e31953-a05dd7d1-d0f8-474f-810a-809cd8a724f8-000000@email.amazonses.com>
References: <5245ECC3.8070200@gmail.com>,<00000141799dd4b3-f6df96c0-1003-427d-9bd8-f6455622f4ea-000000@email.amazonses.com> <F5184659D418E34EA12B1903EE5EF5FD8538E86615@seldmbx02.corpusers.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Bird, Tim" <Tim.Bird@sonymobile.com>
Cc: Frank Rowand <frowand.list@gmail.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, "Bobniev, Roman" <Roman.Bobniev@sonymobile.com>, =?ISO-8859-15?Q?=22Andersson=2C_Bj=F6rn=22?= <Bjorn.Andersson@sonymobile.com>

On Wed, 2 Oct 2013, Bird, Tim wrote:

> The problem child is actually the unconditional call to kmemleak_alloc()
> in kmalloc_large_node() (in slub.c).  The problem comes because that call
> is unconditional on CONFIG_SLUB_DEBUG but the kmemleak
> calls in the hook routines are conditional on CONFIG_SLUB_DEBUG.
> So if you have CONFIG_SLUB_DEBUG=n but CONFIG_DEBUG_KMEMLEAK=y,
> you get the false reports.

Right. You need to put the #ifdef CONFIG_SLUB_DEBUG around the hooks that
need it in the function itself instead of disabling the whole function if
CONFIG_SLUB_DEUBG is not set.

> Now, there are kmemleak calls in kmalloc_large_node() and kfree() that don't
> follow the "hook" pattern.  Should these be moved to 'hook' routines, to keep
> all the checks in the hooks?

That would be great.

> Personally, I like the idea of keeping bookeeping/tracing/debug stuff in hook
> routines.  I also like de-coupling CONFIG_SLUB_DEBUG and CONFIG_DEBUG_KMEMLEAK,
> but maybe others have a different opinon.  Unless someone speaks up, we'll
> move the the currently in-function kmemleak calls into hooks, and all of the
> kmemleak stuff out from under CONFIG_SLUB_DEBUG.
> We'll have to see if the ifdefs get a little messy.

Decouple of you want. CONFIG_SLUB_DEBUG may duplicate what you already do.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
