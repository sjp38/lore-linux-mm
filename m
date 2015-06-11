Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f176.google.com (mail-qk0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id 2D0AD6B006E
	for <linux-mm@kvack.org>; Thu, 11 Jun 2015 18:19:00 -0400 (EDT)
Received: by qkhg32 with SMTP id g32so9165041qkh.0
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 15:19:00 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id x104si1971922qgx.59.2015.06.11.15.18.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 11 Jun 2015 15:18:59 -0700 (PDT)
Message-ID: <557A0949.3020705@fb.com>
Date: Thu, 11 Jun 2015 18:18:49 -0400
From: Chris Mason <clm@fb.com>
MIME-Version: 1.0
Subject: Re: [RFC] net: use atomic allocation for order-3 page allocation
References: <71a20cf185c485fa23d9347bd846a6f4e9753405.1434053941.git.shli@fb.com>	 <1434055687.27504.51.camel@edumazet-glaptop2.roam.corp.google.com>	 <5579FABE.4050505@fb.com> <1434057733.27504.52.camel@edumazet-glaptop2.roam.corp.google.com>
In-Reply-To: <1434057733.27504.52.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Shaohua Li <shli@fb.com>, netdev@vger.kernel.org, davem@davemloft.net, Kernel-team@fb.com, Eric Dumazet <edumazet@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org

On 06/11/2015 05:22 PM, Eric Dumazet wrote:
> On Thu, 2015-06-11 at 17:16 -0400, Chris Mason wrote:
>> On 06/11/2015 04:48 PM, Eric Dumazet wrote:

>>
>> networking is asking for 32KB, and the MM layer is doing what it can to
>> provide it.  Are the gains from getting 32KB contig bigger than the cost
>> of moving pages around if the MM has to actually go into compaction?
>> Should we start disk IO to give back 32KB contig?
>>
>> I think we want to tell the MM to compact in the background and give
>> networking 32KB if it happens to have it available.  If not, fall back
>> to smaller allocations without doing anything expensive.
> 
> Exactly my point. (And I mentioned this about 4 months ago)

Sorry, reading this again I wasn't very clear.  I agree with Shaohua's
patch because it is telling the allocator that we don't want to wait for
reclaim or compaction to find contiguous pages.

But, is there any fallback to a single page allocation somewhere else?
If this is the only way to get memory, we might want to add a single
alloc_page path that won't trigger compaction but is at least able to
wait for kswapd to make progress.

-chris




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
