Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 08C415F0001
	for <linux-mm@kvack.org>; Sun, 12 Apr 2009 17:03:00 -0400 (EDT)
Date: Sun, 12 Apr 2009 22:02:56 +0100
From: Jamie Lokier <jamie@shareable.org>
Subject: Re: [RFC][PATCH 8/9] vfs: Implement generic revoked file operations
Message-ID: <20090412210256.GK4394@shareable.org>
References: <m1skkf761y.fsf@fess.ebiederm.org> <m1prfj5qxp.fsf@fess.ebiederm.org> <20090412185659.GE4394@shareable.org> <m11vrxprk6.fsf@fess.ebiederm.org> <m1r5zxk2y2.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <m1r5zxk2y2.fsf@fess.ebiederm.org>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Al Viro <viro@ZenIV.linux.org.uk>, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>

Eric W. Biederman wrote:
> I just thought about that some more and I am not convinced.
> 
> In general the current return values from proc after an I/O operation
> are suspect.  seek returns -EINVAL instead of -EIO. poll returns
> DEFAULT_POLLMASK (which doesn't set POLLERR).  So I am not convinced
> that the existing proc return values on error are correct, and they
> are recent additions so the historical precedent is not especially
> large.
> 
> EOF does give the impression that you have read all of the data from
> the /proc file, and that is in fact the case.  There is no more
> data coming from that proc file.
> 
> That the data is stale is well know.
> 
> That the data is not atomic, anything that spans more than a single
> read is not atomic.
> 
> So I don't see what returning EIO adds to the equation.  Perhaps
> that your fragile user space string parser may break?
> 
> EOF gives a clear indication the application should stop reading
> the data, because there is no more.
> 
> EIO only says that the was a problem.
> 
> I don't know of anything that depends on the rmmod behavior either
> way.  But if we can get away with it I would like to use something
> that is generally useful instead of something that only makes
> sense in the context of proc.

I'm not thinking of proc, really.  More thinking of applications: EOF
effectively means "whole file read without error - now do the next thing".

If a filesystem file is revoked (umount -f), you definitely want to
stop that Makefile which is copying a file from the unmounted
filesystem to a target file.  Otherwise you get inconsistent states
which can only occur as a result of this umount -f, something
Makefiles should never have to care about.

rmmod behaviour is not something any app should see normally.
Unexpected behaviour when files are oddly truncated (despite never
being written that way) is not "fragile user space".  So whatever it
returns, it should be some error code, imho.

-- Jamie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
