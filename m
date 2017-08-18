Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id D5DFE6B0387
	for <linux-mm@kvack.org>; Fri, 18 Aug 2017 12:55:57 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id v11so13205445oif.2
        for <linux-mm@kvack.org>; Fri, 18 Aug 2017 09:55:57 -0700 (PDT)
Received: from mail-oi0-x241.google.com (mail-oi0-x241.google.com. [2607:f8b0:4003:c06::241])
        by mx.google.com with ESMTPS id j128si2120181oif.349.2017.08.18.09.55.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Aug 2017 09:55:57 -0700 (PDT)
Received: by mail-oi0-x241.google.com with SMTP id j194so9789483oib.4
        for <linux-mm@kvack.org>; Fri, 18 Aug 2017 09:55:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170818122339.24grcbzyhnzmr4qw@techsingularity.net>
References: <84c7f26182b7f4723c0fe3b34ba912a9de92b8b7.1502758114.git.tim.c.chen@linux.intel.com>
 <CA+55aFznC1wqBSfYr8=92LGqz5-F6fHMzdXoqM4aOYx8sT1Dhg@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F07753786CE9@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFwzTMrZwh7TE_VeZt8gx5Syoop-kA=Xqs56=FkyakrM6g@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F0775378761B@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFy_RNx5TQ8esjPPOKuW-o+fXbZgWapau2MHyexcAZtqsw@mail.gmail.com> <20170818122339.24grcbzyhnzmr4qw@techsingularity.net>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 18 Aug 2017 09:55:56 -0700
Message-ID: <CA+55aFysB-2qcvuCjRzV0HD5d7q--nq2McabihDSQ9arBAgnqQ@mail.gmail.com>
Subject: Re: [PATCH 1/2] sched/wait: Break up long wake list walk
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: "Liang, Kan" <kan.liang@intel.com>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, Aug 18, 2017 at 5:23 AM, Mel Gorman <mgorman@techsingularity.net> wrote:
>
>         new_page = alloc_pages_node(node,
> -               (GFP_TRANSHUGE_LIGHT | __GFP_THISNODE),
> +               (GFP_TRANSHUGE_LIGHT | __GFP_THISNODE) & ~__GFP_DIRECT_RECLAIM,
>                 HPAGE_PMD_ORDER);

That can't make any difference. We already have:

  #define GFP_TRANSHUGE_LIGHT     ((GFP_HIGHUSER_MOVABLE | __GFP_COMP | \
                         __GFP_NOMEMALLOC | __GFP_NOWARN) & ~__GFP_RECLAIM)

and that "& ~__GFP_RECLAIM" is removing __GFP_DIRECT_RECLAIM.

So that patch is a no-op, afaik.

Is there something else expensive in there?

It *might* be simply that we have a shit-ton of threads, and the
thread that holds the page lock for migration is just preempted out.
even if it doesn't really do anything particularly expensive.

                           Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
