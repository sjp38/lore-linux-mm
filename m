Message-ID: <3D97E737.80405@colorfullife.com>
Date: Mon, 30 Sep 2002 07:55:03 +0200
From: Manfred Spraul <manfred@colorfullife.com>
MIME-Version: 1.0
Subject: Re: 2.5.39 kmem_cache bug
References: <20020928201308.GA59189@compsoc.man.ac.uk> <200209291137.48483.tomlins@cam.org> <3D972828.6010807@colorfullife.com> <200209292020.40824.tomlins@cam.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ed Tomlinson wrote:
>
>>The first problem is the per-cpu array draining. It's needed, too many
>>objects can sit in the per-cpu arrays.
>>< 2.5.39, the per-cpu arrays can cause more list operations than no
>>batching, this is something that must be avoided.
>>
>>Do you see an alternative to a timer/callback/hook? What's the simplest
>>approach to ensure that the callback runs on all cpus? I know Redhat has
>>a scalable timer patch, that one would fix the timer to the cpu that
>>called add_timer.
> 
> 
> Maybe.  If we treat the per cpu data as special form of cache we could
> use the shrinker callbacks to track how much we have to trim.  When the value
> exceeds a threshold (set when we setup the callback) we trim.  We could
> do the test in freeing path in slab.   
>
2 problems:
* What if a cache falls completely idle? If there is freeing activity on 
the cache, then the cache is active, thus there is no need to flush.
* I don't think it's a good idea to add logic into the path that's 
executed for every kfree/kmem_cache_free. A timer might not be very 
pretty, but is definitively more efficient.

> The patch add shrinker callbacks was posted to linux-mm Sunday and
> to lkml on Thursday.
> 
I'll read them.
Is it guaranteed that the shrinker callbacks are called on all cpus, or 
could some cpu binding happen?

--
	Manfred

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
