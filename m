Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 40AAB6B02D8
	for <linux-mm@kvack.org>; Thu,  3 Nov 2016 16:33:27 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id t125so127336304ywc.4
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 13:33:27 -0700 (PDT)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id l195si3156675ioe.182.2016.11.03.13.33.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Nov 2016 13:33:26 -0700 (PDT)
Date: Thu, 3 Nov 2016 15:33:27 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2] memcg: Prevent memcg caches to be both OFF_SLAB &
 OBJFREELIST_SLAB
In-Reply-To: <alpine.DEB.2.10.1611021744150.110015@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.20.1611031531380.13315@east.gentwo.org>
References: <1477939010-111710-1-git-send-email-thgarnie@google.com> <alpine.DEB.2.10.1610311625430.62482@chino.kir.corp.google.com> <CAJcbSZHic9gfpYHFXySZf=EmUjztBvuHeWWq7CQFi=0Om7OJoA@mail.gmail.com>
 <alpine.DEB.2.10.1611021744150.110015@chino.kir.corp.google.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Thomas Garnier <thgarnie@google.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Greg Thelen <gthelen@google.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@kernel.org>

On Wed, 2 Nov 2016, David Rientjes wrote:

> > Christoph on the first version advised removing invalid flags on the
> > caller and checking they are correct in kmem_cache_create. The memcg
> > path putting the wrong flags is through create_cache but I still used
> > this approach.
> >
>
> I think this is a rather trivial point since it doesn't matter if we clear
> invalid flags on the caller or in the callee and obviously
> kmem_cache_create() does it in the callee.

In order to be correct we need to do the following:

kmem_cache_create should check for invalid flags (and that includes
internal alloocator flgs) being set and refuse to create the slab cache.

memcg needs to call kmem_cache_create without any internal flags.

I also want to make sure that there are no other callers that specify
extraneou flags while we are at it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
