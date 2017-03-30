Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id BC4836B03BB
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 12:31:33 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id g7so11297707wrd.16
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 09:31:33 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s196si4614744wmb.102.2017.03.30.09.31.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 30 Mar 2017 09:31:32 -0700 (PDT)
Date: Thu, 30 Mar 2017 18:31:28 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH -v2 1/2] mm, swap: Use kvzalloc to allocate some swap
 data structure
Message-ID: <20170330163128.GF4326@dhcp22.suse.cz>
References: <20170320084732.3375-1-ying.huang@intel.com>
 <alpine.DEB.2.10.1703201430550.24991@chino.kir.corp.google.com>
 <8737e3z992.fsf@yhuang-dev.intel.com>
 <f17cb7e4-4d47-4aed-6fdb-cda5c5d47fa4@nvidia.com>
 <87poh7xoms.fsf@yhuang-dev.intel.com>
 <2d55e06d-a0b6-771a-bba0-f9517d422789@nvidia.com>
 <87d1d7uoti.fsf@yhuang-dev.intel.com>
 <624b8e59-34e5-3538-0a93-d33d9e4ac555@nvidia.com>
 <e79064f1-8594-bef2-fbd8-1579afb4aac3@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e79064f1-8594-bef2-fbd8-1579afb4aac3@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: John Hubbard <jhubbard@nvidia.com>, "Huang, Ying" <ying.huang@intel.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Tim Chen <tim.c.chen@linux.intel.com>, Mel Gorman <mgorman@techsingularity.net>, Aaron Lu <aaron.lu@intel.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Vegard Nossum <vegard.nossum@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 24-03-17 06:56:10, Dave Hansen wrote:
> On 03/24/2017 12:33 AM, John Hubbard wrote:
> > There might be some additional information you are using to come up with
> > that conclusion, that is not obvious to me. Any thoughts there? These
> > calls use the same underlying page allocator (and I thought that both
> > were subject to the same constraints on defragmentation, as a result of
> > that). So I am not seeing any way that kmalloc could possibly be a
> > less-fragmenting call than vmalloc.
> 
> You guys are having quite a discussion over a very small point.
> 
> But, Ying is right.
> 
> Let's say we have a two-page data structure.  vmalloc() takes two
> effectively random order-0 pages, probably from two different 2M pages
> and pins them.  That "kills" two 2M pages.
> 
> kmalloc(), allocating two *contiguous* pages, is very unlikely to cross
> a 2M boundary (it theoretically could).  That means it will only "kill"
> the possibility of a single 2M page.  More 2M pages == less fragmentation.

Yes I agree with this. And the patch is no brainer. kvmalloc makes sure
to not try too hard on the kmalloc side so I really didn't get the
objection about direct compaction and reclaim which initially started
this discussion. Besides that the swapon path usually happens early
during the boot where we should have those larger blocks available.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
