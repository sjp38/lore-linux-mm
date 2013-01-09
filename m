Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 523666B005A
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 10:39:00 -0500 (EST)
Date: Wed, 9 Jan 2013 15:38:59 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 0/3] retry slab allocation after first failure
In-Reply-To: <50ED44D1.3080803@parallels.com>
Message-ID: <0000013c1ff6e1fc-28ab821a-de1f-4af0-801e-49ae45fff4f6-000000@email.amazonses.com>
References: <1355925702-7537-1-git-send-email-glommer@parallels.com> <0000013bfc1b8640-1708725f-b988-408a-bbb5-d3f95cb42535-000000@email.amazonses.com> <50ED44D1.3080803@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Dave Shrinnker <david@fromorbit.com>, Michal Hocko <mhocko@suse.cz>, kamezawa.hiroyu@jp.fujitsu.com, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>

On Wed, 9 Jan 2013, Glauber Costa wrote:

> I disagree with you, because I don't see the trade-off as being so
> simple, for two main reasons.

The problem is that many people do this kind of tradeoff every year and so
the additional logic accumulates in the hot paths which leads to gradual
decay of allocator performance. It is possible to put
this into the slow path for this round and so lets do it.

> First, the logic of retrying is largely independent of the allocator,
> and doing it in this level of abstraction allow us to move it to common
> code as soon as we can. All the allocation decisions can be kept
> internal to the underlying allocator, and we act only on the very high
> level.

Right now you have separate patches for the allocators. There is also a
way to abstract this in a different way: Both allocators have special
functions to deal with OOM conditions. This could be put into
slab_common.c too to have unified reporting of OOM conditionns and unified
fallback handling.

> I can measure it as much as you want, but I can pretty much guarantee
> you that the cost is near zero. The hot path, which is, when the

I hear the same argument every time around.

> Now, I agree with you, because I now see I missed one detail: those
> functions are all marked as __always_inline. Which means that we will
> double the code size in every allocation, for every single case. So this
> is bad. But it is also very easy to fix: We can have a noinline function
> that calls the allocator function, and we call that function instead -
> with proper comments.

There is a reason these functions are inline because the inlining allows
code generation for special cases (like !NUMA) to have optimized code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
