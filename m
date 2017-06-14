Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9D1146B0279
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 18:13:01 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id o21so9073797qtb.13
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 15:13:01 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id q67si1137173qkb.106.2017.06.14.15.13.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jun 2017 15:13:00 -0700 (PDT)
Subject: Re: [RFC PATCH 2/4] hugetlb: add support for preferred node to
 alloc_huge_page_nodemask
References: <20170613090039.14393-1-mhocko@kernel.org>
 <20170613090039.14393-3-mhocko@kernel.org>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <bd8baf55-8816-452c-5249-904a5f208fb8@oracle.com>
Date: Wed, 14 Jun 2017 15:12:48 -0700
MIME-Version: 1.0
In-Reply-To: <20170613090039.14393-3-mhocko@kernel.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 06/13/2017 02:00 AM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> alloc_huge_page_nodemask tries to allocate from any numa node in the
> allowed node mask starting from lower numa nodes. This might lead to
> filling up those low NUMA nodes while others are not used. We can reduce
> this risk by introducing a concept of the preferred node similar to what
> we have in the regular page allocator. We will start allocating from the
> preferred nid and then iterate over all allowed nodes in the zonelist
> order until we try them all.
> 
> This is mimicking the page allocator logic except it operates on
> per-node mempools. dequeue_huge_page_vma already does this so distill
> the zonelist logic into a more generic dequeue_huge_page_nodemask
> and use it in alloc_huge_page_nodemask.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---


I built attempts/hugetlb-zonelists, threw it on a test machine, ran the
libhugetlbfs test suite and saw failures.  The failures started with this
patch: commit 7e8b09f14495 in your tree.  I have not yet started to look
into the failures.  It is even possible that the tests are making bad
assumptions, but there certainly appears to be changes in behavior visible
to the application(s).

FYI - My 'test machine' is an x86 KVM insatnce with 8GB memory simulating
2 nodes.  Huge page allocations before running tests:
node0
512	free_hugepages
512	nr_hugepages
0	surplus_hugepages
node1
512	free_hugepages
512	nr_hugepages
0	surplus_hugepages

I can take a closer look at the failures tomorrow.
-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
