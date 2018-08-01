Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 501786B0007
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 03:34:26 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id i24-v6so4270909edq.16
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 00:34:26 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 7-v6si4000293edh.451.2018.08.01.00.34.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Aug 2018 00:34:24 -0700 (PDT)
Subject: Re: [Bug 200651] New: cgroups iptables-restor: vmalloc: allocation
 failure
References: <ed7090ad-5004-3133-3faf-607d2a9fa90a@suse.cz>
 <d69d7a82-5b70-051f-a517-f602c3ef1fd7@suse.cz>
 <98788618-94dc-5837-d627-8bbfa1ddea57@icdsoft.com>
 <ff19099f-e0f5-d2b2-e124-cc12d2e05dc1@icdsoft.com>
 <20180730135744.GT24267@dhcp22.suse.cz>
 <89ea4f56-6253-4f51-0fb7-33d7d4b60cfa@icdsoft.com>
 <20180730183820.GA24267@dhcp22.suse.cz>
 <56597af4-73c6-b549-c5d5-b3a2e6441b8e@icdsoft.com>
 <6838c342-2d07-3047-e723-2b641bc6bf79@suse.cz>
 <8105b7b3-20d3-5931-9f3c-2858021a4e12@icdsoft.com>
 <20180731140520.kpotpihqsmiwhh7l@breakpoint.cc>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <e5b24629-0296-5a4d-577a-c25d1c52b03b@suse.cz>
Date: Wed, 1 Aug 2018 09:34:23 +0200
MIME-Version: 1.0
In-Reply-To: <20180731140520.kpotpihqsmiwhh7l@breakpoint.cc>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Westphal <fw@strlen.de>, Georgi Nikolov <gnikolov@icdsoft.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, netfilter-devel@vger.kernel.org

On 07/31/2018 04:05 PM, Florian Westphal wrote:
> Georgi Nikolov <gnikolov@icdsoft.com> wrote:
>>> No, I think that's rather for the netfilter folks to decide. However, it
>>> seems there has been the debate already [1] and it was not found. The
>>> conclusion was that __GFP_NORETRY worked fine before, so it should work
>>> again after it's added back. But now we know that it doesn't...
>>>
>>> [1] https://lore.kernel.org/lkml/20180130140104.GE21609@dhcp22.suse.cz/T/#u
>>
>> Yes i see. I will add Florian Westphal to CC list. netfilter-devel is
>> already in this list so probably have to wait for their opinion.
> 
> It hasn't changed, I think having OOM killer zap random processes
> just because userspace wants to import large iptables ruleset is not a
> good idea.

If we denied the allocation instead of OOM (e.g. by using
__GFP_RETRY_MAYFAIL), a slightly smaller one may succeed, still leaving
the system without much memory, so it will invoke OOM killer sooner or
later anyway.

I don't see any silver-bullet solution, unfortunately. If this can be
abused by (multiple) namespaces, then they have to be contained by
kmemcg as that's the generic mechanism intended for this. Then we could
use the __GFP_RETRY_MAYFAIL.
The only limit we could impose to outright deny the allocation (to
prevent obvious bugs/admin mistakes or abuses) could be based on the
amount of RAM, as was suggested in the old thread.

__GFP_NORETRY might look like a good match at first sight as that stops
allocating when "reclaim becomes hard" which means the system is still
relatively far from OOM. But it's not reliable in principle, and as this
bug report shows. That's fine when __GFP_NORETRY is used for optimistic
allocations that have some other fallback (e.g. huge page with fallback
to base page), but far from ideal when failure means returning -ENOMEM
to userspace.
