Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4CAE76B000A
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 15:15:54 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 203so11885045pfz.19
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 12:15:54 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f10-v6si14964119pln.359.2018.04.17.12.15.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Apr 2018 12:15:53 -0700 (PDT)
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
 <f8f736fe-9e0e-acd2-8040-f4f25ea5a7a2@suse.cz>
 <alpine.LRH.2.02.1804171318010.5023@file01.intranet.prod.int.rdu2.redhat.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <8ab1e75f-9cf9-2a99-d071-c8c7a3554b95@suse.cz>
Date: Tue, 17 Apr 2018 21:13:53 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.LRH.2.02.1804171318010.5023@file01.intranet.prod.int.rdu2.redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Christopher Lameter <cl@linux.com>, Mike Snitzer <snitzer@redhat.com>, Matthew Wilcox <willy@infradead.org>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, dm-devel@redhat.com, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On 04/17/2018 07:26 PM, Mikulas Patocka wrote:
> 
> 
> On Tue, 17 Apr 2018, Vlastimil Babka wrote:
> 
>> On 04/17/2018 04:45 PM, Christopher Lameter wrote:
>>> On Mon, 16 Apr 2018, Mikulas Patocka wrote:
>>>
>>>> This patch introduces a flag SLAB_MINIMIZE_WASTE for slab and slub. This
>>>> flag causes allocation of larger slab caches in order to minimize wasted
>>>> space.
>>>>
>>>> This is needed because we want to use dm-bufio for deduplication index and
>>>> there are existing installations with non-power-of-two block sizes (such
>>>> as 640KB). The performance of the whole solution depends on efficient
>>>> memory use, so we must waste as little memory as possible.
>>>
>>> Hmmm. Can we come up with a generic solution instead?
>>
>> Yes please.
>>
>>> This may mean relaxing the enforcement of the allocation max order a bit
>>> so that we can get dense allocation through higher order allocs.
>>>
>>> But then higher order allocs are generally seen as problematic.
>>
>> I think in this case they are better than wasting/fragmenting 384kB for
>> 640kB object.
> 
> Wasting 37% of memory is still better than the kernel randomly returning 
> -ENOMEM when higher-order allocation fails.

Of course, see below.

>>> That
>>> means that callers need to be able to tolerate failures.
>>
>> Is it any different from now? I suppose there would still be
>> smallest-order fallback involved in sl*b itself? And if your allocation

^ There: "I suppose there would still be smallest-order fallback
involved in sl*b itself?"

If SLAB doesn't currently support fallback to different order, it either
learns to do that, or keeps wasting memory and more people will migrate
to SLUB. Simple.
