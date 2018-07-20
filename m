Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id CAC3D6B000D
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 05:39:56 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id i26-v6so4459594edr.4
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 02:39:56 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d3-v6si632020edj.156.2018.07.20.02.39.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jul 2018 02:39:55 -0700 (PDT)
Subject: Re: [PATCH v3 3/7] mm, slab: allocate off-slab freelists as
 reclaimable when appropriate
References: <20180718133620.6205-1-vbabka@suse.cz>
 <20180718133620.6205-4-vbabka@suse.cz>
 <20180719083530.jhugqzkvjnbrddim@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <d164e040-3422-96c7-68e2-7efdf8818874@suse.cz>
Date: Fri, 20 Jul 2018 11:37:34 +0200
MIME-Version: 1.0
In-Reply-To: <20180719083530.jhugqzkvjnbrddim@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Matthew Wilcox <willy@infradead.org>

On 07/19/2018 10:35 AM, Mel Gorman wrote:
> On Wed, Jul 18, 2018 at 03:36:16PM +0200, Vlastimil Babka wrote:
>> In SLAB, OFF_SLAB caches allocate management structures (currently just the
>> freelist) from kmalloc caches when placement in a slab page together with
>> objects would lead to suboptimal memory usage. For SLAB_RECLAIM_ACCOUNT caches,
>> we can allocate the freelists from the newly introduced reclaimable kmalloc
>> caches, because shrinking the OFF_SLAB cache will in general result to freeing
>> of the freelists as well. This should improve accounting and anti-fragmentation
>> a bit.
>>
>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> 
> I'm not quite convinced by this one. The freelist cache is tied to the
> lifetime of the slab and not the objects. A single freelist can be reclaimed
> eventually but for caches with many objects per slab, it could take a lot
> of shrinking random objects to reclaim one freelist. Functionally the
> patch appears to be fine.

Hm you're right that the reclaimability of freelist is maybe too much
detached, and could do more harm than good for the reclaimable caches. I
will probably drop it unless I can measure it's an improvement. Thanks.
