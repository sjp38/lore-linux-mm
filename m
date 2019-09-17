Return-Path: <SRS0=uo52=XM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88F57C4CECD
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 19:49:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 48F1A20862
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 19:49:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 48F1A20862
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D96C76B0007; Tue, 17 Sep 2019 15:49:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D48666B0008; Tue, 17 Sep 2019 15:49:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C5D806B000A; Tue, 17 Sep 2019 15:49:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0230.hostedemail.com [216.40.44.230])
	by kanga.kvack.org (Postfix) with ESMTP id 9F43F6B0007
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 15:49:03 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 1C2E5180AD807
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 19:49:03 +0000 (UTC)
X-FDA: 75945450966.14.fruit64_6bfd4e5f53b3a
X-HE-Tag: fruit64_6bfd4e5f53b3a
X-Filterd-Recvd-Size: 8217
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf46.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 19:49:01 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 228EF8A1C96;
	Tue, 17 Sep 2019 19:49:00 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-160.bos.redhat.com [10.18.17.160])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 8D0DC5D9D5;
	Tue, 17 Sep 2019 19:48:57 +0000 (UTC)
Subject: Re: [PATCH RFC 00/14] The new slab memory controller
To: Roman Gushchin <guro@fb.com>, linux-mm@kvack.org
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>,
 linux-kernel@vger.kernel.org, kernel-team@fb.com,
 Shakeel Butt <shakeelb@google.com>, Vladimir Davydov <vdavydov.dev@gmail.com>
References: <20190905214553.1643060-1-guro@fb.com>
From: Waiman Long <longman@redhat.com>
Organization: Red Hat
Message-ID: <f63d7f69-83e2-22bc-c235-e887ea03f0c8@redhat.com>
Date: Tue, 17 Sep 2019 15:48:57 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190905214553.1643060-1-guro@fb.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.6.2 (mx1.redhat.com [10.5.110.69]); Tue, 17 Sep 2019 19:49:00 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 9/5/19 5:45 PM, Roman Gushchin wrote:
> The existing slab memory controller is based on the idea of replicating
> slab allocator internals for each memory cgroup. This approach promises
> a low memory overhead (one pointer per page), and isn't adding too much
> code on hot allocation and release paths. But is has a very serious flaw:
> it leads to a low slab utilization.
>
> Using a drgn* script I've got an estimation of slab utilization on
> a number of machines running different production workloads. In most
> cases it was between 45% and 65%, and the best number I've seen was
> around 85%. Turning kmem accounting off brings it to high 90s. Also
> it brings back 30-50% of slab memory. It means that the real price
> of the existing slab memory controller is way bigger than a pointer
> per page.
>
> The real reason why the existing design leads to a low slab utilization
> is simple: slab pages are used exclusively by one memory cgroup.
> If there are only few allocations of certain size made by a cgroup,
> or if some active objects (e.g. dentries) are left after the cgroup is
> deleted, or the cgroup contains a single-threaded application which is
> barely allocating any kernel objects, but does it every time on a new CPU:
> in all these cases the resulting slab utilization is very low.
> If kmem accounting is off, the kernel is able to use free space
> on slab pages for other allocations.
>
> Arguably it wasn't an issue back to days when the kmem controller was
> introduced and was an opt-in feature, which had to be turned on
> individually for each memory cgroup. But now it's turned on by default
> on both cgroup v1 and v2. And modern systemd-based systems tend to
> create a large number of cgroups.
>
> This patchset provides a new implementation of the slab memory controller,
> which aims to reach a much better slab utilization by sharing slab pages
> between multiple memory cgroups. Below is the short description of the new
> design (more details in commit messages).
>
> Accounting is performed per-object instead of per-page. Slab-related
> vmstat counters are converted to bytes. Charging is performed on page-basis,
> with rounding up and remembering leftovers.
>
> Memcg ownership data is stored in a per-slab-page vector: for each slab page
> a vector of corresponding size is allocated. To keep slab memory reparenting
> working, instead of saving a pointer to the memory cgroup directly an
> intermediate object is used. It's simply a pointer to a memcg (which can be
> easily changed to the parent) with a built-in reference counter. This scheme
> allows to reparent all allocated objects without walking them over and changing
> memcg pointer to the parent.
>
> Instead of creating an individual set of kmem_caches for each memory cgroup,
> two global sets are used: the root set for non-accounted and root-cgroup
> allocations and the second set for all other allocations. This allows to
> simplify the lifetime management of individual kmem_caches: they are destroyed
> with root counterparts. It allows to remove a good amount of code and make
> things generally simpler.
>
> The patchset contains a couple of semi-independent parts, which can find their
> usage outside of the slab memory controller too:
> 1) subpage charging API, which can be used in the future for accounting of
>    other non-page-sized objects, e.g. percpu allocations.
> 2) mem_cgroup_ptr API (refcounted pointers to a memcg, can be reused
>    for the efficient reparenting of other objects, e.g. pagecache.
>
> The patchset has been tested on a number of different workloads in our
> production. In all cases, it saved hefty amounts of memory:
> 1) web frontend, 650-700 Mb, ~42% of slab memory
> 2) database cache, 750-800 Mb, ~35% of slab memory
> 3) dns server, 700 Mb, ~36% of slab memory
>
> So far I haven't found any regression on all tested workloads, but
> potential CPU regression caused by more precise accounting is a concern.
>
> Obviously the amount of saved memory depend on the number of memory cgroups,
> uptime and specific workloads, but overall it feels like the new controller
> saves 30-40% of slab memory, sometimes more. Additionally, it should lead
> to a lower memory fragmentation, just because of a smaller number of
> non-movable pages and also because there is no more need to move all
> slab objects to a new set of pages when a workload is restarted in a new
> memory cgroup.
>
> * https://github.com/osandov/drgn
>
>
> Roman Gushchin (14):
>   mm: memcg: subpage charging API
>   mm: memcg: introduce mem_cgroup_ptr
>   mm: vmstat: use s32 for vm_node_stat_diff in struct per_cpu_nodestat
>   mm: vmstat: convert slab vmstat counter to bytes
>   mm: memcg/slab: allocate space for memcg ownership data for non-root
>     slabs
>   mm: slub: implement SLUB version of obj_to_index()
>   mm: memcg/slab: save memcg ownership data for non-root slab objects
>   mm: memcg: move memcg_kmem_bypass() to memcontrol.h
>   mm: memcg: introduce __mod_lruvec_memcg_state()
>   mm: memcg/slab: charge individual slab objects instead of pages
>   mm: memcg: move get_mem_cgroup_from_current() to memcontrol.h
>   mm: memcg/slab: replace memcg_from_slab_page() with
>     memcg_from_slab_obj()
>   mm: memcg/slab: use one set of kmem_caches for all memory cgroups
>   mm: slab: remove redundant check in memcg_accumulate_slabinfo()
>
>  drivers/base/node.c        |  11 +-
>  fs/proc/meminfo.c          |   4 +-
>  include/linux/memcontrol.h | 102 ++++++++-
>  include/linux/mm_types.h   |   5 +-
>  include/linux/mmzone.h     |  12 +-
>  include/linux/slab.h       |   3 +-
>  include/linux/slub_def.h   |   9 +
>  include/linux/vmstat.h     |   8 +
>  kernel/power/snapshot.c    |   2 +-
>  mm/list_lru.c              |  12 +-
>  mm/memcontrol.c            | 431 +++++++++++++++++++++--------------
>  mm/oom_kill.c              |   2 +-
>  mm/page_alloc.c            |   8 +-
>  mm/slab.c                  |  37 ++-
>  mm/slab.h                  | 300 +++++++++++++------------
>  mm/slab_common.c           | 449 ++++---------------------------------
>  mm/slob.c                  |  12 +-
>  mm/slub.c                  |  63 ++----
>  mm/vmscan.c                |   3 +-
>  mm/vmstat.c                |  38 +++-
>  mm/workingset.c            |   6 +-
>  21 files changed, 683 insertions(+), 834 deletions(-)
>
I can only see the first 9 patches. Patches 10-14 are not there.

Cheers,
Longman


