Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f182.google.com (mail-lb0-f182.google.com [209.85.217.182])
	by kanga.kvack.org (Postfix) with ESMTP id F2CFF6B0032
	for <linux-mm@kvack.org>; Thu,  8 Jan 2015 07:16:37 -0500 (EST)
Received: by mail-lb0-f182.google.com with SMTP id u10so2496927lbd.13
        for <linux-mm@kvack.org>; Thu, 08 Jan 2015 04:16:37 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id qp3si7765677lbb.81.2015.01.08.04.10.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 08 Jan 2015 04:10:47 -0800 (PST)
Message-ID: <54AE73C5.4000409@suse.cz>
Date: Thu, 08 Jan 2015 13:10:45 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: Dirty pages underflow on 3.14.23
References: <alpine.LRH.2.02.1501051744020.5119@file01.intranet.prod.int.rdu2.redhat.com> <20150106150250.GA26895@phnom.home.cmpxchg.org> <alpine.LRH.2.02.1501061246400.16437@file01.intranet.prod.int.rdu2.redhat.com> <pan.2015.01.07.10.57.46@googlemail.com> <20150107212858.GA6664@hostway.ca> <54ADA99A.90501@suse.cz> <20150108010426.GB6664@hostway.ca>
In-Reply-To: <20150108010426.GB6664@hostway.ca>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Kirby <sim@hostway.ca>
Cc: Holger Hoffst?tte <holger.hoffstaette@googlemail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 01/08/2015 02:04 AM, Simon Kirby wrote:
> On Wed, Jan 07, 2015 at 10:48:10PM +0100, Vlastimil Babka wrote:
> 
>> On 01/07/2015 10:28 PM, Simon Kirby wrote:
>>
>> > Hmm...A possibly-related issue...Before trying this, after a fresh boot,
>> > /proc/vmstat showed:
>> > 
>> > nr_alloc_batch 4294541205
>> 
>> This can happen, and not be a problem in general. However, there was a fix
>> abe5f972912d086c080be4bde67750630b6fb38b in 3.17 for a potential performance
>> issue if this counter overflows on single processor configuration. It was marked
>> stable, but the 3.16 series was discontinued before the fix could be backported.
>> So if you are on single-core, you might hit the performance issue.
> 
> That particular commit seems to just change the code path in that case,
> but should it be underflowing at all on UP?

Yes, the code using this counter is either treating it as signed, or includes a
<0 tests. It's just the /proc output might be confusing here...

>> > Still, nr_alloc_batch reads as 4294254379 after MySQL restart, and now
>> > seems to stay up there.
>> 
>> Hm if it stays there, then you are probably hitting the performance issue. Look
>> at /proc/zoneinfo, which zone has the underflow. It means this zone will get
>> unfair amount of allocations, while others may contain stale data and would be
>> better candidates.
> 
> In this case, it has only 640MB, and there's only DMA and Normal. This is
> affecting Normal, and DMA is so small that it probably doesn't matter.
> 
> Simon-
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
