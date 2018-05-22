Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5B8276B027A
	for <linux-mm@kvack.org>; Tue, 22 May 2018 09:04:52 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e7-v6so11053646pfi.8
        for <linux-mm@kvack.org>; Tue, 22 May 2018 06:04:52 -0700 (PDT)
Received: from ns.ascade.co.jp (ext-host0001.ascade.co.jp. [218.224.228.194])
        by mx.google.com with ESMTP id e1-v6si12954886pgr.167.2018.05.22.06.04.50
        for <linux-mm@kvack.org>;
        Tue, 22 May 2018 06:04:50 -0700 (PDT)
Subject: Re: [PATCH v2 0/7] mm: pages for hugetlb's overcommit may be able to
 charge to memcg
References: <e863529b-7ce5-4fbe-8cff-581b5789a5f9@ascade.co.jp>
 <240f1b14-ed7d-4983-6c52-be4899d4caa5@oracle.com>
From: TSUKADA Koutaro <tsukada@ascade.co.jp>
Message-ID: <8711fed5-fc35-a11a-3a17-740a9dca1f2a@ascade.co.jp>
Date: Tue, 22 May 2018 22:04:23 +0900
MIME-Version: 1.0
In-Reply-To: <240f1b14-ed7d-4983-6c52-be4899d4caa5@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, David Rientjes <rientjes@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Marc-Andre Lureau <marcandre.lureau@redhat.com>, Punit Agrawal <punit.agrawal@arm.com>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On 2018/05/22 3:07, Mike Kravetz wrote:
> On 05/17/2018 09:27 PM, TSUKADA Koutaro wrote:
>> Thanks to Mike Kravetz for comment on the previous version patch.
>>
>> The purpose of this patch-set is to make it possible to control whether or
>> not to charge surplus hugetlb pages obtained by overcommitting to memory
>> cgroup. In the future, I am trying to accomplish limiting the memory usage
>> of applications that use both normal pages and hugetlb pages by the memory
>> cgroup(not use the hugetlb cgroup).
>>
>> Applications that use shared libraries like libhugetlbfs.so use both normal
>> pages and hugetlb pages, but we do not know how much to use each. Please
>> suppose you want to manage the memory usage of such applications by cgroup
>> How do you set the memory cgroup and hugetlb cgroup limit when you want to
>> limit memory usage to 10GB?
>>
>> If you set a limit of 10GB for each, the user can use a total of 20GB of
>> memory and can not limit it well. Since it is difficult to estimate the
>> ratio used by user of normal pages and hugetlb pages, setting limits of 2GB
>> to memory cgroup and 8GB to hugetlb cgroup is not very good idea. In such a
>> case, I thought that by using my patch-set, we could manage resources just
>> by setting 10GB as the limit of memory cgoup(there is no limit to hugetlb
>> cgroup).
>>
>> In this patch-set, introduce the charge_surplus_huge_pages(boolean) to
>> struct hstate. If it is true, it charges to the memory cgroup to which the
>> task that obtained surplus hugepages belongs. If it is false, do nothing as
>> before, and the default value is false. The charge_surplus_huge_pages can
>> be controlled procfs or sysfs interfaces.
>>
>> Since THP is very effective in environments with kernel page size of 4KB,
>> such as x86, there is no reason to positively use HugeTLBfs, so I think
>> that there is no situation to enable charge_surplus_huge_pages. However, in
>> some distributions such as arm64, the page size of the kernel is 64KB, and
>> the size of THP is too huge as 512MB, making it difficult to use. HugeTLBfs
>> may support multiple huge page sizes, and in such a special environment
>> there is a desire to use HugeTLBfs.
> 
> One of the basic questions/concerns I have is accounting for surplus huge
> pages in the default memory resource controller.  The existing huegtlb
> resource controller already takes hugetlbfs huge pages into account,
> including surplus pages.  This series would allow surplus pages to be
> accounted for in the default  memory controller, or the hugetlb controller
> or both.
> 
> I understand that current mechanisms do not meet the needs of the above
> use case.  The question is whether this is an appropriate way to approach
> the issue.  My cgroup experience and knowledge is extremely limited, but
> it does not appear that any other resource can be controlled by multiple
> controllers.  Therefore, I am concerned that this may be going against
> basic cgroup design philosophy.

Thank you for your feedback.
That makes sense, surplus hugepages are charged to both memcg and hugetlb
cgroup, which may be contrary to cgroup design philosophy.

Based on the above advice, I have considered the following improvements,
what do you think about?

The 'charge_surplus_hugepages' of v2 patch-set was an option to switch
"whether to charge memcg in addition to hugetlb cgroup", but it will be
abolished. Instead, change to "switch only to memcg instead of hugetlb
cgroup" option. This is called 'surplus_charge_to_memcg'.

The surplus_charge_to_memcg option is created in per hugetlb cgroup.
If it is false(default), charge destination cgroup of various page types
is the same as the current kernel version. If it become true, hugetlb
cgroup stops accounting for surplus hugepages, and memcg starts accounting
instead.

A table showing which cgroups are charged:

page types          | current  v2(off)  v2(on)   v3(off)   v3(on)
-------------------------------------------------------------------
normal + THP        |       m       m       m         m        m
hugetlb(persistent) |       h       h       h         h        h
hugetlb(surplus)    |       h       h     m+h         h        m
-------------------------------------------------------------------

 v2: charge_surplus_hugepages option
 v3: next version, surplus_charge_to_memcg option
  m: memory cgroup
  h: hugetlb cgroup

> 
> It would be good to get comments from people more cgroup knowledgeable,
> and especially from those involved in the decision to do separate hugetlb
> control.
> 

I stared at the commit log of mm/hugetlb_cgroup.c, but it did not seem to
have specially considered of surplus hugepages. Later, I will send a mail
to hugetlb cgroup's committer to ask about surplus hugepages charge
specifications.

-- 
Thanks,
Tsukada
