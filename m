Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id B5E156B006C
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 12:17:16 -0400 (EDT)
Received: by igbhj9 with SMTP id hj9so39322592igb.1
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 09:17:16 -0700 (PDT)
Received: from mail-ig0-x232.google.com (mail-ig0-x232.google.com. [2607:f8b0:4001:c05::232])
        by mx.google.com with ESMTPS id ba5si9320335icc.39.2015.06.10.09.17.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jun 2015 09:17:16 -0700 (PDT)
Received: by igblz2 with SMTP id lz2so37243194igb.1
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 09:17:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150610131354.GO19417@two.firstfloor.org>
References: <1433767854-24408-1-git-send-email-mgorman@suse.de>
	<20150608174551.GA27558@gmail.com>
	<20150609084739.GQ26425@suse.de>
	<20150609103231.GA11026@gmail.com>
	<20150609112055.GS26425@suse.de>
	<20150609124328.GA23066@gmail.com>
	<5577078B.2000503@intel.com>
	<55771909.2020005@intel.com>
	<55775749.3090004@intel.com>
	<CA+55aFz6b5pG9tRNazk8ynTCXS3whzWJ_737dt1xxAHDf1jASQ@mail.gmail.com>
	<20150610131354.GO19417@two.firstfloor.org>
Date: Wed, 10 Jun 2015 09:17:15 -0700
Message-ID: <CA+55aFwVUkdaf0_rBk7uJHQjWXu+OcLTHc6FKuCn0Cb2Kvg9NA@mail.gmail.com>
Subject: Re: [PATCH 0/3] TLB flush multiple pages per IPI v5
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Ingo Molnar <mingo@kernel.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, H Peter Anvin <hpa@zytor.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>

On Wed, Jun 10, 2015 at 6:13 AM, Andi Kleen <andi@firstfloor.org> wrote:
>
> Assuming the page tables are cache-hot... And hot here does not mean
> L3 cache, but higher. But a memory intensive workload can easily
> violate that.

In practice, no.

You'll spend all your time on the actual real data cache misses, the
TLB misses won't be any more noticeable.

And if your access patters are even *remoptely* cache-friendly (ie
_not_ spending all your time just waiting for regular data cache
misses), then a radix-tree-like page table like Intel will have much
better locality in the page tables than in the actual data. So again,
the TLB misses won't be your big problem.

There may be pathological cases where you just look at one word per
page, but let's face it, we don't optimize for pathological or
unrealistic cases.

And the thing is, you need to look at the costs. Single-page
invalidation taking hundreds of cycles? Yeah, we definitely need to
take the downside of trying to be clever into account.

If the invalidation was really cheap, the rules might change. As it
is, I really don't think there is any question about this.

That's particularly true when the single-page invalidation approach
has lots of *software* overhead too - not just the complexity, but
even "obvious" costs feeding the list of pages to be invalidated
across CPU's. Think about it - there are cache misses there too, and
because we do those across CPU's those cache misses are *mandatory*.

So trying to avoid a few TLB misses by forcing mandatory cache misses
and extra complexity, and by doing lots of 200+ cycle operations?
Really? In what universe does that sound like a good idea?

Quite frankly, I can pretty much *guarantee* that you didn't actually
think about any real numbers, you've just been taught that fairy-tale
of "TLB misses are expensive". As if TLB entries were somehow sacred.

If somebody can show real numbers on a real workload, that's one
thing. But in the absence of those real numbers, we should go for the
simple and straightforward code, and not try to make up "but but but
it could be expensive" issues.

Trying to avoid IPI's by batching them up sounds like a very obvious
win. I absolutely believe that is worth it. I just don't believe it is
worth it trying to pass a lot of page detail data around. The number
of individual pages flushed should be *very* controlled.

Here's a suggestion: the absolute maximum number of TLB entries we
flush should be something we can describe in one single cacheline.
Strive to minimize the number of cachelines we have to transfer for
the IPI, instead of trying to minimize the number of TLB entries. So
maybe soemthing along the lines of "one word of flags (all or nothing,
or a range), or up to seven indivual addresses to be flushed". I
personally think even seven invlpg's is likely too much, but with the
"single cacheline" at least there's another basis for the limit too.

So anyway, I like the patch series. I just think that the final patch
- the one that actually saves the addreses, and limits things to
BATCH_TLBFLUSH_SIZE, should be limited.

                   Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
