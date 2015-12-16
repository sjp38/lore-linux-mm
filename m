Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id DF16E6B0038
	for <linux-mm@kvack.org>; Tue, 15 Dec 2015 22:19:07 -0500 (EST)
Received: by mail-ig0-f171.google.com with SMTP id mv3so117757452igc.0
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 19:19:07 -0800 (PST)
Received: from mgwkm03.jp.fujitsu.com (mgwkm03.jp.fujitsu.com. [202.219.69.170])
        by mx.google.com with ESMTPS id z36si9243289ioi.192.2015.12.15.19.19.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Dec 2015 19:19:07 -0800 (PST)
Received: from m3051.s.css.fujitsu.com (m3051.s.css.fujitsu.com [10.134.21.209])
	by kw-mxoi1.gw.nic.fujitsu.com (Postfix) with ESMTP id A1850AC0131
	for <linux-mm@kvack.org>; Wed, 16 Dec 2015 12:18:58 +0900 (JST)
Subject: Re: [PATCH 1/7] mm: memcontrol: charge swap to cgroup2
References: <cover.1449742560.git.vdavydov@virtuozzo.com>
 <265d8fe623ed2773d69a26d302eb31e335377c77.1449742560.git.vdavydov@virtuozzo.com>
 <20151214153037.GB4339@dhcp22.suse.cz> <20151214194258.GH28521@esperanza>
 <566F8781.80108@jp.fujitsu.com> <20151215145011.GA20355@cmpxchg.org>
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <5670D806.60408@jp.fujitsu.com>
Date: Wed, 16 Dec 2015 12:18:30 +0900
MIME-Version: 1.0
In-Reply-To: <20151215145011.GA20355@cmpxchg.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2015/12/15 23:50, Johannes Weiner wrote:
> On Tue, Dec 15, 2015 at 12:22:41PM +0900, Kamezawa Hiroyuki wrote:
>> On 2015/12/15 4:42, Vladimir Davydov wrote:
>>> Anyway, if you don't trust a container you'd better set the hard memory
>>> limit so that it can't hurt others no matter what it runs and how it
>>> tweaks its sub-tree knobs.
>>
>> Limiting swap can easily cause "OOM-Killer even while there are available swap"
>> with easy mistake. Can't you add "swap excess" switch to sysctl to allow global
>> memory reclaim can ignore swap limitation ?
>
> That never worked with a combined memory+swap limit, either. How could
> it? The parent might swap you out under pressure, but simply touching
> a few of your anon pages causes them to get swapped back in, thrashing
> with whatever the parent was trying to do. Your ability to swap it out
> is simply no protection against a group touching its pages.
>
> Allowing the parent to exceed swap with separate counters makes even
> less sense, because every page swapped out frees up a page of memory
> that the child can reuse. For every swap page that exceeds the limit,
> the child gets a free memory page! The child doesn't even have to
> cause swapin, it can just steal whatever the parent tried to free up,
> and meanwhile its combined memory & swap footprint explodes.
>
Sure.

> The answer is and always should have been: don't overcommit untrusted
> cgroups. Think of swap as a resource you distribute, not as breathing
> room for the parents to rely on. Because it can't and could never.
>
ok, don't overcommmit.

> And the new separate swap counter makes this explicit.
>
Hmm, my requests are
  - set the same capabilities as mlock() to set swap.limit=0
  - swap-full notification via vmpressure or something mechanism.
  - OOM-Killer's available memory calculation may be corrupted, please check.
  - force swap-in at reducing swap.limit

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
