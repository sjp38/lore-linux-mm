Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id C547F6B0256
	for <linux-mm@kvack.org>; Mon, 30 Nov 2015 12:02:36 -0500 (EST)
Received: by wmuu63 with SMTP id u63so138502919wmu.0
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 09:02:36 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 77si30024052wme.95.2015.11.30.09.02.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 30 Nov 2015 09:02:35 -0800 (PST)
Subject: Re: [PATCH 1/3] tree wide: get rid of __GFP_REPEAT for order-0
 allocations part I
References: <1446740160-29094-1-git-send-email-mhocko@kernel.org>
 <1446740160-29094-2-git-send-email-mhocko@kernel.org>
 <5641185F.9020104@suse.cz> <20151110125101.GA8440@dhcp22.suse.cz>
 <564C8801.2090202@suse.cz> <20151127093807.GD2493@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <565C8129.80302@suse.cz>
Date: Mon, 30 Nov 2015 18:02:33 +0100
MIME-Version: 1.0
In-Reply-To: <20151127093807.GD2493@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On 11/27/2015 10:38 AM, Michal Hocko wrote:
> On Wed 18-11-15 15:15:29, Vlastimil Babka wrote:
>
> I am not sure whether we found any conclusion here. Are there any strong
> arguments against patch 1? I think that should be relatively
> non-controversial.

Agreed.

> What about patch 2? I think it should be ok as well
> as we are basically removing the flag which has never had any effect.

Right.

> I would like to proceed with this further by going through remaining users.
> Most of them depend on a variable size and I am not familiar with the
> code so I will talk to maintainer to find out reasoning behind using the
> flag. Once we have reasonable number of them I would like to go on and
> rename the flag to __GFP_BEST_AFFORD and make it independent on the
> order. It would still trigger OOM killer where applicable but wouldn't
> retry endlessly.
>
> Does this sound like a reasonable plan?

I think we should consider all the related flags together before 
starting renaming them. So IIUC the current state is:

~__GFP_DIRECT_RECLAIM - no reclaim/compaction, fails regardless of 
order; good for allocations that prefer their fallback to the latency of 
reclaim/compaction

__GFP_NORETRY - only one reclaim and two compaction attempts, then fails 
regardless of order; some tradeoff between allocation latency and fallback?

__GFP_REPEAT - for costly orders, tries harder to reclaim before oom, 
otherwise no difference - doesn't fail for non-costly orders, although 
comment says it could.

__GFP_NOFAIL - cannot fail

So the issue I see with simply renaming __GFP_REPEAT to 
__GFP_BEST_AFFORD and making it possible to fail for low orders, is that 
it will conflate the new failure possibility with the existing "try 
harder to reclaim before oom". As I mentioned before, "trying harder" 
could be also extended to mean something for compaction, but that would 
further muddle the meaning of the flag. Maybe the cleanest solution 
would be to have separate flags for "possible to fail" (let's say 
__GFP_MAYFAIL for now) and "try harder" (e.g. __GFP_TRY_HARDER)? And 
introduce two new higher-level "flags" of a GFP_* kind, that callers 
would use instead of GFP_KERNEL, where one would mean 
GFP_KERNEL|__GFP_MAYFAIL and the other 
GFP_KERNEL|__GFP_TRY_HARDER|__GFP_MAYFAIL.

The second thing to consider, is __GFP_NORETRY useful? The latency 
savings are quite vague. Maybe we could just remove this flag to make 
space for __GFP_MAYFAIL?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
