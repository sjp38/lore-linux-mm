Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3F67A6B0009
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 08:07:24 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id m6-v6so5784207pln.8
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 05:07:24 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0133.outbound.protection.outlook.com. [104.47.0.133])
        by mx.google.com with ESMTPS id e32-v6si5656808plb.135.2018.04.13.05.07.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 13 Apr 2018 05:07:23 -0700 (PDT)
Subject: Re: [PATCH] memcg: Remove memcg_cgroup::id from IDR on
 mem_cgroup_css_alloc() failure
References: <152354470916.22460.14397070748001974638.stgit@localhost.localdomain>
 <20180413085553.GF17484@dhcp22.suse.cz>
 <ed75d18c-f516-2feb-53a8-6d2836e1da59@virtuozzo.com>
 <20180413110200.GG17484@dhcp22.suse.cz>
 <06931a83-91d2-3dcf-31cf-0b98d82e957f@virtuozzo.com>
 <20180413112036.GH17484@dhcp22.suse.cz>
 <6dbc33bb-f3d5-1a46-b454-13c6f5865fcd@virtuozzo.com>
 <20180413113855.GI17484@dhcp22.suse.cz>
 <8a81c801-35c8-767d-54b0-df9f1ca0abc0@virtuozzo.com>
 <20180413115454.GL17484@dhcp22.suse.cz>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <abfd4903-c455-fac2-7ed6-73707cda64d1@virtuozzo.com>
Date: Fri, 13 Apr 2018 15:07:14 +0300
MIME-Version: 1.0
In-Reply-To: <20180413115454.GL17484@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov.dev@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 13.04.2018 14:54, Michal Hocko wrote:
> On Fri 13-04-18 14:49:32, Kirill Tkhai wrote:
>> On 13.04.2018 14:38, Michal Hocko wrote:
>>> On Fri 13-04-18 14:29:11, Kirill Tkhai wrote:
> [...]
>>>> mem_cgroup_id_put_many() unpins css, but this may be not the last reference to the css.
>>>> Thus, we release ID earlier, then all references to css are freed.
>>>
>>> Right and so what. If we have released the idr then we are not going to
>>> do that again in css_free. That is why we have that memcg->id.id > 0
>>> check before idr_remove and memcg->id.id = 0 for the last memcg ref.
>>> count. So again, why cannot we do the clean up in mem_cgroup_free and
>>> have a less confusing code? Or am I just not getting your point and
>>> being dense here?
>>
>> We can, but mem_cgroup_free() called from mem_cgroup_css_alloc() is unlikely case.
>> The likely case is mem_cgroup_free() is called from mem_cgroup_css_free(), where
>> this idr manipulations will be a noop. Noop in likely case looks more confusing
>> for me.
> 
> Well, I would really prefer to have _free being symmetric to _alloc so
> that you can rely that the full state is gone after _free is called.
> This confused the hell out of me. Because I _did_ expect that
> mem_cgroup_free would do that and so I was looking at completely
> different place.
>  
>> Less confusing will be to move
>>
>>         memcg->id.id = idr_alloc(&mem_cgroup_idr, NULL,
>>                                  1, MEM_CGROUP_ID_MAX,
>>                                  GFP_KERNEL);
>>
>> into mem_cgroup_css_alloc(). How are you think about this?
> 
> I would have to double check. Maybe it can be done on top. But for the
> actual fix and a stable backport potentially should be as clear as
> possible. Your original patch would be just fine but if I would prefer 
> mem_cgroup_free for the symmetry.

We definitely can move id allocation to mem_cgroup_css_alloc(), but this
is really not for an easy fix, which will be backported to stable.

Moving idr destroy to mem_cgroup_free() hides IDR trick. My IMHO it's less
readable for a reader.

The main problem is allocation asymmetric, and we shouldn't handle it on free path...

Kirill
