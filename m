Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id D91BA6B0005
	for <linux-mm@kvack.org>; Thu, 25 Jan 2018 17:29:16 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id l66so2211906oih.23
        for <linux-mm@kvack.org>; Thu, 25 Jan 2018 14:29:16 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m187si2602767oib.444.2018.01.25.14.29.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jan 2018 14:29:15 -0800 (PST)
Date: Thu, 25 Jan 2018 23:29:10 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH v2] mm: Reduce memory bloat with THP
Message-ID: <20180125222910.GA4454@redhat.com>
References: <1516318444-30868-1-git-send-email-nitingupta910@gmail.com>
 <20180119124957.GA6584@dhcp22.suse.cz>
 <ce7c1498-9f28-2eb0-67b7-ade9b04b8e2b@oracle.com>
 <59F98618-C49F-48A8-BCA1-A8F717888BAA@cs.rutgers.edu>
 <4d7ce874-9771-ad5f-c064-52a46fc37689@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4d7ce874-9771-ad5f-c064-52a46fc37689@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nitin Gupta <nitin.m.gupta@oracle.com>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>, Michal Hocko <mhocko@kernel.org>, Nitin Gupta <nitingupta910@gmail.com>, steven.sistare@oracle.com, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Mel Gorman <mgorman@suse.de>, Nadav Amit <namit@vmware.com>, Minchan Kim <minchan@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Vegard Nossum <vegard.nossum@oracle.com>, "Levin, Alexander" <alexander.levin@verizon.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Shaohua Li <shli@fb.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Dave Jiang <dave.jiang@intel.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Hugh Dickins <hughd@google.com>, Tobin C Harding <me@tobin.cc>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jan 25, 2018 at 11:41:03AM -0800, Nitin Gupta wrote:
> I'm trying to address many different THP issues and memory bloat is
> first among them.

You quoted redis in an earlier email, the redis issue has nothing to
do with MADV_DONTNEED.

I can quickly explain the redis issue.

Redis uses fork() to create a readonly copy of the memory to do
snapshotting in the child, while parent still writes to the memory.

THP CoWs in the parent are higher latency than 4k CoWs, they also take
more memory, but that's secondary, in fact the maximum waste of memory
in this model will reach the same worst case (x2) with 4k CoWs
too, no difference.

The problem is the copy-user there, it adds latency and wastes CPU.

Redis can simply use userfaultfd WP mode once it'll be upstream and
then it will use 4k granularity as the granularity of the writeprotect
userfaults is up to userland to decide.

The main benefit is it can avoid the worst case degradation of using
x2 physical memory (disabling THP makes zero difference in that
regard, if storage is very slow x2 physical memory can still be used
if very unlucky), it can throttle the WP writes (anon COW cannot
throttle), it can avoid to fork altogether so it shares the same
pagetables. It can also put the "user-CoWed" pages (in the fault
handler) in front of the write queue, to be written first, using a
ring buffer for the CoWed 4k pages, to keep memory utilization even
lower despite THP stays on at all times for all pages that didn't get
a CoW yet. This will be an optimal snapshot method, much better than
fork() no matter if 4k or THP are backing the memory.

In short MADV_DONTNEED has nothing to do with redis, if mysql gets an
improvement surely you can post a benchmark instead of URLs.

If you want low memory usage at the cost of potentially slower
performance overall you should use transparent_hugepage=madvise .

The cases where THP is not a good tradeoff are genreally related to
lower performance in copy-user or the higher cost of compaction if the
app is only ever doing short lived allocations.

If you post a reproducible benchmark with real life app that gets an
improvement with whatever change you're doing, it'll be possible to
evaluate it.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
