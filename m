Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 496826B0333
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 09:56:16 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id u202so476616pgb.9
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 06:56:16 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id s9si2964916pgo.309.2017.03.24.06.56.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Mar 2017 06:56:15 -0700 (PDT)
Subject: Re: [PATCH -v2 1/2] mm, swap: Use kvzalloc to allocate some swap data
 structure
References: <20170320084732.3375-1-ying.huang@intel.com>
 <alpine.DEB.2.10.1703201430550.24991@chino.kir.corp.google.com>
 <8737e3z992.fsf@yhuang-dev.intel.com>
 <f17cb7e4-4d47-4aed-6fdb-cda5c5d47fa4@nvidia.com>
 <87poh7xoms.fsf@yhuang-dev.intel.com>
 <2d55e06d-a0b6-771a-bba0-f9517d422789@nvidia.com>
 <87d1d7uoti.fsf@yhuang-dev.intel.com>
 <624b8e59-34e5-3538-0a93-d33d9e4ac555@nvidia.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <e79064f1-8594-bef2-fbd8-1579afb4aac3@linux.intel.com>
Date: Fri, 24 Mar 2017 06:56:10 -0700
MIME-Version: 1.0
In-Reply-To: <624b8e59-34e5-3538-0a93-d33d9e4ac555@nvidia.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>, "Huang, Ying" <ying.huang@intel.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Tim Chen <tim.c.chen@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Aaron Lu <aaron.lu@intel.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Vegard Nossum <vegard.nossum@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 03/24/2017 12:33 AM, John Hubbard wrote:
> There might be some additional information you are using to come up with
> that conclusion, that is not obvious to me. Any thoughts there? These
> calls use the same underlying page allocator (and I thought that both
> were subject to the same constraints on defragmentation, as a result of
> that). So I am not seeing any way that kmalloc could possibly be a
> less-fragmenting call than vmalloc.

You guys are having quite a discussion over a very small point.

But, Ying is right.

Let's say we have a two-page data structure.  vmalloc() takes two
effectively random order-0 pages, probably from two different 2M pages
and pins them.  That "kills" two 2M pages.

kmalloc(), allocating two *contiguous* pages, is very unlikely to cross
a 2M boundary (it theoretically could).  That means it will only "kill"
the possibility of a single 2M page.  More 2M pages == less fragmentation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
