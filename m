Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id F270D82F65
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 10:32:34 -0500 (EST)
Received: by obcse5 with SMTP id se5so14922132obc.3
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 07:32:34 -0800 (PST)
Received: from resqmta-po-05v.sys.comcast.net (resqmta-po-05v.sys.comcast.net. [2001:558:fe16:19:96:114:154:164])
        by mx.google.com with ESMTPS id l3si3343747oia.102.2015.12.08.07.32.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 08 Dec 2015 07:32:34 -0800 (PST)
Date: Tue, 8 Dec 2015 09:32:32 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH 2/2] slab: implement bulk free in SLAB allocator
In-Reply-To: <20151208145635.GI11488@esperanza>
Message-ID: <alpine.DEB.2.20.1512080930290.21190@east.gentwo.org>
References: <20151203155600.3589.86568.stgit@firesoul> <20151203155736.3589.67424.stgit@firesoul> <alpine.DEB.2.20.1512041111180.21819@east.gentwo.org> <20151207122549.109e82db@redhat.com> <alpine.DEB.2.20.1512070858140.8762@east.gentwo.org>
 <20151208141211.GH11488@esperanza> <alpine.DEB.2.20.1512080814350.20678@east.gentwo.org> <20151208145635.GI11488@esperanza>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

On Tue, 8 Dec 2015, Vladimir Davydov wrote:

> Don't think so, because AFAIU the whole kmem_cache_free_bulk
> optimization comes from the assumption that objects passed to it are
> likely to share the same slab page. So they must be of the same kind,
> otherwise no optimization would be possible and the function wouldn't
> perform any better than calling kfree directly in a for-loop. By
> requiring the caller to specify the cache we emphasize this.

This is likely but an implementation specific feature that only SLUB can
exploit. However, one page can only contain objects from the same slab
page. So checking the slab cache too is irrelevant. We could take it out.

If the logic finds two objects that share the same page then they will be
from the same slab cache.  The checking of the cache is just not necessary
and actually increases the code size and therefore reduces performance.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
