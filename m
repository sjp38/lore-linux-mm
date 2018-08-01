Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1F0746B0005
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 12:03:15 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id y13-v6so6208882ita.8
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 09:03:15 -0700 (PDT)
Received: from us.icdsoft.com (us.icdsoft.com. [192.252.146.184])
        by mx.google.com with ESMTPS id l16-v6si3934713itl.138.2018.08.01.09.03.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Aug 2018 09:03:13 -0700 (PDT)
Subject: Re: [Bug 200651] New: cgroups iptables-restor: vmalloc: allocation
 failure
References: <98788618-94dc-5837-d627-8bbfa1ddea57@icdsoft.com>
 <ff19099f-e0f5-d2b2-e124-cc12d2e05dc1@icdsoft.com>
 <20180730135744.GT24267@dhcp22.suse.cz>
 <89ea4f56-6253-4f51-0fb7-33d7d4b60cfa@icdsoft.com>
 <20180730183820.GA24267@dhcp22.suse.cz>
 <56597af4-73c6-b549-c5d5-b3a2e6441b8e@icdsoft.com>
 <6838c342-2d07-3047-e723-2b641bc6bf79@suse.cz>
 <8105b7b3-20d3-5931-9f3c-2858021a4e12@icdsoft.com>
 <20180731140520.kpotpihqsmiwhh7l@breakpoint.cc>
 <e5b24629-0296-5a4d-577a-c25d1c52b03b@suse.cz>
 <20180801083349.GF16767@dhcp22.suse.cz>
From: Georgi Nikolov <gnikolov@icdsoft.com>
Message-ID: <e5c5e965-a6bc-d61f-97fc-78da287b5d94@icdsoft.com>
Date: Wed, 1 Aug 2018 19:03:03 +0300
MIME-Version: 1.0
In-Reply-To: <20180801083349.GF16767@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>
Cc: Florian Westphal <fw@strlen.de>, Andrew Morton <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, netfilter-devel@vger.kernel.org


*Georgi Nikolov*
System Administrator
www.icdsoft.com <http://www.icdsoft.com>

On 08/01/2018 11:33 AM, Michal Hocko wrote:
> On Wed 01-08-18 09:34:23, Vlastimil Babka wrote:
>> On 07/31/2018 04:05 PM, Florian Westphal wrote:
>>> Georgi Nikolov <gnikolov@icdsoft.com> wrote:
>>>>> No, I think that's rather for the netfilter folks to decide. Howeve=
r, it
>>>>> seems there has been the debate already [1] and it was not found. T=
he
>>>>> conclusion was that __GFP_NORETRY worked fine before, so it should =
work
>>>>> again after it's added back. But now we know that it doesn't...
>>>>>
>>>>> [1] https://lore.kernel.org/lkml/20180130140104.GE21609@dhcp22.suse=
=2Ecz/T/#u
>>>> Yes i see. I will add Florian Westphal to CC list. netfilter-devel i=
s
>>>> already in this list so probably have to wait for their opinion.
>>> It hasn't changed, I think having OOM killer zap random processes
>>> just because userspace wants to import large iptables ruleset is not =
a
>>> good idea.
>> If we denied the allocation instead of OOM (e.g. by using
>> __GFP_RETRY_MAYFAIL), a slightly smaller one may succeed, still leavin=
g
>> the system without much memory, so it will invoke OOM killer sooner or=

>> later anyway.
>>
>> I don't see any silver-bullet solution, unfortunately. If this can be
>> abused by (multiple) namespaces, then they have to be contained by
>> kmemcg as that's the generic mechanism intended for this. Then we coul=
d
>> use the __GFP_RETRY_MAYFAIL.
>> The only limit we could impose to outright deny the allocation (to
>> prevent obvious bugs/admin mistakes or abuses) could be based on the
>> amount of RAM, as was suggested in the old thread.

Can we make this configurable - on/off switch or size above which
to pass GFP_NORETRY. Probably hard coded based on amount of RAM is a
good idea too.

>> __GFP_NORETRY might look like a good match at first sight as that stop=
s
>> allocating when "reclaim becomes hard" which means the system is still=

>> relatively far from OOM. But it's not reliable in principle, and as th=
is
>> bug report shows. That's fine when __GFP_NORETRY is used for optimisti=
c
>> allocations that have some other fallback (e.g. huge page with fallbac=
k
>> to base page), but far from ideal when failure means returning -ENOMEM=

>> to userspace.
> I absolutely agree. The whole __GFP_NORETRY is quite dubious TBH. I hav=
e
> used it to get the original behavior because the change wasn't really
> intended to make functional changes. But consideg ring this requires
> higher privileges then I fail to see where the distrust comes from. If
> this is really about untrusted root in a namespace then the proper way
> is to use __GFP_ACCOUNT and limit that via kmemc.
>
> __GFP_NORETRY can fail really easily if the kswapd doesn't keep the pac=
e
> with the allocations which might be completely unrelated to this
> particular request.
