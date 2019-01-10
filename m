Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1579D8E0038
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 05:06:38 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id x9-v6so2613781ljd.21
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 02:06:38 -0800 (PST)
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id f17-v6si54698848ljb.89.2019.01.10.02.06.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 02:06:36 -0800 (PST)
Subject: Re: [PATCH RFC 0/3] mm: Reduce IO by improving algorithm of memcg
 pagecache pages eviction
References: <154703479840.32690.6504699919905946726.stgit@localhost.localdomain>
 <20190109154932.tpc27dk2hzeycqex@MacBook-Pro-91.local>
 <e7dc9a15-9438-cc15-c898-36eca325118a@virtuozzo.com>
 <20190109163353.pxb574odzfwdbcfe@macbook-pro-91.dhcp.thefacebook.com>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <e8cf89d3-f71a-4d9d-3ea0-18157f7da722@virtuozzo.com>
Date: Thu, 10 Jan 2019 13:06:29 +0300
MIME-Version: 1.0
In-Reply-To: <20190109163353.pxb574odzfwdbcfe@macbook-pro-91.dhcp.thefacebook.com>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, jack@suse.cz, hughd@google.com, darrick.wong@oracle.com, mhocko@suse.com, aryabinin@virtuozzo.com, guro@fb.com, mgorman@techsingularity.net, shakeelb@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09.01.2019 19:33, Josef Bacik wrote:
> On Wed, Jan 09, 2019 at 07:08:09PM +0300, Kirill Tkhai wrote:
>> Hi, Josef,
>>
>> On 09.01.2019 18:49, Josef Bacik wrote:
>>> On Wed, Jan 09, 2019 at 03:20:18PM +0300, Kirill Tkhai wrote:
>>>> On nodes without memory overcommit, it's common a situation,
>>>> when memcg exceeds its limit and pages from pagecache are
>>>> shrinked on reclaim, while node has a lot of free memory.
>>>> Further access to the pages requires real device IO, while
>>>> IO causes time delays, worse powerusage, worse throughput
>>>> for other users of the device, etc.
>>>>
>>>> Cleancache is not a good solution for this problem, since
>>>> it implies copying of page on every cleancache_put_page()
>>>> and cleancache_get_page(). Also, it requires introduction
>>>> of internal per-cleancache_ops data structures to manage
>>>> cached pages and their inodes relationships, which again
>>>> introduces overhead.
>>>>
>>>> This patchset introduces another solution. It introduces
>>>> a new scheme for evicting memcg pages:
>>>>
>>>>   1)__remove_mapping() uncharges unmapped page memcg
>>>>     and leaves page in pagecache on memcg reclaim;
>>>>
>>>>   2)putback_lru_page() places page into root_mem_cgroup
>>>>     list, since its memcg is NULL. Page may be evicted
>>>>     on global reclaim (and this will be easily, as
>>>>     page is not mapped, so shrinker will shrink it
>>>>     with 100% probability of success);
>>>>
>>>>   3)pagecache_get_page() charges page into memcg of
>>>>     a task, which takes it first.
>>>>
>>>> Below is small test, which shows profit of the patchset.
>>>>
>>>> Create memcg with limit 20M (exact value does not matter much):
>>>>   $ mkdir /sys/fs/cgroup/memory/ct
>>>>   $ echo 20M > /sys/fs/cgroup/memory/ct/memory.limit_in_bytes
>>>>   $ echo $$ > /sys/fs/cgroup/memory/ct/tasks
>>>>
>>>> Then twice read 1GB file:
>>>>   $ time cat file_1gb > /dev/null
>>>>
>>>> Before (2 iterations):
>>>>   1)0.01user 0.82system 0:11.16elapsed 7%CPU
>>>>   2)0.01user 0.91system 0:11.16elapsed 8%CPU
>>>>
>>>> After (2 iterations):
>>>>   1)0.01user 0.57system 0:11.31elapsed 5%CPU
>>>>   2)0.00user 0.28system 0:00.28elapsed 100%CPU
>>>>
>>>> With the patch set applied, we have file pages are cached
>>>> during the second read, so the result is 39 times faster.
>>>>
>>>> This may be useful for slow disks, NFS, nodes without
>>>> overcommit by memory, in case of two memcg access the same
>>>> files, etc.
>>>>
>>>
>>> This isn't going to work for us (Facebook).  The whole reason the hard limit
>>> exists is to keep different groups from messing up other groups.  Page cache
>>> reclaim is not free, most of our pain and most of the reason we use cgroups
>>> is to limit the effect of flooding the machine with pagecache from different
>>> groups.
>>
>> I understand the problem.
>>
>>> Memory leaks happen few and far between, but chef doing a yum
>>> update in the system container happens regularly.  If you talk about suddenly
>>> orphaning these pages to the root container it still creates pressure on the
>>> main workload, pressure that results in it having to take time from what it's
>>> doing and free up memory instead.
>>
>> Could you please to clarify additional pressure, which introduces the patchset?
>> The number of actions, which are needed to evict a pagecache page, remain almost
>> the same: we just delay __delete_from_page_cache() to global reclaim. Global
>> reclaim should not introduce much pressure, since it's the iteration on a single
>> memcg (we should not dive into hell of children memcg, since root memcg reclaim
>> should be successful and free enough pages, should't we?).
> 
> If we go into global reclaim at all.  If we're unable to allocate a page as the
> most important cgroup we start shrinking ourselves first right?  And then
> eventually end up in global reclaim, right?  So it may be easily enough
> reclaimed, but we're going to waste a lot of time getting there in the meantime,
> which means latency that's hard to pin down.
> 
> And secondly this allows hard limited cgroups to essentially leak pagecache into
> the whole system, creating waaaaaaay more memory pressure than what I think you
> intend.  Your logic is that we'll exceed our limit, evict some pagecache to the
> root cgroup, and we avoid a OOM and everything is ok.  However what will really
> happen is some user is going to do dd if=/dev/zero of=file and we'll just
> happily keep shoving these pages off into the root cg and suddenly we have 100gb
> of useless pagecache that we have to reclaim.  Yeah we just have to delete it
> from the root, but thats only once we get to that part, before that there's a
> bunch of latency inducing work that has to be done to get to deleting the pages.

Yeah, but what does introduce the most latency in setup? Do I understand correctly
that hard limit on your setup allows all alloc_pages() calls to go thru get_page_from_freelist()
path, so most allocations do not dive into __alloc_pages_slowpath()?

>>
>> Also, what is about implementing this as static key option? What about linking
>> orphaned pagecache pages into separate list, which is easy-to-iterate?
> 
> Yeah if we have a way to short-circuit the normal reclaim path and just go to
> evicting these easily evicted pages then that would make it more palatable.  But
> I'd like to see testing to verify that this faster way really is faster and
> doesn't induce latency on other protected workloads.  We put hard limits on
> groups we don't care about, we want those things to die in a fire.  The excess
> IO from re-reading those pages is mitigated with io.latency, and eventually
> io.weight for proportional control, so really isn't an argument for keeping
> pages around.  Thanks,
> 
> Josef
> 
