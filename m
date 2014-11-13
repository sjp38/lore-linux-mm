Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id F0D516B00DC
	for <linux-mm@kvack.org>; Thu, 13 Nov 2014 02:04:28 -0500 (EST)
Received: by mail-wi0-f181.google.com with SMTP id n3so7226976wiv.2
        for <linux-mm@kvack.org>; Wed, 12 Nov 2014 23:04:28 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id qc9si30939081wic.3.2014.11.12.23.04.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 12 Nov 2014 23:04:27 -0800 (PST)
Message-ID: <546457F5.4010908@suse.cz>
Date: Thu, 13 Nov 2014 08:04:21 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [Bug 87891] New: kernel BUG at mm/slab.c:2625!
References: <bug-87891-27@https.bugzilla.kernel.org/> <20141111153120.9131c8e1459415afff8645bc@linux-foundation.org>
In-Reply-To: <20141111153120.9131c8e1459415afff8645bc@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Ming Lei <ming.lei@canonical.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Pauli Nieminen <suokkos@gmail.com>, Dave Airlie <airlied@linux.ie>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: bugzilla-daemon@bugzilla.kernel.org, luke-jr+linuxbugs@utopios.org, dri-devel@lists.freedesktop.org, linux-mm@kvack.org

On 11/12/2014 12:31 AM, Andrew Morton wrote:
>
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
>
> On Thu, 06 Nov 2014 17:28:41 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:
>
>> https://bugzilla.kernel.org/show_bug.cgi?id=87891
>>
>>              Bug ID: 87891
>>             Summary: kernel BUG at mm/slab.c:2625!
>>             Product: Memory Management
>>             Version: 2.5
>>      Kernel Version: 3.17.2
>>            Hardware: i386
>>                  OS: Linux
>>                Tree: Mainline
>>              Status: NEW
>>            Severity: blocking
>>            Priority: P1
>>           Component: Slab Allocator
>>            Assignee: akpm@linux-foundation.org
>>            Reporter: luke-jr+linuxbugs@utopios.org
>>          Regression: No
>
> Well this is interesting.
>
>
>> [359782.842112] kernel BUG at mm/slab.c:2625!
>> ...
>> [359782.843008] Call Trace:
>> [359782.843017]  [<ffffffff8115181f>] __kmalloc+0xdf/0x200
>> [359782.843037]  [<ffffffffa0466285>] ? ttm_page_pool_free+0x35/0x180 [ttm]
>> [359782.843060]  [<ffffffffa0466285>] ttm_page_pool_free+0x35/0x180 [ttm]
>> [359782.843084]  [<ffffffffa046674e>] ttm_pool_shrink_scan+0xae/0xd0 [ttm]
>> [359782.843108]  [<ffffffff8111c2fb>] shrink_slab_node+0x12b/0x2e0
>> [359782.843129]  [<ffffffff81127ed4>] ? fragmentation_index+0x14/0x70
>> [359782.843150]  [<ffffffff8110fc3a>] ? zone_watermark_ok+0x1a/0x20
>> [359782.843171]  [<ffffffff8111ceb8>] shrink_slab+0xc8/0x110
>> [359782.843189]  [<ffffffff81120480>] do_try_to_free_pages+0x300/0x410
>> [359782.843210]  [<ffffffff8112084b>] try_to_free_pages+0xbb/0x190
>> [359782.843230]  [<ffffffff81113136>] __alloc_pages_nodemask+0x696/0xa90
>> [359782.843253]  [<ffffffff8115810a>] do_huge_pmd_anonymous_page+0xfa/0x3f0
>> [359782.843278]  [<ffffffff812dffe7>] ? debug_smp_processor_id+0x17/0x20
>> [359782.843300]  [<ffffffff81118dc7>] ? __lru_cache_add+0x57/0xa0
>> [359782.843321]  [<ffffffff811385ce>] handle_mm_fault+0x37e/0xdd0
>
> It went pagefault
>          ->__alloc_pages_nodemask
>            ->shrink_slab
>              ->ttm_pool_shrink_scan
>                ->ttm_page_pool_free
>                  ->kmalloc
>                    ->cache_grow
>                      ->BUG_ON(flags & GFP_SLAB_BUG_MASK);
>
> And I don't really know why - I'm not seeing anything in there which
> can set a GFP flag which is outside GFP_SLAB_BUG_MASK.  However I see
> lots of nits.
>
> Core MM:
>
> __alloc_pages_nodemask() does
>
> 	if (unlikely(!page)) {
> 		/*
> 		 * Runtime PM, block IO and its error handling path
> 		 * can deadlock because I/O on the device might not
> 		 * complete.
> 		 */
> 		gfp_mask = memalloc_noio_flags(gfp_mask);
> 		page = __alloc_pages_slowpath(gfp_mask, order,
> 				zonelist, high_zoneidx, nodemask,
> 				preferred_zone, classzone_idx, migratetype);
> 	}
>
> so it permanently alters the value of incoming arg gfp_mask.  This
> means that the following trace_mm_page_alloc() will print the wrong
> value of gfp_mask, and if we later do the `goto retry_cpuset', we retry
> with a possibly different gfp_mask.  Isn't this a bug?

I think so. I noticed and fixed it in the RFC about reducing 
alloc_pages* parameters [1], but it's buried in patch 2/4 Guess I should 
have made it a separate non-RFC patch. Will do soon hopefully.

Vlastimil


[1] https://lkml.org/lkml/2014/8/6/249

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
