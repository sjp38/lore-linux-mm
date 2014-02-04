Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f182.google.com (mail-lb0-f182.google.com [209.85.217.182])
	by kanga.kvack.org (Postfix) with ESMTP id C92746B0035
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 10:27:23 -0500 (EST)
Received: by mail-lb0-f182.google.com with SMTP id w7so6613713lbi.13
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 07:27:23 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id e10si12875668laa.11.2014.02.04.07.27.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Feb 2014 07:27:22 -0800 (PST)
Message-ID: <52F106D7.3060802@parallels.com>
Date: Tue, 4 Feb 2014 19:27:19 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/8] memcg, slab: never try to merge memcg caches
References: <cover.1391356789.git.vdavydov@parallels.com> <27c4e7d7fb6b788b66995d2523225ef2dcbc6431.1391356789.git.vdavydov@parallels.com> <20140204145210.GH4890@dhcp22.suse.cz> <52F1004B.90307@parallels.com> <20140204151145.GI4890@dhcp22.suse.cz>
In-Reply-To: <20140204151145.GI4890@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: akpm@linux-foundation.org, rientjes@google.com, penberg@kernel.org, cl@linux.com, glommer@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org

On 02/04/2014 07:11 PM, Michal Hocko wrote:
> On Tue 04-02-14 18:59:23, Vladimir Davydov wrote:
>> On 02/04/2014 06:52 PM, Michal Hocko wrote:
>>> On Sun 02-02-14 20:33:48, Vladimir Davydov wrote:
>>>> Suppose we are creating memcg cache A that could be merged with cache B
>>>> of the same memcg. Since any memcg cache has the same parameters as its
>>>> parent cache, parent caches PA and PB of memcg caches A and B must be
>>>> mergeable too. That means PA was merged with PB on creation or vice
>>>> versa, i.e. PA = PB. From that it follows that A = B, and we couldn't
>>>> even try to create cache B, because it already exists - a contradiction.
>>> I cannot tell I understand the above but I am totally not sure about the
>>> statement bellow.
>>>
>>>> So let's remove unused code responsible for merging memcg caches.
>>> How come the code was unused? find_mergeable called cache_match_memcg...
>> Oh, sorry for misleading comment. I mean the code handling merging of
>> per-memcg caches is useless, AFAIU: if we find an alias for a per-memcg
>> cache on kmem_cache_create_memcg(), the parent of the found alias must
>> be the same as the parent_cache passed to kmem_cache_create_memcg(), but
>> if it were so, we would never proceed to the memcg cache creation,
>> because the cache we want to create already exists.
> I am still not sure I understand this correctly. So the outcome of this
> patch is that compatible caches of different memcgs can be merged
> together? Sorry if this is a stupid question but I am not that familiar
> with this area much I am just seeing that cache_match_memcg goes away
> and my understanding of the function is that it should prevent from
> different memcg's caches merging.

Let me try to explain how I understand it.

What is cache merging/aliasing? When we create a cache
(kmem_cache_create()), we first try to find a compatible cache that
already exists and can handle requests from the new cache. If it is, we
do not create any new caches, instead we simply increment the old cache
refcount and return it.

What about memcgs? Currently, it operates in the same way, i.e. on memcg
cache creation we also try to find a compatible cache of the same memcg
first. But if there were such a cache, they parents would have been
merged (i.e. it would be the same cache). That means we would not even
get to this memcg cache creation, because it already exists. That's why
the code handling memcg caches merging seems pointless to me.

What does this patch change? Actually, it introduces no functional
changes - it only remove the code trying to find an alias for a memcg
cache, because it will fail anyway. So this is rather a cleanup.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
