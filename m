Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id C5D696B0033
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 06:40:27 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id d201so140107492qkg.2
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 03:40:27 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p35si3595801qtd.35.2017.01.11.03.40.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jan 2017 03:40:27 -0800 (PST)
Date: Wed, 11 Jan 2017 12:40:23 +0100
From: Kevin Wolf <kwolf@redhat.com>
Subject: Re: [LSF/MM TOPIC] I/O error handling and fsync()
Message-ID: <20170111114023.GA4813@noname.redhat.com>
References: <20170110160224.GC6179@noname.redhat.com>
 <20170111050356.ldlx73n66zjdkh6i@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170111050356.ldlx73n66zjdkh6i@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@infradead.org>, Ric Wheeler <rwheeler@redhat.com>, Rik van Riel <riel@redhat.com>

Am 11.01.2017 um 06:03 hat Theodore Ts'o geschrieben:
> A couple of thoughts.
> 
> First of all, one of the reasons why this probably hasn't been
> addressed for so long is because programs who really care about issues
> like this tend to use Direct I/O, and don't use the page cache at all.
> And perhaps this is an option open to qemu as well?

For our immediate case, yes, O_DIRECT can be enabled as an option in
qemu, and it is generally recommended to do that at least for long-lived
VMs. For other cases it might be nice to use the cache e.g. for quicker
startup, but those might be cases where error recovery isn't as
important.

I just see a much broader problem here than just for qemu. Essentially
this approach would mean that every program that cares about the state
it sees being safe on disk after a successful fsync() would have to use
O_DIRECT. I'm not sure if that's what we want.

> Secondly, one of the reasons why we mark the page clean is because we
> didn't want a failing disk to memory to be trapped with no way of
> releasing the pages.  For example, if a user plugs in a USB
> thumbstick, writes to it, and then rudely yanks it out before all of
> the pages have been writeback, it would be unfortunate if the dirty
> pages can only be released by rebooting the system.

Yes, I understand that and permanent failure is definitely a case to
consider while making any changes. That's why I suggested to still allow
releasing such pages, but at a lower priority than actually clean pages.
And of course, after losing data, an fsync() may never succeed again on
a file descriptor that was open when the data was thrown away.

> So an approach that might work is fsync() will keep the pages dirty
> --- but only while the file descriptor is open.  This could either be
> the default behavior, or something that has to be specifically
> requested via fcntl(2).  That way, as soon as the process exits (at
> which point it will be too late for it do anything to save the
> contents of the file) we also release the memory.  And if the process
> gets OOM killed, again, the right thing happens.  But if the process
> wants to take emergency measures to write the file somewhere else, it
> knows that the pages won't get lost until the file gets closed.

This sounds more or less like what I had in mind, so I agree.

The fcntl() flag is an interesting thought, too, but would there be
any situation where the userspace would have an advantage from not
requesting the flag?

> (BTW, a process could guarantee this today without any kernel changes
> by mmap'ing the whole file and mlock'ing the pages that it had
> modified.  That way, even if there is an I/O error and the fsync
> causes the pages to be marked clean, the pages wouldn't go away.
> However, this is really a hack, and it would probably be easier for
> the process to use Direct I/O instead.  :-)

That, and even if the pages would still in memory, as I understand it,
the writeout would never be retried because they are still marked clean.
So it wouldn't be usable for a temporary failure, but only for reading
the data back from the cache into a different file.

> Finally, if the kernel knows that an error might be one that could be
> resolved by the simple expedient of waiting (for example, if a fibre
> channel cable is temporarily unplugged so it can be rerouted, but the
> user might plug it back in a minute or two later, or a dm-thin device
> is full, but the system administrator might do something to fix it),
> in the ideal world, the kernel should deal with it without requiring
> any magic from userspace applications.  There might be a helper system
> daemon that enacts policy (we've paged the sysadmin, so it's OK to
> keep the page dirty and retry the writebacks to the dm-thin volume
> after the helper daemon gives the all-clear), but we shouldn't require
> all user space applications to have magic, Linux-specific retry code.

Yes and no. I agree that the kernel should mostly make things just work.
We're talking about a relatively obscure error case here, so if
userspace applications have to do something extraordinary, chances are
they won't be doing it.

On the other hand, indefinitely blocking on fsync() isn't really what we
want either, so while the kernel should keep trying to get the data
written in the background, a failing fsync() would be okay, as long as a
succeeding fsync() afterwards means that we're fully consistent again.

In qemu, indefinitely blocking read/write syscalls are already a problem
(on NFS), because instead of getting an error and then stopping the VM,
the request hangs so long that the guest kernel sees a timeout and
offlines the disk anyway. But that's a separate problem...

Kevin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
