Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8FEB26B0022
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 13:19:59 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id a79-v6so621470itc.3
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 10:19:59 -0700 (PDT)
Received: from resqmta-po-09v.sys.comcast.net (resqmta-po-09v.sys.comcast.net. [2001:558:fe16:19:96:114:154:168])
        by mx.google.com with ESMTPS id c67si400423ioc.193.2018.03.13.10.19.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Mar 2018 10:19:58 -0700 (PDT)
Date: Tue, 13 Mar 2018 12:19:56 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH] slab, slub: remove size disparity on debug kernel
In-Reply-To: <20180313165428.58699-1-shakeelb@google.com>
Message-ID: <alpine.DEB.2.20.1803131217200.9367@nuc-kabylake>
References: <20180313165428.58699-1-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 13 Mar 2018, Shakeel Butt wrote:

> However for SLUB in debug kernel, the sizes were same. On further
> inspection it is found that SLUB always use kmem_cache.object_size to
> measure the kmem_cache.size while SLAB use the given kmem_cache.size. In
> the debug kernel the slab's size can be larger than its object_size.
> Thus in the creation of non-root slab, the SLAB uses the root's size as
> base to calculate the non-root slab's size and thus non-root slab's size
> can be larger than the root slab's size. For SLUB, the non-root slab's
> size is measured based on the root's object_size and thus the size will
> remain same for root and non-root slab.

Note that the object_size and size may differ for SLUB based on kernel
parameters and slab configuration. For SLAB these are compilation options.

> @@ -379,7 +379,7 @@ struct kmem_cache *find_mergeable(unsigned int size, unsigned int align,
>  }
>
>  static struct kmem_cache *create_cache(const char *name,
> -		unsigned int object_size, unsigned int size, unsigned int align,
> +		unsigned int object_size, unsigned int align,
>  		slab_flags_t flags, unsigned int useroffset,

Why was both the size and object_size passed during cache creation in the
first place? From the flags etc the slab logic should be able to compute
the actual bytes required for each object and its metadata.
