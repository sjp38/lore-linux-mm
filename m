Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4E0AF6B000C
	for <linux-mm@kvack.org>; Fri,  4 May 2018 00:27:20 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 3-v6so10025810wry.0
        for <linux-mm@kvack.org>; Thu, 03 May 2018 21:27:20 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id t24-v6si1212741edm.246.2018.05.03.21.27.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 May 2018 21:27:18 -0700 (PDT)
Subject: Re: [PATCH] memcg, hugetlb: pages allocated for hugetlb's overcommit
 will be charged to memcg
References: <ecb737e9-ccec-2d7e-45d9-91884a669b58@ascade.co.jp>
 <dc21a4ac-b57f-59a8-f97a-90a59d5a59cd@oracle.com>
 <c9019050-7c89-86c3-93fc-9beb64e43ed3@ascade.co.jp>
 <249d53f4-225d-8a11-d557-b915fa4fa9cb@oracle.com>
 <a696eccd-24f3-9368-5baa-afbd3628468a@ascade.co.jp>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <fae2dde5-00b0-f12c-66ff-8b69351805a9@oracle.com>
Date: Thu, 3 May 2018 21:26:39 -0700
MIME-Version: 1.0
In-Reply-To: <a696eccd-24f3-9368-5baa-afbd3628468a@ascade.co.jp>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: TSUKADA Koutaro <tsukada@ascade.co.jp>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, =?UTF-8?Q?Marc-Andr=c3=a9_Lureau?= <marcandre.lureau@redhat.com>, Punit Agrawal <punit.agrawal@arm.com>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On 05/03/2018 05:09 PM, TSUKADA Koutaro wrote:
> On 2018/05/03 11:33, Mike Kravetz wrote:
>> On 05/01/2018 11:54 PM, TSUKADA Koutaro wrote:
>>> On 2018/05/02 13:41, Mike Kravetz wrote:
>>>> What is the reason for not charging pages at allocation/reserve time?  I am
>>>> not an expert in memcg accounting, but I would think the pages should be
>>>> charged at allocation time.  Otherwise, a task could allocate a large number
>>>> of (reserved) pages that are not charged to a memcg.  memcg charges in other
>>>> code paths seem to happen at huge page allocation time.
>>>
>>> If we charge to memcg at page allocation time, the new page is not yet
>>> registered in rmap, so it will be accounted as 'cache' inside the memcg. Then,
>>> after being registered in rmap, memcg will account as 'RSS' if the task moves
>>> cgroup, so I am worried about the possibility of inconsistency in statistics
>>> (memory.stat).
>>>
>>> As you said, in this patch, there may be a problem that a memory leak occurs
>>> due to unused pages after being reserved.
>>>
>>>>> This patch targets RHELSA(kernel-alt-4.11.0-45.6.1.el7a.src.rpm).
>>>>
>>>> It would be very helpful to rebase this patch on a recent mainline kernel.
>>>> The code to allocate surplus huge pages has been significantly changed in
>>>> recent kernels.
>>>>
>>>> I have no doubt that this is a real issue and we are not correctly charging
>>>> surplus to a memcg.  But your patch will be hard to evaluate when based on
>>>> an older distro kernel.
>>> I apologize for the patch of the old kernel. The patch was rewritten
>>> for 4.17-rc2(6d08b06).
>>
>> Thank you very much for rebasing the patch.
>>
>> I did not look closely at your patch until now.  My first thought was that
>> you  were changing/expanding the existing accounting.  However, it appears
>> that you want to account for hugetlb surplus pages in the memory cgroup.
>> Is there any reason why the hugetlb cgroup resource controller does not meet
>> your needs?  It a quick look at the code, it does appear to handle surplus
>> pages correctly.
> 
> Yes, basically it is exactly what you are talking about, but my usage is
> somewhat special. I would like users who submit jobs on the HPC cluster to use
> the hugetlb page. When submitting a job, the user specifies a memory resource
> (for example, sbatch --mem in slurm).
> 
> If the user specifies 10GB, we assume that the system administrator has set the
> limit of 10GB for memory cgroup and hugetlb cgroup respectively, and does not
> create a hugetlb pool and sets it so that can overcommit. Then, users can use
> 10GB normal pages and more 10GB hugetlb page by overcommitting, which means
> user can use 20GB totaly. However, the administrator should restrict the normal
> page and hugetlb page to 10GB in total.
> 
> Since it is difficult to estimate the ratio used by user of normal pages and
> hugetlb pages, setting limits of 2 GB to memory cgroup and 8 GB to hugetlb
> cgroup is not very good idea.
> 
> In such a case, with my patch, I thought that the administrator can manage the
> resources just by setting 10GB for the limit of memory cgoup(No limit is set
> for hugetlb cgroup).

Thank you for the explanation of your use case.  I now understand what
you were trying to accomplish with your patch.

Your use case reminds me of the session at LSFMM titled "swap accounting".
https://lwn.net/Articles/753162/

I hope someone with more cgroup expertise (Johannes? Aneesh?) can provide
comments.  My experience in that area is limited.

One question that comes to mind is "Why would the user/application writer
use hugetlbfs overcommit instead of THP?".  For hugetlbfs overcommit, they
need to be prepared for huge page allocations to fail.  So, in some cases
they may not be able to use any hugetlbfs pages.  This is not much different
than THP.  However, in the THP case huge page allocation failures and fall
back to base pages is transparent to the user.  With THP, the normal memory
cgroup controller should work well.
-- 
Mike Kravetz
