Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f171.google.com (mail-ve0-f171.google.com [209.85.128.171])
	by kanga.kvack.org (Postfix) with ESMTP id EEBAE6B0031
	for <linux-mm@kvack.org>; Tue,  3 Jun 2014 15:04:30 -0400 (EDT)
Received: by mail-ve0-f171.google.com with SMTP id oz11so7484832veb.16
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 12:04:30 -0700 (PDT)
Received: from mail-vc0-x229.google.com (mail-vc0-x229.google.com [2607:f8b0:400c:c03::229])
        by mx.google.com with ESMTPS id ek11si65279vdd.25.2014.06.03.12.04.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Jun 2014 12:04:30 -0700 (PDT)
Received: by mail-vc0-f169.google.com with SMTP id il7so3693240vcb.0
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 12:04:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <87mwduqg09.fsf@rasmusvillemoes.dk>
References: <1401260039-18189-1-git-send-email-minchan@kernel.org>
	<1401260039-18189-2-git-send-email-minchan@kernel.org>
	<CA+55aFxXdc22dirnE49UbQP_2s2vLQpjQFL+NptuyK7Xry6c=g@mail.gmail.com>
	<20140528223142.GO8554@dastard>
	<CA+55aFyRk6_v6COPGVvu6hvt=i2A8-dPcs1X3Ydn1g24AxbPkg@mail.gmail.com>
	<20140529013007.GF6677@dastard>
	<20140529015830.GG6677@dastard>
	<20140529233638.GJ10092@bbox>
	<20140530001558.GB14410@dastard>
	<20140530021247.GR10092@bbox>
	<87mwduqg09.fsf@rasmusvillemoes.dk>
Date: Tue, 3 Jun 2014 12:04:29 -0700
Message-ID: <CA+55aFyYQES1CbEfYzRkFas_aw=+YNSbDoLRJpjh2sDFxVV3vg@mail.gmail.com>
Subject: Re: [RFC 2/2] x86_64: expand kernel stack to 16K
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: Minchan Kim <minchan@kernel.org>, Dave Chinner <david@fromorbit.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Steven Rostedt <rostedt@goodmis.org>

On Tue, Jun 3, 2014 at 6:28 AM, Rasmus Villemoes
<linux@rasmusvillemoes.dk> wrote:
> Possibly stupid question: Is it true that any given task can only be
> using one wait_queue_t at a time?

Nope.

Being on multiple different wait-queues is actually very common. The
obvious case is select/poll, but there are others. The more subtle
ones involve being on a wait-queue while doing something that can
cause nested waiting (iow, it's technically not wrong to be on a
wait-queue and then do a user space access, which obviously can end up
doing IO).

That said, the case of a single wait-queue entry is another common
case, and it wouldn't necessarily be wrong to have one pre-initialized
wait queue entry in the task structure for that special case, for when
you know that there is no possible nesting. And even if it *does*
nest, if it's the "leaf" entry it could be used for that innermost
nesting without worrying about other wait queue users (who use stack
allocations or actual explicit allocations like poll).

So it might certainly be worth looking at. In fact, it might be worth
it having multiple per-thread entries, so that we could get rid of the
special on-stack allocation for poll too (and making one of them
special and not available to poll, to handle the "leaf waiter" case).

So it's not necessarily a bad idea at all, even if the general case
requires more than one (or a few) static per-thread allocations.

Anybody want to try to code it up?

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
