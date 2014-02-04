Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f51.google.com (mail-la0-f51.google.com [209.85.215.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4233C6B0031
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 14:19:30 -0500 (EST)
Received: by mail-la0-f51.google.com with SMTP id c6so6723376lan.24
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 11:19:29 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id ml5si13511741lbc.35.2014.02.04.11.19.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Feb 2014 11:19:27 -0800 (PST)
Message-ID: <52F13D3C.801@parallels.com>
Date: Tue, 4 Feb 2014 23:19:24 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 3/7] memcg, slab: separate memcg vs root cache creation
 paths
References: <cover.1391441746.git.vdavydov@parallels.com> <81a403327163facea2b4c7b720fdc0ef62dd1dbf.1391441746.git.vdavydov@parallels.com> <20140204160336.GL4890@dhcp22.suse.cz>
In-Reply-To: <20140204160336.GL4890@dhcp22.suse.cz>
Content-Type: multipart/mixed;
	boundary="------------030205050305010109080506"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: akpm@linux-foundation.org, rientjes@google.com, penberg@kernel.org, cl@linux.com, glommer@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org

--------------030205050305010109080506
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit

On 02/04/2014 08:03 PM, Michal Hocko wrote:
> On Mon 03-02-14 19:54:38, Vladimir Davydov wrote:
>> Memcg-awareness turned kmem_cache_create() into a dirty interweaving of
>> memcg-only and except-for-memcg calls. To clean this up, let's create a
>> separate function handling memcg caches creation. Although this will
>> result in the two functions having several hunks of practically the same
>> code, I guess this is the case when readability fully covers the cost of
>> code duplication.
> I don't know. The code is apparently cleaner because calling a function
> with NULL memcg just to go via several if (memcg) branches is ugly as
> hell. But having a duplicated function like this calls for a problem
> later.
>
> Would it be possible to split kmem_cache_create into memcg independant
> part and do the rest in a single memcg branch?

May be, something like the patch attached?

>  
>> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
>> ---
>>  include/linux/memcontrol.h |   14 ++---
>>  include/linux/slab.h       |    9 ++-
>>  mm/memcontrol.c            |   16 ++----
>>  mm/slab_common.c           |  130 ++++++++++++++++++++++++++------------------
>>  4 files changed, 90 insertions(+), 79 deletions(-)
>>
>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>> index 84e4801fc36c..de79a9617e09 100644
>> --- a/include/linux/memcontrol.h
>> +++ b/include/linux/memcontrol.h
>> @@ -500,8 +500,8 @@ int memcg_cache_id(struct mem_cgroup *memcg);
>>  
>>  char *memcg_create_cache_name(struct mem_cgroup *memcg,
>>  			      struct kmem_cache *root_cache);
>> -int memcg_alloc_cache_params(struct mem_cgroup *memcg, struct kmem_cache *s,
>> -			     struct kmem_cache *root_cache);
>> +int memcg_alloc_cache_params(struct kmem_cache *s,
>> +		struct mem_cgroup *memcg, struct kmem_cache *root_cache);
> Why is the parameters ordering changed? It really doesn't help
> review the patch.

Oh, this is because seeing something like

memcg_alloc_cache_params(NULL, s, NULL);

hurts my brain :-) I prefer to have NULLs in the end.

> Also what does `s' stand for and can we use a more
> descriptive name, please?

Yes, we can call it `cachep', but it would be too long :-/

`s' is the common name for a kmem_cache throughout mm/sl[au]b.c so I
guess it fits here. However, this function certainly needs a comment - I
guess I'll do it along with swapping the function parameters in a
separate patch.

Thanks.

--------------030205050305010109080506
Content-Type: text/x-patch;
	name="0001-memcg-slab-separate-memcg-vs-root-cache-creation-pat.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename*0="0001-memcg-slab-separate-memcg-vs-root-cache-creation-pat.pa";
	filename*1="tch"


--------------030205050305010109080506--
