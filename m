Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id CB5696B0069
	for <linux-mm@kvack.org>; Mon, 19 Sep 2016 03:11:56 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id g22so257687864ioj.1
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 00:11:56 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id g17si24227413ita.7.2016.09.19.00.11.55
        for <linux-mm@kvack.org>;
        Mon, 19 Sep 2016 00:11:56 -0700 (PDT)
Date: Mon, 19 Sep 2016 16:11:53 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH -v3 00/10] THP swap: Delay splitting THP during swapping
 out
Message-ID: <20160919071153.GB4083@bbox>
References: <1473266769-2155-1-git-send-email-ying.huang@intel.com>
 <20160909054336.GA2114@bbox>
 <87sht824n3.fsf@yhuang-mobile.sh.intel.com>
 <20160913061349.GA4445@bbox>
 <87y42wgv5r.fsf@yhuang-dev.intel.com>
 <20160913070524.GA4973@bbox>
 <87vay0ji3m.fsf@yhuang-mobile.sh.intel.com>
 <20160913091652.GB7132@bbox>
 <045D8A5597B93E4EBEDDCBF1FC15F50935BF9343@fmsmsx104.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <045D8A5597B93E4EBEDDCBF1FC15F50935BF9343@fmsmsx104.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Chen, Tim C" <tim.c.chen@intel.com>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Hansen, Dave" <dave.hansen@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, "Lu, Aaron" <aaron.lu@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

Hi Tim,

On Tue, Sep 13, 2016 at 11:52:27PM +0000, Chen, Tim C wrote:
> >>
> >> - Avoid CPU time for splitting, collapsing THP across swap out/in.
> >
> >Yes, if you want, please give us how bad it is.
> >
> 
> It could be pretty bad.  In an experiment with THP turned on and we
> enter swap, 50% of the cpu are spent in the page compaction path.  

It's page compaction overhead, especially, pageblock_pfn_to_page.
Why is it related to overhead THP split for swapout?
I don't understand.

> So if we could deal with units of large page for swap, the splitting
> and compaction of ordinary pages to large page overhead could be avoided.
> 
>    51.89%    51.89%            :1688  [kernel.kallsyms]   [k] pageblock_pfn_to_page                       
>                       |
>                       --- pageblock_pfn_to_page
>                          |          
>                          |--64.57%-- compaction_alloc
>                          |          migrate_pages
>                          |          compact_zone
>                          |          compact_zone_order
>                          |          try_to_compact_pages
>                          |          __alloc_pages_direct_compact
>                          |          __alloc_pages_nodemask
>                          |          alloc_pages_vma
>                          |          do_huge_pmd_anonymous_page
>                          |          handle_mm_fault
>                          |          __do_page_fault
>                          |          do_page_fault
>                          |          page_fault
>                          |          0x401d9a
>                          |          
>                          |--34.62%-- compact_zone
>                          |          compact_zone_order
>                          |          try_to_compact_pages
>                          |          __alloc_pages_direct_compact
>                          |          __alloc_pages_nodemask
>                          |          alloc_pages_vma
>                          |          do_huge_pmd_anonymous_page
>                          |          handle_mm_fault
>                          |          __do_page_fault
>                          |          do_page_fault
>                          |          page_fault
>                          |          0x401d9a
>                           --0.81%-- [...]
> 
> Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
