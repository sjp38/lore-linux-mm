Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5553C6B0010
	for <linux-mm@kvack.org>; Tue, 14 Aug 2018 05:41:01 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id z12-v6so3787409lfe.2
        for <linux-mm@kvack.org>; Tue, 14 Aug 2018 02:41:01 -0700 (PDT)
Received: from forwardcorp1g.cmail.yandex.net (forwardcorp1g.cmail.yandex.net. [87.250.241.190])
        by mx.google.com with ESMTPS id s25-v6si8134129ljs.253.2018.08.14.02.40.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Aug 2018 02:40:59 -0700 (PDT)
Subject: Re: [PATCH RFC 1/3] cgroup: list all subsystem states in debugfs
 files
References: <153414348591.737150.14229960913953276515.stgit@buzz>
 <20180813134842.GF3978217@devbig004.ftw2.facebook.com>
 <20180813171119.GA24658@cmpxchg.org>
 <20180813175348.GA31962@castle.DHCP.thefacebook.com>
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Message-ID: <1cc17b7b-8f5b-6682-ccc0-19ff5f9992e0@yandex-team.ru>
Date: Tue, 14 Aug 2018 12:40:58 +0300
MIME-Version: 1.0
In-Reply-To: <20180813175348.GA31962@castle.DHCP.thefacebook.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On 13.08.2018 20:53, Roman Gushchin wrote:
> On Mon, Aug 13, 2018 at 01:11:19PM -0400, Johannes Weiner wrote:
>> On Mon, Aug 13, 2018 at 06:48:42AM -0700, Tejun Heo wrote:
>>> Hello, Konstantin.
>>>
>>> On Mon, Aug 13, 2018 at 09:58:05AM +0300, Konstantin Khlebnikov wrote:
>>>> After removing cgroup subsystem state could leak or live in background
>>>> forever because it is pinned by some reference. For example memory cgroup
>>>> could be pinned by pages in cache or tmpfs.
>>>>
>>>> This patch adds common debugfs interface for listing basic state for each
>>>> controller. Controller could define callback for dumping own attributes.
>>>>
>>>> In file /sys/kernel/debug/cgroup/<controller> each line shows state in
>>>> format: <common_attr>=<value>... [-- <controller_attr>=<value>... ]
>>>
>>> Seems pretty useful to me.  Roman, Johannes, what do you guys think?
> 
> Totally agree with the idea and was about to suggest something similar.
> 
>> Generally I like the idea of having more introspection into offlined
>> cgroups, but I wonder if having only memory= and swap= could be a
>> little too terse to track down what exactly is pinning the groups.
>>
>> Roman has more experience debugging these pileups, but it seems to me
>> that unless we add a breakdown off memory, and maybe make slabinfo
>> available for these groups, that in practice this might not provide
>> that much more insight than per-cgroup stat counters of dead children.
> 
> I agree here.

I don't think that we could cover all cases with single interface.

This debugfs just gives simple entry point for debugging:
- paths for guessing user
- pointers for looking with gdb via kcore
- inode numbers for page-types - see second and third patch

For slab: this could show one of remaining slab. Anyway each of them pins css.

> 
> It's hard to say in advance what numbers are useful, so let's export
> these numbers, but also make the format more extendable, so we can
> easily add new information later. Maybe, something like:
> 
> cgroup {
>    path = ...
>    ino = ...
>    main css {
>      refcnt = ...
>      key = value
>      ...
>    }
>    memcg css {
>      refcnt = ...
>      ...
>    }
>    some other controller css {
>    }
>    ...
> }
> 
> Also, because we do batch charges, printing numbers without draining stocks
> is not that useful. All stats are also per-cpu cached, what adds some
> inaccuracy.

Seems too verbose. And one-line key=value format is more grep/awk friendly.

Anyway such extended debugging could be implemented as gdb plugin.
While simple list of pointers gives enough information for dumping structures
with gdb alone without extra plugins.

> 
> Thanks!
> 
