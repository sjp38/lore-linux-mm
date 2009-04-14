Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 19F0D5F0001
	for <linux-mm@kvack.org>; Mon, 13 Apr 2009 23:15:34 -0400 (EDT)
Message-ID: <49E4000E.10308@kernel.org>
Date: Tue, 14 Apr 2009 12:16:30 +0900
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/9] File descriptor hot-unplug support
References: <m1skkf761y.fsf@fess.ebiederm.org>
In-Reply-To: <m1skkf761y.fsf@fess.ebiederm.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Al Viro <viro@ZenIV.linux.org.uk>, Hugh Dickins <hugh@veritas.com>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>

Hello, Eric.

Eric W. Biederman wrote:
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

I like the way it's headed.  I'm trying to add similar 'revoke' or
'sever' mechanism at block and char device layers so that low level
drivers don't have to worry about object lifetimes and so on.  Doing
it at the file layer makes sense and can probably replace whatever
mechanism at the chardev.

The biggest obstacle was the extra in-use reference count overhead.  I
thought it could be solved by implementing generic percpu reference
count similar to the one used for module reference counting.  Hot path
overhead could be reduced to local_t cmpxchg (w/o LOCK prefix) on
per-cpu variable + one branch, which was pretty good.  The problem was
that space and access overhead for dynamic per-cpu variables wasn't
too good, so I started working on dynamic percpu allocator.

The dynamic per-cpu allocator is pretty close to completion.  Only
several archs need to be converted and it's likely to happen during
next few months.  The plan after that was 1. add per-cpu local_t
accessors (might replace local_t completely) 2. add generic per-cpu
reference counter and move module reference counting to it
3. implement block/chardev sever (or revoke) support.

I think #3 can be merged with what you're working on.  What do you
think?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
