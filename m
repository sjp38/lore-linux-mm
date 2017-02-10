Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 066FB6B0038
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 17:37:27 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id e137so65223942itc.0
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 14:37:26 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id p124si3453147ioe.121.2017.02.10.14.37.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Feb 2017 14:37:26 -0800 (PST)
Subject: Re: [RFC] mm/hugetlb: use mem policy when allocating surplus huge
 pages
References: <1486662620-18146-1-git-send-email-grzegorz.andrejczuk@intel.com>
 <c5eb34e8-91ff-13cb-3c51-873b9af62125@oracle.com>
 <ED52C51D9B87F54892CE544909A13C6C1FFB07DC@IRSMSX101.ger.corp.intel.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <1960fa0e-a0eb-e39c-c375-77aa9f5a21ac@oracle.com>
Date: Fri, 10 Feb 2017 14:37:13 -0800
MIME-Version: 1.0
In-Reply-To: <ED52C51D9B87F54892CE544909A13C6C1FFB07DC@IRSMSX101.ger.corp.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Andrejczuk, Grzegorz" <grzegorz.andrejczuk@intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mhocko@suse.com" <mhocko@suse.com>, "n-horiguchi@ah.jp.nec.com" <n-horiguchi@ah.jp.nec.com>, "gerald.schaefer@de.ibm.com" <gerald.schaefer@de.ibm.com>, "aneesh.kumar@linux.vnet.ibm.com" <aneesh.kumar@linux.vnet.ibm.com>, "vaishali.thakkar@oracle.com" <vaishali.thakkar@oracle.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 02/10/2017 07:47 AM, Andrejczuk, Grzegorz wrote:
> On Mike Kravetz, February 9, 2017 8:32 PM wrote:
>> I believe another way of stating the problem is as follows:
>>
>> At mmap(MAP_HUGETLB) time a reservation for the number of huge pages
>> is made.  If surplus huge pages need to be (and can be) allocated to
>> satisfy the reservation, they will be allocated at this time.  However,
>> the memory policy of the task is not taken into account when these
>> pages are allocated to satisfy the reservation.
>>
>> Later when the task actually faults on pages in the mapping, reserved
>> huge pages should be instantiated in the mapping.  However, at fault time
>> the task's memory policy is taken into account.  It is possible that the
>> pages reserved at mmap() time, are located on nodes such that they can
>> not satisfy the request with the task's memory policy.  In such a case,
>> the allocation fails in the same way as if there was no reservation.
>>
>> Does that sound accurate?
> 
> Yes, thank you for taking time to rephrase it.
> It's much cleaner now.
> 
>> Your problem statement (and solution) address the case where surplus huge
>> pages need to be allocated at mmap() time to satisfy a reservation and
>> later fault.  I 'think' there is a more general problem huge page reservations
>> and memory policy.
> 
> Yes, I fixed very specific code path. This problem is probably one of many
> problems in the crossing of the memory policy and huge pages reservations.
> 

I think we agree that there is a general issue with huge page reservations
and memory policy.  More on this later.

>> - In both cases, there are enough free pages to satisfy the reservation
>>   at mmap time.  However, at fault time it can not get both the pages is
>>   requires from the specified node.
> 
> There is difference that interleaving in preallocated huge page is well known
> and expected, when in overcommit all the pages might or might not be assigned
> to the requested NUMA node.

Well, one can preallocate huge pages with policies other than interleave.
Of course, as you mention that is the most common policy and what most
people expect.

I am not sure if a failure (SIGBUS) in the preallocated case is more well
known than in the overcommit case.

>                             Also after setting nr_hugepages it is possible
> to check number of the huge pages reserved for each node by:
> cat /sys/devices/system/node/nodeX/hugepages/hugepages-2048kB/nr_hugepages
> with nr_overcommit_hugepages it is impossible.

Correct.  And that is because nr_overcommit_hugepages is a global.  Also,
note that nr_hugepages shows the number of huge pages allocated on that
node.  I think that is what you were trying to say, but 'reserved' has
a very specific meaning in this context.

>>  I'm thinking we may need to expand the reservation tracking to be
>>  per-node like free_huge_pages_node and others.  Like the code below,
>>  we need to take memory policy into account at reservation time.
>>  
>>  Thoughts?
> 
> Are amounts of free, allocated and surplus huge pages tracked in sysfs mentioned above?

Like this?
.../node/node0/hugepages/hugepages-2048kB/free_hugepages       512
.../node/node0/hugepages/hugepages-2048kB/nr_hugepages         512
.../node/node0/hugepages/hugepages-2048kB/surplus_hugepages    0

You can write to nr_hugepages, but free_hugepages and surplus_hugepages
are read only.

> My limited understanding of this problem is that obtaining all the memory policies
> requires struct vm_area (for bind, preferred) and address (for interleave).
> The first is lost in hugetlb_reserve_pages, the latter is lost when file->mmap is called.
> So reservation of the huge pages needs to be done in mmap_region function
> before calling file->mmap and I think this requires some new hugetlb API. 

You are correct about the need for more information.  I was thinking about
creating a 'pseudo vma' as in hugetlbfs_fallocate() to carry the extra
information.  This way the scope would be limited to the huge page code.

I still think there is a bigger question about the purpose of huge page
reservations within the kernel.  If you read the code, it makes it sound
like it is trying to guarantee no failures at fault time if mmap() succeeds
(not in the MAP_NORESERVE case of course).  But, since memory policy is
not taken into account at mmap() time and is used at fault time there can
be no such guarantee.

My question is, should we try to make the reservation code take memory
policy into account?  I'm not sure if we can ever guarantee mmap()
success means fault success.  But, this would get us closer.  Do note
that this would require tracking reservations on a node basis.  It
may not be too difficult to do at mmap time, but could get tricky at
munmap/truncate/hole punch time.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
