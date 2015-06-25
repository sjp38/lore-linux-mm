Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id 103396B0038
	for <linux-mm@kvack.org>; Thu, 25 Jun 2015 18:04:31 -0400 (EDT)
Received: by igin14 with SMTP id n14so1753360igi.1
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 15:04:30 -0700 (PDT)
Received: from mail-ie0-x22a.google.com (mail-ie0-x22a.google.com. [2607:f8b0:4001:c03::22a])
        by mx.google.com with ESMTPS id p20si5461485igs.34.2015.06.25.15.04.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jun 2015 15:04:30 -0700 (PDT)
Received: by iecvh10 with SMTP id vh10so64045867iec.3
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 15:04:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <558C5342.9020702@suse.cz>
References: <1433767854-24408-1-git-send-email-mgorman@suse.de>
	<20150608174551.GA27558@gmail.com>
	<20150609084739.GQ26425@suse.de>
	<20150609103231.GA11026@gmail.com>
	<20150609112055.GS26425@suse.de>
	<20150609124328.GA23066@gmail.com>
	<5577078B.2000503@intel.com>
	<20150621202231.GB6766@node.dhcp.inet.fi>
	<20150625114819.GA20478@gmail.com>
	<CA+55aFykFDZBEP+fBeqF85jSVuhWVjL5SW_22FTCMrCeoihauw@mail.gmail.com>
	<558C5342.9020702@suse.cz>
Date: Thu, 25 Jun 2015 15:04:30 -0700
Message-ID: <CA+55aFx_ZvnrWWXm9fn+gD4Jcdcr3VwvcC61xJP6xVZzJjxVCg@mail.gmail.com>
Subject: Re: [PATCH 0/3] TLB flush multiple pages per IPI v5
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, linux-mm <linux-mm@kvack.org>, Borislav Petkov <bp@alien8.de>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, H Peter Anvin <hpa@zytor.com>, Andi Kleen <andi@firstfloor.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jun 25, 2015 at 12:15 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
>>   [..]  even aside from that, Intel seems to do particularly well at the
>> "next page" TLB fill case
>
> AFAIK that's because they also cache partial translations, so if the first 3
> levels are the same (as they mostly are for the "next page" scenario) it will
> only have to look at the last level of pages tables. AMD does that too.

In the tests I did long ago, Intel seemed to do even more than that.

Now, it's admittedly somewhat hard to do a good job at TLB fill cost
measurement with any aggressively out-of-order core (lots of
asynchronous and potentially speculative stuff going on), so without
any real knowledge about what is going on it's kind of hard to say.
But I had an old TLB benchmark (long lost now, so I can't re-run it to
check on this) that implied that when Intel brings in a new TLB entry,
they brought it in 32 bytes at a time, and would then look up the
adjacent entries in that aligned half-cache-line in just a single
cycle.

(This was back in the P6/P4/Core Duo kinds of days - we're talking
10-15 years ago.  The tests I did mapped the constant zero-page in a
big area, so that the effects of the D$ would be minimized, and I'd
basically *only* see the TLB miss costs. I also did things like
measure the costs of the micro-fault that happens when marking a page
table entry entry dirty for the first time etc, which was absolutely
horrendously slow on a P4).

Now, it could have been other effects too - things like multiple
outstanding TLB misses in parallel due to prefetching TLB entries
could possibly cause similar patterns, although I distinctly remember
that effect of aligned 8-entry entries. So the simplest explanation
*seemed* to be a very special single-entry 32-byte "L0 cache" for TLB
fills (and 32 bytes would probably match the L1 fetch width into the
core).

That's in *addition* to the fact that the upper level entries are
cached in the TLB.

As mentioned earlier, from my Transmeta days I have some insight into
what old pre-NT Windows used to do. The GDI protection traversal
seemed to flush the whole TLB for every GDI kernel entry, and some of
the graphics benchmarks (remember: this was back in the days when
unaccelerated VGA graphics was still a big deal) would literally blow
the TLB away every 5-10k instructions. So it actually makes sense that
Intel and AMD spent a *lot* of effort on making TLB fills go fast,
because those GDI benchmarks were important back then. It was all the
basic old 2D window handling and font drawing etc benchmarking.

None of the RISC vendors ever cared, they had absolutely crap
hardware, and instead encouraged their SW partners (particularly
databases) to change the software to use large-pages and any trick
possible to avoid TLB misses. Their compilers would schedule loads
early and stores late, because the whole memory subsystem was a toy.
TLB misses would break the whole pipeline etc. Truly crap hardware,
and people still look up to it. Sad.

In the Windows world, that wasn't an option: when Microsoft said
"jump", Intel and AMD both said "how high?". As a result, x86 is a
*lot* more well-rounded than any RISC I have ever seen, because
Intel/AMD were simply forced to run any crap software, rather than
having software writers optimize for what they were good at.

                       Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
