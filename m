Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 3B31E5F0001
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 15:09:43 -0400 (EDT)
Subject: Re: [RFC][PATCH 0/9] File descriptor hot-unplug support
References: <m1skkf761y.fsf@fess.ebiederm.org> <49E4000E.10308@kernel.org>
	<m13acbbs5u.fsf@fess.ebiederm.org> <49E43F1D.3070400@kernel.org>
	<m18wm38ws1.fsf@fess.ebiederm.org>
	<20090414150745.GC26621@shareable.org>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: Tue, 14 Apr 2009 12:09:41 -0700
In-Reply-To: <20090414150745.GC26621@shareable.org> (Jamie Lokier's message of "Tue\, 14 Apr 2009 16\:07\:45 +0100")
Message-ID: <m163h72gsq.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Jamie Lokier <jamie@shareable.org>
Cc: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Al Viro <viro@ZenIV.linux.org.uk>, Hugh Dickins <hugh@veritas.com>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>

Jamie Lokier <jamie@shareable.org> writes:

> Eric W. Biederman wrote:
>> > I don't have anything at hand but multithread/process server accepting
>> > on the same socket comes to mind.  I don't think it would be a very
>> > rare thing.  If you confine the scope to character devices or sysfs,
>> > it could be quite rare tho.
>> 
>> Yes.  I think I can safely exclude sockets, and not bother with
>> reference counting them.
>
> Good idea.  As well as many processes calling accept(), it's not
> unusual to have two threads or processes for reading and writing
> concurrently to TCP sockets, and to have a single UDP socket shared
> among threads/processes for sendto.

I have been playing with what I can see when I instrument up my code.

The first thing that popped up was that we have a lots of reads/writes
to files with f_count > 1.  Which defeats my micro optimization in
fops_read_lock.  So in those cases I still have to pay the full cost
of an atomic even if I have an exclusive cache line.

I have found that for make -j N I tend to get N processes all
reading from the same pipe at the same time.  Not a smoking
gun that my assumption that only one process will be using
a file descriptor at a time in performance paths but it certainly
shows that things are nowhere near as rare as I thought.

The good news is that I have found a much better/cheaper optimization.
Instead of per cpu or per file memory, use per task memory.  It is
always uncontended, and a task appears to never use more than two files
simultaneously (stacking?).

I have just prototyped that and things are looking very promising.
Now I just need to clean everything up and resend my patches.

>> The only strong evidence I have that multi-threading on a single file
>> descriptor is likely to be common is that we have pread and pwrite
>> syscalls.  At the same time the number of races we have in struct file
>> if it is accessed by multiple threads at the same time, suggests
>> that at least for cases where you have an offset it doesn't happen often.
>
> Notice the preadv and pwritev syscalls added recently?  They were
> added because QEMU and KVM need them for performance.  Those programs
> have multiple threads doing I/O to the same file concurrently.  It's
> like a poor man's AIO, except it's more reliable than real Linux AIO :-)
>
> Databases probably should use concurrent p{read,write}{,v} if they're
> not using direct I/O and AIO.  I'm not sure if the well-known
> databases do.  In the past there have been some poor quality
> "emulations" of those syscalls prone to races, on Linux and BSD I believe.
>
> What are the races you've noticed?

Besides the f_pos (which pread variants handle) there is no locking on
the file read ahead state, and f_flags only got locking a month or two
ago.


Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
