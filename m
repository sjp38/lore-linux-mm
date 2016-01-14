Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id D8471828DF
	for <linux-mm@kvack.org>; Thu, 14 Jan 2016 10:26:38 -0500 (EST)
Received: by mail-ig0-f181.google.com with SMTP id mw1so171153775igb.1
        for <linux-mm@kvack.org>; Thu, 14 Jan 2016 07:26:38 -0800 (PST)
Received: from resqmta-ch2-10v.sys.comcast.net (resqmta-ch2-10v.sys.comcast.net. [2001:558:fe21:29:69:252:207:42])
        by mx.google.com with ESMTPS id sd6si13345282igb.19.2016.01.14.07.26.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 14 Jan 2016 07:26:38 -0800 (PST)
Date: Thu, 14 Jan 2016 09:26:37 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 09/16] mm/slab: put the freelist at the end of slab
 page
In-Reply-To: <1452749069-15334-10-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.20.1601140924520.2145@east.gentwo.org>
References: <1452749069-15334-1-git-send-email-iamjoonsoo.kim@lge.com> <1452749069-15334-10-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 14 Jan 2016, Joonsoo Kim wrote:

> Currently, the freelist is at the front of slab page. This requires
> extra space to meet object alignment requirement. If we put the freelist
> at the end of slab page, object could start at page boundary and will
> be at correct alignment. This is possible because freelist has
> no alignment constraint itself.
>
> This gives us two benefits. It removes extra memory space
> for the freelist alignment and remove complex calculation
> at cache initialization step. I can't think notable drawback here.


The third one is that the padding space at the end of the slab could
actually be used for the freelist if it fits.

The drawback may be that the location of the freelist at the beginning of
the page is more cache effective because the cache prefetcher may be able
to get the following cachelines and effectively hit the first object.
However, this is rather dubious speculation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
