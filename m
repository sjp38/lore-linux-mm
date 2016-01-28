Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id AE3BB6B0009
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 23:51:25 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id cy9so16611559pac.0
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 20:51:25 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTPS id d26si14162218pfb.137.2016.01.27.20.51.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 27 Jan 2016 20:51:24 -0800 (PST)
Date: Thu, 28 Jan 2016 13:51:28 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 16/16] mm/slab: introduce new slab management type,
 OBJFREELIST_SLAB
Message-ID: <20160128045128.GC14467@js1304-P5Q-DELUXE>
References: <1452749069-15334-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1452749069-15334-17-git-send-email-iamjoonsoo.kim@lge.com>
 <56A8C788.9000004@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56A8C788.9000004@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jan 27, 2016 at 02:35:04PM +0100, Vlastimil Babka wrote:
> On 01/14/2016 06:24 AM, Joonsoo Kim wrote:
> > In fact, I tested another idea implementing OBJFREELIST_SLAB with
> > extendable linked array through another freed object. It can remove
> > memory waste completely but it causes more computational overhead
> > in critical lock path and it seems that overhead outweigh benefit.
> > So, this patch doesn't include it.
> 
> Can you elaborate? Do we actually need an extendable linked array? Why not just
> store the pointer to the next free object into the object, NULL for the last
> one? I.e. a singly-linked list. We should never need to actually traverse it?

As Christoph explained, it's the way SLUB manages freed objects. In SLAB
case, it doesn't want to touch object itself. It's one of main difference
between SLAB and SLUB. These objects are cache-cold now so touching object itself
could cause more cache footprint.

> 
> freeing object obj:
> *obj = page->freelist;
> page->freelist = obj;
> 
> allocating object:
> obj = page->freelist;
> page->freelist = *obj;
> *obj = NULL;
> 
> That means two writes, but if we omit managing page->active, it's not an

It's not just matter of number of instructions as explained above. Touching
more cache line should also be avoided.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
