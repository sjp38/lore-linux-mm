Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 40CFD6B0081
	for <linux-mm@kvack.org>; Wed,  2 Jan 2013 11:32:42 -0500 (EST)
Date: Wed, 2 Jan 2013 16:32:40 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 0/3] retry slab allocation after first failure
In-Reply-To: <1355925702-7537-1-git-send-email-glommer@parallels.com>
Message-ID: <0000013bfc1b8640-1708725f-b988-408a-bbb5-d3f95cb42535-000000@email.amazonses.com>
References: <1355925702-7537-1-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Dave Shrinnker <david@fromorbit.com>, Michal Hocko <mhocko@suse.cz>, kamezawa.hiroyu@jp.fujitsu.com, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>

On Wed, 19 Dec 2012, Glauber Costa wrote:

> The reclaim round, despite not being able to free a whole page, may very well
> have been able to free objects spread around multiple pages. Which means that
> at this point, a new object allocation would likely succeed.

I think this is reasonable but the approach is too intrusive on the hot
paths. Page allocation from the slab allocators happens outside of the hot
allocation and free paths.

slub has call to slab_out_of_memory in __slab_alloc which may be a
reasonable point to insert the logic.

slab has this whole fallback_alloc function to deal with short on memory
situations. Insert the additional logic there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
