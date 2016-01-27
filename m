Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id B77FC6B0253
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 08:35:08 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id l65so145198026wmf.1
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 05:35:08 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id je3si8560338wjb.14.2016.01.27.05.35.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 27 Jan 2016 05:35:07 -0800 (PST)
Subject: Re: [PATCH 16/16] mm/slab: introduce new slab management type,
 OBJFREELIST_SLAB
References: <1452749069-15334-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1452749069-15334-17-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56A8C788.9000004@suse.cz>
Date: Wed, 27 Jan 2016 14:35:04 +0100
MIME-Version: 1.0
In-Reply-To: <1452749069-15334-17-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 01/14/2016 06:24 AM, Joonsoo Kim wrote:
> In fact, I tested another idea implementing OBJFREELIST_SLAB with
> extendable linked array through another freed object. It can remove
> memory waste completely but it causes more computational overhead
> in critical lock path and it seems that overhead outweigh benefit.
> So, this patch doesn't include it.

Can you elaborate? Do we actually need an extendable linked array? Why not just
store the pointer to the next free object into the object, NULL for the last
one? I.e. a singly-linked list. We should never need to actually traverse it?

freeing object obj:
*obj = page->freelist;
page->freelist = obj;

allocating object:
obj = page->freelist;
page->freelist = *obj;
*obj = NULL;

That means two writes, but if we omit managing page->active, it's not an
increase. For counting free objects, we would need to traverse the list, but
that's only needed for debugging?

Also during bulk operations, page->freelist could be updated just once at the
very end.

Vlastimil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
