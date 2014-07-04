Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id A27686B0031
	for <linux-mm@kvack.org>; Fri,  4 Jul 2014 11:39:17 -0400 (EDT)
Received: by mail-la0-f52.google.com with SMTP id ty20so1247793lab.25
        for <linux-mm@kvack.org>; Fri, 04 Jul 2014 08:39:16 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id z2si27166475lae.17.2014.07.04.08.39.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Jul 2014 08:39:15 -0700 (PDT)
Date: Fri, 4 Jul 2014 19:38:53 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH RFC 0/5] Virtual Memory Resource Controller for cgroups
Message-ID: <20140704153853.GA369@esperanza>
References: <cover.1404383187.git.vdavydov@parallels.com>
 <20140704121621.GE12466@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20140704121621.GE12466@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tejun
 Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Balbir Singh <bsingharora@gmail.com>

Hi Michal,

On Fri, Jul 04, 2014 at 02:16:21PM +0200, Michal Hocko wrote:
> On Thu 03-07-14 16:48:16, Vladimir Davydov wrote:
> > Hi,
> > 
> > Typically, when a process calls mmap, it isn't given all the memory pages it
> > requested immediately. Instead, only its address space is grown, while the
> > memory pages will be actually allocated on the first use. If the system fails
> > to allocate a page, it will have no choice except invoking the OOM killer,
> > which may kill this or any other process. Obviously, it isn't the best way of
> > telling the user that the system is unable to handle his request. It would be
> > much better to fail mmap with ENOMEM instead.
> > 
> > That's why Linux has the memory overcommit control feature, which accounts and
> > limits VM size that may contribute to mem+swap, i.e. private writable mappings
> > and shared memory areas. However, currently it's only available system-wide,
> > and there's no way of avoiding OOM in cgroups.
> >
> > This patch set is an attempt to fill the gap. It implements the resource
> > controller for cgroups that accounts and limits address space allocations that
> > may contribute to mem+swap.
> 
> Well, I am not really sure how helpful is this. Could you be more
> specific about real use cases? If the only problem is that memcg OOM can
> trigger to easily then I do not think this is the right approach to
> handle it.

The problem is that an application inside a container is currently given
no hints on how much memory it may actually consume. It can mmap a huge
area and eventually find itself killed or swapped out after using
several percent of it. This can be painful sometimes. Let me give an
example.

Suppose a user wants to run some computational workload, which may take
several days. He doesn't exactly know how much memory it will consume,
so he decides to start with buying a 1G container for it. He then starts
the workload in the container and sees it's working fine for some time.
So he decides he guessed the container size right and now only has to
wait for a day or two. Suppose the workload actually wants 10G. Or it
can consume up to 100G and has some weird logic to determine how much
memory the system may give it, e.g. trying to mmap as much as possible.
Suppose the server the container is running on has 1000G. The workload
won't fail immediately then. It will be allowed to consume 1G, which may
take quite long, but finally it will either fail with OOM or become
really sluggish due to swap out. The user will probably be frustrated to
see his workload failed when he comes back in a day or two, because it
will cost him money and time. This wouldn't happen if there were the VM
limit, which stopped the application immediately at start giving the
user a hint that something is going wrong and he needs to either tune
his application (e.g. setting -Xmsn for java) or buy a bigger container.

You can argue that the container may have a kind of meminfo
virtualization and any sane application must go and check it, but (1)
not all applications do that (some may try mmap-until-failure
heuristic), (2) there may be several unrelated processes inside CT, each
checking that there are pretty of free mem according to meminfo, mmaping
it and failing later, (3) it may be an application container, which
doesn't have proc mounted.

I guess that's why most distributions have overcommit limited by default
(vm.overcommit_memory!=2).

> Strict no-overcommit is basically unusable for many workloads.
> Especially those which try to do their own memory usage optimization
> in a much larger address space.

Sure, 'no-overcommit' is definitely unusable, but we can set it to e.g.
twice memcg limit. This will allow to overcommit memory to some extent,
but fail for really large allocations that can never be served.

> Once I get from internal things (which will happen soon hopefully) I
> will post a series with a new sets of memcg limits. One of them is
> high_limit which can be used as a trigger for memcg reclaim. Unlike
> hard_limit there won't be any OOM if the reclaim fails at this stage. So
> if the high_limit is configured properly the admin will have enough time
> to make additional steps before OOM happens.

High/low limits that start reclaim on internal/external pressure are
definitely a very nice feature (may be even more useful that strict
limits). However, they won't help us against overcommit inside a
container. AFAIC,

 - low limit will allow the container to consume as much as he wants
   until it triggers global memory pressure, then it will be shrunk back
   to its limit aggressively;

 - high limit means allow to breach the limit, but trigger reclaim
   asynchronously (a kind of kswapd) or synchronously when it happens.

Right?

Considering the example I've given above, both of these won't help if
the system has other active CTs: the container will be forcefully kept
around its high/low limit and, since it's definitely not enough for it,
it will be finally killed crossing out the computations it's spent so
much time on. High limit won't be good for the container even if there's
no other load on the node - it will be constantly swapping out anon
memory and evicting file caches. The application won't die quickly then,
but it will get a heavy slowdown, which is no better than killing I
guess.

Also, I guess it'd be beneficial to have

 - mlocked pages accounting per cgroup, because they affect memory
   reclaim, and how low/high limits work, so it'd be nice to have them
   limited to a sane value;

 - shmem areas accounting per cgroup, because the total amount of shmem
   on the system is limited, and it'll be no good if malicious
   containers eat it all.

IMO It wouldn't be a good idea to overwhelm memcg with those limits, the
VM controller suits much better.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
