Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f173.google.com (mail-ie0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 840D36B0038
	for <linux-mm@kvack.org>; Tue, 17 Mar 2015 17:30:58 -0400 (EDT)
Received: by iegc3 with SMTP id c3so23089042ieg.3
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 14:30:58 -0700 (PDT)
Received: from mail-ig0-x22c.google.com (mail-ig0-x22c.google.com. [2607:f8b0:4001:c05::22c])
        by mx.google.com with ESMTPS id h6si16208774icw.107.2015.03.17.14.30.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Mar 2015 14:30:57 -0700 (PDT)
Received: by igcqo1 with SMTP id qo1so25997300igc.0
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 14:30:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150317205104.GA28621@dastard>
References: <CA+55aFyQyZXu2fi7X9bWdSX0utk8=sccfBwFaSoToROXoE_PLA@mail.gmail.com>
	<20150309112936.GD26657@destitution>
	<CA+55aFywW5JLq=BU_qb2OG5+pJ-b1v9tiS5Ygi-vtEKbEZ_T5Q@mail.gmail.com>
	<20150309191943.GF26657@destitution>
	<CA+55aFzFt-vX5Jerci0Ty4Uf7K4_nQ7wyCp8hhU_dB0X4cBpVQ@mail.gmail.com>
	<20150312131045.GE3406@suse.de>
	<CA+55aFx=81BGnQFNhnAGu6CetL7yifPsnD-+v7Y6QRqwgH47gQ@mail.gmail.com>
	<20150312184925.GH3406@suse.de>
	<20150317070655.GB10105@dastard>
	<CA+55aFzdLnFdku-gnm3mGbeS=QauYBNkFQKYXJAGkrMd2jKXhw@mail.gmail.com>
	<20150317205104.GA28621@dastard>
Date: Tue, 17 Mar 2015 14:30:57 -0700
Message-ID: <CA+55aFzSPcNgxw4GC7aAV1r0P5LniyVVC66COz=3cgMcx73Nag@mail.gmail.com>
Subject: Re: [PATCH 4/4] mm: numa: Slow PTE scan rate if migration failures occur
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, xfs@oss.sgi.com, ppc-dev <linuxppc-dev@lists.ozlabs.org>

On Tue, Mar 17, 2015 at 1:51 PM, Dave Chinner <david@fromorbit.com> wrote:
>
> On the -o ag_stride=-1 -o bhash=101073 config, the 60s perf stat I
> was using during steady state shows:
>
>      471,752      migrate:mm_migrate_pages ( +-  7.38% )
>
> The migrate pages rate is even higher than in 4.0-rc1 (~360,000)
> and 3.19 (~55,000), so that looks like even more of a problem than
> before.

Hmm. How stable are those numbers boot-to-boot?

That kind of extreme spread makes me suspicious. It's also interesting
that if the numbers really go up even more (and by that big amount),
then why does there seem to be almost no correlation with performance
(which apparently went up since rc1, despite migrate_pages getting
even _worse_).

> And the profile looks like:
>
> -   43.73%     0.05%  [kernel]            [k] native_flush_tlb_others

Ok, that's down from rc1 (67%), but still hugely up from 3.19 (13.7%).
And flush_tlb_page() does seem to be called about ten times more
(flush_tlb_mm_range used to be 1.4% of the callers, now it's invisible
at 0.13%)

Damn. From a performance number standpoint, it looked like we zoomed
in on the right thing. But now it's migrating even more pages than
before. Odd.

> And the vmstats are:
>
> 3.19:
>
> numa_hit 5163221
> numa_local 5153127

> 4.0-rc1:
>
> numa_hit 36952043
> numa_local 36927384
>
> 4.0-rc4:
>
> numa_hit 23447345
> numa_local 23438564
>
> Page migrations are still up by a factor of ~20 on 3.19.

The thing is, those "numa_hit" things come from the zone_statistics()
call in buffered_rmqueue(), which in turn is simple from the memory
allocator. That has *nothing* to do with virtual memory, and
everything to do with actual physical memory allocations.  So the load
is simply allocating a lot more pages, presumably for those stupid
migration events.

But then it doesn't correlate with performance anyway..

Can you do a simple stupid test? Apply that commit 53da3bc2ba9e ("mm:
fix up numa read-only thread grouping logic") to 3.19, so that it uses
the same "pte_dirty()" logic as 4.0-rc4. That *should* make the 3.19
and 4.0-rc4 numbers comparable.

It does make me wonder if your load is "chaotic" wrt scheduling. The
load presumably wants to spread out across all cpu's, but then the
numa code tries to group things together for numa accesses, but
depending on just random allocation patterns and layout in the hash
tables, there either are patters with page access or there aren't.

Which is kind of why I wonder how stable those numbers are boot to
boot. Maybe this is at least partly about lucky allocation patterns.

                              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
