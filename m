Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 568BB6B0031
	for <linux-mm@kvack.org>; Wed, 16 Oct 2013 16:35:01 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id g10so1207679pdj.35
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 13:35:01 -0700 (PDT)
Date: Wed, 16 Oct 2013 13:34:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 00/15] slab: overload struct slab over struct page to
 reduce memory usage
Message-Id: <20131016133457.60fa71f893cd2962d8ec6ff3@linux-foundation.org>
In-Reply-To: <1381913052-23875-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1381913052-23875-1-git-send-email-iamjoonsoo.kim@lge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Wed, 16 Oct 2013 17:43:57 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:

> There is two main topics in this patchset. One is to reduce memory usage
> and the other is to change a management method of free objects of a slab.
> 
> The SLAB allocate a struct slab for each slab. The size of this structure
> except bufctl array is 40 bytes on 64 bits machine. We can reduce memory
> waste and cache footprint if we overload struct slab over struct page.

Seems a good idea from a quick look.

A thought: when we do things like this - adding additional
interpretations to `struct page', we need to bear in mind that other
unrelated code can inspect that pageframe.  It is not correct to assume
that because slab "owns" this page, no other code will be looking at it
and interpreting its contents.

One example is mm/memory-failure.c:memory_failure().  It starts with a
raw pfn, uses that to get at the `struct page', then starts playing
around with it.  Will that code still work correctly when some of the
page's fields have been overlayed with slab-specific contents?

And memory_failure() is just one example - another is compact_zone()
and there may well be others.

This issue hasn't been well thought through.  Given a random struct
page, there isn't any protocol to determine what it actually *is*. 
It's a plain old variant record, but it lacks the agreed-upon tag field
which tells users which variant is currently in use.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
