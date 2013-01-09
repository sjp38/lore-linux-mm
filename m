Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id E6A2A6B0062
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 05:26:10 -0500 (EST)
Message-ID: <50ED45AA.4010506@parallels.com>
Date: Wed, 9 Jan 2013 14:25:46 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] sl[auo]b: retry allocation once in case of failure.
References: <1355925702-7537-1-git-send-email-glommer@parallels.com> <1355925702-7537-4-git-send-email-glommer@parallels.com> <0000013bfc071798-e09146e7-8c3c-41be-a700-1676fd418e59-000000@email.amazonses.com>
In-Reply-To: <0000013bfc071798-e09146e7-8c3c-41be-a700-1676fd418e59-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Dave Shrinnker <david@fromorbit.com>, Michal Hocko <mhocko@suse.cz>, kamezawa.hiroyu@jp.fujitsu.com, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On 01/02/2013 08:10 PM, Christoph Lameter wrote:
> On Wed, 19 Dec 2012, Glauber Costa wrote:
> 
>> When we are out of space in the caches, we will try to allocate a new
>> page.  If we still fail, the page allocator will try to free pages
>> through direct reclaim. Which means that if an object allocation failed
>> we can be sure that no new pages could be given to us, even though
>> direct reclaim was likely invoked.
> 
> Well this hits the hot allocation path with lots of additional checks
> that also require the touching of more cachelines.
> 
> How much impact will this have?
> 

speed: Hot path is one fast branch (with an almost-always correct hint).
slow path is full retry.

About the flag checking, I must say that they are already in the slow
path. The hot path is allocation succeeding. This is the first condition
to be tested, and we will bail out as soon as we see this value being
true. They can be moved inside a helper noinline function together with
the retry code itself.

size: the branch instruction + a call instruction, if done right (I got
this last part wrong in this set)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
