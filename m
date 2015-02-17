Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 53AB56B0032
	for <linux-mm@kvack.org>; Tue, 17 Feb 2015 11:03:54 -0500 (EST)
Received: by mail-ig0-f170.google.com with SMTP id l13so41401261iga.1
        for <linux-mm@kvack.org>; Tue, 17 Feb 2015 08:03:54 -0800 (PST)
Received: from resqmta-po-11v.sys.comcast.net ([2001:558:fe16:19:250:56ff:feb0:66b3])
        by mx.google.com with ESMTPS id y137si705144iod.20.2015.02.17.08.03.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 17 Feb 2015 08:03:53 -0800 (PST)
Date: Tue, 17 Feb 2015 10:03:51 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/3] Slab infrastructure for array operations
In-Reply-To: <20150217051541.GA15413@js1304-P5Q-DELUXE>
Message-ID: <alpine.DEB.2.11.1502170959130.4996@gentwo.org>
References: <20150210194804.288708936@linux.com> <20150210194811.787556326@linux.com> <alpine.DEB.2.10.1502101542030.15535@chino.kir.corp.google.com> <alpine.DEB.2.11.1502111243380.3887@gentwo.org> <alpine.DEB.2.10.1502111213151.16711@chino.kir.corp.google.com>
 <20150213023534.GA6592@js1304-P5Q-DELUXE> <alpine.DEB.2.11.1502130941360.9442@gentwo.org> <20150217051541.GA15413@js1304-P5Q-DELUXE>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: David Rientjes <rientjes@google.com>, akpm@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo@lge.com, Jesper Dangaard Brouer <brouer@redhat.com>

On Tue, 17 Feb 2015, Joonsoo Kim wrote:

> Hmm...so far, SLAB focus on temporal locality rather than spatial locality
> as you know. Why SLAB need to consider spatial locality first in this
> kmem_cache_alloc_array() case?

Well we are talking about a large number of objects. And going around
randomly in memory is going to cause a lot of TLB misses. Spatial locality
increases the effectiveness of the processing of these objects.

> And, although we use partial list first, we can't reduce
> fragmentation as much as SLUB. Local cache may keep some free objects
> of the partial slab so just exhausting free objects of partial slab doesn't
> means that there is no free object left. For SLUB, exhausting free
> objects of partial slab means there is no free object left.

SLUB will still have the per cpu objects in the per cpu page and te per
cpu slab pages.

> If we allocate objects from local cache as much as possible, we can
> keep temporal locality and return objects as fast as possible since
> returing objects from local cache just needs memcpy from local array
> cache to destination array.

I thought the point was that this is used to allocate very large amounts
of objects. The hotness is not that big of an issue.

> As David said, there is no implementation for SLAB yet and we have
> different opinion about implementation for SLAB. It's better
> to delay detailed implementation of kmem_cache_alloc_array()
> until implementation for SLAB is agreed. Before it, calling
> __kmem_cache_alloc_array() in kmem_cache_alloc_array() is sufficient
> to provide functionality.

Its not that detailed. It is just layin out the basic strategy for the
array allocs. First go to the partial lists to decrease fragmentation.
Then bypass the allocator layers completely and go direct to the page
allocator if all objects that the page will accomodate can be put into
the array. Lastly use the cpu hot objects to fill in the leftover (which
would in any case be less than the objects in a page).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
