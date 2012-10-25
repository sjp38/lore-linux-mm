Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id A689B6B0071
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 09:43:16 -0400 (EDT)
Message-ID: <508941DF.90204@parallels.com>
Date: Thu, 25 Oct 2012 17:42:55 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 06/18] consider a memcg parameter in kmem_create_cache
References: <1350656442-1523-1-git-send-email-glommer@parallels.com> <1350656442-1523-7-git-send-email-glommer@parallels.com> <CAAmzW4OJGSpEO2_p3v1MZJrh6G=+NSS5UoGqFDvxeaQ0qryvpw@mail.gmail.com>
In-Reply-To: <CAAmzW4OJGSpEO2_p3v1MZJrh6G=+NSS5UoGqFDvxeaQ0qryvpw@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JoonSoo Kim <js1304@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, devel@openvz.org, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

On 10/23/2012 09:50 PM, JoonSoo Kim wrote:
>> -struct kmem_cache *__kmem_cache_alias(const char *name, size_t size,
>> > -               size_t align, unsigned long flags, void (*ctor)(void *))
>> > +struct kmem_cache *
>> > +__kmem_cache_alias(struct mem_cgroup *memcg, const char *name, size_t size,
>> > +                  size_t align, unsigned long flags, void (*ctor)(void *))
>> >  {
>> >         struct kmem_cache *s;
>> >
>> > -       s = find_mergeable(size, align, flags, name, ctor);
>> > +       s = find_mergeable(memcg, size, align, flags, name, ctor);
>> >         if (s) {
>> >                 s->refcount++;
>> >                 /*
> If your intention is that find_mergeable() works for memcg-slab-caches properly,
> it cannot works properly with this code.
> When memcg is not NULL, slab cache is only added to memcg's slab cache list.
> find_mergeable() only interate on original-slab-cache list.
> So memcg slab cache never be mergeable.

Actually, recent results made me reconsider this.

I split this in multiple lists so we could transverse the lists faster
for /proc/slabinfo.

Turns out, there are many places that will rely on the ability to scan
through *all* caches in the system (root or not). This is one (easily
fixable) example, but there are others, like the hotplug handlers.

That said, I don't think that /proc/slabinfo is *that* performance
sensitive, so it is better to just skip the non-root caches, and just
keep all caches in the global list.

Maybe we would still benefit from a memcg-side list, for example, when
we're destructing memcg, so I'll consider keeping that (with a list
field in memcg_params). But even for that one, is still doable to
transverse the whole list...



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
