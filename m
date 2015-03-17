Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id A9DD26B0032
	for <linux-mm@kvack.org>; Tue, 17 Mar 2015 12:53:58 -0400 (EDT)
Received: by iegc3 with SMTP id c3so16157874ieg.3
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 09:53:58 -0700 (PDT)
Received: from mail-ig0-x22e.google.com (mail-ig0-x22e.google.com. [2607:f8b0:4001:c05::22e])
        by mx.google.com with ESMTPS id p8si15523657ick.75.2015.03.17.09.53.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Mar 2015 09:53:57 -0700 (PDT)
Received: by ignm3 with SMTP id m3so56667699ign.0
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 09:53:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150317070655.GB10105@dastard>
References: <CA+55aFwDuzpL-k8LsV3touhNLh+TFSLKP8+-nPwMXkWXDYPhrg@mail.gmail.com>
	<20150308100223.GC15487@gmail.com>
	<CA+55aFyQyZXu2fi7X9bWdSX0utk8=sccfBwFaSoToROXoE_PLA@mail.gmail.com>
	<20150309112936.GD26657@destitution>
	<CA+55aFywW5JLq=BU_qb2OG5+pJ-b1v9tiS5Ygi-vtEKbEZ_T5Q@mail.gmail.com>
	<20150309191943.GF26657@destitution>
	<CA+55aFzFt-vX5Jerci0Ty4Uf7K4_nQ7wyCp8hhU_dB0X4cBpVQ@mail.gmail.com>
	<20150312131045.GE3406@suse.de>
	<CA+55aFx=81BGnQFNhnAGu6CetL7yifPsnD-+v7Y6QRqwgH47gQ@mail.gmail.com>
	<20150312184925.GH3406@suse.de>
	<20150317070655.GB10105@dastard>
Date: Tue, 17 Mar 2015 09:53:57 -0700
Message-ID: <CA+55aFzdLnFdku-gnm3mGbeS=QauYBNkFQKYXJAGkrMd2jKXhw@mail.gmail.com>
Subject: Re: [PATCH 4/4] mm: numa: Slow PTE scan rate if migration failures occur
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, xfs@oss.sgi.com, ppc-dev <linuxppc-dev@lists.ozlabs.org>

On Tue, Mar 17, 2015 at 12:06 AM, Dave Chinner <david@fromorbit.com> wrote:
>
> TO close the loop here, now I'm back home and can run tests:
>
> config                            3.19      4.0-rc1     4.0-rc4
> defaults                         8m08s        9m34s       9m14s
> -o ag_stride=-1                  4m04s        4m38s       4m11s
> -o bhash=101073                  6m04s       17m43s       7m35s
> -o ag_stride=-1,bhash=101073     4m54s        9m58s       7m50s
>
> It's better but there are still significant regressions, especially
> for the large memory footprint cases. I haven't had a chance to look
> at any stats or profiles yet, so I don't know yet whether this is
> still page fault related or some other problem....

Ok. I'd love to see some data on what changed between 3.19 and rc4 in
the profiles, just to see whether it's "more page faults due to extra
COW", or whether it's due to "more TLB flushes because of the
pte_write() vs pte_dirty()" differences. I'm *guessing*  lot of the
remaining issues are due to extra page fault overhead because I'd
expect write/dirty to be fairly 1:1, but there could be differences
due to shared memory use and/or just writebacks of dirty pages that
become clean.

I guess you can also see in vmstat.mm_migrate_pages whether it's
because of excessive migration (because of bad grouping) or not. So
not just profiles data.

At the same time, I feel fairly happy about the situation - we at
least understand what is going on, and the "3x worse performance" case
is at least gone.  Even if that last case still looks horrible.

So it's still a bad performance regression, but at the same time I
think your test setup (big 500 TB filesystem, but then a fake-numa
thing with just 4GB per node) is specialized and unrealistic enough
that I don't feel it's all that relevant from a *real-world*
standpoint, and so I wouldn't be uncomfortable saying "ok, the page
table handling cleanup caused some issues, but we know about them and
how to fix them longer-term".  So I don't consider this a 4.0
showstopper or a "we need to revert for now" issue.

If it's a case of "we take a lot more page faults because we handle
the NUMA fault and then have a COW fault almost immediately", then the
fix is likely to do the same early-cow that the normal non-numa-fault
case does. In fact, my gut feel is that we should try to unify that
numa/regula fault handling path a bit more, but that would be a pretty
invasive patch.

                     Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
