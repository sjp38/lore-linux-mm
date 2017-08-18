Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id C95476B0491
	for <linux-mm@kvack.org>; Fri, 18 Aug 2017 13:48:25 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id k82so13393878oih.1
        for <linux-mm@kvack.org>; Fri, 18 Aug 2017 10:48:25 -0700 (PDT)
Received: from mail-oi0-x22c.google.com (mail-oi0-x22c.google.com. [2607:f8b0:4003:c06::22c])
        by mx.google.com with ESMTPS id a10si4711205oib.276.2017.08.18.10.48.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Aug 2017 10:48:24 -0700 (PDT)
Received: by mail-oi0-x22c.google.com with SMTP id f11so103711988oic.0
        for <linux-mm@kvack.org>; Fri, 18 Aug 2017 10:48:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <37D7C6CF3E00A74B8858931C1DB2F07753787AE4@SHSMSX103.ccr.corp.intel.com>
References: <84c7f26182b7f4723c0fe3b34ba912a9de92b8b7.1502758114.git.tim.c.chen@linux.intel.com>
 <CA+55aFznC1wqBSfYr8=92LGqz5-F6fHMzdXoqM4aOYx8sT1Dhg@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F07753786CE9@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFwzTMrZwh7TE_VeZt8gx5Syoop-kA=Xqs56=FkyakrM6g@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F0775378761B@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFy_RNx5TQ8esjPPOKuW-o+fXbZgWapau2MHyexcAZtqsw@mail.gmail.com>
 <20170818122339.24grcbzyhnzmr4qw@techsingularity.net> <37D7C6CF3E00A74B8858931C1DB2F077537879BB@SHSMSX103.ccr.corp.intel.com>
 <20170818144622.oabozle26hasg5yo@techsingularity.net> <37D7C6CF3E00A74B8858931C1DB2F07753787AE4@SHSMSX103.ccr.corp.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 18 Aug 2017 10:48:23 -0700
Message-ID: <CA+55aFxZjjqUM4kPvNEeZahPovBHFATiwADj-iPTDN0-jnU67Q@mail.gmail.com>
Subject: Re: [PATCH 1/2] sched/wait: Break up long wake list walk
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Liang, Kan" <kan.liang@intel.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, Aug 18, 2017 at 9:53 AM, Liang, Kan <kan.liang@intel.com> wrote:
>
>> On Fri, Aug 18, 2017 Mel Gorman wrote:
>>
>> That indicates that it may be a hot page and it's possible that the page is
>> locked for a short time but waiters accumulate.  What happens if you leave
>> NUMA balancing enabled but disable THP?
>
> No, disabling THP doesn't help the case.

Interesting.  That particular code sequence should only be active for
THP. What does the profile look like with THP disabled but with NUMA
balancing still enabled?

Just asking because maybe that different call chain could give us some
other ideas of what the commonality here is that triggers out
behavioral problem.

I was really hoping that we'd root-cause this and have a solution (and
then apply Tim's patch as a "belt and suspenders" kind of thing), but
it's starting to smell like we may have to apply Tim's patch as a
band-aid, and try to figure out what the trigger is longer-term.

                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
