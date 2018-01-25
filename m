Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 50124800D8
	for <linux-mm@kvack.org>; Thu, 25 Jan 2018 04:58:35 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id e195so3647346wmd.9
        for <linux-mm@kvack.org>; Thu, 25 Jan 2018 01:58:35 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 5si617891wmf.69.2018.01.25.01.58.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 25 Jan 2018 01:58:33 -0800 (PST)
Date: Thu, 25 Jan 2018 10:58:32 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm: Reduce memory bloat with THP
Message-ID: <20180125095832.GN28465@dhcp22.suse.cz>
References: <1516318444-30868-1-git-send-email-nitingupta910@gmail.com>
 <20180119124957.GA6584@dhcp22.suse.cz>
 <ce7c1498-9f28-2eb0-67b7-ade9b04b8e2b@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ce7c1498-9f28-2eb0-67b7-ade9b04b8e2b@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nitin Gupta <nitin.m.gupta@oracle.com>
Cc: Nitin Gupta <nitingupta910@gmail.com>, steven.sistare@oracle.com, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Mel Gorman <mgorman@suse.de>, Nadav Amit <namit@vmware.com>, Minchan Kim <minchan@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Vegard Nossum <vegard.nossum@oracle.com>, "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Shaohua Li <shli@fb.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Dave Jiang <dave.jiang@intel.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Hugh Dickins <hughd@google.com>, Tobin C Harding <me@tobin.cc>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri 19-01-18 12:59:17, Nitin Gupta wrote:
> On 1/19/18 4:49 AM, Michal Hocko wrote:
> > On Thu 18-01-18 15:33:16, Nitin Gupta wrote:
> >> From: Nitin Gupta <nitin.m.gupta@oracle.com>
> >>
> >> Currently, if the THP enabled policy is "always", or the mode
> >> is "madvise" and a region is marked as MADV_HUGEPAGE, a hugepage
> >> is allocated on a page fault if the pud or pmd is empty.  This
> >> yields the best VA translation performance, but increases memory
> >> consumption if some small page ranges within the huge page are
> >> never accessed.
> > 
> > Yes, this is true but hardly unexpected for MADV_HUGEPAGE or THP always
> > users.
> >  
> 
> Yes, allocating hugepage on first touch is the current behavior for
> above two cases. However, I see issues with this current behavior.
> Firstly, THP=always mode is often too aggressive/wasteful to be useful
> for any realistic workloads. For THP=madvise, users may want to back
> active parts of memory region with hugepages while avoiding aggressive
> hugepage allocation on first touch. Or, they may really want the current
> behavior.

Then they should use THP=never and rely on the khugepaged to compact
madvise regions. This will avoid first touch problem and you can also
control how large portion of the THP has to be mapped already.

> With this patch, users would have the option to pick what behavior they
> want by passing hints to the kernel in the form of MADV_HUGEPAGE and
> MADV_DONTNEED madvise calls.

more on this below
 
[...]
> >> With this change, whenever an application issues MADV_DONTNEED on a
> >> memory region, the region is marked as "space-efficient". For such
> >> regions, a hugepage is not immediately allocated on first write.
> > 
> > Kirill didn't like it in the previous version and I do not like this
> > either. You are adding a very subtle side effect which might completely
> > unexpected. Consider userspace memory allocator which uses MADV_DONTNEED
> > to free up unused memory. Now you have put it out of THP usage
> > basically.
> >
> 
> Userpsace may want a region to be considered by khugepaged while opting
> out of hugepage allocation on first touch. Asking userspace memory
> allocators to have to track and reclaim unused parts of a THP allocated
> hugepage does not seems right, as the kernel can use simple userspace
> hints to avoid allocating extra memory in the first place.

Yes. This is in sync with what I wrote. Allocators shouldn't care and
that is why MADV_DONTNEED with side effect is simply wrong.

> I agree that this patch is adding a subtle side-effect which may take
> some applications by surprise. However, I often see the opposite too:
> for many workloads, disabling THP is the first advise as this aggressive
> allocation of hugepages on first touch is unexpected and is too
> wasteful. For e.g.:

Ohh, absolutely. And that is why we have changed the default in upstream
444eb2a449ef ("mm: thp: set THP defrag by default to madvise and add a
stall-free defrag option")
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
