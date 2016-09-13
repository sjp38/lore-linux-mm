Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 091026B0069
	for <linux-mm@kvack.org>; Tue, 13 Sep 2016 19:52:30 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id n24so2167656pfb.0
        for <linux-mm@kvack.org>; Tue, 13 Sep 2016 16:52:30 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id ww6si1246235pab.52.2016.09.13.16.52.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 13 Sep 2016 16:52:29 -0700 (PDT)
From: "Chen, Tim C" <tim.c.chen@intel.com>
Subject: RE: [PATCH -v3 00/10] THP swap: Delay splitting THP during swapping
 out
Date: Tue, 13 Sep 2016 23:52:27 +0000
Message-ID: <045D8A5597B93E4EBEDDCBF1FC15F50935BF9343@fmsmsx104.amr.corp.intel.com>
References: <1473266769-2155-1-git-send-email-ying.huang@intel.com>
 <20160909054336.GA2114@bbox> <87sht824n3.fsf@yhuang-mobile.sh.intel.com>
 <20160913061349.GA4445@bbox> <87y42wgv5r.fsf@yhuang-dev.intel.com>
 <20160913070524.GA4973@bbox> <87vay0ji3m.fsf@yhuang-mobile.sh.intel.com>
 <20160913091652.GB7132@bbox>
In-Reply-To: <20160913091652.GB7132@bbox>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Hansen, Dave" <dave.hansen@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, "Lu, Aaron" <aaron.lu@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A .
 Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

>>
>> - Avoid CPU time for splitting, collapsing THP across swap out/in.
>
>Yes, if you want, please give us how bad it is.
>

It could be pretty bad.  In an experiment with THP turned on and we
enter swap, 50% of the cpu are spent in the page compaction path. =20
So if we could deal with units of large page for swap, the splitting
and compaction of ordinary pages to large page overhead could be avoided.

   51.89%    51.89%            :1688  [kernel.kallsyms]   [k] pageblock_pfn=
_to_page                      =20
                      |
                      --- pageblock_pfn_to_page
                         |         =20
                         |--64.57%-- compaction_alloc
                         |          migrate_pages
                         |          compact_zone
                         |          compact_zone_order
                         |          try_to_compact_pages
                         |          __alloc_pages_direct_compact
                         |          __alloc_pages_nodemask
                         |          alloc_pages_vma
                         |          do_huge_pmd_anonymous_page
                         |          handle_mm_fault
                         |          __do_page_fault
                         |          do_page_fault
                         |          page_fault
                         |          0x401d9a
                         |         =20
                         |--34.62%-- compact_zone
                         |          compact_zone_order
                         |          try_to_compact_pages
                         |          __alloc_pages_direct_compact
                         |          __alloc_pages_nodemask
                         |          alloc_pages_vma
                         |          do_huge_pmd_anonymous_page
                         |          handle_mm_fault
                         |          __do_page_fault
                         |          do_page_fault
                         |          page_fault
                         |          0x401d9a
                          --0.81%-- [...]

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
