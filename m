Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f173.google.com (mail-ie0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 79FDE6B0032
	for <linux-mm@kvack.org>; Tue, 27 Jan 2015 11:57:38 -0500 (EST)
Received: by mail-ie0-f173.google.com with SMTP id tr6so16324196ieb.4
        for <linux-mm@kvack.org>; Tue, 27 Jan 2015 08:57:38 -0800 (PST)
Received: from resqmta-po-10v.sys.comcast.net (resqmta-po-10v.sys.comcast.net. [2001:558:fe16:19:96:114:154:169])
        by mx.google.com with ESMTPS id 20si1111230ioi.87.2015.01.27.08.57.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 27 Jan 2015 08:57:37 -0800 (PST)
Date: Tue, 27 Jan 2015 10:57:36 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC 1/3] Slab infrastructure for array operations
In-Reply-To: <20150127082132.GE11358@js1304-P5Q-DELUXE>
Message-ID: <alpine.DEB.2.11.1501271054310.25124@gentwo.org>
References: <20150123213727.142554068@linux.com> <20150123213735.590610697@linux.com> <20150127082132.GE11358@js1304-P5Q-DELUXE>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: akpm@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo@lge.com, Jesper Dangaard Brouer <brouer@redhat.com>

On Tue, 27 Jan 2015, Joonsoo Kim wrote:

> IMHO, exposing these options is not a good idea. It's really
> implementation specific. And, this flag won't show consistent performance
> according to specific slab implementation. For example, to get best
> performance, if SLAB is used, GFP_SLAB_ARRAY_LOCAL would be the best option,
> but, for the same purpose, if SLUB is used, GFP_SLAB_ARRAY_NEW would
> be the best option. And, performance could also depend on number of objects
> and size.

Why would slab show a better performance? SLUB also can have partial
allocated pages per cpu and could also get data quite fast if only a
minimal number of objects are desired. SLAB is slightly better because the
number of cachelines touches stays small due to the arrangement of the freelist
on the slab page and the queueing approach that does not involve linked
lists.


GFP_SLAB_ARRAY new is best for large quantities in either allocator since
SLAB also has to construct local metadata structures.

> And, overriding gfp flag isn't a good idea. Someday gfp could use
> these values and they can't notice that these are used in slab
> subsystem with different meaning.

We can put a BUILD_BUG_ON in there to ensure that the GFP flags do not get
too high. The upper portion of the GFP flags is also used elsewhere. And
it is an allocation option so it naturally fits in there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
