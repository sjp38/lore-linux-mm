Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id BB0806B0333
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 12:52:13 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id l78so5450755pfb.10
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 09:52:13 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id i186si3490256pge.318.2017.03.24.09.52.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Mar 2017 09:52:13 -0700 (PDT)
Message-ID: <1490374331.2733.130.camel@linux.intel.com>
Subject: Re: [PATCH -v2 1/2] mm, swap: Use kvzalloc to allocate some swap
 data structure
From: Tim Chen <tim.c.chen@linux.intel.com>
Date: Fri, 24 Mar 2017 09:52:11 -0700
In-Reply-To: <e79064f1-8594-bef2-fbd8-1579afb4aac3@linux.intel.com>
References: <20170320084732.3375-1-ying.huang@intel.com>
	 <alpine.DEB.2.10.1703201430550.24991@chino.kir.corp.google.com>
	 <8737e3z992.fsf@yhuang-dev.intel.com>
	 <f17cb7e4-4d47-4aed-6fdb-cda5c5d47fa4@nvidia.com>
	 <87poh7xoms.fsf@yhuang-dev.intel.com>
	 <2d55e06d-a0b6-771a-bba0-f9517d422789@nvidia.com>
	 <87d1d7uoti.fsf@yhuang-dev.intel.com>
	 <624b8e59-34e5-3538-0a93-d33d9e4ac555@nvidia.com>
	 <e79064f1-8594-bef2-fbd8-1579afb4aac3@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, John Hubbard <jhubbard@nvidia.com>, "Huang, Ying" <ying.huang@intel.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Aaron Lu <aaron.lu@intel.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, "Kirill
 A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Vegard Nossum <vegard.nossum@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 2017-03-24 at 06:56 -0700, Dave Hansen wrote:
> On 03/24/2017 12:33 AM, John Hubbard wrote:
> > 
> > There might be some additional information you are using to come up with
> > that conclusion, that is not obvious to me. Any thoughts there? These
> > calls use the same underlying page allocator (and I thought that both
> > were subject to the same constraints on defragmentation, as a result of
> > that). So I am not seeing any way that kmalloc could possibly be a
> > less-fragmenting call than vmalloc.
> You guys are having quite a discussion over a very small point.
> 
> But, Ying is right.
> 
> Let's say we have a two-page data structure.A A vmalloc() takes two
> effectively random order-0 pages, probably from two different 2M pages
> and pins them.A A That "kills" two 2M pages.
> 
> kmalloc(), allocating two *contiguous* pages, is very unlikely to cross
> a 2M boundary (it theoretically could).A A That means it will only "kill"
> the possibility of a single 2M page.A A More 2M pages == less fragmentation.

In vmalloc, it eventually calls __vmalloc_area_node that allocates the
page one at a time. A There's no attempt there to make the pages contiguous
if I am reading the code correctly. A So that will increase the memory
fragmentation as we will be piecing together pages from all over the places. A 

Tim A 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
