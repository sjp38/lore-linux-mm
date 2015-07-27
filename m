Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id E0C866B0253
	for <linux-mm@kvack.org>; Mon, 27 Jul 2015 14:25:24 -0400 (EDT)
Received: by pabkd10 with SMTP id kd10so55453588pab.2
        for <linux-mm@kvack.org>; Mon, 27 Jul 2015 11:25:24 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id ev6si2005973pdb.91.2015.07.27.11.25.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Jul 2015 11:25:22 -0700 (PDT)
Subject: Re: [mmotm:master 229/385] fs/hugetlbfs/inode.c:578:13: error:
 'struct vm_area_struct' has no member named 'vm_policy'
References: <201507240615.1plto0Cp%fengguang.wu@intel.com>
 <55B27566.1050202@oracle.com> <20150727071333.GC11317@dhcp22.suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <55B6777F.2050706@oracle.com>
Date: Mon, 27 Jul 2015 11:25:03 -0700
MIME-Version: 1.0
In-Reply-To: <20150727071333.GC11317@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On 07/27/2015 12:13 AM, Michal Hocko wrote:
> On Fri 24-07-15 10:27:02, Mike Kravetz wrote:
>> On 07/23/2015 03:18 PM, kbuild test robot wrote:
>>> tree:   git://git.cmpxchg.org/linux-mmotm.git master
>>> head:   61f5f835b6f06fbc233481b5d3c0afd71ecf54e8
>>> commit: 0c5e1e8ed55974975bb829e4b93cf19aa0dfcafc [229/385] hugetlbfs: add hugetlbfs_fallocate()
>>> config: i386-randconfig-r0-201529 (attached as .config)
>>> reproduce:
>>>    git checkout 0c5e1e8ed55974975bb829e4b93cf19aa0dfcafc
>>>    # save the attached .config to linux build tree
>>>    make ARCH=i386
>>>
>>> All error/warnings (new ones prefixed by >>):
>>>
>>>     fs/hugetlbfs/inode.c: In function 'hugetlbfs_fallocate':
>>>>> fs/hugetlbfs/inode.c:578:13: error: 'struct vm_area_struct' has no member named 'vm_policy'
>>>        pseudo_vma.vm_policy =
>>>                  ^
>>>>> fs/hugetlbfs/inode.c:579:4: error: implicit declaration of function 'mpol_shared_policy_lookup' [-Werror=implicit-function-declaration]
>>>         mpol_shared_policy_lookup(&HUGETLBFS_I(inode)->policy,
>>>         ^
>>>     fs/hugetlbfs/inode.c:595:28: error: 'struct vm_area_struct' has no member named 'vm_policy'
>>>         mpol_cond_put(pseudo_vma.vm_policy);
>>>                                 ^
>>>     fs/hugetlbfs/inode.c:601:27: error: 'struct vm_area_struct' has no member named 'vm_policy'
>>>        mpol_cond_put(pseudo_vma.vm_policy);
>>>                                ^
>>>     cc1: some warnings being treated as errors
>>>
>>> vim +578 fs/hugetlbfs/inode.c
>>>
>>>     572			if (signal_pending(current)) {
>>>     573				error = -EINTR;
>>>     574				break;
>>>     575			}
>>>     576	
>>>     577			/* Get policy based on index */
>>>   > 578			pseudo_vma.vm_policy =
>>>   > 579				mpol_shared_policy_lookup(&HUGETLBFS_I(inode)->policy,
>>>     580								index);
>>>     581	
>>>     582			/* addr is the offset within the file (zero based) */
>>>
>>> ---
>>> 0-DAY kernel test infrastructure                Open Source Technology Center
>>> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
>>>
>>
>> Michal already added a patch to mmotm.  The patch below is functionally
>> equivalent but moves the #ifdef out of the executable code path, and
>> modifies a comment.  This has been functional/stress tested in a kernel
>> without CONFIG_NUMA defined.
>
> I will drop my quick hack once Andrew picks your patch which is indeed
> better.
>
> One nit below...
>
>> hugetlbfs: build fix fallocate if not CONFIG_NUMA
>>
>> When fallocate preallocation allocates pages, it will use the
>> defined numa policy.  However, if numa is not defined there is
>> no such policy and no code should reference numa policy.  Create
>> wrappers to isolate policy manipulation code that are NOOP in
>> the non-NUMA case.
>>
>> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
>> ---
>>   fs/hugetlbfs/inode.c | 39 ++++++++++++++++++++++++++++++---------
>>   1 file changed, 30 insertions(+), 9 deletions(-)
>>
>> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
>> index d977cae..4bae359 100644
>> --- a/fs/hugetlbfs/inode.c
>> +++ b/fs/hugetlbfs/inode.c
>> @@ -85,6 +85,29 @@ static const match_table_t tokens = {
>>   	{Opt_err,	NULL},
>>   };
>>
>> +#ifdef CONFIG_NUMA
>> +static inline void hugetlb_set_vma_policy(struct vm_area_struct *vma,
>> +					struct inode *inode, pgoff_t index)
>> +{
>> +	vma->vm_policy = mpol_shared_policy_lookup(&HUGETLBFS_I(inode)->policy,
>> +							index);
>> +}
>> +
>> +static inline void hugetlb_vma_mpol_cond_put(struct vm_area_struct *vma)
>
> The naming could be better. What about hugetlb_drop_vma_policy to be
> symmetric to hugetlb_set_vma_policy. Or is there any reason to expose
> that this is a cond_put?
>

I like the name.  Will send an updated patch with the change.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
