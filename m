Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id BB6946B0062
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 05:22:13 -0500 (EST)
Message-ID: <50ED44D1.3080803@parallels.com>
Date: Wed, 9 Jan 2013 14:22:09 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] retry slab allocation after first failure
References: <1355925702-7537-1-git-send-email-glommer@parallels.com> <0000013bfc1b8640-1708725f-b988-408a-bbb5-d3f95cb42535-000000@email.amazonses.com>
In-Reply-To: <0000013bfc1b8640-1708725f-b988-408a-bbb5-d3f95cb42535-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Dave Shrinnker <david@fromorbit.com>, Michal
 Hocko <mhocko@suse.cz>, kamezawa.hiroyu@jp.fujitsu.com, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>

Hi,

On 01/02/2013 08:32 PM, Christoph Lameter wrote:
> On Wed, 19 Dec 2012, Glauber Costa wrote:
> 
>> The reclaim round, despite not being able to free a whole page, may very well
>> have been able to free objects spread around multiple pages. Which means that
>> at this point, a new object allocation would likely succeed.
> 
> I think this is reasonable but the approach is too intrusive on the hot
> paths. Page allocation from the slab allocators happens outside of the hot
> allocation and free paths.
> 
> slub has call to slab_out_of_memory in __slab_alloc which may be a
> reasonable point to insert the logic.
> 
> slab has this whole fallback_alloc function to deal with short on memory
> situations. Insert the additional logic there.
> 
I disagree and agree with you at the same time.

I disagree with you, because I don't see the trade-off as being so
simple, for two main reasons.

First, the logic of retrying is largely independent of the allocator,
and doing it in this level of abstraction allow us to move it to common
code as soon as we can. All the allocation decisions can be kept
internal to the underlying allocator, and we act only on the very high
level.

Also, at first sight it looks a bit ugly in the sense that being inwards
the allocator we will necessarily recurse (since the goal is to retry
the whole allocation). We want to keep the retries limited, so we'll
need to do flag passing - if we fail again, we will reach the same retry
code and we have to know that we need to stop. Can it be done? Sure. But
it looks like unnecessarily complicated at best, specially given that I
don't expect the cost of it to be big:

I can measure it as much as you want, but I can pretty much guarantee
you that the cost is near zero. The hot path, which is, when the
allocation succeeds, will load the address, which is guaranteed to be in
the cache, being the value we are returning (or very soon to be, since
someone almost always read the return value anyway). It will then issue
a strongly hinted branch, which unlike normal branches, should not have
any pipeline ill effect at all if we get it right (which we will).

So we are talking about one hot instruction here if the allocation
succeeds. And if it fails, it is no longer a hot path.

Now, I agree with you, because I now see I missed one detail: those
functions are all marked as __always_inline. Which means that we will
double the code size in every allocation, for every single case. So this
is bad. But it is also very easy to fix: We can have a noinline function
that calls the allocator function, and we call that function instead -
with proper comments.

So we are talking here:

hot path with one extra hot instruction executed, which is a hinted
branch with data in cache. Size increased by size of that instruction +
a call instruction that will only be executed in slow paths.

slow path:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
