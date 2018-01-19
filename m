Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id E9A376B0069
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 07:50:01 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id 31so1197486wru.0
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 04:50:01 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t48si8251806wrc.507.2018.01.19.04.50.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 Jan 2018 04:50:00 -0800 (PST)
Date: Fri, 19 Jan 2018 13:49:57 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm: Reduce memory bloat with THP
Message-ID: <20180119124957.GA6584@dhcp22.suse.cz>
References: <1516318444-30868-1-git-send-email-nitingupta910@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1516318444-30868-1-git-send-email-nitingupta910@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nitin Gupta <nitingupta910@gmail.com>
Cc: steven.sistare@oracle.com, Nitin Gupta <nitin.m.gupta@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Mel Gorman <mgorman@suse.de>, Nadav Amit <namit@vmware.com>, Minchan Kim <minchan@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Vegard Nossum <vegard.nossum@oracle.com>, "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Shaohua Li <shli@fb.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Dave Jiang <dave.jiang@intel.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Hugh Dickins <hughd@google.com>, Tobin C Harding <me@tobin.cc>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu 18-01-18 15:33:16, Nitin Gupta wrote:
> From: Nitin Gupta <nitin.m.gupta@oracle.com>
> 
> Currently, if the THP enabled policy is "always", or the mode
> is "madvise" and a region is marked as MADV_HUGEPAGE, a hugepage
> is allocated on a page fault if the pud or pmd is empty.  This
> yields the best VA translation performance, but increases memory
> consumption if some small page ranges within the huge page are
> never accessed.

Yes, this is true but hardly unexpected for MADV_HUGEPAGE or THP always
users.
 
> An alternate behavior for such page faults is to install a
> hugepage only when a region is actually found to be (almost)
> fully mapped and active.  This is a compromise between
> translation performance and memory consumption.  Currently there
> is no way for an application to choose this compromise for the
> page fault conditions above.

Is that really true? We have /sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_none
This is not reflected during the PF of course but you can control the
behavior there as well. Either by the global setting or a per proces
prctl.

> With this change, whenever an application issues MADV_DONTNEED on a
> memory region, the region is marked as "space-efficient". For such
> regions, a hugepage is not immediately allocated on first write.

Kirill didn't like it in the previous version and I do not like this
either. You are adding a very subtle side effect which might completely
unexpected. Consider userspace memory allocator which uses MADV_DONTNEED
to free up unused memory. Now you have put it out of THP usage
basically.

If the memory is used really scarce then we have MADV_NOHUGEPAGE.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
