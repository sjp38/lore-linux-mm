Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id B85226B0038
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 17:15:34 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b195so16194745wmb.6
        for <linux-mm@kvack.org>; Wed, 27 Sep 2017 14:15:34 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id a81si160617wmi.226.2017.09.27.14.15.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Sep 2017 14:15:33 -0700 (PDT)
Date: Wed, 27 Sep 2017 14:15:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Make count list_lru_one::nr_items lockless
Message-Id: <20170927141530.25286286fb92a2573c4b548f@linux-foundation.org>
In-Reply-To: <150583358557.26700.8490036563698102569.stgit@localhost.localdomain>
References: <150583358557.26700.8490036563698102569.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: vdavydov.dev@gmail.com, apolyakov@beget.ru, linux-kernel@vger.kernel.org, linux-mm@kvack.org, aryabinin@virtuozzo.com

On Tue, 19 Sep 2017 18:06:33 +0300 Kirill Tkhai <ktkhai@virtuozzo.com> wrote:

> During the reclaiming slab of a memcg, shrink_slab iterates
> over all registered shrinkers in the system, and tries to count
> and consume objects related to the cgroup. In case of memory
> pressure, this behaves bad: I observe high system time and
> time spent in list_lru_count_one() for many processes on RHEL7
> kernel (collected via $perf record --call-graph fp -j k -a):
> 
> 0,50%  nixstatsagent  [kernel.vmlinux]  [k] _raw_spin_lock                [k] _raw_spin_lock
> 0,26%  nixstatsagent  [kernel.vmlinux]  [k] shrink_slab                   [k] shrink_slab
> 0,23%  nixstatsagent  [kernel.vmlinux]  [k] super_cache_count             [k] super_cache_count
> 0,15%  nixstatsagent  [kernel.vmlinux]  [k] __list_lru_count_one.isra.2   [k] _raw_spin_lock
> 0,15%  nixstatsagent  [kernel.vmlinux]  [k] list_lru_count_one            [k] __list_lru_count_one.isra.2
> 
> 0,94%  mysqld         [kernel.vmlinux]  [k] _raw_spin_lock                [k] _raw_spin_lock
> 0,57%  mysqld         [kernel.vmlinux]  [k] shrink_slab                   [k] shrink_slab
> 0,51%  mysqld         [kernel.vmlinux]  [k] super_cache_count             [k] super_cache_count
> 0,32%  mysqld         [kernel.vmlinux]  [k] __list_lru_count_one.isra.2   [k] _raw_spin_lock
> 0,32%  mysqld         [kernel.vmlinux]  [k] list_lru_count_one            [k] __list_lru_count_one.isra.2
> 
> 0,73%  sshd           [kernel.vmlinux]  [k] _raw_spin_lock                [k] _raw_spin_lock
> 0,35%  sshd           [kernel.vmlinux]  [k] shrink_slab                   [k] shrink_slab
> 0,32%  sshd           [kernel.vmlinux]  [k] super_cache_count             [k] super_cache_count
> 0,21%  sshd           [kernel.vmlinux]  [k] __list_lru_count_one.isra.2   [k] _raw_spin_lock
> 0,21%  sshd           [kernel.vmlinux]  [k] list_lru_count_one            [k] __list_lru_count_one.isra.2
> 
> This patch aims to make super_cache_count() (and other functions,
> which count LRU nr_items) more effective.
> It allows list_lru_node::memcg_lrus to be RCU-accessed, and makes
> __list_lru_count_one() count nr_items lockless to minimize
> overhead introduced by locking operation, and to make parallel
> reclaims more scalable.

And...  what were the effects of the patch?  Did you not run the same
performance tests after applying it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
