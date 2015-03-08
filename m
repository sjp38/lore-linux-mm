Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 2141F6B0038
	for <linux-mm@kvack.org>; Sun,  8 Mar 2015 14:36:00 -0400 (EDT)
Received: by igbhl2 with SMTP id hl2so14621933igb.0
        for <linux-mm@kvack.org>; Sun, 08 Mar 2015 11:35:59 -0700 (PDT)
Received: from mail-ig0-x229.google.com (mail-ig0-x229.google.com. [2607:f8b0:4001:c05::229])
        by mx.google.com with ESMTPS id x13si787032ioi.93.2015.03.08.11.35.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 08 Mar 2015 11:35:59 -0700 (PDT)
Received: by igbhn18 with SMTP id hn18so15463295igb.2
        for <linux-mm@kvack.org>; Sun, 08 Mar 2015 11:35:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150308100223.GC15487@gmail.com>
References: <1425741651-29152-1-git-send-email-mgorman@suse.de>
	<1425741651-29152-5-git-send-email-mgorman@suse.de>
	<20150307163657.GA9702@gmail.com>
	<CA+55aFwDuzpL-k8LsV3touhNLh+TFSLKP8+-nPwMXkWXDYPhrg@mail.gmail.com>
	<20150308100223.GC15487@gmail.com>
Date: Sun, 8 Mar 2015 11:35:59 -0700
Message-ID: <CA+55aFyQyZXu2fi7X9bWdSX0utk8=sccfBwFaSoToROXoE_PLA@mail.gmail.com>
Subject: Re: [PATCH 4/4] mm: numa: Slow PTE scan rate if migration failures occur
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, xfs@oss.sgi.com, ppc-dev <linuxppc-dev@lists.ozlabs.org>

On Sun, Mar 8, 2015 at 3:02 AM, Ingo Molnar <mingo@kernel.org> wrote:
>
> Well, there's a difference in what we write to the pte:
>
>  #define _PAGE_BIT_NUMA          (_PAGE_BIT_GLOBAL+1)
>  #define _PAGE_BIT_PROTNONE      _PAGE_BIT_GLOBAL
>
> and our expectation was that the two should be equivalent methods from
> the POV of the NUMA balancing code, right?

Right.

But yes, we might have screwed something up. In particular, there
might be something that thinks it cares about the global bit, but
doesn't notice that the present bit isn't set, so it considers the
protnone mappings to be global and causes lots more tlb flushes etc.

>> I don't like the old pmdp_set_numa() because it can drop dirty bits,
>> so I think the old code was actively buggy.
>
> Could we, as a silly testing hack not to be applied, write a
> hack-patch that re-introduces the racy way of setting the NUMA bit, to
> confirm that it is indeed this difference that changes pte visibility
> across CPUs enough to create so many more faults?

So one of Mel's patches did that, but I don't know if Dave tested it.

And thinking about it, it *may* be safe for huge-pages, if they always
already have the dirty bit set to begin with. And I don't see how we
could have a clean hugepage (apart from the special case of the
zeropage, which is read-only, so races on teh dirty bit aren't an
issue).

So it might actually be that the non-atomic version is safe for
hpages. And we could possibly get rid of the "atomic read-and-clear"
even for the non-numa case.

I'd rather do it for both cases than for just one of them.

But:

> As a second hack (not to be applied), could we change:
>
>  #define _PAGE_BIT_PROTNONE      _PAGE_BIT_GLOBAL
>
> to:
>
>  #define _PAGE_BIT_PROTNONE      (_PAGE_BIT_GLOBAL+1)
>
> to double check that the position of the bit does not matter?

Agreed. We should definitely try that.

Dave?

Also, is there some sane way for me to actually see this behavior on a
regular machine with just a single socket? Dave is apparently running
in some fake-numa setup, I'm wondering if this is easy enough to
reproduce that I could see it myself.

                          Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
