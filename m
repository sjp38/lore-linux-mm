Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id F06586B0009
	for <linux-mm@kvack.org>; Thu, 12 Apr 2018 16:58:54 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id o4so3753883ywc.16
        for <linux-mm@kvack.org>; Thu, 12 Apr 2018 13:58:54 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id l66si4656078qkd.129.2018.04.12.13.58.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Apr 2018 13:58:53 -0700 (PDT)
Subject: Re: [RFC PATCH 0/3] Interface for higher order contiguous allocations
References: <20180212222056.9735-1-mike.kravetz@oracle.com>
 <770445b3-6caa-a87a-5de7-3157fc5280c2@intel.com>
 <74b7c6e5-bce6-a70a-287a-af44765836c7@intel.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <8f67cb20-3d70-274b-871b-11bedc687bd9@oracle.com>
Date: Thu, 12 Apr 2018 13:58:47 -0700
MIME-Version: 1.0
In-Reply-To: <74b7c6e5-bce6-a70a-287a-af44765836c7@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reinette Chatre <reinette.chatre@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, David Nellans <dnellans@nvidia.com>, Laura Abbott <labbott@redhat.com>, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave.hansen@intel.com>

On 04/12/2018 01:40 PM, Reinette Chatre wrote:
> Hi Mike,
> 
> On 2/15/2018 12:22 PM, Reinette Chatre wrote:
>> On 2/12/2018 2:20 PM, Mike Kravetz wrote:
>>> These patches came out of the "[RFC] mmap(MAP_CONTIG)" discussions at:
>>> http://lkml.kernel.org/r/21f1ec96-2822-1189-1c95-79a2bb491571@oracle.com
>>>
>>> One suggestion in that thread was to create a friendlier interface that
>>> could be used by drivers and others outside core mm code to allocate a
>>> contiguous set of pages.  The alloc_contig_range() interface is used for
>>> this purpose today by CMA and gigantic page allocation.  However, this is
>>> not a general purpose interface.  So, wrap alloc_contig_range() in the
>>> more general interface:
>>>
>>> struct page *find_alloc_contig_pages(unsigned int order, gfp_t gfp, int nid,
>>> 					nodemask_t *nodemask)
>>>
>>> No underlying changes are made to increase the likelihood that a contiguous
>>> set of pages can be found and allocated.  Therefore, any user of this
>>> interface must deal with failure.  The hope is that this interface will be
>>> able to satisfy some use cases today.
>>
>> As discussed in another thread a new feature, Cache Pseudo-Locking,
>> requires large contiguous regions. Until now I just exposed
>> alloc_gigantic_page() to handle these allocations in my testing. I now
>> moved to using find_alloc_contig_pages() as introduced here and all my
>> tests passed. I do hope that an API supporting large contiguous regions
>> become available.
>>
>> Thank you very much for creating this.
>>
>> Tested-by: Reinette Chatre <reinette.chatre@intel.com>
> 
> Do you still intend on submitting these changes for inclusion?
> 
> I would really like to use this work but unfortunately the original
> patches submitted here do not apply anymore. I am encountering conflicts
> with, for example:
> 
> commit d9cc948f6fa1c3384037f500e0acd35f03850d15
> Author: Michal Hocko <mhocko@suse.com>
> Date:   Wed Jan 31 16:20:44 2018 -0800
> 
>     mm, hugetlb: integrate giga hugetlb more naturally to the allocation
> path
> 
> Thank you very much

Thanks for the reminder Reinette.

You were the only one to comment on the original proposal.  In addition,
my original use case may have gone away.  So, this effort went to the
bottom of my priority list.

I am happy rebase the patches, but would really like to get additional
comments.  Allocation of hugetlbfs gigantic pages is the only existing
user.  Perhaps this is a natural progression of Michal's patch above
as it moves all that special pfn range scanning out of hugetlb code.
-- 
Mike Kravetz
