Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9FB006B0279
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 20:12:42 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id l6so3026799iti.0
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 17:12:42 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id j74si1556565itb.73.2017.06.14.17.12.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jun 2017 17:12:41 -0700 (PDT)
Subject: Re: [RFC PATCH 2/4] hugetlb: add support for preferred node to
 alloc_huge_page_nodemask
References: <20170613090039.14393-1-mhocko@kernel.org>
 <20170613090039.14393-3-mhocko@kernel.org>
 <bd8baf55-8816-452c-5249-904a5f208fb8@oracle.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <3ac3d6a8-b62f-2386-cb04-f32b3bebffe7@oracle.com>
Date: Wed, 14 Jun 2017 17:12:31 -0700
MIME-Version: 1.0
In-Reply-To: <bd8baf55-8816-452c-5249-904a5f208fb8@oracle.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 06/14/2017 03:12 PM, Mike Kravetz wrote:
> On 06/13/2017 02:00 AM, Michal Hocko wrote:
>> From: Michal Hocko <mhocko@suse.com>
>>
>> alloc_huge_page_nodemask tries to allocate from any numa node in the
>> allowed node mask starting from lower numa nodes. This might lead to
>> filling up those low NUMA nodes while others are not used. We can reduce
>> this risk by introducing a concept of the preferred node similar to what
>> we have in the regular page allocator. We will start allocating from the
>> preferred nid and then iterate over all allowed nodes in the zonelist
>> order until we try them all.
>>
>> This is mimicking the page allocator logic except it operates on
>> per-node mempools. dequeue_huge_page_vma already does this so distill
>> the zonelist logic into a more generic dequeue_huge_page_nodemask
>> and use it in alloc_huge_page_nodemask.
>>
>> Signed-off-by: Michal Hocko <mhocko@suse.com>
>> ---
> 
> 
> I built attempts/hugetlb-zonelists, threw it on a test machine, ran the
> libhugetlbfs test suite and saw failures.  The failures started with this
> patch: commit 7e8b09f14495 in your tree.  I have not yet started to look
> into the failures.  It is even possible that the tests are making bad
> assumptions, but there certainly appears to be changes in behavior visible
> to the application(s).

nm.  The failures were the result of dequeue_huge_page_nodemask() always
returning NULL.  Vlastimil already noticed this issue and provided a
solution.

-- 
Mike Kravetz

> 
> FYI - My 'test machine' is an x86 KVM insatnce with 8GB memory simulating
> 2 nodes.  Huge page allocations before running tests:
> node0
> 512	free_hugepages
> 512	nr_hugepages
> 0	surplus_hugepages
> node1
> 512	free_hugepages
> 512	nr_hugepages
> 0	surplus_hugepages
> 
> I can take a closer look at the failures tomorrow.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
