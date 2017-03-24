Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 105B46B0333
	for <linux-mm@kvack.org>; Thu, 23 Mar 2017 22:41:51 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id c23so4023464pfj.0
        for <linux-mm@kvack.org>; Thu, 23 Mar 2017 19:41:51 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id v198si794443pgb.216.2017.03.23.19.41.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Mar 2017 19:41:50 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -v2 1/2] mm, swap: Use kvzalloc to allocate some swap data structure
References: <20170320084732.3375-1-ying.huang@intel.com>
	<alpine.DEB.2.10.1703201430550.24991@chino.kir.corp.google.com>
Date: Fri, 24 Mar 2017 10:41:45 +0800
In-Reply-To: <alpine.DEB.2.10.1703201430550.24991@chino.kir.corp.google.com>
	(David Rientjes's message of "Mon, 20 Mar 2017 14:32:27 -0700")
Message-ID: <8737e3z992.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Tim Chen <tim.c.chen@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Aaron Lu <aaron.lu@intel.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Vegard Nossum <vegard.nossum@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

David Rientjes <rientjes@google.com> writes:

> On Mon, 20 Mar 2017, Huang, Ying wrote:
>
>> From: Huang Ying <ying.huang@intel.com>
>> 
>> Now vzalloc() is used in swap code to allocate various data
>> structures, such as swap cache, swap slots cache, cluster info, etc.
>> Because the size may be too large on some system, so that normal
>> kzalloc() may fail.  But using kzalloc() has some advantages, for
>> example, less memory fragmentation, less TLB pressure, etc.  So change
>> the data structure allocation in swap code to use kvzalloc() which
>> will try kzalloc() firstly, and fallback to vzalloc() if kzalloc()
>> failed.
>> 
>
> As questioned in -v1 of this patch, what is the benefit of directly 
> compacting and reclaiming memory for high-order pages by first preferring 
> kmalloc() if this does not require contiguous memory?

The memory allocation here is only for swap on time, not for swap out/in
time.  The performance of swap on is not considered critical.  But if
the kmalloc() is used instead of the vmalloc(), the swap out/in
performance could be improved (marginally).  More importantly, the
interference for the other activity on the system could be reduced, For
example, less memory fragmentation, less TLB usage of swap subsystem,
etc.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
