Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id E43D56B01CC
	for <linux-mm@kvack.org>; Thu,  1 Jul 2010 17:54:27 -0400 (EDT)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id o61LsPeA007622
	for <linux-mm@kvack.org>; Thu, 1 Jul 2010 14:54:25 -0700
Received: from gxk24 (gxk24.prod.google.com [10.202.11.24])
	by wpaz24.hot.corp.google.com with ESMTP id o61Ls2BV024226
	for <linux-mm@kvack.org>; Thu, 1 Jul 2010 14:54:24 -0700
Received: by gxk24 with SMTP id 24so121111gxk.9
        for <linux-mm@kvack.org>; Thu, 01 Jul 2010 14:54:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100630142443.d9a9c49e.akpm@linux-foundation.org>
References: <1277747099-12770-1-git-send-email-mrubin@google.com>
	<20100630142443.d9a9c49e.akpm@linux-foundation.org>
From: Michael Rubin <mrubin@google.com>
Date: Thu, 1 Jul 2010 14:53:57 -0700
Message-ID: <AANLkTikMRjLS7lGFRF8DI7ThAi9VtedYJ4C8BaVwKOsG@mail.gmail.com>
Subject: Re: [PATCH] Adding four read-only files to /proc/sys/vm
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, jack@suse.cz, david@fromorbit.com, hch@lst.de, axboe@kernel.dk
List-ID: <linux-mm.kvack.org>

On Wed, Jun 30, 2010 at 2:24 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> Well... =A0why are these useful? =A0In what operational scenario would
> someone use these and get goodness from the experience? =A0Where is the
> value? =A0Sell it to us!

OK here it is in email before I add it to the commit description.

Before when users are trying to track their IO activity there has always
been a gap in the flow from user app to disk for buffered IO. With
page_dirtied and
page_entered_writeback the user can now track IO from buffered writes
as they are indicated to the block layer.

pages_dirtied helps storage workloads generating buffered writes
that need to see over time how much memory the app is able to dirty.
It can help trace app issues where iostat won't. In mixed workloads
where an appserver is writing via DIRECT_IO it can help root cause
issues where other apps are giving bursts of io behavior.

pages_entered_writeback is useful to help grant visibility into the
writeback subsystem. By tracking pages_entered_writeback with
pages_dirtied app developers can learn about the performance and/or
stability of the writeback subsystem. Comparing the rates of change
between the two allow developers to see when writeback is not able to
keep up with incoming traffic and the rate of dirty memory being sent
to the IO back end.

> It's hard to see how any future implementation could have a problem
> implementing pages_dirtied and pages_entered_writeback, however
> dirty_threshold and dirty_background_threshold are, I think, somewhat
> specific to the current implementation and may be hard to maintain next
> time we rip up and rewrite everything.

We already expose these thresholds in /proc/sys/vm with
dirty_background_ratio and background_ratio. What's frustrating about
the ratio variables and the need for these are that they are not honored
by the kernel. Instead the kernel may alter the number requested without
giving the user any indication that is the case.  An app developer can
set the ratio to 2% but end up with 5% as get_dirty_limits makes sure
it is never lower than 5% when set from the ratio. Arguably that can
be fixed too but the limits which decide whether writeback is invoked
to aggressively clean dirty pages is dependent on changing page state
retrieved in determine_dirtyable_memory. It makes understanding when
the kernel decides to writeback data a moving target that no app can
ever determine. With these thresholds visible and collected over time it
gives apps a chance to know why writeback happened, or why it did not.
As systems get larger and larger RAM developers use the ratios to predict
when their workloads will see writeback invoked. Today there is no way
to accurately predict this.

> Documentation doesn't describe the units. =A0Pages? =A0kbytes? =A0bytes?

Ouch. Thanks. That will be fixed.

> I think it's best to encode the units in the procfs filename
> (eg: dirty_expire_centisecs, min_free_kbytes).

I agree that will be fixed.

> units?
They will all get units

> We're very very interested in knowing how many pages entered writeback
> via mm/vmscan.c however this procfs file lumps those together with the
> pages which entered writeback via the regular writeback paths, I assume.

Yes and I think that's ok. It describes how the whole system is moving
dirty memory to writeback state and sending it to the I/O path.
TO me trying to distinguish between fs/fs-writeback.c code doing this
or vmscan.c code doing this is exposing implementation that we may
change in the future.


> But we need EXPORT_SYMBOL(account_page_dirtied), methinks.

Ouch thanks. Will be fixed.

> This should be a separate patch IMO.

I will split these into two patches. One with the fix and then the
other with the counters.

mrubin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
