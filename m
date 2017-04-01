Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 339576B0390
	for <linux-mm@kvack.org>; Sat,  1 Apr 2017 00:48:02 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id v4so99226319pgc.20
        for <linux-mm@kvack.org>; Fri, 31 Mar 2017 21:48:02 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id c73si7054759pfj.383.2017.03.31.21.48.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Mar 2017 21:48:01 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -v2 1/2] mm, swap: Use kvzalloc to allocate some swap data structure
References: <20170320084732.3375-1-ying.huang@intel.com>
	<alpine.DEB.2.10.1703201430550.24991@chino.kir.corp.google.com>
	<8737e3z992.fsf@yhuang-dev.intel.com>
	<f17cb7e4-4d47-4aed-6fdb-cda5c5d47fa4@nvidia.com>
	<87poh7xoms.fsf@yhuang-dev.intel.com>
	<2d55e06d-a0b6-771a-bba0-f9517d422789@nvidia.com>
	<87d1d7uoti.fsf@yhuang-dev.intel.com>
	<624b8e59-34e5-3538-0a93-d33d9e4ac555@nvidia.com>
	<e79064f1-8594-bef2-fbd8-1579afb4aac3@linux.intel.com>
	<20170330163128.GF4326@dhcp22.suse.cz>
Date: Sat, 01 Apr 2017 12:47:56 +0800
In-Reply-To: <20170330163128.GF4326@dhcp22.suse.cz> (Michal Hocko's message of
	"Thu, 30 Mar 2017 18:31:28 +0200")
Message-ID: <87lgrkpwcj.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, John Hubbard <jhubbard@nvidia.com>, "Huang, Ying" <ying.huang@intel.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Tim Chen <tim.c.chen@linux.intel.com>, Mel Gorman <mgorman@techsingularity.net>, Aaron Lu <aaron.lu@intel.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Vegard Nossum <vegard.nossum@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi, Michal,

Michal Hocko <mhocko@kernel.org> writes:

> On Fri 24-03-17 06:56:10, Dave Hansen wrote:
>> On 03/24/2017 12:33 AM, John Hubbard wrote:
>> > There might be some additional information you are using to come up with
>> > that conclusion, that is not obvious to me. Any thoughts there? These
>> > calls use the same underlying page allocator (and I thought that both
>> > were subject to the same constraints on defragmentation, as a result of
>> > that). So I am not seeing any way that kmalloc could possibly be a
>> > less-fragmenting call than vmalloc.
>> 
>> You guys are having quite a discussion over a very small point.
>> 
>> But, Ying is right.
>> 
>> Let's say we have a two-page data structure.  vmalloc() takes two
>> effectively random order-0 pages, probably from two different 2M pages
>> and pins them.  That "kills" two 2M pages.
>> 
>> kmalloc(), allocating two *contiguous* pages, is very unlikely to cross
>> a 2M boundary (it theoretically could).  That means it will only "kill"
>> the possibility of a single 2M page.  More 2M pages == less fragmentation.
>
> Yes I agree with this. And the patch is no brainer. kvmalloc makes sure
> to not try too hard on the kmalloc side so I really didn't get the
> objection about direct compaction and reclaim which initially started
> this discussion. Besides that the swapon path usually happens early
> during the boot where we should have those larger blocks available.

Could I add your Acked-by for this patch?

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
