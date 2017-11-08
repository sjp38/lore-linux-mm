Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id D456B440417
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 10:05:14 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id i38so5767575iod.10
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 07:05:14 -0800 (PST)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id 91si3743368ioq.86.2017.11.08.07.05.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Nov 2017 07:05:13 -0800 (PST)
Date: Wed, 8 Nov 2017 09:05:12 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: Fix sysfs duplicate filename creation when
 slub_debug=O
In-Reply-To: <1510119138.17435.19.camel@mtkswgap22>
Message-ID: <alpine.DEB.2.20.1711080903460.6161@nuc-kabylake>
References: <1510023934-17517-1-git-send-email-miles.chen@mediatek.com> <alpine.DEB.2.20.1711070916480.18776@nuc-kabylake> <1510119138.17435.19.camel@mtkswgap22>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Miles Chen <miles.chen@mediatek.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, wsd_upstream@mediatek.com, linux-mediatek@lists.infradead.org

On Wed, 8 Nov 2017, Miles Chen wrote:

> > Ok then the aliasing failed for some reason. The creation of the unique id
> > and the alias detection needs to be in sync otherwise duplicate filenames
> > are created. What is the difference there?
>
> The aliasing failed because find_mergeable() returns if (flags &
> SLAB_NEVER_MERGE) is true. So we do not go to search for alias caches.
>
> __kmem_cache_alias()
>   find_mergeable()
>     kmem_cache_flags()  --> setup flag by the slub_debug
>     if (flags & SLAB_NEVER_MERGE) return NULL;
>     ...
>     search alias logic...
>
>
> The flags maybe changed if disable_higher_order_debug=1. So the
> unmergeable cache becomes mergeable later.

Ok so make sure taht the aliasing logic also clears those flags before
checking for SLAB_NEVER_MERGE.

> > The clearing of the DEBUG_METADATA_FLAGS looks ok to me. kmem_cache_alias
> > should do the same right?
> >
> Yes, I think clearing DEBUG_METADATA flags in kmem_cache_alias is
> another solution for this issue.
>
> We will need to do calculate_sizes() by using original flags and compare
> the order of s->size and s->object_size when
> disable_higher_order_debug=1.

Hmmm... Or move the aliasing check to a point where we know the size of
the slab objects?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
