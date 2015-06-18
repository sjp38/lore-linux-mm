Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 972496B0074
	for <linux-mm@kvack.org>; Thu, 18 Jun 2015 11:22:43 -0400 (EDT)
Received: by wiga1 with SMTP id a1so174819441wig.0
        for <linux-mm@kvack.org>; Thu, 18 Jun 2015 08:22:43 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id eu4si14495525wjb.112.2015.06.18.08.22.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 18 Jun 2015 08:22:41 -0700 (PDT)
Message-ID: <5582E240.8080704@suse.cz>
Date: Thu, 18 Jun 2015 17:22:40 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [RFC V3] net: don't wait for order-3 page allocation
References: <0099265406c32b9b9057de100404a4148d602cdd.1434066549.git.shli@fb.com> <557AA834.8070503@suse.cz> <alpine.DEB.2.10.1506171602300.8203@chino.kir.corp.google.com> <20150618143019.GE5858@dhcp22.suse.cz> <CANn89iLr2iNV3VjA4POPpfsmOpyB7jP2-wPiAkCOcA+Oh+2=5A@mail.gmail.com> <20150618144311.GF5858@dhcp22.suse.cz>
In-Reply-To: <20150618144311.GF5858@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Eric Dumazet <edumazet@google.com>
Cc: David Rientjes <rientjes@google.com>, Shaohua Li <shli@fb.com>, netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>, kernel-team <Kernel-team@fb.com>, clm@fb.com, linux-mm@kvack.org, dbavatar@gmail.com

On 06/18/2015 04:43 PM, Michal Hocko wrote:
> On Thu 18-06-15 07:35:53, Eric Dumazet wrote:
>> On Thu, Jun 18, 2015 at 7:30 AM, Michal Hocko <mhocko@suse.cz> wrote:
>>
>>> Abusing __GFP_NO_KSWAPD is a wrong way to go IMHO. It is true that the
>>> _current_ implementation of the allocator has this nasty and very subtle
>>> side effect but that doesn't mean it should be abused outside of the mm
>>> proper. Why shouldn't this path wake the kswapd and let it compact
>>> memory on the background to increase the success rate for the later
>>> high order allocations?
>>
>> I kind of agree.
>>
>> If kswapd is a problem (is it ???) we should fix it, instead of adding
>> yet another flag to some random locations attempting
>> memory allocations.
>
> No, kswapd is not a problem. The problem is ~__GFP_WAIT allocation can
> access some portion of the memory reserves (see gfp_to_alloc_flags resp.
> __zone_watermark_ok and ALLOC_HARDER). __GFP_NO_KSWAPD is just a dirty
> hack to not give that access which was introduced for THP AFAIR.
>
> The implicit access to memory reserves for non sleeping allocation has
> been there for ages and it might be not suitable for this particular
> path but that doesn't mean another gfp flag with a different side effect
> should be hijacked. We should either stop doing that implicit access to
> memory reserves and give __GFP_RESERVE or add the __GFP_NORESERVE. But
> that is a problem to be solved in the mm proper. Spreading subtle
> dependencies outside of mm will just make situation worse.

So you are not proposing to use these __GFP_RESERVE/NORESERVE flag 
outside of mm, right? (besides, we distinguish several kinds of 
reserves, so what exactly would the flag do?) As that would be also 
subtle dependency. The general problem I think is that we should want 
the mm users to specify higher-level intentions (such as GFP_KERNEL) 
which would map to specific directions (__GFP_*) for the allocator, and 
currently it's rather a mess of both kinds of flags. Clearly the 
intention here is "opportunistic allocation that should not 
reclaim/compact, use reserves, wake up kswapd (?) because it's better to 
fall back to smaller pages than wait") and we don't seem to have a 
GFP_OPPORTUNISTIC flag for that. The allocation has to then mask out 
__GFP_WAIT which however looks like an atomic allocation to the 
allocator and give access to reserves, etc...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
