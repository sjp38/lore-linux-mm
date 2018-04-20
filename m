Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id D8C846B0005
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 13:50:29 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id c6-v6so4940563oif.1
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 10:50:29 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id r185-v6si1957082oie.270.2018.04.20.10.50.28
        for <linux-mm@kvack.org>;
        Fri, 20 Apr 2018 10:50:28 -0700 (PDT)
Date: Fri, 20 Apr 2018 18:50:24 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [RFC] mm: kmemleak: replace __GFP_NOFAIL to GFP_NOWAIT in
 gfp_kmemleak_mask
Message-ID: <20180420175023.3c4okuayrcul2bom@armageddon.cambridge.arm.com>
References: <1524243513-29118-1-git-send-email-chuhu@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1524243513-29118-1-git-send-email-chuhu@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chunyu Hu <chuhu@redhat.com>
Cc: mhocko@suse.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dmitry Vyukov <dvyukov@google.com>

On Sat, Apr 21, 2018 at 12:58:33AM +0800, Chunyu Hu wrote:
> __GFP_NORETRY and  __GFP_NOFAIL are combined in gfp_kmemleak_mask now.
> But it's a wrong combination. As __GFP_NOFAIL is blockable, but
> __GFP_NORETY is not blockable, make it self-contradiction.
> 
> __GFP_NOFAIL means 'The VM implementation _must_ retry infinitely'. But
> it's not the real intention, as kmemleak allow alloc failure happen in
> memory pressure, in that case kmemleak just disables itself.

Good point. The __GFP_NOFAIL flag was added by commit d9570ee3bd1d
("kmemleak: allow to coexist with fault injection") to keep kmemleak
usable under fault injection.

> commit 9a67f6488eca ("mm: consolidate GFP_NOFAIL checks in the allocator
> slowpath") documented that what user wants here should use GFP_NOWAIT, and
> the WARN in __alloc_pages_slowpath caught this weird usage.
> 
>  <snip>
>  WARNING: CPU: 3 PID: 64 at mm/page_alloc.c:4261 __alloc_pages_slowpath+0x1cc3/0x2780
[...]
> Replace the __GFP_NOFAIL with GFP_NOWAIT in gfp_kmemleak_mask, __GFP_NORETRY
> and GFP_NOWAIT are in the gfp_kmemleak_mask. So kmemleak object allocaion
> is no blockable and no reclaim, making kmemleak less disruptive to user
> processes in pressure.

It doesn't solve the fault injection problem for kmemleak (unless we
change __should_failslab() somehow, not sure yet). An option would be to
replace __GFP_NORETRY with __GFP_NOFAIL in kmemleak when fault injection
is enabled.

BTW, does the combination of NOWAIT and NORETRY make kmemleak
allocations more likely to fail?

Cc'ing Dmitry as well.

> Signed-off-by: Chunyu Hu <chuhu@redhat.com>
> CC: Michal Hocko <mhocko@suse.com>
> ---
>  mm/kmemleak.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/kmemleak.c b/mm/kmemleak.c
> index 9a085d5..4ea07e4 100644
> --- a/mm/kmemleak.c
> +++ b/mm/kmemleak.c
> @@ -126,7 +126,7 @@
>  /* GFP bitmask for kmemleak internal allocations */
>  #define gfp_kmemleak_mask(gfp)	(((gfp) & (GFP_KERNEL | GFP_ATOMIC)) | \
>  				 __GFP_NORETRY | __GFP_NOMEMALLOC | \
> -				 __GFP_NOWARN | __GFP_NOFAIL)
> +				 __GFP_NOWARN | GFP_NOWAIT)
>  
>  /* scanning area inside a memory block */
>  struct kmemleak_scan_area {
> -- 
> 1.8.3.1
