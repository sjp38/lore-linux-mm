Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 429F46B0032
	for <linux-mm@kvack.org>; Mon, 23 Feb 2015 17:47:01 -0500 (EST)
Received: by pdbfp1 with SMTP id fp1so28681185pdb.9
        for <linux-mm@kvack.org>; Mon, 23 Feb 2015 14:47:00 -0800 (PST)
Received: from smtp2.provo.novell.com (smtp2.provo.novell.com. [137.65.250.81])
        by mx.google.com with ESMTPS id f2si1190415pas.147.2015.02.23.14.46.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 23 Feb 2015 14:47:00 -0800 (PST)
Message-ID: <1424731603.6539.51.camel@stgolabs.net>
Subject: Re: [RFC 0/6] the big khugepaged redesign
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Mon, 23 Feb 2015 14:46:43 -0800
In-Reply-To: <1424696322-21952-1-git-send-email-vbabka@suse.cz>
References: <1424696322-21952-1-git-send-email-vbabka@suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Alex Thorlton <athorlton@sgi.com>, David Rientjes <rientjes@google.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>

On Mon, 2015-02-23 at 13:58 +0100, Vlastimil Babka wrote:
> Recently, there was concern expressed (e.g. [1]) whether the quite aggressive
> THP allocation attempts on page faults are a good performance trade-off.
> 
> - THP allocations add to page fault latency, as high-order allocations are
>   notoriously expensive. Page allocation slowpath now does extra checks for
>   GFP_TRANSHUGE && !PF_KTHREAD to avoid the more expensive synchronous
>   compaction for user page faults. But even async compaction can be expensive.
> - During the first page fault in a 2MB range we cannot predict how much of the
>   range will be actually accessed - we can theoretically waste as much as 511
>   worth of pages [2]. Or, the pages in the range might be accessed from CPUs
>   from different NUMA nodes and while base pages could be all local, THP could
>   be remote to all but one CPU. The cost of remote accesses due to this false
>   sharing would be higher than any savings on the TLB.
> - The interaction with memcg are also problematic [1].
> 
> Now I don't have any hard data to show how big these problems are, and I
> expect we will discuss this on LSF/MM (and hope somebody has such data [3]).
> But it's certain that e.g. SAP recommends to disable THPs [4] for their apps
> for performance reasons.

There are plenty of examples of this, ie for Oracle:

https://blogs.oracle.com/linux/entry/performance_issues_with_transparent_huge
http://oracle-base.com/articles/linux/configuring-huge-pages-for-oracle-on-linux-64.php

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
