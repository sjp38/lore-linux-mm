Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id 00F4D6B0038
	for <linux-mm@kvack.org>; Tue, 15 Dec 2015 21:44:38 -0500 (EST)
Received: by mail-ig0-f175.google.com with SMTP id ph11so123989420igc.1
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 18:44:37 -0800 (PST)
Received: from mgwym01.jp.fujitsu.com (mgwym01.jp.fujitsu.com. [211.128.242.40])
        by mx.google.com with ESMTPS id ys2si9112578igb.0.2015.12.15.18.44.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Dec 2015 18:44:37 -0800 (PST)
Received: from m3050.s.css.fujitsu.com (msm.b.css.fujitsu.com [10.134.21.208])
	by yt-mxoi2.gw.nic.fujitsu.com (Postfix) with ESMTP id 8B18EAC0273
	for <linux-mm@kvack.org>; Wed, 16 Dec 2015 11:44:32 +0900 (JST)
Subject: Re: [PATCH 1/7] mm: memcontrol: charge swap to cgroup2
References: <cover.1449742560.git.vdavydov@virtuozzo.com>
 <265d8fe623ed2773d69a26d302eb31e335377c77.1449742560.git.vdavydov@virtuozzo.com>
 <20151214153037.GB4339@dhcp22.suse.cz> <20151214194258.GH28521@esperanza>
 <566F8781.80108@jp.fujitsu.com> <20151215110219.GJ28521@esperanza>
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <5670CFFA.3060309@jp.fujitsu.com>
Date: Wed, 16 Dec 2015 11:44:10 +0900
MIME-Version: 1.0
In-Reply-To: <20151215110219.GJ28521@esperanza>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2015/12/15 20:02, Vladimir Davydov wrote:
> On Tue, Dec 15, 2015 at 12:22:41PM +0900, Kamezawa Hiroyuki wrote:
>> On 2015/12/15 4:42, Vladimir Davydov wrote:
>>> On Mon, Dec 14, 2015 at 04:30:37PM +0100, Michal Hocko wrote:
>>>> On Thu 10-12-15 14:39:14, Vladimir Davydov wrote:
>>>>> In the legacy hierarchy we charge memsw, which is dubious, because:
>>>>>
>>>>>   - memsw.limit must be >= memory.limit, so it is impossible to limit
>>>>>     swap usage less than memory usage. Taking into account the fact that
>>>>>     the primary limiting mechanism in the unified hierarchy is
>>>>>     memory.high while memory.limit is either left unset or set to a very
>>>>>     large value, moving memsw.limit knob to the unified hierarchy would
>>>>>     effectively make it impossible to limit swap usage according to the
>>>>>     user preference.
>>>>>
>>>>>   - memsw.usage != memory.usage + swap.usage, because a page occupying
>>>>>     both swap entry and a swap cache page is charged only once to memsw
>>>>>     counter. As a result, it is possible to effectively eat up to
>>>>>     memory.limit of memory pages *and* memsw.limit of swap entries, which
>>>>>     looks unexpected.
>>>>>
>>>>> That said, we should provide a different swap limiting mechanism for
>>>>> cgroup2.
>>>>> This patch adds mem_cgroup->swap counter, which charges the actual
>>>>> number of swap entries used by a cgroup. It is only charged in the
>>>>> unified hierarchy, while the legacy hierarchy memsw logic is left
>>>>> intact.
>>>>
>>>> I agree that the previous semantic was awkward. The problem I can see
>>>> with this approach is that once the swap limit is reached the anon
>>>> memory pressure might spill over to other and unrelated memcgs during
>>>> the global memory pressure. I guess this is what Kame referred to as
>>>> anon would become mlocked basically. This would be even more of an issue
>>>> with resource delegation to sub-hierarchies because nobody will prevent
>>>> setting the swap amount to a small value and use that as an anon memory
>>>> protection.
>>>
>>> AFAICS such anon memory protection has a side-effect: real-life
>>> workloads need page cache to run smoothly (at least for mapping
>>> executables). Disabling swapping would switch pressure to page caches,
>>> resulting in performance degradation. So, I don't think per memcg swap
>>> limit can be abused to boost your workload on an overcommitted system.
>>>
>>> If you mean malicious users, well, they already have plenty ways to eat
>>> all available memory up to the hard limit by creating unreclaimable
>>> kernel objects.
>>>
>> "protect anon" user's malicious degree is far lower than such cracker like users.
>
> What do you mean by "malicious degree"? What is such a user trying to
> achieve? Killing the system? Well, there are much more effective ways to
> do so. Or does it want to exploit a system specific feature to get
> benefit for itself? If so, it will hardly win by mlocking all anonymous
> memory, because this will result in higher pressure exerted upon its
> page cache and dcache, which normal workloads just can't get along
> without.
>

I wanted to say almost all application developers want to set swap.limit=0 if allowed.
So, it's a usual people who can kill the system if swap imbalance is allowed.
  
>>
>>> Anyway, if you don't trust a container you'd better set the hard memory
>>> limit so that it can't hurt others no matter what it runs and how it
>>> tweaks its sub-tree knobs.
>>>
>>
>> Limiting swap can easily cause "OOM-Killer even while there are
>> available swap" with easy mistake.
>
> What do you mean by "easy mistake"? Misconfiguration? If so, it's a lame
> excuse IMO. Admin should take system configuration seriously. If the
> host is not overcommitted, it's trivial. Otherwise, there's always a
> chance that things will go south, so it's not going to be easy. It's up
> to admin to analyze risks and set limits accordingly. Exporting knobs
> with clear meaning is the best we can do here. swap.max is one such knob
> It defines maximal usage of swap resource. Allowing to breach it just
> does not add up.
>
>> Can't you add "swap excess" switch to sysctl to allow global memory
>> reclaim can ignore swap limitation ?
>
> I'd be opposed to it, because this would obscure the user API. OTOH, a
> kind of swap soft limit (swap.high?) might be considered. I'm not sure
> if it's really necessary though, because all arguments for it do not
> look convincing to me for now. So, personally, I would refrain from
> implementing it until it is really called for by users of cgroup v2.
>

Considering my customers, running OOM-Killer while there are free swap space is
system's error rather than their misconfiguration.

BTW, mlock() requires CAP_IPC_LOCK.
please set default unlimited and check capability at setting swap limit, at least.

Thanks,
-Kame


> Thanks,
> Vladimir
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
