Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 0A5D56B0032
	for <linux-mm@kvack.org>; Fri, 12 Jun 2015 05:25:36 -0400 (EDT)
Received: by wiwd19 with SMTP id d19so12624249wiw.0
        for <linux-mm@kvack.org>; Fri, 12 Jun 2015 02:25:35 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y11si2316033wiv.114.2015.06.12.02.25.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 12 Jun 2015 02:25:33 -0700 (PDT)
Message-ID: <557AA58A.2060207@suse.cz>
Date: Fri, 12 Jun 2015 11:25:30 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [RFC] net: use atomic allocation for order-3 page allocation
References: <71a20cf185c485fa23d9347bd846a6f4e9753405.1434053941.git.shli@fb.com>	<1434055687.27504.51.camel@edumazet-glaptop2.roam.corp.google.com>	<5579FABE.4050505@fb.com> <CAATkVEw93KaUQuNJY9hxA+q2dxPb2AAxicojkjDfXDZU5VGxtg@mail.gmail.com>
In-Reply-To: <CAATkVEw93KaUQuNJY9hxA+q2dxPb2AAxicojkjDfXDZU5VGxtg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Debabrata Banerjee <dbavatar@gmail.com>, Chris Mason <clm@fb.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Shaohua Li <shli@fb.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "davem@davemloft.net" <davem@davemloft.net>, Kernel-team@fb.com, Eric Dumazet <edumazet@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Joshua Hunt <johunt@akamai.com>, "Banerjee, Debabrata" <dbanerje@akamai.com>

On 06/11/2015 11:35 PM, Debabrata Banerjee wrote:
> There is no "background" it doesn't matter if this activity happens
> synchronously or asynchronously, unless you're sensitive to the
> latency on that single operation. If you're driving all your cpu's and
> memory hard then this is work that still takes resources. If there's a
> kernel thread with compaction running, then obviously your process is
> not.

Well that of course depends on the CPU utilization of "your process".

> Your patch should help in that not every atomic allocation failure
> should mean yet another run at compaction/reclaim.

If you don't want to wake up kswapd, add also __GFP_NO_KSWAPD flag. 
Additionally, gfp_to_alloc_flags() will stop treating such allocation as 
atomic - it allows atomic allocations to bypass cpusets and lowers the 
watermark by 1/4 (unless there's also __GFP_NOMEMALLOC). It might 
actually make sense to add __GFP_NO_KSWAPD for an allocation like this 
one that has a simple order-0 fallback.

Vlastimil


> -Deb
>
> On Thu, Jun 11, 2015 at 5:16 PM, Chris Mason <clm@fb.com> wrote:
>
>> networking is asking for 32KB, and the MM layer is doing what it can to
>> provide it.  Are the gains from getting 32KB contig bigger than the cost
>> of moving pages around if the MM has to actually go into compaction?
>> Should we start disk IO to give back 32KB contig?
>>
>> I think we want to tell the MM to compact in the background and give
>> networking 32KB if it happens to have it available.  If not, fall back
>> to smaller allocations without doing anything expensive.
>>
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
