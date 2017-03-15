Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5D9506B0389
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 08:53:17 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id j127so11398713qke.2
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 05:53:17 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d58si1346251qta.157.2017.03.15.05.53.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Mar 2017 05:53:16 -0700 (PDT)
From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: ZONE_NORMAL vs. ZONE_MOVABLE
References: <20170315091347.GA32626@dhcp22.suse.cz>
	<87shmedddm.fsf@vitty.brq.redhat.com>
	<20170315122914.GG32620@dhcp22.suse.cz>
Date: Wed, 15 Mar 2017 13:53:09 +0100
In-Reply-To: <20170315122914.GG32620@dhcp22.suse.cz> (Michal Hocko's message
	of "Wed, 15 Mar 2017 13:29:14 +0100")
Message-ID: <87k27qd7m2.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, qiuxishi@huawei.com, toshi.kani@hpe.com, xieyisheng1@huawei.com, slaoub@gmail.com, iamjoonsoo.kim@lge.com, Zhang Zhen <zhenzhang.zhang@huawei.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Andi Kleen <ak@linux.intel.com>

Michal Hocko <mhocko@kernel.org> writes:

> On Wed 15-03-17 11:48:37, Vitaly Kuznetsov wrote:
>> Michal Hocko <mhocko@kernel.org> writes:
> [...]
>> Speaking about long term approach,
>
> Not really related to the patch but ok (I hope this will not distract
> from the original intention here)...
>

Yes, not directly related to your patch.

>> (I'm not really familiar with the history of memory zones code so please
>> bear with me if my questions are stupid)
>> 
>> Currently when we online memory blocks we need to know where to put the
>> boundary between NORMAL and MOVABLE and this is a very hard decision to
>> make, no matter if we do this from kernel or from userspace. In theory,
>> we just want to avoid redundant limitations with future unplug but we
>> don't really know how much memory we'll need for kernel allocations in
>> future.
>
> yes, and that is why I am not really all that happy about the whole
> movable zones concept. It is basically reintroducing highmem issues from
> 32b times. But this is the only concept we currently have to provide a
> reliable memory hotremove right now.
>
>> What actually stops us from having the following approach:
>> 1) Everything is added to MOVABLE
>> 2) When we're out of memory for kernel allocations in NORMAL we 'harvest'
>> the first MOVABLE block and 'convert' it to NORMAL. It may happen that
>> there is no free pages in this block but it was MOVABLE which means we
>> can move all allocations somewhere else.
>> 3) Freeing the whole 128mb memblock takes time but we don't need to wait
>> till it finishes, we just need to satisfy the currently pending
>> allocation and we can continue moving everything else in the background.
>
> Although it sounds like a good idea at first sight there are many tiny
> details which will make it much more complicated. First of all, how
> do we know that the lowmem (resp. all zones normal zones) are under
> pressure to reduce the movable zone? Getting OOM for ~__GFP_MOVABLE
> request? Isn't that too late already?

Yes, I was basically thinking about OOM handling. It can also be a sort
of watermark-based decision.

>  Sync migration at that state might
> be really non trivial (pages might be dirty, pinned etc...).

Non-trivial, yes, but we already have the code to move all allocations
away from MOVABLE block when we try to offline it, we can probably
leverage it.

>  What about
> user expectation to hotremove that memory later, should we just break
> it?  How do we inflate movable zone back?

I think that it's OK to leave this block non-offlineable for future. As
Andrea already pointed out it is not practical to try to guarantee we
can unplug everything we plugged in, we're talking about 'best effort'
service here anyway.

>
>> An alternative approach would be to have lists of memblocks which
>> constitute ZONE_NORMAL and ZONE_MOVABLE instead of a simple 'NORMAL
>> before MOVABLE' rule we have now but I'm not sure this is a viable
>> approach with the current code base.
>
> I am not sure I understand.

Now we have 

[Normal][Normal][Normal][Movable][Movable][Movable]

we could have
[Normal][Normal][Movable][Normal][Movable][Normal]

so when new block comes in we make a decision to which zone we want to
online it (based on memory usage in these zones) and zone becomes a list
of memblocks which constitute it, not a simple [from..to] range.

-- 
  Vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
