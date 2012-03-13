Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 2E3656B004A
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 19:21:05 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so1479002ghr.14
        for <linux-mm@kvack.org>; Tue, 13 Mar 2012 16:21:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4F5C8414.5090800@parallels.com>
References: <1331325556-16447-1-git-send-email-ssouhlal@FreeBSD.org>
	<1331325556-16447-7-git-send-email-ssouhlal@FreeBSD.org>
	<4F5C8414.5090800@parallels.com>
Date: Tue, 13 Mar 2012 16:21:03 -0700
Message-ID: <CABCjUKCioWO-F7k=hVs_18B3uyL4zG3-krPFDh++YAnmejKKdg@mail.gmail.com>
Subject: Re: [PATCH v2 06/13] slab: Add kmem_cache_gfp_flags() helper function.
From: Suleiman Souhlal <suleiman@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Suleiman Souhlal <ssouhlal@freebsd.org>, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, penberg@kernel.org, cl@linux.com, yinghan@google.com, hughd@google.com, gthelen@google.com, peterz@infradead.org, dan.magenheimer@oracle.com, hannes@cmpxchg.org, mgorman@suse.de, James.Bottomley@hansenpartnership.com, linux-mm@kvack.org, devel@openvz.org, linux-kernel@vger.kernel.org

On Sun, Mar 11, 2012 at 3:53 AM, Glauber Costa <glommer@parallels.com> wrot=
e:
> On 03/10/2012 12:39 AM, Suleiman Souhlal wrote:
>>
>> This function returns the gfp flags that are always applied to
>> allocations of a kmem_cache.
>>
>> Signed-off-by: Suleiman Souhlal<suleiman@google.com>
>> ---
>> =A0include/linux/slab_def.h | =A0 =A06 ++++++
>> =A0include/linux/slob_def.h | =A0 =A06 ++++++
>> =A0include/linux/slub_def.h | =A0 =A06 ++++++
>> =A03 files changed, 18 insertions(+), 0 deletions(-)
>>
>> diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
>> index fbd1117..25f9a6a 100644
>> --- a/include/linux/slab_def.h
>> +++ b/include/linux/slab_def.h
>> @@ -159,6 +159,12 @@ found:
>> =A0 =A0 =A0 =A0return __kmalloc(size, flags);
>> =A0}
>>
>> +static inline gfp_t
>> +kmem_cache_gfp_flags(struct kmem_cache *cachep)
>> +{
>> + =A0 =A0 =A0 return cachep->gfpflags;
>> +}
>> +
>> =A0#ifdef CONFIG_NUMA
>> =A0extern void *__kmalloc_node(size_t size, gfp_t flags, int node);
>> =A0extern void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, =
int
>> node);
>> diff --git a/include/linux/slob_def.h b/include/linux/slob_def.h
>> index 0ec00b3..3fa527d 100644
>> --- a/include/linux/slob_def.h
>> +++ b/include/linux/slob_def.h
>> @@ -34,4 +34,10 @@ static __always_inline void *__kmalloc(size_t size,
>> gfp_t flags)
>> =A0 =A0 =A0 =A0return kmalloc(size, flags);
>> =A0}
>>
>> +static inline gfp_t
>> +kmem_cache_gfp_flags(struct kmem_cache *cachep)
>> +{
>> + =A0 =A0 =A0 return 0;
>> +}
>> +
>> =A0#endif /* __LINUX_SLOB_DEF_H */
>> diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
>> index a32bcfd..5911d81 100644
>> --- a/include/linux/slub_def.h
>> +++ b/include/linux/slub_def.h
>> @@ -313,4 +313,10 @@ static __always_inline void *kmalloc_node(size_t
>> size, gfp_t flags, int node)
>> =A0}
>> =A0#endif
>>
>> +static inline gfp_t
>> +kmem_cache_gfp_flags(struct kmem_cache *cachep)
>> +{
>> + =A0 =A0 =A0 return cachep->allocflags;
>> +}
>> +
>
>
> Why is this needed? Can't the caller just call
> mem_cgroup_get_kmem_cache(cachep, flags | cachep->allocflags) ?

Because slub calls this cachep->allocflags, while slab calls it
cachep->gfpflags.

I'll look into renaming one of them to match the other.

-- Suleiman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
