Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f52.google.com (mail-ee0-f52.google.com [74.125.83.52])
	by kanga.kvack.org (Postfix) with ESMTP id 2FC0D6B0035
	for <linux-mm@kvack.org>; Mon, 21 Apr 2014 08:18:55 -0400 (EDT)
Received: by mail-ee0-f52.google.com with SMTP id e49so3532468eek.25
        for <linux-mm@kvack.org>; Mon, 21 Apr 2014 05:18:54 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id i49si2048704eem.12.2014.04.21.05.18.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 21 Apr 2014 05:18:53 -0700 (PDT)
Date: Mon, 21 Apr 2014 08:18:40 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC] how should we deal with dead memcgs' kmem caches?
Message-ID: <20140421121840.GA11622@cmpxchg.org>
References: <5353A3E3.4020302@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5353A3E3.4020302@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Glauber Costa <glommer@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, devel@openvz.org

On Sun, Apr 20, 2014 at 02:39:31PM +0400, Vladimir Davydov wrote:
> * Way #2 - reap caches periodically or on vmpressure *
> 
> We can remove the async work scheduling from kmem_cache_free completely,
> and instead walk over all dead kmem caches either periodically or on
> vmpressure to shrink and destroy those of them that become empty.
> 
> That is what I had in mind when submitting the patch set titled "kmemcg:
> simplify work-flow":
> 	https://lkml.org/lkml/2014/4/18/42
> 
> Pros: easy to implement
> Cons: instead of being destroyed asap, dead caches will hang around
> until some point in time or, even worse, memory pressure condition.

This would continue to pin css after cgroup destruction indefinitely,
or at least for an arbitrary amount of time.  To reduce the waste from
such pinning, we currently have to tear down other parts of the memcg
optimistically from css_offline(), which is called before the last
reference disappears and out of hierarchy order, making the teardown
unnecessarily complicated and error prone.

So I think "easy to implement" is misleading.  What we really care
about is "easy to maintain", and this basically excludes any async
schemes.

As far as synchronous cache teardown goes, I think everything that
introduces object accounting into the slab hotpaths will also be a
tough sell.

Personally, I would prefer the cache merging, where remaining child
slab pages are moved to the parent's cache on cgroup destruction.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
