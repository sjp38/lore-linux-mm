Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B56DB6B0033
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 05:46:24 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id n126so1007771wma.7
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 02:46:24 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p80sor470893wmf.64.2017.12.13.02.46.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Dec 2017 02:46:21 -0800 (PST)
Date: Wed, 13 Dec 2017 11:46:17 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH] locking/lockdep: Remove the cross-release locking checks
Message-ID: <20171213104617.7lffucjhaa6xb7lp@gmail.com>
References: <CANrsvRPQcWz-p_3TYfNf+Waek3bcNNPniXhFzyyS=7qbCqzGyg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANrsvRPQcWz-p_3TYfNf+Waek3bcNNPniXhFzyyS=7qbCqzGyg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <max.byungchul.park@gmail.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, david@fromorbit.com, tytso@mit.edu, willy@infradead.org, Linus Torvalds <torvalds@linux-foundation.org>, Amir Goldstein <amir73il@gmail.com>, byungchul.park@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, oleg@redhat.com


* Byungchul Park <max.byungchul.park@gmail.com> wrote:

> Lockdep works, based on the following:
> 
>    (1) Classifying locks properly
>    (2) Checking relationship between the classes
> 
> If (1) is not good or (2) is not good, then we
> might get false positives.
> 
> For (1), we don't have to classify locks 100%
> properly but need as enough as lockdep works.
> 
> For (2), we should have a mechanism w/o
> logical defects.
> 
> Cross-release added an additional capacity to
> (2) and requires (1) to get more precisely classified.
> 
> Since the current classification level is too low for
> cross-release to work, false positives are being
> reported frequently with enabling cross-release.
> Yes. It's a obvious problem. It needs to be off by
> default until the classification is done by the level
> that cross-release requires.
> 
> But, the logic (2) is valid and logically true. Please
> keep the code, mechanism, and logic.

Just to give a full context to everyone: the patch that removes the cross-release 
locking checks was Cc:-ed to lkml, I've attached the patch below again.

In general, as described in the changelog, the cross-release checks were 
historically just too painful (first they were too slow, and they also had a lot 
of false positives), and today, 4 months after its introduction, the cross-release 
checks *still* produce numerous false positives, especially in the filesystem 
space, but the continuous-integration testing folks were still having trouble with 
kthread locking patterns causing false positives:

  https://bugs.freedesktop.org/show_bug.cgi?id=103950

which were resulting in two bad reactions:

 - turning off lockdep

 - writing patches that uglified unrelated subsystems

So while I appreciate the fixes that resulted from running cross-release, there's 
still numerous false positives, months after its interaction, which is 
unacceptable. For us to have this feature it has to have roughly similar qualities 
as compiler warnings:

 - there's a "zero false positive warnings" policy

 - plus any widespread changes to avoid warnings has to improve the code,
   not make it uglier.

Lockdep itself is a following that policy: the default state is that it produces 
no warnings upstream, and any annotations added to unrelated code documents the 
locking hierarchies.

While technically we could keep the cross-release checking code upstream and turn 
it off by default via the Kconfig switch, I'm not a big believer in such a policy 
for complex debugging code:

 - We already did that for v4.14, two months ago:

     b483cf3bc249: locking/lockdep: Disable cross-release features for now

   ... and re-enabled it for v4.15 - but the false positives are still not fixed.

 - either the cross-release checking code can be fixed and then having it off by
   default is just wrong, because we can apply the fixed code again once it's
   fixed.

 - or it cannot be fixed (or we don't have the manpower/interest to fix it),
   in which case having it off is only delaying the inevitable.

In any case, for v4.15 it's clear that the false positives are too numerous.

Thanks,

	Ingo


=============================>
