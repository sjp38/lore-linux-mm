Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5C3756B0038
	for <linux-mm@kvack.org>; Sat, 30 Dec 2017 15:44:28 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id n187so31827918pfn.10
        for <linux-mm@kvack.org>; Sat, 30 Dec 2017 12:44:28 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id o23si12205567pgc.553.2017.12.30.12.44.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 30 Dec 2017 12:44:26 -0800 (PST)
Date: Sat, 30 Dec 2017 12:44:17 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: About the try to remove cross-release feature entirely by Ingo
Message-ID: <20171230204417.GF27959@bombadil.infradead.org>
References: <CANrsvRPQcWz-p_3TYfNf+Waek3bcNNPniXhFzyyS=7qbCqzGyg@mail.gmail.com>
 <20171229014736.GA10341@X58A-UD3R>
 <20171229035146.GA11757@thunk.org>
 <20171229072851.GA12235@X58A-UD3R>
 <20171230061624.GA27959@bombadil.infradead.org>
 <20171230154041.GB3366@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171230154041.GB3366@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Byungchul Park <byungchul.park@lge.com>, Byungchul Park <max.byungchul.park@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, david@fromorbit.com, Linus Torvalds <torvalds@linux-foundation.org>, Amir Goldstein <amir73il@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, oleg@redhat.com, kernel-team@lge.com, daniel@ffwll.ch

On Sat, Dec 30, 2017 at 10:40:41AM -0500, Theodore Ts'o wrote:
> On Fri, Dec 29, 2017 at 10:16:24PM -0800, Matthew Wilcox wrote:
> > > The problems come from wrong classification. Waiters either classfied
> > > well or invalidated properly won't bitrot.
> > 
> > I disagree here.  As Ted says, it's the interactions between the
> > subsystems that leads to problems.  Everything's goig to work great
> > until somebody does something in a way that's never been tried before.
> 
> The question what is classified *well* mean?  At the extreme, we could
> put the locks for every single TCP connection into their own lockdep
> class.  But that would blow the limits in terms of the number of locks
> out of the water super-quickly --- and it would destroy the ability
> for lockdep to learn what the proper locking order should be.  Yet
> given Lockdep's current implementation, the only way to guarantee that
> there won't be any interactions between subsystems that cause false
> positives would be to categorizes locks for each TCP connection into
> their own class.

I'm not sure I agree with this part.  What if we add a new TCP lock class
for connections which are used for filesystems/network block devices/...?
Yes, it'll be up to each user to set the lockdep classification correctly,
but that's a relatively small number of places to add annotations,
and I don't see why it wouldn't work.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
