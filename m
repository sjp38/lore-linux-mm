Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 139906B0012
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 12:18:14 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 38so15516174wrv.8
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 09:18:14 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p25si1848526edi.103.2018.04.17.09.18.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Apr 2018 09:18:12 -0700 (PDT)
Subject: Re: [PATCH RESEND] slab: introduce the flag SLAB_MINIMIZE_WASTE
References: <alpine.LRH.2.02.1803201740280.21066@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.20.1803211024220.2175@nuc-kabylake>
 <alpine.LRH.2.02.1803211153320.16017@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.20.1803211226350.3174@nuc-kabylake>
 <alpine.LRH.2.02.1803211425330.26409@file01.intranet.prod.int.rdu2.redhat.com>
 <20c58a03-90a8-7e75-5fc7-856facfb6c8a@suse.cz>
 <20180413151019.GA5660@redhat.com>
 <ee8807ff-d650-0064-70bf-e1d77fa61f5c@suse.cz>
 <20180416142703.GA22422@redhat.com>
 <alpine.LRH.2.02.1804161031300.24222@file01.intranet.prod.int.rdu2.redhat.com>
 <20180416144638.GA22484@redhat.com>
 <alpine.LRH.2.02.1804161530360.19492@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.20.1804170940340.17557@nuc-kabylake>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <f8f736fe-9e0e-acd2-8040-f4f25ea5a7a2@suse.cz>
Date: Tue, 17 Apr 2018 18:16:13 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1804170940340.17557@nuc-kabylake>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>, Mikulas Patocka <mpatocka@redhat.com>
Cc: Mike Snitzer <snitzer@redhat.com>, Matthew Wilcox <willy@infradead.org>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, dm-devel@redhat.com, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On 04/17/2018 04:45 PM, Christopher Lameter wrote:
> On Mon, 16 Apr 2018, Mikulas Patocka wrote:
> 
>> This patch introduces a flag SLAB_MINIMIZE_WASTE for slab and slub. This
>> flag causes allocation of larger slab caches in order to minimize wasted
>> space.
>>
>> This is needed because we want to use dm-bufio for deduplication index and
>> there are existing installations with non-power-of-two block sizes (such
>> as 640KB). The performance of the whole solution depends on efficient
>> memory use, so we must waste as little memory as possible.
> 
> Hmmm. Can we come up with a generic solution instead?

Yes please.

> This may mean relaxing the enforcement of the allocation max order a bit
> so that we can get dense allocation through higher order allocs.
> 
> But then higher order allocs are generally seen as problematic.

I think in this case they are better than wasting/fragmenting 384kB for
640kB object.

> Note that SLUB will fall back to smallest order already if a failure
> occurs so increasing slub_max_order may not be that much of an issue.
> 
> Maybe drop the max order limit completely and use MAX_ORDER instead?

For packing, sure. For performance, please no (i.e. don't try to
allocate MAX_ORDER for each and every cache).

> That
> means that callers need to be able to tolerate failures.

Is it any different from now? I suppose there would still be
smallest-order fallback involved in sl*b itself? And if your allocation
is so large it can fail even with the fallback (i.e. >= costly order),
you need to tolerate failures anyway?

One corner case I see is if there is anyone who would rather use their
own fallback instead of the space-wasting smallest-order fallback.
Maybe we could map some GFP flag to indicate that.

> 
