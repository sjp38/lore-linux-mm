Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 2D6966B006E
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 17:54:02 -0400 (EDT)
Received: by igbpi8 with SMTP id pi8so21833219igb.1
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 14:54:02 -0700 (PDT)
Received: from mail-ig0-x233.google.com (mail-ig0-x233.google.com. [2607:f8b0:4001:c05::233])
        by mx.google.com with ESMTPS id nq6si2324610igb.16.2015.06.09.14.54.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jun 2015 14:54:01 -0700 (PDT)
Received: by igbzc4 with SMTP id zc4so21884929igb.0
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 14:54:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <55775749.3090004@intel.com>
References: <1433767854-24408-1-git-send-email-mgorman@suse.de>
	<20150608174551.GA27558@gmail.com>
	<20150609084739.GQ26425@suse.de>
	<20150609103231.GA11026@gmail.com>
	<20150609112055.GS26425@suse.de>
	<20150609124328.GA23066@gmail.com>
	<5577078B.2000503@intel.com>
	<55771909.2020005@intel.com>
	<55775749.3090004@intel.com>
Date: Tue, 9 Jun 2015 14:54:01 -0700
Message-ID: <CA+55aFz6b5pG9tRNazk8ynTCXS3whzWJ_737dt1xxAHDf1jASQ@mail.gmail.com>
Subject: Re: [PATCH 0/3] TLB flush multiple pages per IPI v5
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Andi Kleen <andi@firstfloor.org>, H Peter Anvin <hpa@zytor.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>

On Tue, Jun 9, 2015 at 2:14 PM, Dave Hansen <dave.hansen@intel.com> wrote:
>
> The 0 cycle TLB miss was also interesting.  It goes back up to something
> reasonable if I put the mb()/mfence's back.

So I've said it before, and I'll say it again: Intel does really well
on TLB fills.

The reason is partly historical, with Win95 doing a ton of TLB
invalidation (I think every single GDI call ended up invalidating the
TLB, so under some important Windows benchmarks of the time, you
literally had a TLB flush every 10k instructions!).

But partly it is because people are wrong in thinking that TLB fills
have to be slow. There's a lot of complete garbage RISC machines where
the TLB fill took forever, because in the name of simplicity it would
stop the pipeline and often be done in SW.

The zero-cycle TLB fill is obviously a bit optimistic, but at the same
time it's not completely insane. TLB fills can be prefetched, and the
table walker can hit the cache, if you do them right. And Intel mostly
does.

So the normal full (non-global) TLB fill really is fairly cheap. It's
been optimized for, and the TLB gets re-filled fairly efficiently. I
suspect that it's really the case that doing more than just a couple
of single-tlb flushes is a complete waste of time: the flushing takes
longer than re-filling the TLB well.

                         Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
