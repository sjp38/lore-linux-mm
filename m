Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f182.google.com (mail-lb0-f182.google.com [209.85.217.182])
	by kanga.kvack.org (Postfix) with ESMTP id 8A2E06B0031
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 04:01:36 -0500 (EST)
Received: by mail-lb0-f182.google.com with SMTP id l4so329054lbv.27
        for <linux-mm@kvack.org>; Thu, 19 Dec 2013 01:01:35 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id le8si1302846lab.33.2013.12.19.01.01.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 19 Dec 2013 01:01:35 -0800 (PST)
Message-ID: <52B2B5E8.6020307@parallels.com>
Date: Thu, 19 Dec 2013 13:01:28 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/6] memcg, slab: kmem_cache_create_memcg(): free memcg
 params on error
References: <6f02b2d079ffd0990ae335339c803337b13ecd8c.1387372122.git.vdavydov@parallels.com> <9420ad797a2cfa14c23ad1ba6db615a2a51ffee0.1387372122.git.vdavydov@parallels.com> <20131218170649.GC31080@dhcp22.suse.cz> <52B292FD.8040603@parallels.com> <20131219084845.GB9331@dhcp22.suse.cz>
In-Reply-To: <20131219084845.GB9331@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Glauber Costa <glommer@gmail.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On 12/19/2013 12:48 PM, Michal Hocko wrote:
> On Thu 19-12-13 10:32:29, Vladimir Davydov wrote:
>> On 12/18/2013 09:06 PM, Michal Hocko wrote:
>>> On Wed 18-12-13 17:16:53, Vladimir Davydov wrote:
>>>> Plus, rename memcg_register_cache() to memcg_init_cache_params(),
>>>> because it actually does not register the cache anywhere, but simply
>>>> initialize kmem_cache::memcg_params.
>>> I've almost missed this is a memory leak fix.
>> Yeah, the comment is poor, sorry about that. Will fix it.
>>
>>> I do not mind renaming and the name but wouldn't
>>> memcg_alloc_cache_params suit better?
>> As you wish. I don't have a strong preference for memcg_init_cache_params.
> I really hate naming... but it seems that alloc is a better fit. _init_
> would expect an already allocated object.
>
> Btw. memcg_free_cache_params is called only once which sounds
> suspicious. The regular destroy path should use it as well?
> [...]

The usual destroy path uses memcg_release_cache(), which does the trick.
Plus, it actually "unregisters" the cache. BTW, I forgot to substitute
kfree(s->memcg_params) with the new memcg_free_cache_params() there.
Although it currently does not break anything, better to fix it in case
new memcg_free_cache_params() will have to do something else.

And you're right about the naming is not good.

Currently we have:

  on create:
    memcg_register_cache()
    memcg_cache_list_add()
  on destroy:
    memcg_release_cache()

After this patch we would have:

  on create:
    memcg_alloc_cache_params()
    memcg_register_cache()
  on destroy:
    memcg_release_cache()

Still not perfect: "alloc" does not have corresponding "free", while
"register" does not have corresponding "unregister", everything is done
by "release".

What do you think about splitting memcg_release_cache() into two functions:

    memcg_unregister_cache()
    memcg_free_cache_params()

?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
