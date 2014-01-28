Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 797BF6B0031
	for <linux-mm@kvack.org>; Mon, 27 Jan 2014 20:37:10 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa1so6691379pad.14
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 17:37:10 -0800 (PST)
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
        by mx.google.com with ESMTPS id nf8si13341666pbc.330.2014.01.27.17.37.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 27 Jan 2014 17:37:08 -0800 (PST)
Received: by mail-pd0-f173.google.com with SMTP id y10so6442108pdj.32
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 17:37:08 -0800 (PST)
Message-ID: <52E709C0.1050006@linaro.org>
Date: Mon, 27 Jan 2014 17:37:04 -0800
From: John Stultz <john.stultz@linaro.org>
MIME-Version: 1.0
Subject: [RFC] shmgetfd idea
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Greg KH <gregkh@linuxfoundation.org>, Kay Sievers <kay@vrfy.org>, Android Kernel Team <kernel-team@android.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Johannes Weiner <hannes@cmpxchg.org>, "H. Peter Anvin" <hpa@linux.intel.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Takahiro Akashi <takahiro.akashi@linaro.org>, Minchan Kim <minchan@kernel.org>, Lennart Poettering <mzxreary@0pointer.de>

In working with ashmem and looking briefly at kdbus' memfd ideas,
there's a commonality that both basically act as a method to provide
applications with unlinked tmpfs/shmem fds.

In the Android case, its important to have this interface to atomically
provide these unlinked tmpfs fds, because they'd like to avoid having
tmpfs mounts that are writable by applications (since that creates a
potential DOS on the system by applications writing random files that
persist after the process has been killed). It also provides better
life-cycle management for resources, since as the fds never have named
links in the filesystem, their resources are automatically cleaned up
when the last process with the fd dies, and there's no potential races
between create and unlink with processes being terminated, which avoids
the need for cleanup management.

I won't speak for the kdbus use, but my understanding is memfds address
similar needs along with being something to connect with other features.


So one idea was maybe we need a new interface. Something like:

int shmgetfd(char* name, size_t size, int shmflg);


Basically this would be very similar to shmget, but would return a file
descriptor which could be mapped and passed to other processes to map.
Basically very similar to the in-kernel shmem_file_setup() interface.

(Thanks to Akashi-san for initially pointing out the similarity to shmget.)

Of course, shmgetfd on its own wouldn't address the quota issue right
away, but it would be fairly easy have a limit for the total number of
bytes a process could generate, or some other limiting mechanism.


The probably more major drawback here is that both ashmem and memfd tack
on additional features that can be done to the fds.

In ashmems' case it allows for changing the segment's name, and
unpinning regions which can then be lazily discarded by the kernel.

For memfd, the extra feature is sealing, which prevents modification of
the file when its shared.

In ashmem's case, both vma-naming and volatile ranges are trying to
address how the needed features would be generically applied to tmpfs
fds (as well as potentially wider uses as well) - so with something like
shmgetfd it would provide all the functionality needed. I am not aware
of any current plans for memfd's sealing to be similarly worked into a
generic concept - the code hasn't even been submitted, so this is too
early - but in any case, its important to note none of these plans for
generic functionality have been merged or even received with much
interest, so I do understand how a proposal for a new interface that
only solves half of the needed infrastructure may not be particularly
welcome.

So while I do understand the difficulty of trying to create more generic
interfaces rather then just creating a new chardev/ioctl interface to a
more limited subset of functionality, I do think its worth exploring if
we can find a way to share infrastructure at some level (even if its
just due-diligence to prove if the more limited scope chardev/ioctl
interfaces are widely agreed to be better).

Anyway, I just wanted to submit this sketched out idea as food for
thought to see if there was any objection or interest (I've got a draft
patch I'll send out once I get a chance to test it). So let me know if
you have any feedback or comments.

thanks
-john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
