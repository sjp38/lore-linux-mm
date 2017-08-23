Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 52D342803E9
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 14:17:32 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id u6so884946oif.0
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 11:17:32 -0700 (PDT)
Received: from mail-oi0-x242.google.com (mail-oi0-x242.google.com. [2607:f8b0:4003:c06::242])
        by mx.google.com with ESMTPS id i190si1653211oib.547.2017.08.23.11.17.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Aug 2017 11:17:31 -0700 (PDT)
Received: by mail-oi0-x242.google.com with SMTP id w8so282328oig.5
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 11:17:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <6e8b81de-e985-9222-29c5-594c6849c351@linux.intel.com>
References: <CA+55aFwzTMrZwh7TE_VeZt8gx5Syoop-kA=Xqs56=FkyakrM6g@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F077537879BB@SHSMSX103.ccr.corp.intel.com>
 <20170818144622.oabozle26hasg5yo@techsingularity.net> <37D7C6CF3E00A74B8858931C1DB2F07753787AE4@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFxZjjqUM4kPvNEeZahPovBHFATiwADj-iPTDN0-jnU67Q@mail.gmail.com>
 <20170818185455.qol3st2nynfa47yc@techsingularity.net> <CA+55aFwX0yrUPULrDxTWVCg5c6DKh-yCG84NXVxaptXNQ4O_kA@mail.gmail.com>
 <20170821183234.kzennaaw2zt2rbwz@techsingularity.net> <37D7C6CF3E00A74B8858931C1DB2F07753788B58@SHSMSX103.ccr.corp.intel.com>
 <37D7C6CF3E00A74B8858931C1DB2F0775378A24A@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFy=4y0fq9nL2WR1x8vwzJrDOdv++r036LXpR=6Jx8jpzg@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F0775378A377@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFwavpFfKNW9NVgNhLggqhii-guc5aX1X5fxrPK+==id0g@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F0775378A8AB@SHSMSX103.ccr.corp.intel.com> <6e8b81de-e985-9222-29c5-594c6849c351@linux.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 23 Aug 2017 11:17:30 -0700
Message-ID: <CA+55aFzbom=qFc2pYk07XhiMBn083EXugSUHmSVbTuu8eJtHVQ@mail.gmail.com>
Subject: Re: [PATCH 1/2] sched/wait: Break up long wake list walk
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: "Liang, Kan" <kan.liang@intel.com>, Mel Gorman <mgorman@techsingularity.net>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, Aug 23, 2017 at 8:58 AM, Tim Chen <tim.c.chen@linux.intel.com> wrote:
>
> Will you still consider the original patch as a fail safe mechanism?

I don't think we have much choice, although I would *really* want to
get this root-caused rather than just papering over the symptoms.

Maybe still worth testing that "sched/numa: Scale scan period with
tasks in group and shared/private" patch that Mel mentioned.

In fact, looking at that patch description, it does seem to match this
particular load a lot. Quoting from the commit message:

  "Running 80 tasks in the same group, or as threads of the same process,
   results in the memory getting scanned 80x as fast as it would be if a
   single task was using the memory.

   This really hurts some workloads"

So if 80 threads causes 80x as much scanning, a few thousand threads
might indeed be really really bad.

So once more unto the breach, dear friends, once more.

Please.

The patch got applied to -tip as commit b5dd77c8bdad, and can be
downloaded here:

  https://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git/commit/?id=b5dd77c8bdada7b6262d0cba02a6ed525bf4e6e1

(Hmm. It says it's cc'd to me, but I never noticed that patch simply
because it was in a big group of other -tip commits.. Oh well).

          Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
