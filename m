Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id D96E56B0069
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 02:28:59 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id s78so1699841wmd.14
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 23:28:59 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x194si8323348wme.55.2017.10.17.23.28.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Oct 2017 23:28:58 -0700 (PDT)
Subject: Re: [PATCH] mm/page_alloc: make sure __rmqueue() etc. always inline
References: <20171009054434.GA1798@intel.com>
 <3a46edcf-88f8-e4f4-8b15-3c02620308e4@intel.com>
 <20171010025151.GD1798@intel.com> <20171010025601.GE1798@intel.com>
 <8d6a98d3-764e-fd41-59dc-88a9d21822c7@intel.com>
 <20171010054342.GF1798@intel.com>
 <20171010144545.c87a28b0f3c4e475305254ab@linux-foundation.org>
 <20171011023402.GC27907@intel.com> <20171013063111.GA26032@intel.com>
 <7304b3a4-d6cb-63fa-743d-ea8e7b126e32@suse.cz>
 <1508291629.14336.14.camel@intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <29e5343f-b352-fe6a-02a8-74955cd606b8@suse.cz>
Date: Wed, 18 Oct 2017 08:28:56 +0200
MIME-Version: 1.0
In-Reply-To: <1508291629.14336.14.camel@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Lu, Aaron" <aaron.lu@intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tim.c.chen@linux.intel.com" <tim.c.chen@linux.intel.com>, "khandual@linux.vnet.ibm.com" <khandual@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "ak@linux.intel.com" <ak@linux.intel.com>, "Wang, Kemi" <kemi.wang@intel.com>, "Hansen, Dave" <dave.hansen@intel.com>, "Huang, Ying" <ying.huang@intel.com>

On 10/18/2017 03:53 AM, Lu, Aaron wrote:
> On Tue, 2017-10-17 at 13:32 +0200, Vlastimil Babka wrote:
>>
>> Are transparent hugepages enabled? If yes, __rmqueue() is called from
>> rmqueue(), and there's only one page fault (and __rmqueue()) per 512
>> "writes to each page". If not, __rmqueue() is called from rmqueue_bulk()
>> in bursts once pcplists are depleted. I guess it's the latter, otherwise
>> I wouldn't expect a function call to have such visible overhead.
> 
> THP is disabled. I should have mentioned this in the changelog, sorry
> about that.

OK, then it makes sense!

>>
>> I guess what would help much more would be a bulk __rmqueue_smallest()
>> to grab multiple pages from the freelists. But can't argue with your
> 
> Do I understand you correctly that you suggest to use a bulk
> __rmqueue_smallest(), say __rmqueue_smallest_bulk(). With that, instead
> of looping pcp->batch times in rmqueue_bulk(), a single call to
> __rmqueue_smallest_bulk() is enough and __rmqueue_smallest_bulk() will
> loop pcp->batch times to get those pages?

Yeah, but I looked at it more closely, and maybe there's not much to
gain after all. E.g., there seem to be no atomic counter updates that
would benefit from batching, or expensive setup/cleanup in
__rmqueue_smallest().

> Then it feels like __rmqueue_smallest_bulk() has become rmqueue_bulk(),
> or do I miss something?

Right, looks like thanks to inlining, the compiler can already achieve
most of the potential gains.

>> With gcc 7.2.1:
>>> ./scripts/bloat-o-meter base.o mm/page_alloc.o
>>
>> add/remove: 1/2 grow/shrink: 2/0 up/down: 2493/-1649 (844)
> 
> Nice, it clearly showed 844 bytes bloat.
> 
>> function                                     old     new   delta
>> get_page_from_freelist                      2898    4937   +2039
>> steal_suitable_fallback                        -     365    +365
>> find_suitable_fallback                        31     120     +89
>> find_suitable_fallback.part                  115       -    -115
>> __rmqueue                                   1534       -   -1534

It also shows that steal_suitable_fallback() is no longer inlined. Which
is fine, because that should ideally be rarely executed.

>>
>>> [aaron@aaronlu obj]$ size */*/vmlinux
>>>    text    data     bss     dec       hex     filename
>>> 10342757   5903208 17723392 33969357  20654cd gcc-4.9.4/base/vmlinux
>>> 10342757   5903208 17723392 33969357  20654cd gcc-4.9.4/head/vmlinux
>>> 10332448   5836608 17715200 33884256  2050860 gcc-5.5.0/base/vmlinux
>>> 10332448   5836608 17715200 33884256  2050860 gcc-5.5.0/head/vmlinux
>>> 10094546   5836696 17715200 33646442  201676a gcc-6.4.0/base/vmlinux
>>> 10094546   5836696 17715200 33646442  201676a gcc-6.4.0/head/vmlinux
>>> 10018775   5828732 17715200 33562707  2002053 gcc-7.2.0/base/vmlinux
>>> 10018775   5828732 17715200 33562707  2002053 gcc-7.2.0/head/vmlinux
>>>
>>> Text size for vmlinux has no change though, probably due to function
>>> alignment.
>>
>> Yep that's useless to show. These differences do add up though, until
>> they eventually cross the alignment boundary.
> 
> Agreed.
> But you know, it is the hot path, the performance improvement might be
> worth it.

I'd agree, so you can add

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
