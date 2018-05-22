Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E6C096B0003
	for <linux-mm@kvack.org>; Tue, 22 May 2018 14:54:11 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id y82-v6so791969wmb.5
        for <linux-mm@kvack.org>; Tue, 22 May 2018 11:54:11 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w50-v6si811907edm.249.2018.05.22.11.54.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 22 May 2018 11:54:10 -0700 (PDT)
Date: Tue, 22 May 2018 20:54:07 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 0/7] mm: pages for hugetlb's overcommit may be able to
 charge to memcg
Message-ID: <20180522185407.GC20441@dhcp22.suse.cz>
References: <e863529b-7ce5-4fbe-8cff-581b5789a5f9@ascade.co.jp>
 <240f1b14-ed7d-4983-6c52-be4899d4caa5@oracle.com>
 <8711fed5-fc35-a11a-3a17-740a9dca1f2a@ascade.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8711fed5-fc35-a11a-3a17-740a9dca1f2a@ascade.co.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: TSUKADA Koutaro <tsukada@ascade.co.jp>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, David Rientjes <rientjes@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Marc-Andre Lureau <marcandre.lureau@redhat.com>, Punit Agrawal <punit.agrawal@arm.com>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Tue 22-05-18 22:04:23, TSUKADA Koutaro wrote:
> On 2018/05/22 3:07, Mike Kravetz wrote:
> > On 05/17/2018 09:27 PM, TSUKADA Koutaro wrote:
> >> Thanks to Mike Kravetz for comment on the previous version patch.
> >>
> >> The purpose of this patch-set is to make it possible to control whether or
> >> not to charge surplus hugetlb pages obtained by overcommitting to memory
> >> cgroup. In the future, I am trying to accomplish limiting the memory usage
> >> of applications that use both normal pages and hugetlb pages by the memory
> >> cgroup(not use the hugetlb cgroup).
> >>
> >> Applications that use shared libraries like libhugetlbfs.so use both normal
> >> pages and hugetlb pages, but we do not know how much to use each. Please
> >> suppose you want to manage the memory usage of such applications by cgroup
> >> How do you set the memory cgroup and hugetlb cgroup limit when you want to
> >> limit memory usage to 10GB?
> >>
> >> If you set a limit of 10GB for each, the user can use a total of 20GB of
> >> memory and can not limit it well. Since it is difficult to estimate the
> >> ratio used by user of normal pages and hugetlb pages, setting limits of 2GB
> >> to memory cgroup and 8GB to hugetlb cgroup is not very good idea. In such a
> >> case, I thought that by using my patch-set, we could manage resources just
> >> by setting 10GB as the limit of memory cgoup(there is no limit to hugetlb
> >> cgroup).
> >>
> >> In this patch-set, introduce the charge_surplus_huge_pages(boolean) to
> >> struct hstate. If it is true, it charges to the memory cgroup to which the
> >> task that obtained surplus hugepages belongs. If it is false, do nothing as
> >> before, and the default value is false. The charge_surplus_huge_pages can
> >> be controlled procfs or sysfs interfaces.
> >>
> >> Since THP is very effective in environments with kernel page size of 4KB,
> >> such as x86, there is no reason to positively use HugeTLBfs, so I think
> >> that there is no situation to enable charge_surplus_huge_pages. However, in
> >> some distributions such as arm64, the page size of the kernel is 64KB, and
> >> the size of THP is too huge as 512MB, making it difficult to use. HugeTLBfs
> >> may support multiple huge page sizes, and in such a special environment
> >> there is a desire to use HugeTLBfs.
> > 
> > One of the basic questions/concerns I have is accounting for surplus huge
> > pages in the default memory resource controller.  The existing huegtlb
> > resource controller already takes hugetlbfs huge pages into account,
> > including surplus pages.  This series would allow surplus pages to be
> > accounted for in the default  memory controller, or the hugetlb controller
> > or both.
> > 
> > I understand that current mechanisms do not meet the needs of the above
> > use case.  The question is whether this is an appropriate way to approach
> > the issue.

I do share your view Mike!

> > My cgroup experience and knowledge is extremely limited, but
> > it does not appear that any other resource can be controlled by multiple
> > controllers.  Therefore, I am concerned that this may be going against
> > basic cgroup design philosophy.
> 
> Thank you for your feedback.
> That makes sense, surplus hugepages are charged to both memcg and hugetlb
> cgroup, which may be contrary to cgroup design philosophy.
> 
> Based on the above advice, I have considered the following improvements,
> what do you think about?
> 
> The 'charge_surplus_hugepages' of v2 patch-set was an option to switch
> "whether to charge memcg in addition to hugetlb cgroup", but it will be
> abolished. Instead, change to "switch only to memcg instead of hugetlb
> cgroup" option. This is called 'surplus_charge_to_memcg'.

This all looks so hackish and ad-hoc that I would be tempted to give it
an outright nack, but let's here more about why do we need this fiddling
at all. I've asked in other email so I guess I will get an answer there
but let me just emphasize again that I absolutely detest a possibility
to put hugetlb pages into the memcg mix. They just do not belong there.
Try to look at previous discussions why it has been decided to have a
separate hugetlb pages at all.

I am also quite confused why you keep distinguishing surplus hugetlb
pages from regular preallocated ones. Being a surplus page is an
implementation detail that we use for an internal accounting rather than
something to exhibit to the userspace even more than we do currently.
Just look at what [sw]hould when you need to adjust accounting - e.g.
due to the pool resize. Are you going to uncharge those surplus pages
ffrom memcg to reflect their persistence?
-- 
Michal Hocko
SUSE Labs
