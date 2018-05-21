Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1B4CF6B0007
	for <linux-mm@kvack.org>; Mon, 21 May 2018 10:52:23 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id e32-v6so11807334ote.23
        for <linux-mm@kvack.org>; Mon, 21 May 2018 07:52:23 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id y125-v6si4660923oig.434.2018.05.21.07.52.21
        for <linux-mm@kvack.org>;
        Mon, 21 May 2018 07:52:22 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: Re: [PATCH v2 0/7] mm: pages for hugetlb's overcommit may be able to charge to memcg
References: <e863529b-7ce5-4fbe-8cff-581b5789a5f9@ascade.co.jp>
Date: Mon, 21 May 2018 15:52:19 +0100
In-Reply-To: <e863529b-7ce5-4fbe-8cff-581b5789a5f9@ascade.co.jp> (TSUKADA
	Koutaro's message of "Fri, 18 May 2018 13:27:27 +0900")
Message-ID: <871se5ysbg.fsf@e105922-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: TSUKADA Koutaro <tsukada@ascade.co.jp>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, David Rientjes <rientjes@google.com>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Marc-Andre Lureau <marcandre.lureau@redhat.com>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

Hi Tsukada,

I was staring at memcg code to better understand your changes and had
the below thought.

TSUKADA Koutaro <tsukada@ascade.co.jp> writes:

[...]

> In this patch-set, introduce the charge_surplus_huge_pages(boolean) to
> struct hstate. If it is true, it charges to the memory cgroup to which the
> task that obtained surplus hugepages belongs. If it is false, do nothing as
> before, and the default value is false. The charge_surplus_huge_pages can
> be controlled procfs or sysfs interfaces.

Instead of tying the surplus huge page charging control per-hstate,
could the control be made per-memcg?

This can be done by introducing a per-memory controller file in sysfs
(memory.charge_surplus_hugepages?) that indicates whether surplus
hugepages are to be charged to the controller and forms part of the
total limit. IIUC, the limit already accounts for page and swap cache
pages.

This would allow the control to be enabled per-cgroup and also keep the
userspace control interface in one place.

As said earlier, I'm not familiar with memcg so the above might not be a
feasible but think it'll lead to a more coherent user
interface. Hopefully, more knowledgeable folks on the thread can chime
in.

Thanks,
Punit

> Since THP is very effective in environments with kernel page size of 4KB,
> such as x86, there is no reason to positively use HugeTLBfs, so I think
> that there is no situation to enable charge_surplus_huge_pages. However, in
> some distributions such as arm64, the page size of the kernel is 64KB, and
> the size of THP is too huge as 512MB, making it difficult to use. HugeTLBfs
> may support multiple huge page sizes, and in such a special environment
> there is a desire to use HugeTLBfs.
>
> The patch set is for 4.17.0-rc3+. I don't know whether patch-set are
> acceptable or not, so I just done a simple test.
>
> Thanks,
> Tsukada
>
> TSUKADA Koutaro (7):
>   hugetlb: introduce charge_surplus_huge_pages to struct hstate
>   hugetlb: supports migrate charging for surplus hugepages
>   memcg: use compound_order rather than hpage_nr_pages
>   mm, sysctl: make charging surplus hugepages controllable
>   hugetlb: add charge_surplus_hugepages attribute
>   Documentation, hugetlb: describe about charge_surplus_hugepages
>   memcg: supports movement of surplus hugepages statistics
>
>  Documentation/vm/hugetlbpage.txt |    6 +
>  include/linux/hugetlb.h          |    4 +
>  kernel/sysctl.c                  |    7 +
>  mm/hugetlb.c                     |  148 +++++++++++++++++++++++++++++++++++++++
>  mm/memcontrol.c                  |  109 +++++++++++++++++++++++++++-
>  5 files changed, 269 insertions(+), 5 deletions(-)
