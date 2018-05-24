Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id A13246B0272
	for <linux-mm@kvack.org>; Thu, 24 May 2018 00:40:19 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id d20-v6so239082pfn.16
        for <linux-mm@kvack.org>; Wed, 23 May 2018 21:40:19 -0700 (PDT)
Received: from ns.ascade.co.jp (ext-host0001.ascade.co.jp. [218.224.228.194])
        by mx.google.com with ESMTP id t23-v6si21756130plo.508.2018.05.23.21.40.17
        for <linux-mm@kvack.org>;
        Wed, 23 May 2018 21:40:18 -0700 (PDT)
Subject: Re: [PATCH v2 0/7] mm: pages for hugetlb's overcommit may be able to
 charge to memcg
References: <e863529b-7ce5-4fbe-8cff-581b5789a5f9@ascade.co.jp>
 <240f1b14-ed7d-4983-6c52-be4899d4caa5@oracle.com>
 <8711fed5-fc35-a11a-3a17-740a9dca1f2a@ascade.co.jp>
 <20180522185407.GC20441@dhcp22.suse.cz>
From: TSUKADA Koutaro <tsukada@ascade.co.jp>
Message-ID: <455b1a07-d7e3-102b-65e7-3892947b7675@ascade.co.jp>
Date: Thu, 24 May 2018 13:39:59 +0900
MIME-Version: 1.0
In-Reply-To: <20180522185407.GC20441@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, David Rientjes <rientjes@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Marc-Andre Lureau <marcandre.lureau@redhat.com>, Punit Agrawal <punit.agrawal@arm.com>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On 2018/05/23 3:54, Michal Hocko wrote:
> On Tue 22-05-18 22:04:23, TSUKADA Koutaro wrote:
>> On 2018/05/22 3:07, Mike Kravetz wrote:
>>> On 05/17/2018 09:27 PM, TSUKADA Koutaro wrote:
>>>> Thanks to Mike Kravetz for comment on the previous version patch.
>>>>
>>>> The purpose of this patch-set is to make it possible to control whether or
>>>> not to charge surplus hugetlb pages obtained by overcommitting to memory
>>>> cgroup. In the future, I am trying to accomplish limiting the memory usage
>>>> of applications that use both normal pages and hugetlb pages by the memory
>>>> cgroup(not use the hugetlb cgroup).
>>>>
>>>> Applications that use shared libraries like libhugetlbfs.so use both normal
>>>> pages and hugetlb pages, but we do not know how much to use each. Please
>>>> suppose you want to manage the memory usage of such applications by cgroup
>>>> How do you set the memory cgroup and hugetlb cgroup limit when you want to
>>>> limit memory usage to 10GB?
>>>>
>>>> If you set a limit of 10GB for each, the user can use a total of 20GB of
>>>> memory and can not limit it well. Since it is difficult to estimate the
>>>> ratio used by user of normal pages and hugetlb pages, setting limits of 2GB
>>>> to memory cgroup and 8GB to hugetlb cgroup is not very good idea. In such a
>>>> case, I thought that by using my patch-set, we could manage resources just
>>>> by setting 10GB as the limit of memory cgoup(there is no limit to hugetlb
>>>> cgroup).
>>>>
>>>> In this patch-set, introduce the charge_surplus_huge_pages(boolean) to
>>>> struct hstate. If it is true, it charges to the memory cgroup to which the
>>>> task that obtained surplus hugepages belongs. If it is false, do nothing as
>>>> before, and the default value is false. The charge_surplus_huge_pages can
>>>> be controlled procfs or sysfs interfaces.
>>>>
>>>> Since THP is very effective in environments with kernel page size of 4KB,
>>>> such as x86, there is no reason to positively use HugeTLBfs, so I think
>>>> that there is no situation to enable charge_surplus_huge_pages. However, in
>>>> some distributions such as arm64, the page size of the kernel is 64KB, and
>>>> the size of THP is too huge as 512MB, making it difficult to use. HugeTLBfs
>>>> may support multiple huge page sizes, and in such a special environment
>>>> there is a desire to use HugeTLBfs.
>>>
>>> One of the basic questions/concerns I have is accounting for surplus huge
>>> pages in the default memory resource controller.  The existing huegtlb
>>> resource controller already takes hugetlbfs huge pages into account,
>>> including surplus pages.  This series would allow surplus pages to be
>>> accounted for in the default  memory controller, or the hugetlb controller
>>> or both.
>>>
>>> I understand that current mechanisms do not meet the needs of the above
>>> use case.  The question is whether this is an appropriate way to approach
>>> the issue.
> 
> I do share your view Mike!
> 
>>> My cgroup experience and knowledge is extremely limited, but
>>> it does not appear that any other resource can be controlled by multiple
>>> controllers.  Therefore, I am concerned that this may be going against
>>> basic cgroup design philosophy.
>>
>> Thank you for your feedback.
>> That makes sense, surplus hugepages are charged to both memcg and hugetlb
>> cgroup, which may be contrary to cgroup design philosophy.
>>
>> Based on the above advice, I have considered the following improvements,
>> what do you think about?
>>
>> The 'charge_surplus_hugepages' of v2 patch-set was an option to switch
>> "whether to charge memcg in addition to hugetlb cgroup", but it will be
>> abolished. Instead, change to "switch only to memcg instead of hugetlb
>> cgroup" option. This is called 'surplus_charge_to_memcg'.
> 
> This all looks so hackish and ad-hoc that I would be tempted to give it
> an outright nack, but let's here more about why do we need this fiddling
> at all. I've asked in other email so I guess I will get an answer there
> but let me just emphasize again that I absolutely detest a possibility
> to put hugetlb pages into the memcg mix. They just do not belong there.
> Try to look at previous discussions why it has been decided to have a
> separate hugetlb pages at all.
> 
> I am also quite confused why you keep distinguishing surplus hugetlb
> pages from regular preallocated ones. Being a surplus page is an
> implementation detail that we use for an internal accounting rather than
> something to exhibit to the userspace even more than we do currently.

I apologize for having confused.

The hugetlb pages obtained from the pool do not waste the buddy pool. On
the other hand, surplus hugetlb pages waste the buddy pool. Due to this
difference in property, I thought it could be distinguished.

Although my memcg knowledge is extremely limited, memcg is accounting for
various kinds of pages obtained from the buddy pool by the task belonging
to it. I would like to argue that surplus hugepage has specificity in
terms of obtaining from the buddy pool, and that it is specially permitted
charge requirements for memcg.

It seems very strange that charge hugetlb page to memcg, but essentially
it only charges the usage of the compound page obtained from the buddy pool,
and even if that page is used as hugetlb page after that, memcg is not
interested in that.

I will completely apologize if my way of thinking is wrong. It would be
greatly appreciated if you could mention why we can not charge surplus
hugepages to memcg.

> Just look at what [sw]hould when you need to adjust accounting - e.g.
> due to the pool resize. Are you going to uncharge those surplus pages
> ffrom memcg to reflect their persistence?
> 

I could not understand the intention of this question, sorry. When resize
the pool, I think that the number of surplus hugepages in use does not
change. Could you explain what you were concerned about?

-- 
Thanks,
Tsukada
