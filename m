Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 27B7C280757
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 04:01:03 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id t3so9286709pgt.5
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 01:01:03 -0700 (PDT)
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30114.outbound.protection.outlook.com. [40.107.3.114])
        by mx.google.com with ESMTPS id t190si651433pgb.678.2017.08.23.01.01.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 23 Aug 2017 01:01:01 -0700 (PDT)
Subject: Re: [PATCH 3/3] mm: Count list_lru_one::nr_items lockless
References: <150340381428.3845.6099251634440472539.stgit@localhost.localdomain>
 <150340497499.3845.3045559119569209195.stgit@localhost.localdomain>
 <20170822194725.ik3xwxu67wcthisb@esperanza>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <b1600bca-32cc-e285-8589-778999584d5a@virtuozzo.com>
Date: Wed, 23 Aug 2017 11:00:56 +0300
MIME-Version: 1.0
In-Reply-To: <20170822194725.ik3xwxu67wcthisb@esperanza>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: apolyakov@beget.ru, linux-kernel@vger.kernel.org, linux-mm@kvack.org, aryabinin@virtuozzo.com, akpm@linux-foundation.org

On 22.08.2017 22:47, Vladimir Davydov wrote:
> On Tue, Aug 22, 2017 at 03:29:35PM +0300, Kirill Tkhai wrote:
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
> 
> It would be nice to see how this is improved by this patch.
> Can you try to record the traces on the vanilla kernel with
> and without this patch?

Sadly, the talk is about a production node, and it's impossible to use vanila kernel there.

>>
>> This patch aims to make super_cache_count() more effective. It
>> makes __list_lru_count_one() count nr_items lockless to minimize
>> overhead introducing by locking operation, and to make parallel
>> reclaims more scalable.
>>
>> The lock won't be taken on shrinker::count_objects(),
>> it would be taken only for the real shrink by the thread,
>> who realizes it.
>>
> 
>> https://jira.sw.ru/browse/PSBM-69296
> 
> Not relevant.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
