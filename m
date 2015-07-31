Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id A8B126B0253
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 09:57:38 -0400 (EDT)
Received: by qged69 with SMTP id d69so45964017qge.0
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 06:57:38 -0700 (PDT)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id h38si5774837qga.34.2015.07.31.06.57.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 31 Jul 2015 06:57:37 -0700 (PDT)
Date: Fri, 31 Jul 2015 08:57:35 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: slab:Fix the unexpected index mapping result of kmalloc_size(INDEX_NODE
 + 1)
In-Reply-To: <20150731001827.GA15029@js1304-P5Q-DELUXE>
Message-ID: <alpine.DEB.2.11.1507310845440.11895@east.gentwo.org>
References: <OF591717D2.930C6B40-ON48257E7D.0017016C-48257E7D.0020AFB4@zte.com.cn> <20150729152803.67f593847050419a8696fe28@linux-foundation.org> <20150731001827.GA15029@js1304-P5Q-DELUXE>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, liu.hailong6@zte.com.cn, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, jiang.xuexin@zte.com.cn, David Rientjes <rientjes@google.com>

On Fri, 31 Jul 2015, Joonsoo Kim wrote:

> I don't think that this fix is right.
> Just "kmalloc_size(INDEX_NODE) * 2" looks insane because it means 192 * 2
> = 384 on his platform. Why we need to check size is larger than 384?

Its an arbitrary boundary. Making it large ensures that the smaller caches
stay operational and do not fall back to page sized allocations.

> I'm wondering what's the meaning of this check "size >=
> kmalloc_size(INDEX_NODE + 1)".

This is pretty old code. IMHO The check is if it fits in the
kmem_cache used for INDEX_NODE. If not then fall back to a page sized
allocation for the cache. Looks like DEBUG_PAGEALLOC wants one page per
object.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
