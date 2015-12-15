Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 91F136B0038
	for <linux-mm@kvack.org>; Tue, 15 Dec 2015 04:30:26 -0500 (EST)
Received: by mail-ig0-f171.google.com with SMTP id to18so9157859igc.0
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 01:30:26 -0800 (PST)
Received: from mgwkm04.jp.fujitsu.com (mgwkm04.jp.fujitsu.com. [202.219.69.171])
        by mx.google.com with ESMTPS id n9si29141870igv.82.2015.12.15.01.30.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Dec 2015 01:30:25 -0800 (PST)
Received: from m3050.s.css.fujitsu.com (msm.b.css.fujitsu.com [10.134.21.208])
	by kw-mxq.gw.nic.fujitsu.com (Postfix) with ESMTP id 86635AC012F
	for <linux-mm@kvack.org>; Tue, 15 Dec 2015 18:30:17 +0900 (JST)
Subject: Re: [PATCH 1/7] mm: memcontrol: charge swap to cgroup2
References: <cover.1449742560.git.vdavydov@virtuozzo.com>
 <265d8fe623ed2773d69a26d302eb31e335377c77.1449742560.git.vdavydov@virtuozzo.com>
 <20151214153037.GB4339@dhcp22.suse.cz> <566F8528.9060205@jp.fujitsu.com>
 <20151215083007.GI28521@esperanza>
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <566FDD97.9070100@jp.fujitsu.com>
Date: Tue, 15 Dec 2015 18:29:59 +0900
MIME-Version: 1.0
In-Reply-To: <20151215083007.GI28521@esperanza>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2015/12/15 17:30, Vladimir Davydov wrote:
> On Tue, Dec 15, 2015 at 12:12:40PM +0900, Kamezawa Hiroyuki wrote:
>> On 2015/12/15 0:30, Michal Hocko wrote:
>>> On Thu 10-12-15 14:39:14, Vladimir Davydov wrote:
>>>> In the legacy hierarchy we charge memsw, which is dubious, because:
>>>>
>>>>   - memsw.limit must be >= memory.limit, so it is impossible to limit
>>>>     swap usage less than memory usage. Taking into account the fact that
>>>>     the primary limiting mechanism in the unified hierarchy is
>>>>     memory.high while memory.limit is either left unset or set to a very
>>>>     large value, moving memsw.limit knob to the unified hierarchy would
>>>>     effectively make it impossible to limit swap usage according to the
>>>>     user preference.
>>>>
>>>>   - memsw.usage != memory.usage + swap.usage, because a page occupying
>>>>     both swap entry and a swap cache page is charged only once to memsw
>>>>     counter. As a result, it is possible to effectively eat up to
>>>>     memory.limit of memory pages *and* memsw.limit of swap entries, which
>>>>     looks unexpected.
>>>>
>>>> That said, we should provide a different swap limiting mechanism for
>>>> cgroup2.
>>>> This patch adds mem_cgroup->swap counter, which charges the actual
>>>> number of swap entries used by a cgroup. It is only charged in the
>>>> unified hierarchy, while the legacy hierarchy memsw logic is left
>>>> intact.
>>>
>>> I agree that the previous semantic was awkward. The problem I can see
>>> with this approach is that once the swap limit is reached the anon
>>> memory pressure might spill over to other and unrelated memcgs during
>>> the global memory pressure. I guess this is what Kame referred to as
>>> anon would become mlocked basically. This would be even more of an issue
>>> with resource delegation to sub-hierarchies because nobody will prevent
>>> setting the swap amount to a small value and use that as an anon memory
>>> protection.
>>>
>>> I guess this was the reason why this approach hasn't been chosen before
>>
>> Yes. At that age, "never break global VM" was the policy. And "mlock" can be
>> used for attacking system.
>
> If we are talking about "attacking system" from inside a container,
> there are much easier and disruptive ways, e.g. running a fork-bomb or
> creating pipes - such memory can't be reclaimed and global OOM killer
> won't help.

You're right. We just wanted to avoid affecting global memory reclaim by
each cgroup settings.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
