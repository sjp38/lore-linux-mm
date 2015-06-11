Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 1A5246B0032
	for <linux-mm@kvack.org>; Thu, 11 Jun 2015 17:16:56 -0400 (EDT)
Received: by pdbnf5 with SMTP id nf5so10439248pdb.2
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 14:16:55 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id s7si2485995pdl.14.2015.06.11.14.16.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 11 Jun 2015 14:16:55 -0700 (PDT)
Message-ID: <5579FABE.4050505@fb.com>
Date: Thu, 11 Jun 2015 17:16:46 -0400
From: Chris Mason <clm@fb.com>
MIME-Version: 1.0
Subject: Re: [RFC] net: use atomic allocation for order-3 page allocation
References: <71a20cf185c485fa23d9347bd846a6f4e9753405.1434053941.git.shli@fb.com> <1434055687.27504.51.camel@edumazet-glaptop2.roam.corp.google.com>
In-Reply-To: <1434055687.27504.51.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>, Shaohua Li <shli@fb.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net, Kernel-team@fb.com, Eric Dumazet <edumazet@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org

On 06/11/2015 04:48 PM, Eric Dumazet wrote:
> On Thu, 2015-06-11 at 13:24 -0700, Shaohua Li wrote:
>> We saw excessive memory compaction triggered by skb_page_frag_refill.
>> This causes performance issues. Commit 5640f7685831e0 introduces the
>> order-3 allocation to improve performance. But memory compaction has
>> high overhead. The benefit of order-3 allocation can't compensate the
>> overhead of memory compaction.
>>
>> This patch makes the order-3 page allocation atomic. If there is no
>> memory pressure and memory isn't fragmented, the alloction will still
>> success, so we don't sacrifice the order-3 benefit here. If the atomic
>> allocation fails, compaction will not be triggered and we will fallback
>> to order-0 immediately.
>>
>> The mellanox driver does similar thing, if this is accepted, we must fix
>> the driver too.
>>
>> Cc: Eric Dumazet <edumazet@google.com>
>> Signed-off-by: Shaohua Li <shli@fb.com>
>> ---
>>  net/core/sock.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/net/core/sock.c b/net/core/sock.c
>> index 292f422..e9855a4 100644
>> --- a/net/core/sock.c
>> +++ b/net/core/sock.c
>> @@ -1883,7 +1883,7 @@ bool skb_page_frag_refill(unsigned int sz, struct page_frag *pfrag, gfp_t gfp)
>>  
>>  	pfrag->offset = 0;
>>  	if (SKB_FRAG_PAGE_ORDER) {
>> -		pfrag->page = alloc_pages(gfp | __GFP_COMP |
>> +		pfrag->page = alloc_pages((gfp & ~__GFP_WAIT) | __GFP_COMP |
>>  					  __GFP_NOWARN | __GFP_NORETRY,
>>  					  SKB_FRAG_PAGE_ORDER);
>>  		if (likely(pfrag->page)) {
> 
> This is not a specific networking issue, but mm one.
> 
> You really need to start a discussion with mm experts.
> 
> Your changelog does not exactly explains what _is_ the problem.
> 
> If the problem lies in mm layer, it might be time to fix it, instead of
> work around the bug by never triggering it from this particular point,
> which is a safe point where a process is willing to wait a bit.
> 
> Memory compaction is either working as intending, or not.
> 
> If we enabled it but never run it because it hurts, what is the point
> enabling it ?

networking is asking for 32KB, and the MM layer is doing what it can to
provide it.  Are the gains from getting 32KB contig bigger than the cost
of moving pages around if the MM has to actually go into compaction?
Should we start disk IO to give back 32KB contig?

I think we want to tell the MM to compact in the background and give
networking 32KB if it happens to have it available.  If not, fall back
to smaller allocations without doing anything expensive.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
