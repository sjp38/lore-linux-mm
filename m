Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 377A16B0038
	for <linux-mm@kvack.org>; Thu, 28 Sep 2017 03:49:07 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 188so2376223pgb.3
        for <linux-mm@kvack.org>; Thu, 28 Sep 2017 00:49:07 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0094.outbound.protection.outlook.com. [104.47.2.94])
        by mx.google.com with ESMTPS id j2si856388pgs.702.2017.09.28.00.49.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 28 Sep 2017 00:49:05 -0700 (PDT)
Subject: Re: [PATCH] mm: Make count list_lru_one::nr_items lockless
References: <150583358557.26700.8490036563698102569.stgit@localhost.localdomain>
 <20170927141530.25286286fb92a2573c4b548f@linux-foundation.org>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <fbb67bef-c13f-7fcb-fa6a-e3a7f6e5c82b@virtuozzo.com>
Date: Thu, 28 Sep 2017 10:48:55 +0300
MIME-Version: 1.0
In-Reply-To: <20170927141530.25286286fb92a2573c4b548f@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: vdavydov.dev@gmail.com, apolyakov@beget.ru, linux-kernel@vger.kernel.org, linux-mm@kvack.org, aryabinin@virtuozzo.com

On 28.09.2017 00:15, Andrew Morton wrote:
> On Tue, 19 Sep 2017 18:06:33 +0300 Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
> 
>> During the reclaiming slab of a memcg, shrink_slab iterates
>> over all registered shrinkers in the system, and tries to count
>> and consume objects related to the cgroup. In case of memory
>> pressure, this behaves bad: I observe high system time and
>> time spent in list_lru_count_one() for many processes on RHEL7
>> kernel (collected via $perf record --call-graph fp -j k -a):
>>
>> 0,50%  nixstatsagent  [kernel.vmlinux]  [k] _raw_spin_lock                [k] _raw_spin_lock
>> 0,26%  nixstatsagent  [kernel.vmlinux]  [k] shrink_slab                   [k] shrink_slab
>> 0,23%  nixstatsagent  [kernel.vmlinux]  [k] super_cache_count             [k] super_cache_count
>> 0,15%  nixstatsagent  [kernel.vmlinux]  [k] __list_lru_count_one.isra.2   [k] _raw_spin_lock
>> 0,15%  nixstatsagent  [kernel.vmlinux]  [k] list_lru_count_one            [k] __list_lru_count_one.isra.2
>>
>> 0,94%  mysqld         [kernel.vmlinux]  [k] _raw_spin_lock                [k] _raw_spin_lock
>> 0,57%  mysqld         [kernel.vmlinux]  [k] shrink_slab                   [k] shrink_slab
>> 0,51%  mysqld         [kernel.vmlinux]  [k] super_cache_count             [k] super_cache_count
>> 0,32%  mysqld         [kernel.vmlinux]  [k] __list_lru_count_one.isra.2   [k] _raw_spin_lock
>> 0,32%  mysqld         [kernel.vmlinux]  [k] list_lru_count_one            [k] __list_lru_count_one.isra.2
>>
>> 0,73%  sshd           [kernel.vmlinux]  [k] _raw_spin_lock                [k] _raw_spin_lock
>> 0,35%  sshd           [kernel.vmlinux]  [k] shrink_slab                   [k] shrink_slab
>> 0,32%  sshd           [kernel.vmlinux]  [k] super_cache_count             [k] super_cache_count
>> 0,21%  sshd           [kernel.vmlinux]  [k] __list_lru_count_one.isra.2   [k] _raw_spin_lock
>> 0,21%  sshd           [kernel.vmlinux]  [k] list_lru_count_one            [k] __list_lru_count_one.isra.2
>>
>> This patch aims to make super_cache_count() (and other functions,
>> which count LRU nr_items) more effective.
>> It allows list_lru_node::memcg_lrus to be RCU-accessed, and makes
>> __list_lru_count_one() count nr_items lockless to minimize
>> overhead introduced by locking operation, and to make parallel
>> reclaims more scalable.
> 
> And...  what were the effects of the patch?  Did you not run the same
> performance tests after applying it?

I've just detected the such high usage of shrink slab on production node. It's rather
difficult to make it use another kernel, than it uses, only kpatches are possible.
So, I haven't estimated how it acts on node's performance.
On test node I see, that the patch obviously removes raw_spin_lock from perf profile.
So, it's a little bit untested in this way.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
