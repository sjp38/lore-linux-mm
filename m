Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 3CE336B002C
	for <linux-mm@kvack.org>; Wed,  1 Feb 2012 03:59:40 -0500 (EST)
Message-ID: <4F28FEB6.4040905@parallels.com>
Date: Wed, 1 Feb 2012 12:58:30 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [LSF/MM TOPIC] memcg topics.
References: <20120201095556.812db19c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120201095556.812db19c.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Mel Gorman <mgorman@suse.de>

On 02/01/2012 04:55 AM, KAMEZAWA Hiroyuki wrote:
> Hi, I guess we have some topics on memory cgroups.
>
> 1-4 : someone has an implemanation
> 5   : no implemenation.
>
> 1. page_cgroup diet
>     memory cgroup uses 'struct page_cgroup', it was 40bytes per 4096bytes in past.
>     Johannes removed ->page and ->lru from page_cgroup, then now,
>     sizeof(page_cgroup)==16. Now, I'm working on removing ->flags to make
>     sizeof(page_cgroup)==8.
>
>     Then, finally, page_cgroup can be moved into struct page on 64bit system ?
>     How 32bit system will be ?
>
> 2. memory reclaim
>     Johannes, Michal and Ying, ant others, are now working on memory reclaim problem
>     with new LRU. Under it, LRU is per-memcg-per-zone.
>     Following topics are discussed now.
>
>     - simplificaiton/re-implemenation of softlimit
>     - isolation of workload (by softlimit)
>     - when we should stop memory reclaim, especially under direct-reclaim.
>       (Now, we scan all zonelist..)
>
> 3. per-memcg-lru-zone-lru-lock
>     I hear Hugh Dickins have some patches and are testing it.
>     It will be good to discuss this if it has Pros. and Cons or implemenation issue.
>
> 4. dirty ratio
>     In the last year, patches were posted but not merged. I'd like to hear
>     works on this area.
>
> 5. accounting other than user pages.
>     Last year, tcp buffer limiting was added to "memcg".
I was about to correct you about "last year", when suddenly my mind went 
"oh god, this is 2012!"

>     If someone has other plans, I'd like to hear.
>     I myself don't think 'generic kernel memory limitation' is a good thing....
>     admins can't predict performance.
>
>     Can we make accounting on dentry/inode into memcg and call shrink_slab() ?
>     But I guess per-zone-shrink-slab() should go 1st...

Well, I have work in progress to continue that. There are a couple of 
slabs I'd like to track. I am convinced that a generic framework is a 
good thing, but indeed, I am still not sure if a generic interface is.

The advantage of keeping it unified, is that it prevents the number of 
knobs from exploding. For us, this is not that much of a problem, 
because there are only a couple of ones we are interested in. dcache and 
inode is an example of that: when we sent out some proposals (that 
didn't use memcg), some people wanted to see inode, not dcache being 
tracked. We disagreed. But yet, the truth remains that only *one* of 
them needs to be tracked, because they live in a close relation to each 
other. So if we manage to find a couple of slabs that are key to that, 
we can limit only those.

Well, that was food for thought only. I do think this is a nice topic.

Also, there is no serious implementation for that, as you mentioned, but 
a series of patches were sent out for appreciation last year. So there 
is at least a basis for starting

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
