Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 709476B004D
	for <linux-mm@kvack.org>; Sat,  6 Jun 2009 04:03:42 -0400 (EDT)
Date: Sat, 6 Jun 2009 09:03:34 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 0/23] File descriptor hot-unplug support v2
Message-ID: <20090606080334.GA15204@ZenIV.linux.org.uk>
References: <m1skkf761y.fsf@fess.ebiederm.org> <m1oct739xu.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <m1oct739xu.fsf@fess.ebiederm.org>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 01, 2009 at 02:45:17PM -0700, Eric W. Biederman wrote:
> 
> I found myself looking at the uio, seeing that it does not support pci
> hot-unplug, and thinking "Great yet another implementation of
> hotunplug logic that needs to be added".
> 
> I decided to see what it would take to add a generic implementation of
> the code we have for supporting hot unplugging devices in sysfs, proc,
> sysctl, tty_io, and now almost in the tun driver.
> 
> Not long after I touched the tun driver and made it safe to delete the
> network device while still holding it's file descriptor open I someone
> else touch the code adding a different feature and my careful work
> went up in flames.  Which brought home another point at the best of it
> this is ultimately complex tricky code that subsystems should not need
> to worry about.
> 
> What makes this even more interesting is that in the presence of pci
> hot-unplug it looks like most subsystems and most devices will have to
> deal with the issue one way or another.
> 
> This infrastructure could also be used to implement both force
> unmounts and sys_revoke.  When I could not think of a better name for
> I have drawn on that and used revoke.

To be honest, the longer I'm looking at it, the less I like the approach...
It really looks as if we'd be much better off with functionality sitting
in a set of library helpers to be used by instances that need this stuff.
Do we really want it for generic case?

Note that "we might someday implement real force-umount" doesn't count;
the same kind of arguments had been given nine years ago in case of AIO
("oh, sure, we'll eventually cover foo_get_block() too - it will all be
a state machine, fully asynchronous; whaddya mean 'it's not feasible'?").
Of course, it was _not_ feasible and had never been implemented.

Frankly, I very much suspect that force-umount is another case like that;
we'll need a *lot* of interesting cooperation from fs for that to work and
to be useful.  I'd be delighted to be proven incorrect on that one, so
if you have anything serious in that direction, please share the details.

As for the patchset in the current form...  Could you explain what's to prevent
POSIX locks and dnotify entries from outliving a struct file you'd revoked,
seeing that filp_close() will skip killing them in that case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
