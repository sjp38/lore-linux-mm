Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 37A106B0003
	for <linux-mm@kvack.org>; Thu,  1 Feb 2018 05:46:35 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id 17so1135452wma.1
        for <linux-mm@kvack.org>; Thu, 01 Feb 2018 02:46:35 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g76si1400933wmd.44.2018.02.01.02.46.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Feb 2018 02:46:33 -0800 (PST)
Date: Thu, 1 Feb 2018 10:46:28 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v2] mm: Reduce memory bloat with THP
Message-ID: <20180201104627.33uhhrk45kuimxqd@suse.de>
References: <1516318444-30868-1-git-send-email-nitingupta910@gmail.com>
 <20180119124957.GA6584@dhcp22.suse.cz>
 <ce7c1498-9f28-2eb0-67b7-ade9b04b8e2b@oracle.com>
 <59F98618-C49F-48A8-BCA1-A8F717888BAA@cs.rutgers.edu>
 <4d7ce874-9771-ad5f-c064-52a46fc37689@oracle.com>
 <20180125211303.rbfeg7ultwr6hpd3@suse.de>
 <20180201102730.al4jl2raldfgoy7f@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20180201102730.al4jl2raldfgoy7f@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Nitin Gupta <nitin.m.gupta@oracle.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Michal Hocko <mhocko@kernel.org>, Nitin Gupta <nitingupta910@gmail.com>, steven.sistare@oracle.com, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Nadav Amit <namit@vmware.com>, Minchan Kim <minchan@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Vegard Nossum <vegard.nossum@oracle.com>, "Levin, Alexander" <alexander.levin@verizon.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Shaohua Li <shli@fb.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Dave Jiang <dave.jiang@intel.com>, J?r?me Glisse <jglisse@redhat.com>, Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Hugh Dickins <hughd@google.com>, Tobin C Harding <me@tobin.cc>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Feb 01, 2018 at 01:27:30PM +0300, Kirill A. Shutemov wrote:
> > It's non-trivial to do this because at minimum a page fault has to check
> > if there is a potential promotion candidate by checking the PTEs around
> > the faulting address searching for a correctly-aligned base page that is
> > already inserted. If there is, then check if the correctly aligned base
> > page for the current faulting address is free and if so use it. It'll
> > also then need to check the remaining PTEs to see if both the promotion
> > threshold has been reached and if so, promote it to a THP (or else teach
> > khugepaged to do an in-place promotion if possible). In other words,
> > implementing the promotion threshold is both hard and it's not free.
> 
> "not free" is understatement.
> 
> Converting PTE page table to PMD would require down_write(mmap_sem).
> Doing it from within page fault path would also mean that we need to drop
> down_read(mmap) we hold, re-aquaire it with down_write(), find the vma again
> and re-validate that nothing changed in meanwhile...
> 
> That's an interesting exercise, but I'm skeptical it would result in anything
> practical.
> 

The details are painful but we're somewhat caught between a rock and a
hard place for workloads that sparsely reference memory and want to avoid
excessive memory usage. Given that the cost will be high, it may need to
dynamically detect what the promotion threshold is -- default high and
reduce it on a per-task basis if promotions are frequent.

Either way, expecting applications to get it right with hints is the road
to hell paved with good intentions. If they were able to get this right,
they would be using prctl(PR_SET_THP_DISABLE) already.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
