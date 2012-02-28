Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 129E16B004A
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 18:31:16 -0500 (EST)
Received: by qcsd16 with SMTP id d16so2858482qcs.14
        for <linux-mm@kvack.org>; Tue, 28 Feb 2012 15:31:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4F4CD573.20208@parallels.com>
References: <1330383533-20711-1-git-send-email-ssouhlal@FreeBSD.org>
	<1330383533-20711-6-git-send-email-ssouhlal@FreeBSD.org>
	<4F4CD573.20208@parallels.com>
Date: Tue, 28 Feb 2012 15:31:14 -0800
Message-ID: <CABCjUKCXuY3mKX-zj51=PZLmD9ojVyerqx7UjaMiJgYwAcE6HQ@mail.gmail.com>
Subject: Re: [PATCH 05/10] memcg: Slab accounting.
From: Suleiman Souhlal <suleiman@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Suleiman Souhlal <ssouhlal@freebsd.org>, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, penberg@kernel.org, yinghan@google.com, hughd@google.com, gthelen@google.com, linux-mm@kvack.org, devel@openvz.org

On Tue, Feb 28, 2012 at 5:24 AM, Glauber Costa <glommer@parallels.com> wrot=
e:
> On 02/27/2012 07:58 PM, Suleiman Souhlal wrote:
>>
>> Introduce per-cgroup kmem_caches for memcg slab accounting, that
>> get created the first time we do an allocation of that type in the
>> cgroup.
>> If we are not permitted to sleep in that allocation, the cache
>> gets created asynchronously.
>
> And then we allocate from the root cgroup?

Yes, the allocation will go to the root cgroup (or not get accounted
at all if you don't have CONFIG_CGROUP_MEM_RES_CTLR_KMEM_ACCT_ROOT).
Once the workqueue runs and creates the memcg cache, all the
allocations of that type will start using it.

>> The cgroup cache gets used in subsequent allocations, and permits
>> accounting of slab on a per-page basis.
>>
>> The per-cgroup kmem_caches get looked up at slab allocation time,
>> in a MAX_KMEM_CACHE_TYPES-sized array in the memcg structure, based
>> on the original kmem_cache's id, which gets allocated when the original
>> cache gets created.
>>
>> Allocations that cannot be attributed to a cgroup get charged to
>> the root cgroup.
>>
>> Each cgroup kmem_cache has a refcount that dictates the lifetime
>> of the cache: We destroy a cgroup cache when its cgroup has been
>> destroyed and there are no more active objects in the cache.
>
>
> Since we already track the number of pages in the slab, why do we need a
> refcnt?

I must be missing something, but I don't see a counter of the number
of active pages in the cache in the code. :-(

>> diff --git a/include/linux/slab.h b/include/linux/slab.h
>> index 573c809..fe21a91 100644
>> --- a/include/linux/slab.h
>> +++ b/include/linux/slab.h
>> @@ -21,6 +21,7 @@
>> =A0#define SLAB_POISON =A0 =A0 =A0 =A0 =A0 0x00000800UL =A0 =A0/* DEBUG:=
 Poison objects */
>> =A0#define SLAB_HWCACHE_ALIGN =A0 =A00x00002000UL =A0 =A0/* Align objs o=
n cache
>> lines */
>> =A0#define SLAB_CACHE_DMA =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00x00004000UL =
=A0 =A0/* Use GFP_DMA
>> memory */
>> +#define SLAB_MEMCG =A0 =A0 =A0 =A0 =A0 =A0 0x00008000UL =A0 =A0/* memcg=
 kmem_cache */
>> =A0#define SLAB_STORE_USER =A0 =A0 =A0 =A0 =A0 =A0 =A0 0x00010000UL =A0 =
=A0/* DEBUG: Store the
>> last owner for bug hunting */
>> =A0#define SLAB_PANIC =A0 =A0 =A0 =A0 =A0 =A00x00040000UL =A0 =A0/* Pani=
c if
>> kmem_cache_create() fails */
>> =A0/*
>
>
> We'll get to this later, but I dislike adding this flag, since we can jus=
t
> test for existence of a pointer that we need to track anyway in
> the slab structure.

I might be able to remove this flag. I'll try to get that done in v2.

>
> This may create some problems when we track it for root memcg, but this i=
s
> something your patchset does, and I believe we shouldn't.
>
>
>> diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
>> index fbd1117..449a0de 100644
>> --- a/include/linux/slab_def.h
>> +++ b/include/linux/slab_def.h
>> @@ -41,6 +41,10 @@ struct kmem_cache {
>> =A0 =A0 =A0 =A0/* force GFP flags, e.g. GFP_DMA */
>> =A0 =A0 =A0 =A0gfp_t gfpflags;
>>
>> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
>> + =A0 =A0 =A0 int id; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*=
 id used for slab accounting */
>> +#endif
>> +
>
> What role does it play? Is it the same as the array index in my patchset?

Yes, this is the index into the memcg slab array.
The id gets allocated when someone does kmem_cache_create().


>> =A0 =A0 =A0 =A0size_t colour; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* cach=
e colouring range */
>> =A0 =A0 =A0 =A0unsigned int colour_off; =A0 =A0 =A0 =A0/* colour offset =
*/
>> =A0 =A0 =A0 =A0struct kmem_cache *slabp_cache;
>> @@ -51,7 +55,7 @@ struct kmem_cache {
>> =A0 =A0 =A0 =A0void (*ctor)(void *obj);
>>
>> =A0/* 4) cache creation/removal */
>> - =A0 =A0 =A0 const char *name;
>> + =A0 =A0 =A0 char *name;
>> =A0 =A0 =A0 =A0struct list_head next;
>>
>> =A0/* 5) statistics */
>> @@ -78,9 +82,26 @@ struct kmem_cache {
>> =A0 =A0 =A0 =A0 * variables contain the offset to the user object and it=
s size.
>> =A0 =A0 =A0 =A0 */
>> =A0 =A0 =A0 =A0int obj_offset;
>> - =A0 =A0 =A0 int obj_size;
>> =A0#endif /* CONFIG_DEBUG_SLAB */
>>
>> +#if defined(CONFIG_DEBUG_SLAB) ||
>> defined(CONFIG_CGROUP_MEM_RES_CTLR_KMEM)
>> + =A0 =A0 =A0 int obj_size;
>> +#endif
>> +
>> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
>> + =A0 =A0 =A0 /* Original cache parameters, used when creating a memcg c=
ache */
>> + =A0 =A0 =A0 size_t orig_align;
>> + =A0 =A0 =A0 unsigned long orig_flags;
>> +
>> + =A0 =A0 =A0 struct mem_cgroup *memcg;
>> +
>> + =A0 =A0 =A0 /* Who we copied from when creating cpuset cache */
>> + =A0 =A0 =A0 struct kmem_cache *orig_cache;
>> +
>> + =A0 =A0 =A0 atomic_t refcnt;
>> + =A0 =A0 =A0 struct list_head destroyed_list; /* Used when deleting cpu=
set
>> cache */
>> +#endif /* CONFIG_CGROUP_MEM_RES_CTLR_KMEM */
>
> I think you're adding way to many things here.
>
> I prefer the approach I took of having a memcg pointer, and then having t=
hat
> stuff into memcg. It will be better for people not interested in this
> feature - like if you compile this in, but then does not mount memcg.

Given that there are only on the order of a hundred different
kmem_caches, when slab accounting is disabled, I'm not sure the 52
bytes (or 64?) that are being added here are a big concern.

If you really think this is important, I can move them to a different struc=
ture.

>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index c82ca1c..d1c0cd7 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -297,6 +297,11 @@ struct mem_cgroup {
>> =A0#ifdef CONFIG_INET
>> =A0 =A0 =A0 =A0struct tcp_memcontrol tcp_mem;
>> =A0#endif
>> +
>> +#if defined(CONFIG_CGROUP_MEM_RES_CTLR_KMEM)&& =A0defined(CONFIG_SLAB)
>>
>> + =A0 =A0 =A0 /* Slab accounting */
>> + =A0 =A0 =A0 struct kmem_cache *slabs[MAX_KMEM_CACHE_TYPES];
>> +#endif
>> =A0 =A0 =A0 =A0int independent_kmem_limit;
>> =A0};
>>
>> @@ -5633,6 +5638,312 @@ memcg_uncharge_kmem(struct mem_cgroup *memcg, lo=
ng
>> long delta)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0res_counter_uncharge(&memcg->res, delta);
>> =A0}
>>
>> +#ifdef CONFIG_SLAB
>
>
> Why CONFIG_SLAB? If this is in memcontrol.c, shouldn't have anything
> slab-specific here...

I'm not sure this code will compile with another slab allocator.
I'll look into what I need to do get rid of these #ifdefs.

Thanks,
-- Suleiman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
