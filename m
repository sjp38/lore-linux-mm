Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 243D36B0069
	for <linux-mm@kvack.org>; Thu, 28 Dec 2017 22:51:55 -0500 (EST)
Received: by mail-yb0-f199.google.com with SMTP id r15so8252702ybm.10
        for <linux-mm@kvack.org>; Thu, 28 Dec 2017 19:51:55 -0800 (PST)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id m4si5598353ybm.773.2017.12.28.19.51.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Dec 2017 19:51:54 -0800 (PST)
Date: Thu, 28 Dec 2017 22:51:46 -0500
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: About the try to remove cross-release feature entirely by Ingo
Message-ID: <20171229035146.GA11757@thunk.org>
References: <CANrsvRPQcWz-p_3TYfNf+Waek3bcNNPniXhFzyyS=7qbCqzGyg@mail.gmail.com>
 <20171229014736.GA10341@X58A-UD3R>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171229014736.GA10341@X58A-UD3R>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: Byungchul Park <max.byungchul.park@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, david@fromorbit.com, willy@infradead.org, Linus Torvalds <torvalds@linux-foundation.org>, Amir Goldstein <amir73il@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, oleg@redhat.com, kernel-team@lge.com

On Fri, Dec 29, 2017 at 10:47:36AM +0900, Byungchul Park wrote:
> 
>    (1) The best way: To classify all waiters correctly.

It's really not all waiters, but all *locks*, no?

>       Ultimately the problems should be solved in this way. But it
>       takes a lot of time so it's not easy to use the way right away.
>       And I need helps from experts of other sub-systems.
> 
>       While talking about this way, I made a trouble.. I still believe
>       that each sub-system expert knows how to solve dependency problems
>       most, since each has own dependency rule, but it was not about
>       responsibility. I've never wanted to charge someone else it but me.

The problem is that it's not one subsystem, but *many*.  And it's the
interactions between the subsystems.

Consider the example I gave of a network block device, on which a
local disk file system is mounted, which is then exported over NFS.
So we have the Networking (TCP) stack involved, the NBD device driver,
the local disk file system, the NFS file system, and the networking
stack a second time.  That is *many* subsystem maintainers who have to
get involved.

In addition, the lock classification system is not documented at all,
so now you also need someone who understands the lockdep code.  And
since some of these classifications involve transient objects, and
lockdep doesn't have a way of dealing with transient locks, and has a
hard compile time limit of the number of locks that it supports, to
expect a subsystem maintainer to figure out all of the interactions,
plus figure out lockdep, and work around lockdep's limitations
seems.... not realistic.

(By the way, I've tried reading the crosslock and crossrelease
documentation --- and I'm lost.  Sorry, I'm just not smart enough to
understand how it works, at least not from reading the documentation
that was in the patch series.  And honestly, I don't care.  All I do
need is some practical instructions for how to "classify locks
properly", and how this interacts with lockdep's limitations.)

>    (2) The 2nd way: To make cross-release off by default.
> 
>       At the beginning, I proposed cross-release being off by default.
>       Honestly, I was happy and did it when Ingo suggested it on by
>       default once lockdep on. But I shouldn't have done that but kept
>       it off by default. Cross-release can make some happy but some
>       unhappy until problems go away through (1) or (2).

Ingo's argument is that (1) is not going to be happening any time
soon, and in the meantime, code which is turned off will bitrot.

Given that once Lockdep reports a locking violation, it doesn't report
any more lockdep violations, if there are a large number of false
positives, people will not want to turn on cross-release, since it
will report the false positive and then turn itself off, so it won't
report anything useful.  So if no one turns it on because of the false
positives, how does the bitrot problem get resolved?

And if the answer is that some small number of lockdep experts will be
trying to figure out how to do (1) in a tractable way, then Ingo has
argued it can be handled via an out-of-tree patch.

>    (3) The 3rd way: To invalidate waiters making trouble.

Hmm, can we make cross-release and cross-lock off by default on a per
lock basis?  With a well documented to enable it?  I'm still not sure
how this works given the cross-subsystem problem, though.

So if networking enables it because there are no problems with their
TCP-only test, and then it blows up when someone is doing NBD or NFS
testing, what's the recourse?  The file system developer submitting a
patch against the networking subsystem to turn off the lockdep
tracking on that particular lock because it's causing pain for the
file system developer?  I can see that potentially causing all sorts
of inter-subsystem conflicts.

> Talking about what Ingo said in the commit msg.. I want to ask him back,
> if he did it with no false positives at the moment merging it in 2006,
> without using (2) or (3) method. I bet he know what it means.. And
> classifying locks/waiters correctly is not something uglifying code but
> a way to document code better. I've felt ill at ease because of the
> unnatural and forced explanation.

So I think this is the big difference is that potential for
cross-subsystem false positives is dramatically higher than with
cross-release compared with the traditional lockdep.  And I'm not sure
there is a clean solution --- how do you "cleanly classify" locks when
in some cases each object's locks needs to be considered individual
locks, and when that must not be done lest there is an explosion of
the number of locks which lockdep needs to track (which is strictly
limited due to memory and CPU overhead, as I understand things)?  I
haven't seen an explanation for how to solve this in a clean, general
way --- and I strongly suspect it doesn't exist.

Regards,

						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
