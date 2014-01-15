Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-gg0-f171.google.com (mail-gg0-f171.google.com [209.85.161.171])
	by kanga.kvack.org (Postfix) with ESMTP id 8C2C76B0031
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 17:58:01 -0500 (EST)
Received: by mail-gg0-f171.google.com with SMTP id i2so669026ggn.30
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 14:58:01 -0800 (PST)
Received: from mail-gg0-x229.google.com (mail-gg0-x229.google.com [2607:f8b0:4002:c02::229])
        by mx.google.com with ESMTPS id s6si7120147yho.64.2014.01.15.14.58.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 15 Jan 2014 14:58:00 -0800 (PST)
Received: by mail-gg0-f169.google.com with SMTP id j5so677756ggn.28
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 14:58:00 -0800 (PST)
Date: Wed, 15 Jan 2014 14:57:56 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: Make {,set}page_address() static inline if
 WANT_PAGE_VIRTUAL
In-Reply-To: <1389778426-14836-1-git-send-email-geert@linux-m68k.org>
Message-ID: <alpine.DEB.2.02.1401151454440.24121@chino.kir.corp.google.com>
References: <1389778426-14836-1-git-send-email-geert@linux-m68k.org>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="531381512-692950067-1389826679=:24121"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Guenter Roeck <linux@roeck-us.net>, "Michael S. Tsirkin" <mst@redhat.com>, linux-mm@kvack.org, linux-bcache@vger.kernel.org, Vineet Gupta <vgupta@synopsys.com>, sparclinux@vger.kernel.org, linux-m68k@vger.kernel.org, linux-kernel@vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--531381512-692950067-1389826679=:24121
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Wed, 15 Jan 2014, Geert Uytterhoeven wrote:

> {,set}page_address() are macros if WANT_PAGE_VIRTUAL.
> If !WANT_PAGE_VIRTUAL, they're plain C functions.
> 
> If someone calls them with a void *, this pointer is auto-converted to
> struct page * if !WANT_PAGE_VIRTUAL, but causes a build failure on
> architectures using WANT_PAGE_VIRTUAL (arc, m68k and sparc):

s/sparc/sparc64/

> 
> drivers/md/bcache/bset.c: In function a??__btree_sorta??:
> drivers/md/bcache/bset.c:1190: warning: dereferencing a??void *a?? pointer
> drivers/md/bcache/bset.c:1190: error: request for member a??virtuala?? in something not a structure or union
> 
> Convert them to static inline functions to fix this. There are already
> plenty of  users of struct page members inside <linux/mm.h>, so there's no
> reason to keep them as macros.
> 
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>

Tested-by: David Rientjes <rientjes@google.com>

I'm cringing at the page_address(mempool_alloc(..., GFP_NOIO)) in 
drivers/md/bcache/bset.c, though.  It's relying on that fact that 
mempool_alloc() can never return NULL if __GFP_WAIT but I think this could 
have all been avoided with

	struct page *page = mempool_alloc(state->pool, GFP_NOIO);
	out = page_address(page);

instead of burying the mempool_alloc() in page_address() for what I think 
is cleaner code.  Owell, it fixes the issue.
--531381512-692950067-1389826679=:24121--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
