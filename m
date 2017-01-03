Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 05DA06B0261
	for <linux-mm@kvack.org>; Tue,  3 Jan 2017 11:25:08 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id c85so48301879wmi.6
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 08:25:07 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 203si74132908wmg.3.2017.01.03.08.25.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Jan 2017 08:25:06 -0800 (PST)
Subject: Re: [PATCH 0/3 -v3] GFP_NOFAIL cleanups
References: <20161220134904.21023-1-mhocko@kernel.org>
 <20170102154858.GC18048@dhcp22.suse.cz>
 <201701031036.IBE51044.QFLFSOHtFOJVMO@I-love.SAKURA.ne.jp>
 <20170103084211.GB30111@dhcp22.suse.cz>
 <201701032338.EFH69294.VOMSHFLOFOtQFJ@I-love.SAKURA.ne.jp>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <ad1fdd02-04c4-d7e1-776b-1a49302303d9@suse.cz>
Date: Tue, 3 Jan 2017 17:25:02 +0100
MIME-Version: 1.0
In-Reply-To: <201701032338.EFH69294.VOMSHFLOFOtQFJ@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@kernel.org
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, rientjes@google.com, mgorman@suse.de, hillf.zj@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 01/03/2017 03:38 PM, Tetsuo Handa wrote:
> Michal Hocko wrote:
>> On Tue 03-01-17 10:36:31, Tetsuo Handa wrote:
>> [...]
>> > I'm OK with "[PATCH 1/3] mm: consolidate GFP_NOFAIL checks in the allocator
>> > slowpath" given that we describe that we make __GFP_NOFAIL stronger than
>> > __GFP_NORETRY with this patch in the changelog.
>>
>> Again. __GFP_NORETRY | __GFP_NOFAIL is nonsense! I do not really see any
>> reason to describe all the nonsense combinations of gfp flags.
>
> Before [PATCH 1/3]:
>
>   __GFP_NORETRY is used as "Do not invoke the OOM killer. Fail allocation
>   request even if __GFP_NOFAIL is specified if direct reclaim/compaction
>   did not help."
>
>   __GFP_NOFAIL is used as "Never fail allocation request unless __GFP_NORETRY
>   is specified even if direct reclaim/compaction did not help."
>
> After [PATCH 1/3]:
>
>   __GFP_NORETRY is used as "Do not invoke the OOM killer. Fail allocation
>   request unless __GFP_NOFAIL is specified."
>
>   __GFP_NOFAIL is used as "Never fail allocation request even if direct
>   reclaim/compaction did not help. Invoke the OOM killer unless __GFP_NORETRY is
>   specified."
>
> Thus, __GFP_NORETRY | __GFP_NOFAIL perfectly makes sense as
> "Never fail allocation request if direct reclaim/compaction did not help.
> But do not invoke the OOM killer even if direct reclaim/compaction did not help."

It may technically do that, but how exactly is that useful, i.e. "make sense"? 
Patch 2/3 here makes sure that OOM killer is not invoked when the allocation 
context is "limited" and thus OOM might be premature (despite __GFP_NOFAIL).
What's the use case for __GFP_NORETRY | __GFP_NOFAIL ?

>
>>
>> > But I don't think "[PATCH 2/3] mm, oom: do not enfore OOM killer for __GFP_NOFAIL
>> > automatically" is correct. Firstly, we need to confirm
>> >
>> >   "The pre-mature OOM killer is a real issue as reported by Nils Holland"
>> >
>> > in the changelog is still true because we haven't tested with "[PATCH] mm, memcg:
>> > fix the active list aging for lowmem requests when memcg is enabled" applied and
>> > without "[PATCH 2/3] mm, oom: do not enfore OOM killer for __GFP_NOFAIL
>> > automatically" and "[PATCH 3/3] mm: help __GFP_NOFAIL allocations which do not
>> > trigger OOM killer" applied.
>>
>> Yes I have dropped the reference to this report already in my local
>> patch because in this particular case the issue was somewhere else
>> indeed!
>
> OK.
>
>>
>> > Secondly, as you are using __GFP_NORETRY in "[PATCH] mm: introduce kv[mz]alloc
>> > helpers" as a mean to enforce not to invoke the OOM killer
>> >
>> > 	/*
>> > 	 * Make sure that larger requests are not too disruptive - no OOM
>> > 	 * killer and no allocation failure warnings as we have a fallback
>> > 	 */
>> > 	if (size > PAGE_SIZE)
>> > 		kmalloc_flags |= __GFP_NORETRY | __GFP_NOWARN;
>> >
>> > , we can use __GFP_NORETRY as a mean to enforce not to invoke the OOM killer
>> > rather than applying "[PATCH 2/3] mm, oom: do not enfore OOM killer for
>> > __GFP_NOFAIL automatically".
>> >
>
> As I wrote above, __GFP_NORETRY | __GFP_NOFAIL perfectly makes sense.
>
>> > Additionally, although currently there seems to be no
>> > kv[mz]alloc(GFP_KERNEL | __GFP_NOFAIL) users, kvmalloc_node() in
>> > "[PATCH] mm: introduce kv[mz]alloc helpers" will be confused when a
>> > kv[mz]alloc(GFP_KERNEL | __GFP_NOFAIL) user comes in in the future because
>> > "[PATCH 1/3] mm: consolidate GFP_NOFAIL checks in the allocator slowpath" makes
>> > __GFP_NOFAIL stronger than __GFP_NORETRY.
>>
>> Using NOFAIL in kv[mz]alloc simply makes no sense at all. The vmalloc
>> fallback would be simply unreachable!
>
> My intention is shown below.
>
>  void *kvmalloc_node(size_t size, gfp_t flags, int node)
>  {
>  	gfp_t kmalloc_flags = flags;
>  	void *ret;
>
>  	/*
>  	 * vmalloc uses GFP_KERNEL for some internal allocations (e.g page tables)
>  	 * so the given set of flags has to be compatible.
>  	 */
>  	WARN_ON_ONCE((flags & GFP_KERNEL) != GFP_KERNEL);
>
>  	/*
>  	 * Make sure that larger requests are not too disruptive - no OOM
>  	 * killer and no allocation failure warnings as we have a fallback
>  	 */
> -	if (size > PAGE_SIZE)
> +	if (size > PAGE_SIZE) {
>  		kmalloc_flags |= __GFP_NORETRY | __GFP_NOWARN;
> +		kmalloc_flags &= ~__GFP_NOFAIL;

This does make kvmalloc_node more robust against callers that would try to use 
it with __GFP_NOFAIL, but is it a good idea to allow that right now? If there 
are none yet (AFAIK?), we should rather let the existing WARN_ON kick in (which 
won't happen if we strip __GFP_NOFAIL) and discuss a better solution for such 
new future caller.

Also this means the kmalloc() cannot do "__GFP_NORETRY | __GFP_NOFAIL" so I'm 
not sure how it's related with your points above - it's not an example of the 
combination that would show that "it makes perfect sense".

Thanks,
Vlastimil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
