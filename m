Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 781DA5F0001
	for <linux-mm@kvack.org>; Sat, 11 Apr 2009 11:58:08 -0400 (EDT)
Date: Sat, 11 Apr 2009 16:58:52 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [RFC][PATCH 0/9] File descriptor hot-unplug support
Message-ID: <20090411155852.GV26366@ZenIV.linux.org.uk>
References: <m1skkf761y.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <m1skkf761y.fsf@fess.ebiederm.org>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>

On Sat, Apr 11, 2009 at 05:01:29AM -0700, Eric W. Biederman wrote:

> A couple of weeks ago I found myself looking at the uio, seeing that
> it does not support pci hot-unplug, and thinking "Great yet another
> implementation of hotunplug logic that needs to be added".
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

Ehh...  The real mess is in things like "TTY in the middle of random
ioctl" and there's another pile that won't be solved on struct file
level - individual fs internals ;-/

> This infrastructure could also be used to implement sys_revoke and
> when I could not think of a better name I have drawn on that.

Yes, that's more or less obvious direction for revoke(), but there's a
problem with locking overhead that always scared me away from that.
Maybe I'm wrong, though...  In any case, you want to carefully check
the overhead and cacheline bouncing implications for things like pipes
and sockets.  Hell knows, maybe it'll work out, but...

Anyway, the really nasty part of revoke() (and true SAK, which is obviously
related) is handling of deep-inside-the-driver ioctls.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
