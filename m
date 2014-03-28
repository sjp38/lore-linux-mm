Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id 7A8D36B0035
	for <linux-mm@kvack.org>; Fri, 28 Mar 2014 03:56:36 -0400 (EDT)
Received: by mail-la0-f47.google.com with SMTP id y1so3387479lam.6
        for <linux-mm@kvack.org>; Fri, 28 Mar 2014 00:56:35 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id c1si2791860lbp.128.2014.03.28.00.56.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Mar 2014 00:56:34 -0700 (PDT)
Message-ID: <53352B2D.4000306@parallels.com>
Date: Fri, 28 Mar 2014 11:56:29 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm 1/4] sl[au]b: do not charge large allocations to memcg
References: <cover.1395846845.git.vdavydov@parallels.com> <5a5b09d4cb9a15fc120b4bec8be168630a3b43c2.1395846845.git.vdavydov@parallels.com> <xr93fvm42rew.fsf@gthelen.mtv.corp.google.com> <5333D527.2060208@parallels.com> <CAHH2K0YFB9yXF_oyxhQt9EiD_kuBuK7py6ah8YEy2H70P8SC_A@mail.gmail.com>
In-Reply-To: <CAHH2K0YFB9yXF_oyxhQt9EiD_kuBuK7py6ah8YEy2H70P8SC_A@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Glauber Costa <glommer@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, devel@openvz.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>

On 03/28/2014 12:42 AM, Greg Thelen wrote:
> On Thu, Mar 27, 2014 at 12:37 AM, Vladimir Davydov
> <vdavydov@parallels.com> wrote:
>> On 03/27/2014 08:31 AM, Greg Thelen wrote:
>>> Before this change both of the following allocations are charged to
>>> memcg (assuming kmem accounting is enabled):
>>>  a = kmalloc(KMALLOC_MAX_CACHE_SIZE, GFP_KERNEL)
>>>  b = kmalloc(KMALLOC_MAX_CACHE_SIZE + 1, GFP_KERNEL)
>>>
>>> After this change only 'a' is charged; 'b' goes directly to page
>>> allocator which no longer does accounting.
>>
>> Why do we need to charge 'b' in the first place? Can the userspace
>> trigger such allocations massively? If there can only be one or two such
>> allocations from a cgroup, is there any point in charging them?
> 
> Of the top of my head I don't know of any >8KIB kmalloc()s so I can't
> say if they're directly triggerable by user space en masse.  But we
> recently ran into some order:3 allocations in networking.  The
> networking allocations used a non-generic kmem_cache (rather than
> kmalloc which started this discussion).  For details, see ed98df3361f0
> ("net: use __GFP_NORETRY for high order allocations").  I can't say if
> such allocations exist in device drivers, but given the networking
> example, it's conceivable that they may (or will) exist.

Hmm, also not sure about device drivers, but the sock frag pages you
mentioned are worth charging I guess.

For such non-generic kmem allocations, we have two options: either go
with __GFP_KMEMCG, or introduce special alloc/free_kmem_pages methods,
which would be used instead of kmalloc for large allocations (e.g.
threadinfo, sock frags). I vote for the second, because I dislike having
kmemcg charging in the general allocation path.

Anyway, that brings us back to the necessity to reliably track arbitrary
pages in kmemcg to allow reparenting.

> With slab this isn't a problem because sla has kmalloc kmem_caches for
> all supported allocation sizes.  However, slub shows this issue for
> any kmalloc() allocations larger than 8KIB (at least on x86_64).  It
> seems like a strange directly to take kmem accounting to say that
> kmalloc allocations are kmem limited, but only if they are either less
> than a threshold size or done with slab.  Simply increasing the size
> of a data structure doesn't seem like it should automatically cause
> the memory to become exempt from kmem limits.

Sounds fair.

>> In fact, do we actually need to charge every random kmem allocation? I
>> guess not. For instance, filesystems often allocate data shared among
>> all the FS users. It's wrong to charge such allocations to a particular
>> memcg, IMO. That said the next step is going to be adding a per kmem
>> cache flag specifying if allocations from this cache should be charged
>> so that accounting will work only for those caches that are marked so
>> explicitly.
> 
> It's a question of what direction to approach kmem slab accounting
> from: either opt-out (as the code currently is), or opt-in (with per
> kmem_cache flags as you suggest).  I agree that some structures end up
> being shared (e.g. filesystem block bit map structures).  In an
> opt-out system these are charged to a memcg initially and remain
> charged there until the memcg is deleted at which point the shared
> objects are reparented to a shared location.  While this isn't
> perfect, it's unclear if it's better or worse than analyzing each
> class of allocation and deciding if they should be opt'd-in.  One
> could (though I'm not) make the case that even dentries are easily
> shareable between containers and thus shouldn't be accounted to a
> single memcg.  But given user space's ability to DoS a machine with
> dentires, they should be accounted.

Again, you must be right. After a bit of thinking I agree that deciding
which caches should be accounted and which shouldn't would be
cumbersome. Opt-out would be clearer, I guess.

>> There is one more argument for removing kmalloc_large accounting - we
>> don't have an easy way to track such allocations, which prevents us from
>> reparenting kmemcg charges on css offline. Of course, we could link
>> kmalloc_large pages in some sort of per-memcg list which would allow us
>> to find them on css offline, but I don't think such a complication is
>> justified.
> 
> I assume that reparenting of such non kmem_cache allocations (e.g.
> large kmalloc) is difficult because such pages refer to the memcg,
> which we're trying to delete and the memcg has no index of such pages.
>  If such zombie memcg are undesirable, then an alternative to indexing
> the pages is to define a kmem context object which such large pages
> point to.  The kmem context would be reparented without needing to
> adjust the individual large pages.  But there are plenty of options.

I like the idea about the context object. For usual kmalloc'ed data, we
already have one - the kmem_cache itself. For non-generic kmem (e.g.
threadinfo pages), we could easily introduce a separate one with the
pointer to the owning memcg on it. Reparenting wouldn't be a problem at
all then.

I guess I'll give it a try in the next iteration. Thank you!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
