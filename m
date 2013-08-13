Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 85D3A6B0032
	for <linux-mm@kvack.org>; Tue, 13 Aug 2013 00:53:49 -0400 (EDT)
Received: by mail-vc0-f181.google.com with SMTP id hz10so3436249vcb.26
        for <linux-mm@kvack.org>; Mon, 12 Aug 2013 21:53:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130812152812.915d5e8ebe5467586a457eb0@linux-foundation.org>
References: <1375995086-15456-1-git-send-email-avagin@openvz.org>
	<20130812152812.915d5e8ebe5467586a457eb0@linux-foundation.org>
Date: Tue, 13 Aug 2013 08:53:48 +0400
Message-ID: <CANaxB-zdt69+db0pprMEwmxhDRGprk9SwS0+ZCwhNqGTrxxKmQ@mail.gmail.com>
Subject: Re: [PATCH] [RFC] kmemcg: remove union from memcg_params
From: Andrey Wagin <avagin@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Glauber Costa <glommer@openvz.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

2013/8/13 Andrew Morton <akpm@linux-foundation.org>:
> On Fri,  9 Aug 2013 00:51:26 +0400 Andrey Vagin <avagin@openvz.org> wrote:
>
>> struct memcg_cache_params {
>>         bool is_root_cache;
>>         union {
>>                 struct kmem_cache *memcg_caches[0];
>>                 struct {
>>                         struct mem_cgroup *memcg;
>>                         struct list_head list;
>>                         struct kmem_cache *root_cache;
>>                         bool dead;
>>                         atomic_t nr_pages;
>>                         struct work_struct destroy;
>>                 };
>>         };
>> };
>>
>> This union is a bit dangerous. //Andrew Morton
>>
>> The first problem was fixed in v3.10-rc5-67-gf101a94.
>> The second problem is that the size of memory for root
>> caches is calculated incorrectly:
>>
>>       ssize_t size = memcg_caches_array_size(num_groups);
>>
>>       size *= sizeof(void *);
>>       size += sizeof(struct memcg_cache_params);
>>
>> The last line should be fixed like this:
>>       size += offsetof(struct memcg_cache_params, memcg_caches)
>>
>> Andrew suggested to rework this code without union and
>> this patch tries to do that.
>
> hm, did I?

I reread your messages. I have seen in it, what I want. Sorry, you
suggested to rework this code how you explained bellow in this
message. "without union" is my fantasy.
http://lkml.indiana.edu/hypermail/linux/kernel/1305.3/01985.html

>
>> This patch removes is_root_cache and union. The size of the
>> memcg_cache_params structure is not changed.
>>
>
> It's a bit sad to consume more space because we're sucky programmers.
> It would be better to retain the union and to stop writing buggy code
> to handle it!

I decided to implement this approach, because it doesn't increase
memory consumptions. This patch is replace is_root_cache on a pointer,
but due to alignment the size of the structure is not changed.

but the size of struct kmem_cache is increased on one pointer, if
accounting of kernel memory is not enabled.

The overhead of this patch on a real system is about 1K if the kernel
memory accounting is disabled and the overhead is zero after enabling
the accounting.

>
> Maybe there are things we can do to reduce the likelihood of people
> mishandling the union - don't use anonymous fields, name each member,
> access it via helper functions, etc.

Ok, I wil try this way.

Thanks,
Andrey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
