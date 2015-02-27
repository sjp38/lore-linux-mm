Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f171.google.com (mail-we0-f171.google.com [74.125.82.171])
	by kanga.kvack.org (Postfix) with ESMTP id 730EF6B0032
	for <linux-mm@kvack.org>; Fri, 27 Feb 2015 13:24:40 -0500 (EST)
Received: by wevm14 with SMTP id m14so21986201wev.8
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 10:24:40 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p12si8511526wjr.195.2015.02.27.10.24.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 27 Feb 2015 10:24:38 -0800 (PST)
Message-ID: <54F0B662.8020508@suse.cz>
Date: Fri, 27 Feb 2015 19:24:34 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: How to handle TIF_MEMDIE stalls?
References: <20150210151934.GA11212@phnom.home.cmpxchg.org> <201502111123.ICD65197.FMLOHSQJFVOtFO@I-love.SAKURA.ne.jp> <201502172123.JIE35470.QOLMVOFJSHOFFt@I-love.SAKURA.ne.jp> <20150217125315.GA14287@phnom.home.cmpxchg.org> <20150217225430.GJ4251@dastard> <20150219102431.GA15569@phnom.home.cmpxchg.org> <20150219225217.GY12722@dastard> <20150221235227.GA25079@phnom.home.cmpxchg.org> <20150223004521.GK12722@dastard> <20150222172930.6586516d.akpm@linux-foundation.org> <20150223073235.GT4251@dastard>
In-Reply-To: <20150223073235.GT4251@dastard>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@suse.cz, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com

On 02/23/2015 08:32 AM, Dave Chinner wrote:
>> > And then there will be an unknown number of
>> > slab allocations of unknown size with unknown slabs-per-page rules
>> > - how many pages needed for them?
> However many pages needed to allocate the number of objects we'll
> consume from the slab.

I think the best way is if slab could also learn to provide reserves for
individual objects. Either just mark internally how many of them are reserved,
if sufficient number is free, or translate this to the page allocator reserves,
as slab knows which order it uses for the given objects.

>> > And to make it much worse, how
>> > many pages of which orders?  Bless its heart, slub will go and use
>> > a 1-order page for allocations which should have been in 0-order
>> > pages..
> The majority of allocations will be order-0, though if we know that
> they are going to be significant numbers of high order allocations,
> then it should be simple enough to tell the mm subsystem "need a
> reserve of 32 order-0, 4 order-1 and 1 order-3 allocations" and have
> memory compaction just do it's stuff. But, IMO, we should cross that
> bridge when somebody actually needs reservations to be that
> specific....

Note that watermark checking for higher-order allocations is somewhat fuzzy
compared to order-0 checks, but I guess some kind of reservations could work
there too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
