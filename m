Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 04F8A6B0069
	for <linux-mm@kvack.org>; Tue, 13 Sep 2016 11:06:07 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id i129so49041891ywb.1
        for <linux-mm@kvack.org>; Tue, 13 Sep 2016 08:06:07 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id z197si8816525iod.240.2016.09.13.08.06.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Sep 2016 08:06:06 -0700 (PDT)
Date: Tue, 13 Sep 2016 17:05:54 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v3 07/15] lockdep: Implement crossrelease feature
Message-ID: <20160913150554.GI2794@worktop>
References: <1473759914-17003-1-git-send-email-byungchul.park@lge.com>
 <1473759914-17003-8-git-send-email-byungchul.park@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1473759914-17003-8-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com



So the idea is to add support for non-owner serialization primitives,
like completions/semaphores, and so far I've not looked at the code yet.
I did spend 2+ hours trying to decipher your documentation thing, but am
still confused, that thing is exceedingly hard to parse/read.

So the typical scenario would be something like:

L a	L a
	U a
W b	C b

where L := lock, U := unlock, W := wait_for_completion and C :=
complete.

On the left, the blocking thread we can easily observe the 'b depends on
a' relation, since we block while holding a.

On the right however that same relation is hard to see, since by the
time we would run complete, a has already been released.

I _think_ you propose to keep track of all prior held locks and then use
the union of the held list on the block-chain with the prior held list
from the complete context.

The document describes you have a prior held list, and that its a
circular thing, but it then completely fails to specify what gets added
and how its used.

Also, by it being a circular list (of indeterminate, but finite size),
there is the possibility of missing dependencies if they got spooled out
by recent activity.

The document has an example in the section 'How cross release works'
(the 3rd) that simply cannot be. It lists lock action _after_ acquire,
but you place the acquire in wait_for_completion. We _block_ there.

Is this the general idea?

If so, I cannot see how something like:

W a	W b
C b	C a

would work, somewhere in that document it states that this would be
handled by the existing dependencies, but I cannot see how. The blocking
thread (either one) has no held context, therefore the previously
mentioned union of held and prev-held is empty.

The alternative is not doing the union, but then you end up with endless
pointless dependencies afaict.


On the whole 'release context' thing you want to cast lockdep in, please
consider something like:

L a	L b
L b	L a
U a	U a
U b	U b

Note that the release order of locks is immaterial and can generate
'wrong' dependencies. Note how on both sides a is released under b,
failing to observe the stil obvious AB-BA deadlock.

Note that lockdep doesn't model release or anything, it models
blocked-on relations, like PI does.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
