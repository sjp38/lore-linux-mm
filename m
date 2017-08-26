Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 80F476810D7
	for <linux-mm@kvack.org>; Sat, 26 Aug 2017 13:57:38 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id c189so3197499lfe.7
        for <linux-mm@kvack.org>; Sat, 26 Aug 2017 10:57:38 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i70sor863741lfe.10.2017.08.26.10.57.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 26 Aug 2017 10:57:36 -0700 (PDT)
Date: Sat, 26 Aug 2017 20:57:33 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH 3/3] mm: Count list_lru_one::nr_items lockless
Message-ID: <20170826175733.wlnxteawx4aj7oqg@esperanza>
References: <150340381428.3845.6099251634440472539.stgit@localhost.localdomain>
 <150340497499.3845.3045559119569209195.stgit@localhost.localdomain>
 <20170822194725.ik3xwxu67wcthisb@esperanza>
 <b1600bca-32cc-e285-8589-778999584d5a@virtuozzo.com>
 <20170823082712.tw6qtyllctn25puq@esperanza>
 <6f4a624d-047f-6455-d8fa-e9e73871df03@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6f4a624d-047f-6455-d8fa-e9e73871df03@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: apolyakov@beget.ru, linux-kernel@vger.kernel.org, linux-mm@kvack.org, aryabinin@virtuozzo.com, akpm@linux-foundation.org

On Wed, Aug 23, 2017 at 03:26:12PM +0300, Kirill Tkhai wrote:
> On 23.08.2017 11:27, Vladimir Davydov wrote:
> > On Wed, Aug 23, 2017 at 11:00:56AM +0300, Kirill Tkhai wrote:
> >> On 22.08.2017 22:47, Vladimir Davydov wrote:
> >>> On Tue, Aug 22, 2017 at 03:29:35PM +0300, Kirill Tkhai wrote:
> >>>> During the reclaiming slab of a memcg, shrink_slab iterates
> >>>> over all registered shrinkers in the system, and tries to count
> >>>> and consume objects related to the cgroup. In case of memory
> >>>> pressure, this behaves bad: I observe high system time and
> >>>> time spent in list_lru_count_one() for many processes on RHEL7
> >>>> kernel (collected via $perf record --call-graph fp -j k -a):
> >>>>
> >>>> 0,50%  nixstatsagent  [kernel.vmlinux]  [k] _raw_spin_lock                [k] _raw_spin_lock
> >>>> 0,26%  nixstatsagent  [kernel.vmlinux]  [k] shrink_slab                   [k] shrink_slab
> >>>> 0,23%  nixstatsagent  [kernel.vmlinux]  [k] super_cache_count             [k] super_cache_count
> >>>> 0,15%  nixstatsagent  [kernel.vmlinux]  [k] __list_lru_count_one.isra.2   [k] _raw_spin_lock
> >>>> 0,15%  nixstatsagent  [kernel.vmlinux]  [k] list_lru_count_one            [k] __list_lru_count_one.isra.2
> >>>>
> >>>> 0,94%  mysqld         [kernel.vmlinux]  [k] _raw_spin_lock                [k] _raw_spin_lock
> >>>> 0,57%  mysqld         [kernel.vmlinux]  [k] shrink_slab                   [k] shrink_slab
> >>>> 0,51%  mysqld         [kernel.vmlinux]  [k] super_cache_count             [k] super_cache_count
> >>>> 0,32%  mysqld         [kernel.vmlinux]  [k] __list_lru_count_one.isra.2   [k] _raw_spin_lock
> >>>> 0,32%  mysqld         [kernel.vmlinux]  [k] list_lru_count_one            [k] __list_lru_count_one.isra.2
> >>>>
> >>>> 0,73%  sshd           [kernel.vmlinux]  [k] _raw_spin_lock                [k] _raw_spin_lock
> >>>> 0,35%  sshd           [kernel.vmlinux]  [k] shrink_slab                   [k] shrink_slab
> >>>> 0,32%  sshd           [kernel.vmlinux]  [k] super_cache_count             [k] super_cache_count
> >>>> 0,21%  sshd           [kernel.vmlinux]  [k] __list_lru_count_one.isra.2   [k] _raw_spin_lock
> >>>> 0,21%  sshd           [kernel.vmlinux]  [k] list_lru_count_one            [k] __list_lru_count_one.isra.2
> >>>
> >>> It would be nice to see how this is improved by this patch.
> >>> Can you try to record the traces on the vanilla kernel with
> >>> and without this patch?
> >>
> >> Sadly, the talk is about a production node, and it's impossible to use vanila kernel there.
> > 
> > I see :-( Then maybe you could try to come up with a contrived test?
> 
> I've tried and I'm not sure I'm able to reproduce on my test 8-cpu
> node the situation like I saw on production node via a test. Maybe you
> have an idea how to measure that?

Since the issue here is heavy lock contention while counting shrinkable
objects, what we need to do in order to demonstrate that this patch
really helps is trigger parallel direct reclaim that would walk over a
large number of cgroups. For the effect of this patch to be perceptible,
the cgroups should have no shrinkable objects (inodes, dentries)
accounted to them so that direct reclaim would spend most time counting
objects, not shrinking them. So I would try to create a cgroup with a
large number (say 1000) of empty sub-cgroups, set its limit to be <
system memory (to easily trigger direct reclaim and avoid kswapd
weighting in and disrupting the picture), and run N processes in it each
reading its own large file that does not fit in the limit where N is >
the number of cores (say 4 processes per core). I would expect each of
the processes to spend a lot of time trying to acquire a list_lru lock
to count inodes/dentries, which should be observed via perf. With this
patch the processes would be able to proceed in parallel without
stalling on list_lru lock.

> 
> I've changed the places, you commented, and the merged patch is below.
> How are you about it?

Looks good, thanks.

Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>

> 
> [PATCH]mm: Make count list_lru_one::nr_items lockless
>     
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
>     
> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
