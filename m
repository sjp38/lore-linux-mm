Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id D5C929003C7
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 19:19:56 -0400 (EDT)
Received: by pachj5 with SMTP id hj5so127735596pac.3
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 16:19:56 -0700 (PDT)
Received: from mail-pd0-x230.google.com (mail-pd0-x230.google.com. [2607:f8b0:400e:c02::230])
        by mx.google.com with ESMTPS id rq5si46590387pab.83.2015.07.21.16.19.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jul 2015 16:19:56 -0700 (PDT)
Received: by pdbbh15 with SMTP id bh15so82297686pdb.1
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 16:19:55 -0700 (PDT)
Date: Tue, 21 Jul 2015 16:19:53 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [rfc] mm, thp: allow khugepaged to periodically compact memory
 synchronously
In-Reply-To: <55AE1285.4010600@suse.cz>
Message-ID: <alpine.DEB.2.10.1507211607250.3833@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1507141918340.11697@chino.kir.corp.google.com> <55AE1285.4010600@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 21 Jul 2015, Vlastimil Babka wrote:

> On 07/15/2015 04:19 AM, David Rientjes wrote:
> > We have seen a large benefit in the amount of hugepages that can be
> > allocated at fault
> 
> That's understandable...
> 
> > and by khugepaged when memory is periodically
> > compacted in the background.
> 
> ... but for khugepaged it's surprising. Doesn't khugepaged (unlike page
> faults) attempt the same sync compaction as your manual triggers?
> 

Not exactly, this compaction is over all memory rather than just 
terminating when you find a pageblock free.  It keeps more pageblocks free 
of memory that are easily allocated both at fault and by khugepaged 
without having to do its own compaction.  The largest benefit, obviously, 
is to the page fault path, however.

> > We trigger synchronous memory compaction over all memory every 15 minutes
> > to keep fragmentation low and to offset the lightweight compaction that
> > is done at page fault to keep latency low.
> 
> I'm surprised that 15 minutes is frequent enough to make a difference. I'd
> expect it very much depends on the memory size and workload though.
> 

This is over all machines running all workloads and its directly related 
to how abort-happy we have made memory compaction in the pagefault path 
which occurs when locks are contended or need_resched() triggers.  
Sometimes we see memory compaction doing very little work in the fault 
path as a result of this and this patch becomes the only real source of 
memory compactions over all memory; it just isn't triggered anywhere else.

We make it a tunable here because some users will want speed it up just as 
they do scan_sleep_millisecs or abort_sleep_millisecs and, yes, that will 
rely on your particular workload and config.

> > compact_sleep_millisecs controls how often khugepaged will compact all
> > memory.  Each scan_sleep_millisecs wakeup after this value has expired, a
> > node is synchronously compacted until all memory has been scanned.  Then,
> > khugepaged will restart the process compact_sleep_millisecs later.
> > 
> > This defaults to 0, which means no memory compaction is done.
> 
> Being another tunable and defaulting to 0 it means that most people won't use
> it at all, or their distro will provide some other value. We should really
> strive to make it self-tuning based on e.g. memory fragmentation statistics.
> But I know that my kcompactd proposal also wasn't quite there yet...
> 

Agreed on a better default.  I proposed the rfc this way because we need 
this functionality now and works well for our 15m period so we have no 
problem immediately tuning this to 15m.

I would imagine that the default should be a multiple of the 
abort_sleep_millisecs default of 60000 and consider the length of the 
largest node.

That said, I'm not sure about self-tuning of the period itself.  The 
premise is that this compaction keeps the memory in a relatively 
unfragmented state such that thp does not need to compact in the fault 
path and we have a much higher likelihood of being able to allocate since 
nothing else may actually trigger memory compaction besides this.  It 
seems like that should done on period defined by the user; hence, this is 
for "periodic memory compaction".

However, I agree with your comment in the kcompactd thread about the 
benefits of a different type, "background memory compaction", that can be 
kicked off when a high-order allocation fails, for instance, or based on 
a heuristic that looks at memory fragmentation statistics.  I think the 
two are quite distinct.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
