Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 25C156B0007
	for <linux-mm@kvack.org>; Thu,  1 Feb 2018 05:09:50 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id o2so3159259pls.10
        for <linux-mm@kvack.org>; Thu, 01 Feb 2018 02:09:50 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 137si1186525pgd.237.2018.02.01.02.09.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Feb 2018 02:09:49 -0800 (PST)
Date: Thu, 1 Feb 2018 10:09:40 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v2] mm: Reduce memory bloat with THP
Message-ID: <20180201100940.mry3x7lbkcdnid56@suse.de>
References: <1516318444-30868-1-git-send-email-nitingupta910@gmail.com>
 <20180119124957.GA6584@dhcp22.suse.cz>
 <ce7c1498-9f28-2eb0-67b7-ade9b04b8e2b@oracle.com>
 <59F98618-C49F-48A8-BCA1-A8F717888BAA@cs.rutgers.edu>
 <4d7ce874-9771-ad5f-c064-52a46fc37689@oracle.com>
 <20180125211303.rbfeg7ultwr6hpd3@suse.de>
 <c8e16ca6-b78d-6066-4d5a-bb6be337c93e@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <c8e16ca6-b78d-6066-4d5a-bb6be337c93e@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nitin Gupta <nitin.m.gupta@oracle.com>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>, Michal Hocko <mhocko@kernel.org>, Nitin Gupta <nitingupta910@gmail.com>, steven.sistare@oracle.com, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Nadav Amit <namit@vmware.com>, Minchan Kim <minchan@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Vegard Nossum <vegard.nossum@oracle.com>, "Levin, Alexander" <alexander.levin@verizon.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Shaohua Li <shli@fb.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Dave Jiang <dave.jiang@intel.com>, J?r?me Glisse <jglisse@redhat.com>, Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Hugh Dickins <hughd@google.com>, Tobin C Harding <me@tobin.cc>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jan 31, 2018 at 05:09:48PM -0800, Nitin Gupta wrote:
> > 
> > It's non-trivial to do this because at minimum a page fault has to check
> > if there is a potential promotion candidate by checking the PTEs around
> > the faulting address searching for a correctly-aligned base page that is
> > already inserted. If there is, then check if the correctly aligned base
> > page for the current faulting address is free and if so use it. It'll
> > also then need to check the remaining PTEs to see if both the promotion
> > threshold has been reached and if so, promote it to a THP (or else teach
> > khugepaged to do an in-place promotion if possible). In other words,
> > implementing the promotion threshold is both hard and it's not free.
> > 
> > However, if it did exist then the only tunable would be the "promotion
> > threshold" and applications would not need any special awareness of their
> > address space.
> > 
> 
> I went through both references you mentioned and I really like the
> idea of reservation-based hugepage allocation.  Navarro also extends
> the idea to allow multiple hugepage sizes to be used (as support by
> underlying hardware) which was next in order of what I wanted to do in
> THP.
> 

Don't sweat too much about the multiple page size part. At the time Navarro
was writing, it was expected that hardware would support multiple page
sizes with fine granularity (e.g. what Itanium did). Just covering the PMD
huge page size would go a long way towards balancing memory consumption
and huge page usage.

> So, please ignore this patch and I would work towards implementing
> ideas in these papers.
> 
> Thanks for the feedback.
> 

My pleasure.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
