Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 96F665F0001
	for <linux-mm@kvack.org>; Sat, 11 Apr 2009 19:56:40 -0400 (EDT)
References: <m1skkf761y.fsf@fess.ebiederm.org>
	<20090411155852.GV26366@ZenIV.linux.org.uk>
	<m1k55ryw2n.fsf@fess.ebiederm.org>
	<20090411165651.GW26366@ZenIV.linux.org.uk>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sat, 11 Apr 2009 16:57:25 -0700
In-Reply-To: <20090411165651.GW26366@ZenIV.linux.org.uk> (Al Viro's message of "Sat\, 11 Apr 2009 17\:56\:51 +0100")
Message-ID: <m1skkeu4ka.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Subject: Re: [RFC][PATCH 0/9] File descriptor hot-unplug support
Sender: owner-linux-mm@kvack.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>

Al Viro <viro@ZenIV.linux.org.uk> writes:

> On Sat, Apr 11, 2009 at 09:49:36AM -0700, Eric W. Biederman wrote:
>
>> The fact that in the common case only one task ever accesses a struct
>> file leaves a lot of room for optimization.
>
> I'm not at all sure that it's a good assumption; even leaving aside e.g.
> several tasks sharing stdout/stderr, a bunch of datagrams coming out of
> several threads over the same socket is quite possible.

Maybe not.  However those cases are already more expensive today.
Somewhere along the way we are already going to get cache line ping
pongs if there is real contention, and we are going to see the cost of
atomic operations.  In which case the extra ref counting I am doing is
a little more expensive.  And when I say a little more expensive I
mean 10-20ns per read/write more expensive.

At the same time if the common case really is applications not sharing
file descriptors (which seems sane) my current optimization easily
keeps the cost to practically nothing.

Using the srcu locking would also keep the cost down in the noise
because it guarantees non-shared cachelines and no expensive atomic
operations.  srcu has the downside of requiring per cpu memory which
seems wrong to me somehow.  However there are hybrid models like what
is used in mnt_want_write that are possible to limit the total amount
of per cpu memory while still getting the advantages.

Beyond that for correctness it looks like a pay me now or pay me later
situation.  Do we track when we are in the methods for an object
generically where we can do the work once, and then concentrate on
enhancements.  Or do we bog ourselves down using inferior
implementations that are replicated in varying ways from subsystem to
subsystem, and spend our time fighting the bugs in the subsystems?

I have the refcount/locking abstraction wrapped and have only to
perform the most basic of optimizations. So if we need to do something
more it should be easy.

Is performance your only concern with my patches?

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
