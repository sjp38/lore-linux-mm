Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 58FA26B025E
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 18:21:57 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id r202so727063wmd.1
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 15:21:57 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id e7sor3680717wrg.71.2017.10.10.15.21.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 10 Oct 2017 15:21:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171010091042.eokqlrqec33w3qzt@dhcp22.suse.cz>
References: <20171005222144.123797-1-shakeelb@google.com> <20171006075900.icqjx5rr7hctn3zd@dhcp22.suse.cz>
 <CALvZod7YN4JCG7Anm2FViyZ0-APYy+nxEd3nyxe5LT_P0FC9wg@mail.gmail.com>
 <20171009062426.hmqedtqz5hkmhnff@dhcp22.suse.cz> <xr93a810xl77.fsf@gthelen.svl.corp.google.com>
 <20171009180409.z3mpk3m7m75hjyfv@dhcp22.suse.cz> <20171009181754.37svpqljub2goojr@dhcp22.suse.cz>
 <20171010091042.eokqlrqec33w3qzt@dhcp22.suse.cz>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 10 Oct 2017 15:21:53 -0700
Message-ID: <CALvZod5VzPRRbhxLSn5GkgPbJEVJ9X5SfA=rjzRtTqLbCAe+eA@mail.gmail.com>
Subject: Re: [PATCH] fs, mm: account filp and names caches to kmemcg
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Greg Thelen <gthelen@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>

On Sun, Oct 8, 2017 at 11:24 PM, Michal Hocko <mhocko@kernel.org> wrote:
> On Fri 06-10-17 12:33:03, Shakeel Butt wrote:
>> >>       names_cachep = kmem_cache_create("names_cache", PATH_MAX, 0,
>> >> -                     SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL);
>> >> +                     SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_ACCOUNT, NULL);
>> >
>> > I might be wrong but isn't name cache only holding temporary objects
>> > used for path resolution which are not stored anywhere?
>> >
>>
>> Even though they're temporary, many containers can together use a
>> significant amount of transient uncharged memory. We've seen machines
>> with 100s of MiBs in names_cache.
>
> Yes that might be possible but are we prepared for random ENOMEM from
> vfs calls which need to allocate a temporary name?
>

I looked at all the syscalls which invoke allocations from
'names_cache' and tried to narrow down whose man page does not mention
that they can return ENOMEM. I found couple of syscalls like
truncate(), readdir() & getdents() which does not mention that they
can return ENOMEM but this patch will make them return ENOMEM.

>>
>> >>       filp_cachep = kmem_cache_create("filp", sizeof(struct file), 0,
>> >> -                     SLAB_HWCACHE_ALIGN | SLAB_PANIC, NULL);
>> >> +                     SLAB_HWCACHE_ALIGN | SLAB_PANIC | SLAB_ACCOUNT, NULL);
>> >>       percpu_counter_init(&nr_files, 0, GFP_KERNEL);
>> >>  }
>> >
>> > Don't we have a limit for the maximum number of open files?
>> >
>>
>> Yes, there is a system limit of maximum number of open files. However
>> this limit is shared between different users on the system and one
>> user can hog this resource. To cater that, we set the maximum limit
>> very high and let the memory limit of each user limit the number of
>> files they can open.
>
> Similarly here. Are all syscalls allocating a fd prepared to return
> ENOMEM?

For filp, I found _sysctl(). However the man page says not to use it.

On Tue, Oct 10, 2017 at 2:10 AM, Michal Hocko <mhocko@kernel.org> wrote:
> On Mon 09-10-17 20:17:54, Michal Hocko wrote:
>> the primary concern for this patch was whether we really need/want to
>> charge short therm objects which do not outlive a single syscall.
>
> Let me expand on this some more. What is the benefit of kmem accounting
> of such an object? It cannot stop any runaway as a syscall lifetime
> allocations are bound to number of processes which we kind of contain by
> other means.

We can contain by limited the number of processes or thread but for us
applications having thousands of threads is very common. So, limiting
the number of threads/processes will not work.

> If we do account then we put a memory pressure due to
> something that cannot be reclaimed by no means. Even the memcg OOM
> killer would simply kick a single path while there might be others
> to consume the same type of memory.
>
> So what is the actual point in accounting these? Does it help to contain
> any workload better? What kind of workload?
>

I think the benefits will be isolation and more accurate billing. As I
have said before we have observed 100s of MiBs in names_cache on many
machines and cumulative amount is not something we can ignore as just
memory overhead.

> Or am I completely wrong and name objects can outlive a syscall
> considerably?
>

No, I didn't find any instance of the name objects outliving the syscall.

Anyways, we can discuss more on names_cache, do you have any objection
regarding charging filp?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
