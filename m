Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 7637182F64
	for <linux-mm@kvack.org>; Thu,  1 Oct 2015 04:39:21 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so17421618wic.1
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 01:39:20 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i3si2427614wib.6.2015.10.01.01.39.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 01 Oct 2015 01:39:19 -0700 (PDT)
Subject: Re: [PATCH 06/10] mm, page_alloc: Rename __GFP_WAIT to __GFP_RECLAIM
References: <1442832762-7247-1-git-send-email-mgorman@techsingularity.net>
 <1442832762-7247-7-git-send-email-mgorman@techsingularity.net>
 <20150928165523.a52facb27c7ff4c29d902b6c@linux-foundation.org>
 <20150929133721.GJ3068@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <560CF134.2060107@suse.cz>
Date: Thu, 1 Oct 2015 10:39:16 +0200
MIME-Version: 1.0
In-Reply-To: <20150929133721.GJ3068@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 09/29/2015 03:37 PM, Mel Gorman wrote:
> mm: page_alloc: Hide some GFP internals and document the bits and flag combinations
>
> Andrew started the following
>
> 	We have quite a history of remote parts of the kernel using
> 	weird/wrong/inexplicable combinations of __GFP_ flags.	I tend
> 	to think that this is because we didn't adequately explain the
> 	interface.
>
> 	And I don't think that gfp.h really improved much in this area as
> 	a result of this patchset.  Could you go through it some time and
> 	decide if we've adequately documented all this stuff?
>
> This patches first moves some GFP flag combinations that are part of the MM
> internals to mm/internal.h. The rest of the patch documents the __GFP_FOO
> bits under various headings and then documents the flag combinations. It
> will not help callers that are brain damaged but the clarity might motivate
> some fixes and avoid future mistakes.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

With some nitpicks below.

> +/*
> + * Reclaim modifiers
> + *
> + * __GFP_IO can start physical IO.
> + *
> + * __GFP_FS can call down to the low-level FS. Avoids the allocator

"Clearing the flag avoids..."? Avoids confusion.

> + *   recursing into the filesystem which might already be holding locks.
> + *
> + * __GFP_DIRECT_RECLAIM indicates that the caller may enter direct reclaim.
> + *   This flag can be cleared to avoid unnecessary delays when a fallback
> + *   option is available.
> + *
> + * __GFP_KSWAPD_RECLAIM indicates that the caller wants kswapd when the low

s/wants/wakes/? or "wants kswapd woken up"?

> + * GFP_USER is for userspace allocations that also need to be directly
> + *   accessibly by the kernel or hardware. It is typically used by hardware
> + *   for buffers that are mapped to userspace (e.g. graphics) that hardware
> + *   still must DMA to. cpuset limits are enforced for these allocations.
> + *
> + * GFP_HIGHUSER is for userspace allocations that may be mapped to userspace,
> + *   do not need to be directly accessible by the kernel but that cannot
> + *   move once in use. An example may be a hardware allocation that maps
> + *   data directly into userspace but has no addressing limitations.
> + *
> + * GFP_DMA exists for historical reasons and should be avoided where possible.
> + *   The flags indicates that the caller requires that the lowest zone be
> + *   used (ZONE_DMA or 16M on x86-64). Ideally, this would be removed but
> + *   it would require careful auditing as some users really require it and
> + *   others use the flag to avoid lowmem reserves in ZONE_DMA and treat the
> + *   lowest zone as a type of emergency reserve.
> + *
> + * GFP_DMA32 is similar to GFP_DMA except that the caller requires a 32-bit
> + *   address.
> + *
> + * GFP_HIGHUSER_MOVABLE is for userspace allocations that the kernel does not
> + *   need direct access to but can use kmap() when access is required. They
> + *   are expected to be movable via page reclaim or page migration. Typically,
> + *   pages on the LRU would also be allocated with GFP_HIGHUSER_MOVABLE.

Move GFP_HIGHUSER_MOVABLE right below GFP_HIGHUSER?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
