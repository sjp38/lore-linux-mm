Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 43D0A6B004D
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 01:58:24 -0400 (EDT)
References: <m1skkf761y.fsf@fess.ebiederm.org>
	<m1oct739xu.fsf@fess.ebiederm.org>
	<20090606080334.GA15204@ZenIV.linux.org.uk>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: Mon, 08 Jun 2009 23:22:50 -0700
In-Reply-To: <20090606080334.GA15204@ZenIV.linux.org.uk> (Al Viro's message of "Sat\, 6 Jun 2009 09\:03\:34 +0100")
Message-ID: <m1k53mylhh.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Subject: Re: [PATCH 0/23] File descriptor hot-unplug support v2
Sender: owner-linux-mm@kvack.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>
List-ID: <linux-mm.kvack.org>

Al Viro <viro@ZenIV.linux.org.uk> writes:

> On Mon, Jun 01, 2009 at 02:45:17PM -0700, Eric W. Biederman wrote:
>> 
>> I found myself looking at the uio, seeing that it does not support pci
>> hot-unplug, and thinking "Great yet another implementation of
>> hotunplug logic that needs to be added".
>> 
>> I decided to see what it would take to add a generic implementation of
>> the code we have for supporting hot unplugging devices in sysfs, proc,
>> sysctl, tty_io, and now almost in the tun driver.
>> 
>> Not long after I touched the tun driver and made it safe to delete the
>> network device while still holding it's file descriptor open I someone
>> else touch the code adding a different feature and my careful work
>> went up in flames.  Which brought home another point at the best of it
>> this is ultimately complex tricky code that subsystems should not need
>> to worry about.
>> 
>> What makes this even more interesting is that in the presence of pci
>> hot-unplug it looks like most subsystems and most devices will have to
>> deal with the issue one way or another.
>> 
>> This infrastructure could also be used to implement both force
>> unmounts and sys_revoke.  When I could not think of a better name for
>> I have drawn on that and used revoke.
>
> To be honest, the longer I'm looking at it, the less I like the approach...
> It really looks as if we'd be much better off with functionality sitting
> in a set of library helpers to be used by instances that need this stuff.
> Do we really want it for generic case?

I think so.  I do know I have seen enough weird cases actually being
used and not being done correctly we want a clean pattern for handling
the general case that works and is complete.

The problem seems to break up into several pieces.
- unmap support.
- Getting a list of the files that are open for an inode.
- Waking up interruptible sleepers.
- A test to see if we are executing any of the functions in 
  the file_operations structure. (needed before we can free state)
- Calling frelease and generally releasing of the state held by the
  file.

It might be possible to solve the entire problem outside of the vfs

> Note that "we might someday implement real force-umount" doesn't count;
> the same kind of arguments had been given nine years ago in case of AIO
> ("oh, sure, we'll eventually cover foo_get_block() too - it will all be
> a state machine, fully asynchronous; whaddya mean 'it's not feasible'?").
> Of course, it was _not_ feasible and had never been implemented.

> Frankly, I very much suspect that force-umount is another case like that;
> we'll need a *lot* of interesting cooperation from fs for that to work and
> to be useful.  I'd be delighted to be proven incorrect on that one, so
> if you have anything serious in that direction, please share the details.

So far nothing but thought experiments, but you have a good point at
least a proof of concept should be done of the various pieces.  To flush
out some niggling little detail that messes up the design.

So I hereby sign up for writing a sys_revoke patch, a forced umount patch
and a writing a patch to ext2 to support it.  Supporting proc and
sysfs while easy is not really the common case of an nfs exportable block
filesystem so it is not complete.

> As for the patchset in the current form...  Could you explain what's to prevent
> POSIX locks and dnotify entries from outliving a struct file you'd revoked,
> seeing that filp_close() will skip killing them in that case.

Good catch that looks like a big fat bug to me.  It seems I overlooked
the fact that we actually free things in filp_close.

Given that posix_remove_file calls vfs_lock_file which calls
file->f_op->lock it looks like something really needs to be done here.

dnotify_flush doesn't look to hard to spin a special case for revoke.

I am going to have to spend I while longer studying the rest of the
code in filp_close.  I hope I don't need to figure out the various
fl_owner_t values to safely revoke a file, but it looks like I might.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
