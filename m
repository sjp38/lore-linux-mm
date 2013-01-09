Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 05CA86B006C
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 13:59:48 -0500 (EST)
Date: Wed, 9 Jan 2013 18:59:47 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 0/3] retry slab allocation after first failure
In-Reply-To: <50ED93E7.5030704@parallels.com>
Message-ID: <0000013c20aebaf3-af9edf37-af11-4a9f-87ae-ba694bcfd236-000000@email.amazonses.com>
References: <1355925702-7537-1-git-send-email-glommer@parallels.com> <0000013bfc1b8640-1708725f-b988-408a-bbb5-d3f95cb42535-000000@email.amazonses.com> <50ED44D1.3080803@parallels.com> <0000013c1ff6e1fc-28ab821a-de1f-4af0-801e-49ae45fff4f6-000000@email.amazonses.com>
 <50ED93E7.5030704@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Dave Shrinnker <david@fromorbit.com>, Michal Hocko <mhocko@suse.cz>, kamezawa.hiroyu@jp.fujitsu.com, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>

On Wed, 9 Jan 2013, Glauber Costa wrote:

> I will certainly look into that. But I still fear that regardless of
> what we do here, the logic is still "retry the whole thing again". We
> already know there is no free page, and without inspecting the internals
> of the allocator it is hard to know where to start looking - therefore,
> we need to retry from the start.

The slow paths functions in the allocator can performa the retry of
"the whole thing".

slab's fallback alloc does precisely that. What you need to do there is to
just go back to the retry: label if the attempt to grow the slab fails.

slub's __slab_alloc() can use a similar approach by looping back to the
redo: label.

Either one is trivial to implement.

> If it fails again, we will recurse to the same oom state. This means we
> need to keep track of the state, at least, in which retry we are. If I
> can keep it local, fine, I will argue no further. But if this state
> needs to spread throughout the other paths, I think we have a lot more
> to lose.

Adding another state variable is not that intrusive in fallback_alloc or
__slab_alloc.

Alternatively we could extract the functionality to check the current
queues from the allocator and call them twice from the slow paths.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
