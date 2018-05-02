Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 12BBB6B0005
	for <linux-mm@kvack.org>; Wed,  2 May 2018 17:13:48 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id u16-v6so2580426iol.18
        for <linux-mm@kvack.org>; Wed, 02 May 2018 14:13:48 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id z2-v6si10485262ite.117.2018.05.02.14.13.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 May 2018 14:13:47 -0700 (PDT)
Subject: Re: [PATCH 2/3] mm: add find_alloc_contig_pages() interface
References: <20180417020915.11786-1-mike.kravetz@oracle.com>
 <20180417020915.11786-3-mike.kravetz@oracle.com>
 <deb9dd1d-84bf-75c7-2880-a7bcec880d47@suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <af56d281-fea1-2bd7-aff1-108fa1d9f3be@oracle.com>
Date: Wed, 2 May 2018 14:13:32 -0700
MIME-Version: 1.0
In-Reply-To: <deb9dd1d-84bf-75c7-2880-a7bcec880d47@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
Cc: Reinette Chatre <reinette.chatre@intel.com>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, David Nellans <dnellans@nvidia.com>, Laura Abbott <labbott@redhat.com>, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>

On 04/21/2018 09:16 AM, Vlastimil Babka wrote:
> On 04/17/2018 04:09 AM, Mike Kravetz wrote:
>> find_alloc_contig_pages() is a new interface that attempts to locate
>> and allocate a contiguous range of pages.  It is provided as a more
>> convenient interface than alloc_contig_range() which is currently
>> used by CMA and gigantic huge pages.
>>
>> When attempting to allocate a range of pages, migration is employed
>> if possible.  There is no guarantee that the routine will succeed.
>> So, the user must be prepared for failure and have a fall back plan.
>>
>> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> 
> Hi, just two quick observations, maybe discussion pointers for the
> LSF/MM session:
> - it's weird that find_alloc_contig_pages() takes an order, and
> free_contig_pages() takes a nr_pages. I suspect the interface would be
> more future-proof with both using nr_pages? Perhaps also minimum
> alignment for the allocation side? Order is fine for hugetlb, but what
> about other potential users?

Agreed, and I am changing this to nr_pages and adding alignment.

> - contig_alloc_migratetype_ok() says that MIGRATE_CMA blocks are OK to
> allocate from. This silently assumes that everything allocated by this
> will be migratable itself, or it might eat CMA reserves. Is it the case?
> Also you then call alloc_contig_range() with MIGRATE_MOVABLE, so it will
> skip/fail on MIGRATE_CMA anyway IIRC.

When looking closer at the code, alloc_contig_range currently has comments
saying migratetype must be MIGRATE_MOVABLE or MIGRATE_CMA.  However, this
is not checked/enforced anywhere in the code (that I can see).  The
migratetype passed to alloc_contig_range() will be used to set the migrate
type of all pageblocks in the range.  If there is an error, one side effect
is that some pageblocks may have their migrate type changed to migratetype.
Depending on how far we got before hitting the error, the number of pageblocks
changed is unknown.  This actually can happen at the lower level routine
start_isolate_page_range().

My first thought was to make start_isolate_page_range/set_migratetype_isolate
check that the migrate type of a pageblock was migratetype before isolating.
This would work for CMA, and I could make it work for the new allocator.
However, offline_pages also calls start_isolate_page_range and I believe we
do not want to enforce such a rule (all pageblocks must be of the same migrate
type) for memory hotplug/offline?

Should we be concerned at all about this potential changing of migrate type
on error?  The only way I can think to avoid this is to save the original
migrate type before isolation.

-- 
Mike Kravetz
