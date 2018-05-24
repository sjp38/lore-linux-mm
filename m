Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D38C86B0271
	for <linux-mm@kvack.org>; Thu, 24 May 2018 00:26:32 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id p189-v6so240207pfp.2
        for <linux-mm@kvack.org>; Wed, 23 May 2018 21:26:32 -0700 (PDT)
Received: from ns.ascade.co.jp (ext-host0001.ascade.co.jp. [218.224.228.194])
        by mx.google.com with ESMTP id b7-v6si14937362pgn.583.2018.05.23.21.26.30
        for <linux-mm@kvack.org>;
        Wed, 23 May 2018 21:26:30 -0700 (PDT)
Subject: Re: [PATCH v2 0/7] mm: pages for hugetlb's overcommit may be able to
 charge to memcg
References: <e863529b-7ce5-4fbe-8cff-581b5789a5f9@ascade.co.jp>
 <20180522135148.GA20441@dhcp22.suse.cz>
From: TSUKADA Koutaro <tsukada@ascade.co.jp>
Message-ID: <af1a3050-7365-428a-dfb1-2f3da37dc9ff@ascade.co.jp>
Date: Thu, 24 May 2018 13:26:12 +0900
MIME-Version: 1.0
In-Reply-To: <20180522135148.GA20441@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, David Rientjes <rientjes@google.com>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Marc-Andre Lureau <marcandre.lureau@redhat.com>, Punit Agrawal <punit.agrawal@arm.com>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On 2018/05/22 22:51, Michal Hocko wrote:
> On Fri 18-05-18 13:27:27, TSUKADA Koutaro wrote:
>> The purpose of this patch-set is to make it possible to control whether or
>> not to charge surplus hugetlb pages obtained by overcommitting to memory
>> cgroup. In the future, I am trying to accomplish limiting the memory usage
>> of applications that use both normal pages and hugetlb pages by the memory
>> cgroup(not use the hugetlb cgroup).
> 
> There was a deliberate decision to keep hugetlb and "normal" memory
> cgroup controllers separate. Mostly because hugetlb memory is an
> artificial memory subsystem on its own and it doesn't fit into the rest
> of memcg accounted memory very well. I believe we want to keep that
> status quo.
> 
>> Applications that use shared libraries like libhugetlbfs.so use both normal
>> pages and hugetlb pages, but we do not know how much to use each. Please
>> suppose you want to manage the memory usage of such applications by cgroup
>> How do you set the memory cgroup and hugetlb cgroup limit when you want to
>> limit memory usage to 10GB?
> 
> Well such a usecase requires an explicit configuration already. Either
> by using special wrappers or modifying the code. So I would argue that
> you have quite a good knowlege of the setup. If you need a greater
> flexibility then just do not use hugetlb at all and rely on THP.
> [...]
> 
>> In this patch-set, introduce the charge_surplus_huge_pages(boolean) to
>> struct hstate. If it is true, it charges to the memory cgroup to which the
>> task that obtained surplus hugepages belongs. If it is false, do nothing as
>> before, and the default value is false. The charge_surplus_huge_pages can
>> be controlled procfs or sysfs interfaces.
> 
> I do not really think this is a good idea. We really do not want to make
> the current hugetlb code more complex than it is already. The current
> hugetlb cgroup controller is simple and works at least somehow. I would
> not add more on top unless there is a _really_ strong usecase behind.
> Please make sure to describe such a usecase in details before we even
> start considering the code.

Thank you for your time.

I do not know if it is really a strong use case, but I will explain my
motive in detail. English is not my native language, so please pardon
my poor English.

I am one of the developers for software that managing the resource used
from user job at HPC-Cluster with Linux. The resource is memory mainly.
The HPC-Cluster may be shared by multiple people and used. Therefore, the
memory used by each user must be strictly controlled, otherwise the
user's job will runaway, not only will it hamper the other users, it will
crash the entire system in OOM.

Some users of HPC are very nervous about performance. Jobs are executed
while synchronizing with MPI communication using multiple compute nodes.
Since CPU wait time will occur when synchronizing, they want to minimize
the variation in execution time at each node to reduce waiting times as
much as possible. We call this variation a noise.

THP does not guarantee to use the Huge Page, but may use the normal page.
This mechanism is one cause of variation(noise).

The users who know this mechanism will be hesitant to use THP. However,
the users also know the benefits of the Huge Page's TLB hit rate
performance, and the Huge Page seems to be attractive. It seems natural
that these users are interested in HugeTLBfs, I do not know at all
whether it is the right approach or not.

At the very least, our HPC system is pursuing high versatility and we
have to consider whether we can provide it if users want to use HugeTLBfs.

In order to use HugeTLBfs we need to create a persistent pool, but in
our use case sharing nodes, it would be impossible to create, delete or
resize the pool.

One of the answers I have reached is to use HugeTLBfs by overcommitting
without creating a pool(this is the surplus hugepage).

Surplus hugepages is hugetlb page, but I think at least that consuming
buddy pool is a decisive difference from hugetlb page of persistent pool.
If nr_overcommit_hugepages is assumed to be infinite, allocating pages for
surplus hugepages from buddy pool is all unlimited even if being limited
by memcg. In extreme cases, overcommitment will allow users to exhaust
the entire memory of the system. Of course, this can be prevented by the
hugetlb cgroup, but even if we set the limit for memcg and hugetlb cgroup
respectively, as I asked in the first mail(set limit to 10GB), the
control will not work.

I thought I could charge surplus hugepages to memcg, but maybe I did not
have enough knowledge about memcg. I would like to reply to another mail
for details.

>> Since THP is very effective in environments with kernel page size of 4KB,
>> such as x86, there is no reason to positively use HugeTLBfs, so I think
>> that there is no situation to enable charge_surplus_huge_pages. However, in
>> some distributions such as arm64, the page size of the kernel is 64KB, and
>> the size of THP is too huge as 512MB, making it difficult to use. HugeTLBfs
>> may support multiple huge page sizes, and in such a special environment
>> there is a desire to use HugeTLBfs.
> 
> Well, then I would argue that you shouldn't use 64kB pages for your
> setup or allow THP for smaller sizes. Really hugetlb pages are by no
> means a substitute here.
> 

Actually, I am opposed to the 64KB page, but the proposal to change the
page size is expected to be dismissed as a problem.

-- 
Thanks,
Tsukada
