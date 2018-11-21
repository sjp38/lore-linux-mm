Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0581D6B2441
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 08:22:54 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id e17so2976089edr.7
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 05:22:53 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k10-v6si332956ejq.34.2018.11.21.05.22.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Nov 2018 05:22:52 -0800 (PST)
Subject: Re: [PATCH] slab.h: Avoid using & for logical and of booleans
From: Vlastimil Babka <vbabka@suse.cz>
References: <20181105204000.129023-1-bvanassche@acm.org>
 <62188a351f2249188ce654ee03c894b1@AcuMS.aculab.com>
 <e44e6c8b-e4e4-e7cb-a5ca-88e9559eb0d7@suse.cz>
 <3c9adab0f1f74c46a60b3d4401030337@AcuMS.aculab.com>
 <60deb90d-e521-39e5-5072-fc9efb98e365@suse.cz>
 <9af3ac1d43bb422cb3c41e7e8e422e6e@AcuMS.aculab.com>
 <cbc1fc52-dc8c-aa38-8f29-22da8bcd91c1@suse.cz>
 <20181109110019.c82fba8125d4e2891fbe4a6c@linux-foundation.org>
 <b8ffd59b-0d15-9c98-b9ea-ad71e4c0c734@suse.cz>
 <bf7c2a6b801a4430bf842fc20e826db6@AcuMS.aculab.com>
 <aa5975b6-58ed-5a3e-7de1-4b1384f88457@suse.cz>
Message-ID: <80340595-d7c5-97b9-4f6c-23fa893a91e9@suse.cz>
Date: Wed, 21 Nov 2018 14:22:49 +0100
MIME-Version: 1.0
In-Reply-To: <aa5975b6-58ed-5a3e-7de1-4b1384f88457@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Laight <David.Laight@ACULAB.COM>, Andrew Morton <akpm@linux-foundation.org>
Cc: 'Bart Van Assche' <bvanassche@acm.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Christoph Lameter <cl@linux.com>, Roman Gushchin <guro@fb.com>, "Darryl T. Agostinelli" <dagostinelli@gmail.com>, linux-mm <linux-mm@kvack.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Dan Carpenter <dan.carpenter@oracle.com>

On 11/13/18 7:22 PM, Vlastimil Babka wrote:
> On 11/12/18 10:55 AM, David Laight wrote:
>> From: Vlastimil Babka [mailto:vbabka@suse.cz]
>>> Sent: 09 November 2018 19:16
>> ...
>>> This? Not terribly elegant, but I don't see a nicer way right now...
>>
>> Maybe just have two copies of the function body?
>>
>>  static __always_inline enum kmalloc_cache_type kmalloc_type(gfp_t flags)
>> {
>> #ifndef CONFIG_ZONE_DMA
>> 	return flags & __GFP_RECLAIMABLE ? KMALLOC_RECLAIM : KMALLOC_NORMAL;
>> #else
>> 	if (likely((flags & (__GFP_DMA | __GFP_RECLAIMABLE)) == 0))
>> 		return KMALLOC_NORMAL;
>> 	return flags & __GFP_DMA ? KMALLOC_DMA : KMALLOC_RECLAIM;
>> #endif
>> }
> 
> OK that's probably the most straightforward to follow, thanks.
> Note that for CONFIG_ZONE_DMA=n the result is identical to original code and
> all other attempts. flags & __GFP_DMA is converted to 1/0 index without branches
> or cmovs or whatnot.

Ping? Seems like people will report duplicates until the sparse warning
is gone in mainline...

Also CC linux-mm which was somehow lost.


----8<----
