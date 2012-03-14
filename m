Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 72A3A6B0044
	for <linux-mm@kvack.org>; Wed, 14 Mar 2012 18:04:35 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so2966171ghr.14
        for <linux-mm@kvack.org>; Wed, 14 Mar 2012 15:04:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4F60775F.20709@parallels.com>
References: <1331325556-16447-1-git-send-email-ssouhlal@FreeBSD.org>
	<1331325556-16447-8-git-send-email-ssouhlal@FreeBSD.org>
	<4F5C7D82.7030904@parallels.com>
	<CABCjUKDsYyg4ONGTEeh1oen-L=OuBrP53qRdpHAT8AYYQ-JqWA@mail.gmail.com>
	<4F60775F.20709@parallels.com>
Date: Wed, 14 Mar 2012 15:04:33 -0700
Message-ID: <CABCjUKCWaXTzsVaFHG57ELWV4Yk15vt=Ei8tvbsxpQKnxTmksg@mail.gmail.com>
Subject: Re: [PATCH v2 07/13] memcg: Slab accounting.
From: Suleiman Souhlal <suleiman@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Suleiman Souhlal <ssouhlal@freebsd.org>, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, cl@linux.com, yinghan@google.com, hughd@google.com, gthelen@google.com, peterz@infradead.org, dan.magenheimer@oracle.com, hannes@cmpxchg.org, mgorman@suse.de, James.Bottomley@hansenpartnership.com, linux-mm@kvack.org, devel@openvz.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@kernel.org>

On Wed, Mar 14, 2012 at 3:47 AM, Glauber Costa <glommer@parallels.com> wrot=
e:
> On 03/14/2012 02:50 AM, Suleiman Souhlal wrote:
>>
>> On Sun, Mar 11, 2012 at 3:25 AM, Glauber Costa<glommer@parallels.com>
>> =A0wrote:
>>>
>>> On 03/10/2012 12:39 AM, Suleiman Souhlal wrote:
>>>>
>>>> +static inline void
>>>> +mem_cgroup_kmem_cache_prepare_sleep(struct kmem_cache *cachep)
>>>> +{
>>>> + =A0 =A0 =A0 /*
>>>> + =A0 =A0 =A0 =A0* Make sure the cache doesn't get freed while we have
>>>> interrupts
>>>> + =A0 =A0 =A0 =A0* enabled.
>>>> + =A0 =A0 =A0 =A0*/
>>>> + =A0 =A0 =A0 kmem_cache_get_ref(cachep);
>>>> + =A0 =A0 =A0 rcu_read_unlock();
>>>> +}
>>>
>>>
>>>
>>> Is this really needed ? After this function call in slab.c, the slab co=
de
>>> itself accesses cachep a thousand times. If it could be freed, it would
>>> already explode today for other reasons?
>>> Am I missing something here?
>>
>>
>> We need this because once we drop the rcu_read_lock and go to sleep,
>> the memcg could get deleted, which could lead to the cachep from
>> getting deleted as well.
>>
>> So, we need to grab a reference to the cache, to make sure that the
>> cache doesn't disappear from under us.
>
>
> Don't we grab a memcg reference when we fire the cache creation?
> (I did that for slub, can't really recall from the top of my head if
> you are doing it as well)
>
> That would prevent the memcg to go away, while relieving us from the
> need to take a temporary reference for every page while sleeping.

The problem isn't the memcg going away, but the cache going away.

>>>> +static struct kmem_cache *
>>>> +memcg_create_kmem_cache(struct mem_cgroup *memcg, struct kmem_cache
>>>> *cachep)
>>>> +{
>>>> + =A0 =A0 =A0 struct kmem_cache *new_cachep;
>>>> + =A0 =A0 =A0 struct dentry *dentry;
>>>> + =A0 =A0 =A0 char *name;
>>>> + =A0 =A0 =A0 int idx;
>>>> +
>>>> + =A0 =A0 =A0 idx =3D cachep->memcg_params.id;
>>>> +
>>>> + =A0 =A0 =A0 dentry =3D memcg->css.cgroup->dentry;
>>>> + =A0 =A0 =A0 BUG_ON(dentry =3D=3D NULL);
>>>> +
>>>> + =A0 =A0 =A0 /* Preallocate the space for "dead" at the end */
>>>> + =A0 =A0 =A0 name =3D kasprintf(GFP_KERNEL, "%s(%d:%s)dead",
>>>> + =A0 =A0 =A0 =A0 =A0 cachep->name, css_id(&memcg->css), dentry->d_nam=
e.name);
>>>> + =A0 =A0 =A0 if (name =3D=3D NULL)
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return cachep;
>>>> + =A0 =A0 =A0 /* Remove "dead" */
>>>> + =A0 =A0 =A0 name[strlen(name) - 4] =3D '\0';
>>>> +
>>>> + =A0 =A0 =A0 new_cachep =3D kmem_cache_create_memcg(cachep, name);
>>>> +
>>>> + =A0 =A0 =A0 /*
>>>> + =A0 =A0 =A0 =A0* Another CPU is creating the same cache?
>>>> + =A0 =A0 =A0 =A0* We'll use it next time.
>>>> + =A0 =A0 =A0 =A0*/
>>>
>>>
>>> This comment is a bit misleading. Is it really the only reason
>>> it can fail?
>>>
>>> The impression I got is that it can also fail under the normal conditio=
ns
>>> in
>>> which kmem_cache_create() fails.
>>
>>
>> kmem_cache_create() isn't expected to fail often.
>> I wasn't making an exhaustive lists of why this condition can happen,
>> just what I think is the most common one is.
>
>
> Keep in mind that our notion of "fail often" may start to change when
> we start limiting the amount of kernel memory =3Dp.
>
> Specially in nested cgroups limited by its parent.
>
> So apart from the comment issue, the problem here to me seems to be that:
>
> yes, kmem_cache_create failing is rare. But the circumstances in which it
> can happen all involve memory pressure. And in this case, we'll leave
> memcg->slabs[idx] as NULL, which means we'll keep trying to create the ca=
che
> in further allocations.
>
> This seems at best a tricky way to escape the memcg constraint...
>
> I am not sure this is the behavior we want. Have to think a little bit.

Keep in mind that this function is only called in workqueue context.
(In the earlier revision of the patchset this function was called in
the process context, but kmem_cache_create() would ignore memory
limits, because of __GFP_NOACCOUNT.)

>>>> @@ -1756,17 +1765,23 @@ static void *kmem_getpages(struct kmem_cache
>>>> *cachep, gfp_t flags, int nodeid)
>>>> =A0 =A0 =A0 =A0if (cachep->flags& =A0 =A0SLAB_RECLAIM_ACCOUNT)
>>>>
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0flags |=3D __GFP_RECLAIMABLE;
>>>>
>>>> + =A0 =A0 =A0 nr_pages =3D (1<< =A0 =A0cachep->gfporder);
>>>> + =A0 =A0 =A0 if (!mem_cgroup_charge_slab(cachep, flags, nr_pages *
>>>> PAGE_SIZE))
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
>>>> +
>>>> =A0 =A0 =A0 =A0page =3D alloc_pages_exact_node(nodeid, flags | __GFP_N=
OTRACK,
>>>> cachep->gfporder);
>>>> - =A0 =A0 =A0 if (!page)
>>>> + =A0 =A0 =A0 if (!page) {
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_uncharge_slab(cachep, nr_page=
s * PAGE_SIZE);
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return NULL;
>>>> + =A0 =A0 =A0 }
>>>
>>>
>>>
>>>
>>> Can't the following happen:
>>>
>>> =A0*) mem_cgroup_charge_slab() is the first one to touch the slab.
>>> =A0 =A0Therefore, this first one is billed to root.
>>> =A0*) A slab is queued for creation.
>>> =A0*) alloc_pages sleep.
>>> =A0*) our workers run, and create the cache, therefore filling
>>> =A0 =A0cachep->memcg_param.memcg
>>> =A0*) alloc_pages still can't allocate.
>>> =A0*) uncharge tries to uncharge from cachep->memcg_param.memcg,
>>> =A0 =A0which doesn't have any charges...
>>>
>>> Unless you have a strong oposition to this, to avoid this kind of
>>> corner cases, we could do what I was doing in the slub:
>>> Allocate the page first, and then account it.
>>> (freeing the page if it fails).
>>>
>>> I know it is not the way it is done for the user pages, but I believe i=
t
>>> to
>>> be better suited for the slab.
>>
>>
>> I don't think the situation you're describing can happen, because the
>> memcg caches get created and selected at the beginning of the slab
>> allocation, in mem_cgroup_get_kmem_cache() and not in
>> mem_cgroup_charge_slab(), which is much later.
>>
>> Once we are in mem_cgroup_charge_slab() we know that the allocation
>> will be charged to the cgroup.
>
>
> That's not how I read it. Since there is no completion guarantees coming
> from the workqueue, I really don't see how we can be sure that the data i=
n
> cachep->memcg_param.memcg won't change.
>
> You are right that touching the slab actually happens in
> mem_cgroup_get_kmem_cache(). That is called in kmem_cache_aloc(). And the
> first object is likely to be billed to the parent cgroup (or root)
>
> Now imagine that cache being full, so we need a new page for it.
> This will quickly lead us to cache_grow(), and all the other steps are
> therefore the same.
>
> So how can we guarantee that the memcg pointer is stable between alloc an=
d
> free?

When mem_cgroup_get_kmem_cache() returns a memcg cache, that cache has
already been created.

The memcg pointer is not stable between alloc and free: It can become
NULL when the cgroup gets deleted, at which point the accounting has
been "moved to root" (uncharged from the cgroup it was charged in).
When that has happened, we don't want to uncharge it again.
I think the current code already handles this situation.

>>>> @@ -2703,12 +2787,74 @@ void kmem_cache_destroy(struct kmem_cache
>>>> *cachep)
>>>> =A0 =A0 =A0 =A0if (unlikely(cachep->flags& =A0 =A0SLAB_DESTROY_BY_RCU)=
)
>>>>
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rcu_barrier();
>>>>
>>>> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
>>>> + =A0 =A0 =A0 /* Not a memcg cache */
>>>> + =A0 =A0 =A0 if (cachep->memcg_params.id !=3D -1) {
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __clear_bit(cachep->memcg_params.id, cac=
he_types);
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_flush_cache_create_queue();
>>>> + =A0 =A0 =A0 }
>>>> +#endif
>>>
>>>
>>>
>>> This will clear the id when a leaf cache is destroyed. It seems it is n=
ot
>>> what we want, right? We want this id to be cleared only when
>>> the parent cache is gone.
>>
>>
>> id !=3D -1, for parent caches (that's what the comment is trying to poin=
t
>> out).
>> I will improve the comment.
>
>
> /me goes check all the code again...
>
> Does that mean that when two memcg's are creating the same cache they wil=
l
> end up with different ids??

No, only parent caches have an id that is not -1. memcg caches always
have an id of -1.
Sorry if that wasn't clear. I will try to document it better.

-- Suleiman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
