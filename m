Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id BF9C06B04A9
	for <linux-mm@kvack.org>; Fri, 18 Aug 2017 16:34:39 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id s21so13863553oie.5
        for <linux-mm@kvack.org>; Fri, 18 Aug 2017 13:34:39 -0700 (PDT)
Received: from mail-oi0-x243.google.com (mail-oi0-x243.google.com. [2607:f8b0:4003:c06::243])
        by mx.google.com with ESMTPS id k129si5212397oih.103.2017.08.18.13.34.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Aug 2017 13:34:38 -0700 (PDT)
Received: by mail-oi0-x243.google.com with SMTP id v11so10365185oif.1
        for <linux-mm@kvack.org>; Fri, 18 Aug 2017 13:34:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <37D7C6CF3E00A74B8858931C1DB2F07753787CCE@SHSMSX103.ccr.corp.intel.com>
References: <84c7f26182b7f4723c0fe3b34ba912a9de92b8b7.1502758114.git.tim.c.chen@linux.intel.com>
 <CA+55aFznC1wqBSfYr8=92LGqz5-F6fHMzdXoqM4aOYx8sT1Dhg@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F07753786CE9@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFwzTMrZwh7TE_VeZt8gx5Syoop-kA=Xqs56=FkyakrM6g@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F0775378761B@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFy_RNx5TQ8esjPPOKuW-o+fXbZgWapau2MHyexcAZtqsw@mail.gmail.com>
 <20170818122339.24grcbzyhnzmr4qw@techsingularity.net> <37D7C6CF3E00A74B8858931C1DB2F077537879BB@SHSMSX103.ccr.corp.intel.com>
 <20170818144622.oabozle26hasg5yo@techsingularity.net> <37D7C6CF3E00A74B8858931C1DB2F07753787AE4@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFxZjjqUM4kPvNEeZahPovBHFATiwADj-iPTDN0-jnU67Q@mail.gmail.com> <37D7C6CF3E00A74B8858931C1DB2F07753787CCE@SHSMSX103.ccr.corp.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 18 Aug 2017 13:34:37 -0700
Message-ID: <CA+55aFxuO1r1riZ=5dO9NtvWOhGQdKHfhfCTuahoOTjN_yd6UA@mail.gmail.com>
Subject: Re: [PATCH 1/2] sched/wait: Break up long wake list walk
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Liang, Kan" <kan.liang@intel.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, Aug 18, 2017 at 1:29 PM, Liang, Kan <kan.liang@intel.com> wrote:
> Here is the profiling with THP disabled for wait_on_page_bit_common and
> wake_up_page_bit.
>
>
> The call stack of wait_on_page_bit_common
> # Overhead  Trace output
> # ........  ..................
> #
>    100.00%  (ffffffff821aefca)
>             |
>             ---wait_on_page_bit
>                __migration_entry_wait
>                migration_entry_wait
>                do_swap_page

Ok, so it really is exactly the same thing, just for a regular page,
and there is absolutely nothing huge-page specific to this.

Thanks.

If you can test that (hacky, ugly) yield() patch, just to see how it
behaves (maybe it degrades performance horribly even if it then avoids
the long wait queues), that would be lovely.

Does the load actually have some way of measuring performance? Because
with the yield(), I'd hope that all the wait_on_page_bit() stuff is
all gone, but it might just *perform* horribly badly.

                      Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
