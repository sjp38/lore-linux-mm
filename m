Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 89D616B006E
	for <linux-mm@kvack.org>; Mon, 23 Feb 2015 17:56:21 -0500 (EST)
Received: by pablf10 with SMTP id lf10so31000036pab.12
        for <linux-mm@kvack.org>; Mon, 23 Feb 2015 14:56:21 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id sk3si23046580pab.208.2015.02.23.14.56.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Feb 2015 14:56:20 -0800 (PST)
Date: Mon, 23 Feb 2015 14:56:19 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC 0/6] the big khugepaged redesign
Message-Id: <20150223145619.64f3a225b914034a17d4f520@linux-foundation.org>
In-Reply-To: <1424731603.6539.51.camel@stgolabs.net>
References: <1424696322-21952-1-git-send-email-vbabka@suse.cz>
	<1424731603.6539.51.camel@stgolabs.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Alex Thorlton <athorlton@sgi.com>, David Rientjes <rientjes@google.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>

On Mon, 23 Feb 2015 14:46:43 -0800 Davidlohr Bueso <dave@stgolabs.net> wrote:

> On Mon, 2015-02-23 at 13:58 +0100, Vlastimil Babka wrote:
> > Recently, there was concern expressed (e.g. [1]) whether the quite aggressive
> > THP allocation attempts on page faults are a good performance trade-off.
> > 
> > - THP allocations add to page fault latency, as high-order allocations are
> >   notoriously expensive. Page allocation slowpath now does extra checks for
> >   GFP_TRANSHUGE && !PF_KTHREAD to avoid the more expensive synchronous
> >   compaction for user page faults. But even async compaction can be expensive.
> > - During the first page fault in a 2MB range we cannot predict how much of the
> >   range will be actually accessed - we can theoretically waste as much as 511
> >   worth of pages [2]. Or, the pages in the range might be accessed from CPUs
> >   from different NUMA nodes and while base pages could be all local, THP could
> >   be remote to all but one CPU. The cost of remote accesses due to this false
> >   sharing would be higher than any savings on the TLB.
> > - The interaction with memcg are also problematic [1].
> > 
> > Now I don't have any hard data to show how big these problems are, and I
> > expect we will discuss this on LSF/MM (and hope somebody has such data [3]).
> > But it's certain that e.g. SAP recommends to disable THPs [4] for their apps
> > for performance reasons.
> 
> There are plenty of examples of this, ie for Oracle:
> 
> https://blogs.oracle.com/linux/entry/performance_issues_with_transparent_huge

hm, five months ago and I don't recall seeing any followup to this. 
Does anyone know what's happening?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
