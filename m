Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id E14C86B04DC
	for <linux-mm@kvack.org>; Thu, 17 May 2018 07:49:36 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id t9-v6so1437465ioa.2
        for <linux-mm@kvack.org>; Thu, 17 May 2018 04:49:36 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0097.outbound.protection.outlook.com. [104.47.1.97])
        by mx.google.com with ESMTPS id b10-v6si4632916itj.22.2018.05.17.04.49.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 17 May 2018 04:49:32 -0700 (PDT)
Subject: Re: [PATCH v5 11/13] mm: Iterate only over charged shrinkers during
 memcg shrink_slab()
References: <152594582808.22949.8353313986092337675.stgit@localhost.localdomain>
 <152594603565.22949.12428911301395699065.stgit@localhost.localdomain>
 <20180515054445.nhe4zigtelkois4p@esperanza>
 <5c0dbd12-8100-61a2-34fd-8878c57195a3@virtuozzo.com>
 <20180517041634.lgkym6gdctya3oq6@esperanza>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <f2dec4fb-6107-5d6c-62b3-8b680895c5c1@virtuozzo.com>
Date: Thu, 17 May 2018 14:49:26 +0300
MIME-Version: 1.0
In-Reply-To: <20180517041634.lgkym6gdctya3oq6@esperanza>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: akpm@linux-foundation.org, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

On 17.05.2018 07:16, Vladimir Davydov wrote:
> On Tue, May 15, 2018 at 05:49:59PM +0300, Kirill Tkhai wrote:
>>>> @@ -589,13 +647,7 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
>>>>  			.memcg = memcg,
>>>>  		};
>>>>  
>>>> -		/*
>>>> -		 * If kernel memory accounting is disabled, we ignore
>>>> -		 * SHRINKER_MEMCG_AWARE flag and call all shrinkers
>>>> -		 * passing NULL for memcg.
>>>> -		 */
>>>> -		if (memcg_kmem_enabled() &&
>>>> -		    !!memcg != !!(shrinker->flags & SHRINKER_MEMCG_AWARE))
>>>> +		if (!!memcg != !!(shrinker->flags & SHRINKER_MEMCG_AWARE))
>>>>  			continue;
>>>
>>> I want this check gone. It's easy to achieve, actually - just remove the
>>> following lines from shrink_node()
>>>
>>> 		if (global_reclaim(sc))
>>> 			shrink_slab(sc->gfp_mask, pgdat->node_id, NULL,
>>> 				    sc->priority);
>>
>> This check is not related to the patchset.
> 
> Yes, it is. This patch modifies shrink_slab which is used only by
> shrink_node. Simplifying shrink_node along the way looks right to me.

shrink_slab() is used not only in this place. I does not seem a trivial
change for me.

>> Let's don't mix everything in the single series of patches, because
>> after your last remarks it will grow at least up to 15 patches.
> 
> Most of which are trivial so I don't see any problem here.
> 
>> This patchset can't be responsible for everything.
> 
> I don't understand why you balk at simplifying the code a bit while you
> are patching related functions anyway.

Because this function is used in several places, and we have some particulars
on root_mem_cgroup initialization, and this function called from these places
with different states of root_mem_cgroup. It does not seem trivial fix for me.

Let's do it on top of the series later, what is the problem? It does not seem
critical problem.

Kirill
