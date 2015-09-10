Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 43D996B0038
	for <linux-mm@kvack.org>; Thu, 10 Sep 2015 02:39:29 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so11432019wic.1
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 23:39:28 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lg1si17620384wjc.136.2015.09.09.23.39.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 09 Sep 2015 23:39:28 -0700 (PDT)
Subject: Re: [PATCH/RFC] mm: do not regard CMA pages as free on watermark
 check
References: <BLU436-SMTP171766343879051ED4CED0A2520@phx.gbl>
 <55F072EA.4000703@redhat.com>
 <CAMJBoFNsCuktUC0aZF6Xw05v4g_2eK1G183KkSkhQYkztEVHCA@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55F1259C.3020006@suse.cz>
Date: Thu, 10 Sep 2015 08:39:24 +0200
MIME-Version: 1.0
In-Reply-To: <CAMJBoFNsCuktUC0aZF6Xw05v4g_2eK1G183KkSkhQYkztEVHCA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>, Laura Abbott <labbott@redhat.com>
Cc: Vitaly Wool <vwool@hotmail.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>

[CC Joonsoo, Mel]

On 09/09/2015 08:31 PM, Vitaly Wool wrote:
> Hi Laura,
> 
> On Wed, Sep 9, 2015 at 7:56 PM, Laura Abbott <labbott@redhat.com> wrote:
> 
>> (cc-ing linux-mm)
>> On 09/09/2015 07:44 AM, Vitaly Wool wrote:
>>
>>> __zone_watermark_ok() does not corrrectly take high-order
>>> CMA pageblocks into account: high-order CMA blocks are not
>>> removed from the watermark check. Moreover, CMA pageblocks
>>> may suddenly vanish through CMA allocation, so let's not
>>> regard these pages as free in __zone_watermark_ok().
>>>
>>> This patch also adds some primitive testing for the method
>>> implemented which has proven that it works as it should.
>>>
>>>
>> The choice to include CMA as part of watermarks was pretty deliberate.
>> Do you have a description of the problem you are facing with
>> the watermark code as is? Any performance numbers?
>>
>>
> let's start with facing the fact that the calculation in
> __zone_watermark_ok() is done incorrectly for the case when ALLOC_CMA is
> not set. While going through pages by order it is implicitly considered

You're not the first who tried to fix it, I think Joonsoo tried as well?
I think the main objection was against further polluting fastpaths due to CMA.

Note that Mel has a patchset removing high-order watermark checks (in the last
patch of https://lwn.net/Articles/655406/ ) so this will be moot afterwards.

> that CMA pages can be used and this impacts the result of the function.
> 
> This can be solved in a slightly different way compared to what I proposed
> but it needs per-order CMA pages accounting anyway. Then it would have
> looked like:
> 
>         for (o = 0; o < order; o++) {
>                 /* At the next order, this order's pages become unavailable
> */
>                 free_pages -= z->free_area[o].nr_free << o;
> #ifdef CONFIG_CMA
>                 if (!(alloc_flags & ALLOC_CMA))
>                         free_pages -= z->free_area[o].nr_free_cma << o;
>                 /* Require fewer higher order pages to be free */
>                 min >>= 1;
> ...
> 
> But what we have also seen is that CMA pages may suddenly disappear due to
> CMA allocator work so the whole watermark checking was still unreliable,
> causing compaction to not run when it ought to and thus leading to

Well, watermark checking is inherently racy. CMA pages disappearing is no
exception, non-CMA pages may disappear as well.

> (otherwise redundant) low memory killer operations, so I decided to propose
> a safer method instead.
> 
> Best regards,
>    Vitaly
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
