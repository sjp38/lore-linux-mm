Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 37B3F6B0253
	for <linux-mm@kvack.org>; Tue,  1 Dec 2015 11:27:21 -0500 (EST)
Received: by wmww144 with SMTP id w144so180302710wmw.1
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 08:27:20 -0800 (PST)
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com. [74.125.82.54])
        by mx.google.com with ESMTPS id n16si74650588wjw.236.2015.12.01.08.27.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Dec 2015 08:27:19 -0800 (PST)
Received: by wmec201 with SMTP id c201so21341825wme.1
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 08:27:19 -0800 (PST)
Date: Tue, 1 Dec 2015 17:27:18 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3] tree wide: get rid of __GFP_REPEAT for order-0
 allocations part I
Message-ID: <20151201162718.GA4662@dhcp22.suse.cz>
References: <1446740160-29094-1-git-send-email-mhocko@kernel.org>
 <1446740160-29094-2-git-send-email-mhocko@kernel.org>
 <5641185F.9020104@suse.cz>
 <20151110125101.GA8440@dhcp22.suse.cz>
 <564C8801.2090202@suse.cz>
 <20151127093807.GD2493@dhcp22.suse.cz>
 <565C8129.80302@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <565C8129.80302@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Mon 30-11-15 18:02:33, Vlastimil Babka wrote:
[...]
> I think we should consider all the related flags together before starting
> renaming them. So IIUC the current state is:
> 
> ~__GFP_DIRECT_RECLAIM - no reclaim/compaction, fails regardless of order;
> good for allocations that prefer their fallback to the latency of
> reclaim/compaction
> 
> __GFP_NORETRY - only one reclaim and two compaction attempts, then fails
> regardless of order; some tradeoff between allocation latency and fallback?

Also doesn't invoke OOM killer.

> __GFP_REPEAT - for costly orders, tries harder to reclaim before oom,
> otherwise no difference - doesn't fail for non-costly orders, although
> comment says it could.
> 
> __GFP_NOFAIL - cannot fail
> 
> So the issue I see with simply renaming __GFP_REPEAT to __GFP_BEST_AFFORD
> and making it possible to fail for low orders, is that it will conflate the
> new failure possibility with the existing "try harder to reclaim before
> oom". As I mentioned before, "trying harder" could be also extended to mean
> something for compaction, but that would further muddle the meaning of the
> flag. Maybe the cleanest solution would be to have separate flags for
> "possible to fail" (let's say __GFP_MAYFAIL for now) and "try harder" (e.g.
> __GFP_TRY_HARDER)? And introduce two new higher-level "flags" of a GFP_*
> kind, that callers would use instead of GFP_KERNEL, where one would mean
> GFP_KERNEL|__GFP_MAYFAIL and the other
> GFP_KERNEL|__GFP_TRY_HARDER|__GFP_MAYFAIL.

I will think about that but this sounds quite confusing to me. All the
allocations on behalf of a user process are MAYFAIL basically (e.g. the
oom victim failure case) unless they are explicitly __GFP_NOFAIL. It
also sounds that ~__GFP_NOFAIL should imply MAYFAIL automatically.
__GFP_BEST_EFFORT on the other hand clearly states that the allocator
should try its best but it can fail. The way how it achieves that is
an implementation detail and users do not have to care. In your above
hierarchy of QoS we have:
- no reclaim ~__GFP_DIRECT_RECLAIM - optimistic allocation with a
  fallback (e.g. smaller allocation request)
- no destructive reclaim __GFP_NORETRY - allocation with a more
  expensive fallback (e.g. vmalloc)
- all reclaim types but only fail if there is no good hope for success
  __GFP_BEST_EFFORT (fail rather than invoke the OOM killer second time)
  user allocations
- no failure allowed __GFP_NOFAIL - failure mode is not acceptable

we can keep the current implicit "low order imply __GFP_NOFAIL" behavior
of the GFP_KERNEL and still offer users to use __GFP_BEST_EFFORT as a
way to override it.

> The second thing to consider, is __GFP_NORETRY useful? The latency savings
> are quite vague. Maybe we could just remove this flag to make space for
> __GFP_MAYFAIL?

There are users who would like to see some reclaim but rather fail then
see the OOM killer. I assume there are also users who can handle the
failure but the OOM killer is not a big deal for them. I think that
GFP_USER is an example of the later.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
