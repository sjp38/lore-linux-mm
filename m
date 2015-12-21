Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id B7CC46B0003
	for <linux-mm@kvack.org>; Mon, 21 Dec 2015 07:18:22 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id p187so66908357wmp.0
        for <linux-mm@kvack.org>; Mon, 21 Dec 2015 04:18:22 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w124si3557990wmw.53.2015.12.21.04.18.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 21 Dec 2015 04:18:21 -0800 (PST)
Subject: Re: [PATCH 1/3] tree wide: get rid of __GFP_REPEAT for order-0
 allocations part I
References: <1446740160-29094-1-git-send-email-mhocko@kernel.org>
 <1446740160-29094-2-git-send-email-mhocko@kernel.org>
 <5641185F.9020104@suse.cz> <20151110125101.GA8440@dhcp22.suse.cz>
 <564C8801.2090202@suse.cz> <20151127093807.GD2493@dhcp22.suse.cz>
 <565C8129.80302@suse.cz> <20151201162718.GA4662@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5677EE0B.7090606@suse.cz>
Date: Mon, 21 Dec 2015 13:18:19 +0100
MIME-Version: 1.0
In-Reply-To: <20151201162718.GA4662@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On 12/01/2015 05:27 PM, Michal Hocko wrote:
> On Mon 30-11-15 18:02:33, Vlastimil Babka wrote:
> [...]
>> So the issue I see with simply renaming __GFP_REPEAT to __GFP_BEST_AFFORD
>> and making it possible to fail for low orders, is that it will conflate the
>> new failure possibility with the existing "try harder to reclaim before
>> oom". As I mentioned before, "trying harder" could be also extended to mean
>> something for compaction, but that would further muddle the meaning of the
>> flag. Maybe the cleanest solution would be to have separate flags for
>> "possible to fail" (let's say __GFP_MAYFAIL for now) and "try harder" (e.g.
>> __GFP_TRY_HARDER)? And introduce two new higher-level "flags" of a GFP_*
>> kind, that callers would use instead of GFP_KERNEL, where one would mean
>> GFP_KERNEL|__GFP_MAYFAIL and the other
>> GFP_KERNEL|__GFP_TRY_HARDER|__GFP_MAYFAIL.
>
> I will think about that but this sounds quite confusing to me. All the
> allocations on behalf of a user process are MAYFAIL basically (e.g. the
> oom victim failure case) unless they are explicitly __GFP_NOFAIL. It
> also sounds that ~__GFP_NOFAIL should imply MAYFAIL automatically.
> __GFP_BEST_EFFORT on the other hand clearly states that the allocator
> should try its best but it can fail. The way how it achieves that is
> an implementation detail and users do not have to care. In your above
> hierarchy of QoS we have:
> - no reclaim ~__GFP_DIRECT_RECLAIM - optimistic allocation with a
>    fallback (e.g. smaller allocation request)
> - no destructive reclaim __GFP_NORETRY - allocation with a more
>    expensive fallback (e.g. vmalloc)

Maybe it would be less confusing / more consistent if __GFP_NORETRY was 
renamed to __GFP_LOW_EFFORT ?

> - all reclaim types but only fail if there is no good hope for success
>    __GFP_BEST_EFFORT (fail rather than invoke the OOM killer second time)
>    user allocations
> - no failure allowed __GFP_NOFAIL - failure mode is not acceptable
>
> we can keep the current implicit "low order imply __GFP_NOFAIL" behavior
> of the GFP_KERNEL and still offer users to use __GFP_BEST_EFFORT as a
> way to override it.
>
>> The second thing to consider, is __GFP_NORETRY useful? The latency savings
>> are quite vague. Maybe we could just remove this flag to make space for
>> __GFP_MAYFAIL?
>
> There are users who would like to see some reclaim but rather fail then
> see the OOM killer. I assume there are also users who can handle the
> failure but the OOM killer is not a big deal for them. I think that
> GFP_USER is an example of the later.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
