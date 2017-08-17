Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id AC4CC6B025F
	for <linux-mm@kvack.org>; Thu, 17 Aug 2017 16:44:42 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id g131so9892604oic.10
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 13:44:42 -0700 (PDT)
Received: from mail-oi0-x232.google.com (mail-oi0-x232.google.com. [2607:f8b0:4003:c06::232])
        by mx.google.com with ESMTPS id f189si3278305oig.443.2017.08.17.13.44.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Aug 2017 13:44:41 -0700 (PDT)
Received: by mail-oi0-x232.google.com with SMTP id f11so78548391oic.0
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 13:44:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <37D7C6CF3E00A74B8858931C1DB2F0775378761B@SHSMSX103.ccr.corp.intel.com>
References: <84c7f26182b7f4723c0fe3b34ba912a9de92b8b7.1502758114.git.tim.c.chen@linux.intel.com>
 <CA+55aFznC1wqBSfYr8=92LGqz5-F6fHMzdXoqM4aOYx8sT1Dhg@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F07753786CE9@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFwzTMrZwh7TE_VeZt8gx5Syoop-kA=Xqs56=FkyakrM6g@mail.gmail.com> <37D7C6CF3E00A74B8858931C1DB2F0775378761B@SHSMSX103.ccr.corp.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 17 Aug 2017 13:44:40 -0700
Message-ID: <CA+55aFy_RNx5TQ8esjPPOKuW-o+fXbZgWapau2MHyexcAZtqsw@mail.gmail.com>
Subject: Re: [PATCH 1/2] sched/wait: Break up long wake list walk
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Liang, Kan" <kan.liang@intel.com>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Aug 17, 2017 at 1:18 PM, Liang, Kan <kan.liang@intel.com> wrote:
>
> Here is the call stack of wait_on_page_bit_common
> when the queue is long (entries >1000).
>
> # Overhead  Trace output
> # ........  ..................
> #
>    100.00%  (ffffffff931aefca)
>             |
>             ---wait_on_page_bit
>                __migration_entry_wait
>                migration_entry_wait
>                do_swap_page
>                __handle_mm_fault
>                handle_mm_fault
>                __do_page_fault
>                do_page_fault
>                page_fault

Hmm. Ok, so it does seem to very much be related to migration. Your
wake_up_page_bit() profile made me suspect that, but this one seems to
pretty much confirm it.

So it looks like that wait_on_page_locked() thing in
__migration_entry_wait(), and what probably happens is that your load
ends up triggering a lot of migration (or just migration of a very hot
page), and then *every* thread ends up waiting for whatever page that
ended up getting migrated.

And so the wait queue for that page grows hugely long.

Looking at the other profile, the thing that is locking the page (that
everybody then ends up waiting on) would seem to be
migrate_misplaced_transhuge_page(), so this is _presumably_ due to
NUMA balancing.

Does the problem go away if you disable the NUMA balancing code?

Adding Mel and Kirill to the participants, just to make them aware of
the issue, and just because their names show up when I look at blame.

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
