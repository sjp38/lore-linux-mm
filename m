Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 5363A6B0032
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 02:35:29 -0400 (EDT)
Date: Fri, 23 Aug 2013 15:35:39 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 00/16] slab: overload struct slab over struct page to
 reduce memory usage
Message-ID: <20130823063539.GD22605@lge.com>
References: <1377161065-30552-1-git-send-email-iamjoonsoo.kim@lge.com>
 <00000140a6ec66e5-a4d245c0-76b6-4a8b-9cf0-d941ca9e08b0-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <00000140a6ec66e5-a4d245c0-76b6-4a8b-9cf0-d941ca9e08b0-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Aug 22, 2013 at 04:47:25PM +0000, Christoph Lameter wrote:
> On Thu, 22 Aug 2013, Joonsoo Kim wrote:
> 
> > And this patchset change a management method of free objects of a slab.
> > Current free objects management method of the slab is weird, because
> > it touch random position of the array of kmem_bufctl_t when we try to
> > get free object. See following example.
> 
> The ordering is intentional so that the most cache hot objects are removed
> first.

Yes, I know.

> 
> > To get free objects, we access this array with following pattern.
> > 6 -> 3 -> 7 -> 2 -> 5 -> 4 -> 0 -> 1 -> END
> 
> Because that is the inverse order of the objects being freed.
> 
> The cache hot effect may not be that significant since per cpu and per
> node queues have been aded on top. So maybe we do not be so cache aware
> anymore when actually touching struct slab.

I don't change the ordering, I just change how we store that order to
reduce cache footprint. We can simply implement this order via stack.

Assume indexes of free order are 1 -> 0 -> 4.
Currently, this order is stored in very complex way like below.

struct slab's free = 4
kmem_bufctl_t array: 1 END ACTIVE ACTIVE 0

If we allocate one object, we access slab's free and index 4 of
kmem_bufctl_t array.

struct slab's free = 0
kmem_bufctl_t array: 1 END ACTIVE ACTIVE ACTIVE
<we get object at index 4>

And then,

struct slab's free = 1
kmem_bufctl_t array: ACTIVE END ACTIVE ACTIVE ACTIVE
<we get object at index 0>

And then,

struct slab's free = END
kmem_bufctl_t array: ACTIVE ACTIVE ACTIVE ACTIVE ACTIVE
<we get object at index 0>

Following is newly implementation (stack) in same situation.

struct slab's free = 0
kmem_bufctl_t array: 4 0 1

To get an one object,

struct slab's free = 1
kmem_bufctl_t array: dummy 0 1
<we get object at index 4>

And then,

struct slab's free = 2
kmem_bufctl_t array: dummy dummy 1
<we get object at index 0>

struct slab's free = 3
kmem_bufctl_t array: dummy dummy dummy
<we get object at index 1>

The order of returned object is same as previous algorithm.
However this algorithm sequentially accesses kmem_bufctl_t array,
instead of randomly access. This is an advantage of this patch.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
