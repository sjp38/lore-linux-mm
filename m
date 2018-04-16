Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 996BC6B0003
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 09:14:25 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id i4so13082806wrh.4
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 06:14:25 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w7si1428677edk.140.2018.04.16.06.14.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 Apr 2018 06:14:24 -0700 (PDT)
Date: Mon, 16 Apr 2018 15:14:21 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 0/3] Interface for higher order contiguous allocations
Message-ID: <20180416131421.GQ17484@dhcp22.suse.cz>
References: <20180212222056.9735-1-mike.kravetz@oracle.com>
 <770445b3-6caa-a87a-5de7-3157fc5280c2@intel.com>
 <74b7c6e5-bce6-a70a-287a-af44765836c7@intel.com>
 <8f67cb20-3d70-274b-871b-11bedc687bd9@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8f67cb20-3d70-274b-871b-11bedc687bd9@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Reinette Chatre <reinette.chatre@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christopher Lameter <cl@linux.com>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, David Nellans <dnellans@nvidia.com>, Laura Abbott <labbott@redhat.com>, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave.hansen@intel.com>

On Thu 12-04-18 13:58:47, Mike Kravetz wrote:
> On 04/12/2018 01:40 PM, Reinette Chatre wrote:
> > Hi Mike,
> > 
> > On 2/15/2018 12:22 PM, Reinette Chatre wrote:
> >> On 2/12/2018 2:20 PM, Mike Kravetz wrote:
> >>> These patches came out of the "[RFC] mmap(MAP_CONTIG)" discussions at:
> >>> http://lkml.kernel.org/r/21f1ec96-2822-1189-1c95-79a2bb491571@oracle.com
> >>>
> >>> One suggestion in that thread was to create a friendlier interface that
> >>> could be used by drivers and others outside core mm code to allocate a
> >>> contiguous set of pages.  The alloc_contig_range() interface is used for
> >>> this purpose today by CMA and gigantic page allocation.  However, this is
> >>> not a general purpose interface.  So, wrap alloc_contig_range() in the
> >>> more general interface:
> >>>
> >>> struct page *find_alloc_contig_pages(unsigned int order, gfp_t gfp, int nid,
> >>> 					nodemask_t *nodemask)
> >>>
> >>> No underlying changes are made to increase the likelihood that a contiguous
> >>> set of pages can be found and allocated.  Therefore, any user of this
> >>> interface must deal with failure.  The hope is that this interface will be
> >>> able to satisfy some use cases today.
> >>
> >> As discussed in another thread a new feature, Cache Pseudo-Locking,
> >> requires large contiguous regions. Until now I just exposed
> >> alloc_gigantic_page() to handle these allocations in my testing. I now
> >> moved to using find_alloc_contig_pages() as introduced here and all my
> >> tests passed. I do hope that an API supporting large contiguous regions
> >> become available.
> >>
> >> Thank you very much for creating this.
> >>
> >> Tested-by: Reinette Chatre <reinette.chatre@intel.com>
> > 
> > Do you still intend on submitting these changes for inclusion?
> > 
> > I would really like to use this work but unfortunately the original
> > patches submitted here do not apply anymore. I am encountering conflicts
> > with, for example:
> > 
> > commit d9cc948f6fa1c3384037f500e0acd35f03850d15
> > Author: Michal Hocko <mhocko@suse.com>
> > Date:   Wed Jan 31 16:20:44 2018 -0800
> > 
> >     mm, hugetlb: integrate giga hugetlb more naturally to the allocation
> > path
> > 
> > Thank you very much
> 
> Thanks for the reminder Reinette.
> 
> You were the only one to comment on the original proposal.  In addition,
> my original use case may have gone away.  So, this effort went to the
> bottom of my priority list.
> 
> I am happy rebase the patches, but would really like to get additional
> comments.  Allocation of hugetlbfs gigantic pages is the only existing
> user.  Perhaps this is a natural progression of Michal's patch above
> as it moves all that special pfn range scanning out of hugetlb code.

Yes, that was and still is the plan. Turn the hackish contig allocator
into something more usable so I guess it would be in line with what
Reinette is after.
-- 
Michal Hocko
SUSE Labs
