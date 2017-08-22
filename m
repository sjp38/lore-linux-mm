Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id D36F128071E
	for <linux-mm@kvack.org>; Tue, 22 Aug 2017 15:30:22 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id g131so24886678oic.10
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 12:30:22 -0700 (PDT)
Received: from mail-oi0-x244.google.com (mail-oi0-x244.google.com. [2607:f8b0:4003:c06::244])
        by mx.google.com with ESMTPS id t130si11983963oib.238.2017.08.22.12.30.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Aug 2017 12:30:21 -0700 (PDT)
Received: by mail-oi0-x244.google.com with SMTP id h4so2060260oic.2
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 12:30:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170822190828.GO32112@worktop.programming.kicks-ass.net>
References: <37D7C6CF3E00A74B8858931C1DB2F077537879BB@SHSMSX103.ccr.corp.intel.com>
 <20170818144622.oabozle26hasg5yo@techsingularity.net> <37D7C6CF3E00A74B8858931C1DB2F07753787AE4@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFxZjjqUM4kPvNEeZahPovBHFATiwADj-iPTDN0-jnU67Q@mail.gmail.com>
 <20170818185455.qol3st2nynfa47yc@techsingularity.net> <CA+55aFwX0yrUPULrDxTWVCg5c6DKh-yCG84NXVxaptXNQ4O_kA@mail.gmail.com>
 <20170821183234.kzennaaw2zt2rbwz@techsingularity.net> <37D7C6CF3E00A74B8858931C1DB2F07753788B58@SHSMSX103.ccr.corp.intel.com>
 <37D7C6CF3E00A74B8858931C1DB2F0775378A24A@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFy=4y0fq9nL2WR1x8vwzJrDOdv++r036LXpR=6Jx8jpzg@mail.gmail.com> <20170822190828.GO32112@worktop.programming.kicks-ass.net>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 22 Aug 2017 12:30:19 -0700
Message-ID: <CA+55aFzPt401xpRzd6Qu-WuDNGneR_m7z25O=0YspNi+cLRb8w@mail.gmail.com>
Subject: Re: [PATCH 1/2] sched/wait: Break up long wake list walk
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "Liang, Kan" <kan.liang@intel.com>, Mel Gorman <mgorman@techsingularity.net>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Aug 22, 2017 at 12:08 PM, Peter Zijlstra <peterz@infradead.org> wrote:
>
> So that migration stuff has a filter on, we need two consecutive numa
> faults from the same page_cpupid 'hash', see
> should_numa_migrate_memory().

Hmm. That is only called for MPOL_F_MORON.

We don't actually know what policy the problem space uses, since tthis
is some specialized load.

I could easily see somebody having set MPOL_PREFERRED with
MPOL_F_LOCAL and then touch it from every single node. Isn't that even
the default?

> And since this appears to be anonymous memory (no THP) this is all a
> single address space. However, we don't appear to invalidate TLBs when
> we upgrade the PTE protection bits (not strictly required of course), so
> we can have multiple CPUs trip over the same 'old' NUMA PTE.
>
> Still, generating such a migration storm would be fairly tricky I think.

Well, Mel seems to have been unable to generate a load that reproduces
the long page waitqueues. And I don't think we've had any other
reports of this either.

So "quite tricky" may well be exactly what it needs.

Likely also with a user load that does something that the people
involved in the automatic numa migration would have considered
completely insane and never tested or even thought about.

Users sometimes do completely insane things. It may have started as a
workaround for some particular case where they did something wrong "on
purpose", and then they entirely forgot about it, and five years later
it's running their whole infrastructure and doing insane things
because the "particular case" it was tested with was on some broken
preproduction machine with totally broken firmware tables for memory
node layout.

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
