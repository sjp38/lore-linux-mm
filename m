Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id F3B176B0033
	for <linux-mm@kvack.org>; Sat, 30 Dec 2017 10:45:05 -0500 (EST)
Received: by mail-yb0-f198.google.com with SMTP id u30so8798718ybi.2
        for <linux-mm@kvack.org>; Sat, 30 Dec 2017 07:45:05 -0800 (PST)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id f14si875958ybk.213.2017.12.30.07.45.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 30 Dec 2017 07:45:04 -0800 (PST)
Date: Sat, 30 Dec 2017 10:40:41 -0500
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: About the try to remove cross-release feature entirely by Ingo
Message-ID: <20171230154041.GB3366@thunk.org>
References: <CANrsvRPQcWz-p_3TYfNf+Waek3bcNNPniXhFzyyS=7qbCqzGyg@mail.gmail.com>
 <20171229014736.GA10341@X58A-UD3R>
 <20171229035146.GA11757@thunk.org>
 <20171229072851.GA12235@X58A-UD3R>
 <20171230061624.GA27959@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171230061624.GA27959@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Byungchul Park <byungchul.park@lge.com>, Byungchul Park <max.byungchul.park@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, david@fromorbit.com, Linus Torvalds <torvalds@linux-foundation.org>, Amir Goldstein <amir73il@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, oleg@redhat.com, kernel-team@lge.com, daniel@ffwll.ch

On Fri, Dec 29, 2017 at 10:16:24PM -0800, Matthew Wilcox wrote:
> 
> I think this is a terminology problem.  To me (and, I suspect Ted), a
> waiter is a subject of a verb while a lock is an object.  So Ted is asking
> whether we have to classify the users, while I think you're saying we
> have extra objects to classify.

Exactly, the classification is applied when the {lock, mutex,
completion} object is initialized.  Not currently at the individual
call points to mutex_lock(), wait_for_completion(), down_write(), etc.


> > The problems come from wrong classification. Waiters either classfied
> > well or invalidated properly won't bitrot.
> 
> I disagree here.  As Ted says, it's the interactions between the
> subsystems that leads to problems.  Everything's goig to work great
> until somebody does something in a way that's never been tried before.

The question what is classified *well* mean?  At the extreme, we could
put the locks for every single TCP connection into their own lockdep
class.  But that would blow the limits in terms of the number of locks
out of the water super-quickly --- and it would destroy the ability
for lockdep to learn what the proper locking order should be.  Yet
given Lockdep's current implementation, the only way to guarantee that
there won't be any interactions between subsystems that cause false
positives would be to categorizes locks for each TCP connection into
their own class.

So this is why I get a little annoyed when you say, "it's just a
matter of classification".  NO IT IS NOT.  We can not possibly
classify things "correctly" to completely limit false positives
without completely destroying lockdep's scalability as it is currently
designed.  Byungchul, you don't acknowledge this, and it makes the
"just classify everything" argument completely suspect as a result.

As far as the "just invalidate the waiter", the problem is that it
requires source level changes to invalidate the waiter, and for
different use cases, we will need to validate different waiters.  For
example, in the example I gave, we would have to invalidate *all* TCP
waiters/locks in order to prevent false positives.  But that makes the
lockdep useless for all TCP locks.  What's the solution?  I claim that
until lockdep is fundamentally fixed, there is no way to eliminate
*all* false positives without invalidating *all*
cross-release/cross-locks --- in which case you might as well leave
the cross-release patches as an out of tree patch.

So to claim that we can somehow fix the problem by making source-level
changes outside of lockdep, by "properly classifying" or "properly
invalidating" all locks, just doesn't make sense. 

The only way it can work is to either dump it on the reposibility of
the people debugging lockdep reports to make source level changes to
other subsystems which they aren't the maintainers of to suppress
false positives that arise due to how the subsystems are being used
together in their particular configuration ---- or you can try to
claim that there is an "acceptable level" of false positives with
which we can live with forever, and which can not be fixed by "proper
classifying" the locks.

Or you can try to make lockdep scalable enough that if we could put
every single lock for every single object into its own lock class
(e.g., each lock for every single TCP connection gets its own lock
class) which is after all the only way we can "properly classify
everything") and still let lockdep be useful.

If you think that is doable, why don't you work on that, and once that
is done, maybe cross-locks lockdep will be considered more acceptable
for mainstream?

					- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
