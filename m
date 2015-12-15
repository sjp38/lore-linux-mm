Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id ACDAB6B0255
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 22:23:06 -0500 (EST)
Received: by pacwq6 with SMTP id wq6so114525823pac.1
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 19:23:06 -0800 (PST)
Received: from mgwym03.jp.fujitsu.com (mgwym03.jp.fujitsu.com. [211.128.242.42])
        by mx.google.com with ESMTPS id o90si21398624pfi.73.2015.12.14.19.23.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Dec 2015 19:23:05 -0800 (PST)
Received: from m3050.s.css.fujitsu.com (msm.b.css.fujitsu.com [10.134.21.208])
	by yt-mxauth.gw.nic.fujitsu.com (Postfix) with ESMTP id 9EDF3AC0702
	for <linux-mm@kvack.org>; Tue, 15 Dec 2015 12:23:00 +0900 (JST)
Subject: Re: [PATCH 1/7] mm: memcontrol: charge swap to cgroup2
References: <cover.1449742560.git.vdavydov@virtuozzo.com>
 <265d8fe623ed2773d69a26d302eb31e335377c77.1449742560.git.vdavydov@virtuozzo.com>
 <20151214153037.GB4339@dhcp22.suse.cz> <20151214194258.GH28521@esperanza>
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <566F8781.80108@jp.fujitsu.com>
Date: Tue, 15 Dec 2015 12:22:41 +0900
MIME-Version: 1.0
In-Reply-To: <20151214194258.GH28521@esperanza>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2015/12/15 4:42, Vladimir Davydov wrote:
> On Mon, Dec 14, 2015 at 04:30:37PM +0100, Michal Hocko wrote:
>> On Thu 10-12-15 14:39:14, Vladimir Davydov wrote:
>>> In the legacy hierarchy we charge memsw, which is dubious, because:
>>>
>>>   - memsw.limit must be >= memory.limit, so it is impossible to limit
>>>     swap usage less than memory usage. Taking into account the fact that
>>>     the primary limiting mechanism in the unified hierarchy is
>>>     memory.high while memory.limit is either left unset or set to a very
>>>     large value, moving memsw.limit knob to the unified hierarchy would
>>>     effectively make it impossible to limit swap usage according to the
>>>     user preference.
>>>
>>>   - memsw.usage != memory.usage + swap.usage, because a page occupying
>>>     both swap entry and a swap cache page is charged only once to memsw
>>>     counter. As a result, it is possible to effectively eat up to
>>>     memory.limit of memory pages *and* memsw.limit of swap entries, which
>>>     looks unexpected.
>>>
>>> That said, we should provide a different swap limiting mechanism for
>>> cgroup2.
>>> This patch adds mem_cgroup->swap counter, which charges the actual
>>> number of swap entries used by a cgroup. It is only charged in the
>>> unified hierarchy, while the legacy hierarchy memsw logic is left
>>> intact.
>>
>> I agree that the previous semantic was awkward. The problem I can see
>> with this approach is that once the swap limit is reached the anon
>> memory pressure might spill over to other and unrelated memcgs during
>> the global memory pressure. I guess this is what Kame referred to as
>> anon would become mlocked basically. This would be even more of an issue
>> with resource delegation to sub-hierarchies because nobody will prevent
>> setting the swap amount to a small value and use that as an anon memory
>> protection.
>
> AFAICS such anon memory protection has a side-effect: real-life
> workloads need page cache to run smoothly (at least for mapping
> executables). Disabling swapping would switch pressure to page caches,
> resulting in performance degradation. So, I don't think per memcg swap
> limit can be abused to boost your workload on an overcommitted system.
>
> If you mean malicious users, well, they already have plenty ways to eat
> all available memory up to the hard limit by creating unreclaimable
> kernel objects.
>
"protect anon" user's malicious degree is far lower than such cracker like users.

> Anyway, if you don't trust a container you'd better set the hard memory
> limit so that it can't hurt others no matter what it runs and how it
> tweaks its sub-tree knobs.
>

Limiting swap can easily cause "OOM-Killer even while there are available swap"
with easy mistake. Can't you add "swap excess" switch to sysctl to allow global
memory reclaim can ignore swap limitation ?

Regards,
-Kame








--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
