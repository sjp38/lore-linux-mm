Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 594B0280725
	for <linux-mm@kvack.org>; Tue, 22 Aug 2017 15:47:30 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id f7so17087078lfg.12
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 12:47:30 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k203sor735713lfg.4.2017.08.22.12.47.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 22 Aug 2017 12:47:28 -0700 (PDT)
Date: Tue, 22 Aug 2017 22:47:25 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH 3/3] mm: Count list_lru_one::nr_items lockless
Message-ID: <20170822194725.ik3xwxu67wcthisb@esperanza>
References: <150340381428.3845.6099251634440472539.stgit@localhost.localdomain>
 <150340497499.3845.3045559119569209195.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <150340497499.3845.3045559119569209195.stgit@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: apolyakov@beget.ru, linux-kernel@vger.kernel.org, linux-mm@kvack.org, aryabinin@virtuozzo.com, akpm@linux-foundation.org

On Tue, Aug 22, 2017 at 03:29:35PM +0300, Kirill Tkhai wrote:
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

It would be nice to see how this is improved by this patch.
Can you try to record the traces on the vanilla kernel with
and without this patch?

> 
> This patch aims to make super_cache_count() more effective. It
> makes __list_lru_count_one() count nr_items lockless to minimize
> overhead introducing by locking operation, and to make parallel
> reclaims more scalable.
> 
> The lock won't be taken on shrinker::count_objects(),
> it would be taken only for the real shrink by the thread,
> who realizes it.
> 

> https://jira.sw.ru/browse/PSBM-69296

Not relevant.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
