Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 471426B0369
	for <linux-mm@kvack.org>; Tue, 20 Dec 2016 22:07:27 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id q10so534088726pgq.7
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 19:07:27 -0800 (PST)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id 62si24738052ply.256.2016.12.20.19.07.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Dec 2016 19:07:26 -0800 (PST)
Received: by mail-pg0-x243.google.com with SMTP id g1so12675323pgn.0
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 19:07:26 -0800 (PST)
Subject: Re: [PATCH RFC 1/1] mm, page_alloc: fix incorrect zone_statistics
 data
References: <1481522347-20393-1-git-send-email-hejianet@gmail.com>
 <1481522347-20393-2-git-send-email-hejianet@gmail.com>
 <20161220123121.e4wgkxm2txdoxogo@techsingularity.net>
From: hejianet <hejianet@gmail.com>
Message-ID: <8cb130a7-3753-7f14-632b-11d53bf2272d@gmail.com>
Date: Wed, 21 Dec 2016 11:07:12 +0800
MIME-Version: 1.0
In-Reply-To: <20161220123121.e4wgkxm2txdoxogo@techsingularity.net>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>



On 20/12/2016 8:31 PM, Mel Gorman wrote:
> On Mon, Dec 12, 2016 at 01:59:07PM +0800, Jia He wrote:
>> In commit b9f00e147f27 ("mm, page_alloc: reduce branches in
>> zone_statistics"), it reconstructed codes to reduce the branch miss rate.
>> Compared with the original logic, it assumed if !(flag & __GFP_OTHER_NODE)
>>   z->node would not be equal to preferred_zone->node. That seems to be
>> incorrect.
>>
>> Fixes: commit b9f00e147f27 ("mm, page_alloc: reduce branches in
>> zone_statistics")
>>
>> Signed-off-by: Jia He <hejianet@gmail.com>
> This is slightly curious. It appear it would only occur if a process was
> running on a node that was outside the memory policy. Can you confirm
> that is the case?
Yes, here is what I caught:

dumpstack() is triggered when z->node(5) == preferred_zone->node(5) and z->node != numa_node_id(4)
without flag GET_OTHER_NODE

It is not a rare case. I saw hundreds of such cases when kernel boots up
[c000000cdcaef440] [c0000000002e88cc] cache_grow_begin+0xcc/0x500
[c000000cdcaef6f0] [c0000000002ecb44] do_tune_cpucache+0x64/0x100
[c000000cdcaef750] [c0000000002ecc7c] enable_cpucache+0x9c/0x180
[c000000cdcaef7d0] [c0000000002ed01c] __kmem_cache_create+0x1ec/00x2c0
[c000000cdcaef820] [c000000000291c98] create_cache+0xb8/0x240
[c000000cdcaef890] [c000000000291fa8] kmem_cache_create+0x188/0x2290
[c000000cdcaef950] [d000000011dc5c70] ext4_mb_init+0x3c0/0x5e0 [eext4]
[c000000cdcaef9f0] [d000000011daaedc] ext4_fill_super+0x266c/0x33390 [ext4]
[c000000cdcaefb30] [c000000000328b8c] mount_bdev+0x22c/0x260
[c000000cdcaefbd0] [d000000011da1fa8] ext4_mount+0x48/0x60 [ext4]
[c000000cdcaefc10] [c00000000032a11c] mount_fs+0x8c/0x230
[c000000cdcaefcb0] [c000000000351f98] vfs_kern_mount+0x78/0x180
[c000000cdcaefd00] [c000000000356d68] do_mount+0x258/0xea0
[c000000cdcaefde0] [c000000000357da0] SyS_mount+0xa0/0x110
[c000000cdcaefe30] [c00000000000bd84] system_call+0x38/0xe0


> If so, your patch is a a semantic curiousity because it's actually
> impossible for a NUMA allocation to be local and the definition of "HIT"
> is fuzzy enough to be useless.
>
> I won't object to the patch but it makes me trust "hit" even less than I
> already do for any analysis.
>
> Note that after this mail that I'll be unavailable by mail until early
> new years.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
