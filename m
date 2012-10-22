Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 16B306B0069
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 03:37:44 -0400 (EDT)
Message-ID: <5084F7B2.7000105@parallels.com>
Date: Mon, 22 Oct 2012 11:37:22 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 14/18] memcg/sl[au]b: shrink dead caches
References: <1350656442-1523-1-git-send-email-glommer@parallels.com> <1350656442-1523-15-git-send-email-glommer@parallels.com> <0000013a7a9144d1-de184c46-2a7d-4e6c-8606-927cc1f48969-000000@email.amazonses.com>
In-Reply-To: <0000013a7a9144d1-de184c46-2a7d-4e6c-8606-927cc1f48969-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, devel@openvz.org, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

On 10/19/2012 11:47 PM, Christoph Lameter wrote:
> On Fri, 19 Oct 2012, Glauber Costa wrote:
> 
>> An unlikely branch is used to make sure this case does not affect
>> performance in the usual slab_free path.
>>
>> The slab allocator has a time based reaper that would eventually get rid
>> of the objects, but we can also call it explicitly, since dead caches
>> are not a likely event.
> 
> This is also something that could be done from slab_common since all
> allocators have kmem_cache_shrink and kmem_cache_shrink can be used to
> drain the caches and free up empty slab pages.
> 

The changelog needs to be updated. I updated the code, forgot the
changelog =(

I am actually now following Tejun's last suggestion, and no longer using
my old verify_dead code.

So I am basically calling shrink_slab every once in a while until the
cache disappears.

The only change I still need in the allocators is to count the amount of
pages they have, so I can differentiate between need-to-shrink and
need-to-destroy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
