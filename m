Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2B92C6B0033
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 00:04:00 -0500 (EST)
Received: by mail-yb0-f198.google.com with SMTP id l23so426742759ybj.6
        for <linux-mm@kvack.org>; Tue, 10 Jan 2017 21:04:00 -0800 (PST)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id r36si1324140ybd.276.2017.01.10.21.03.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jan 2017 21:03:59 -0800 (PST)
Date: Wed, 11 Jan 2017 00:03:56 -0500
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [LSF/MM TOPIC] I/O error handling and fsync()
Message-ID: <20170111050356.ldlx73n66zjdkh6i@thunk.org>
References: <20170110160224.GC6179@noname.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170110160224.GC6179@noname.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kevin Wolf <kwolf@redhat.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@infradead.org>, Ric Wheeler <rwheeler@redhat.com>, Rik van Riel <riel@redhat.com>

A couple of thoughts.

First of all, one of the reasons why this probably hasn't been
addressed for so long is because programs who really care about issues
like this tend to use Direct I/O, and don't use the page cache at all.
And perhaps this is an option open to qemu as well?

Secondly, one of the reasons why we mark the page clean is because we
didn't want a failing disk to memory to be trapped with no way of
releasing the pages.  For example, if a user plugs in a USB
thumbstick, writes to it, and then rudely yanks it out before all of
the pages have been writeback, it would be unfortunate if the dirty
pages can only be released by rebooting the system.

So an approach that might work is fsync() will keep the pages dirty
--- but only while the file descriptor is open.  This could either be
the default behavior, or something that has to be specifically
requested via fcntl(2).  That way, as soon as the process exits (at
which point it will be too late for it do anything to save the
contents of the file) we also release the memory.  And if the process
gets OOM killed, again, the right thing happens.  But if the process
wants to take emergency measures to write the file somewhere else, it
knows that the pages won't get lost until the file gets closed.

(BTW, a process could guarantee this today without any kernel changes
by mmap'ing the whole file and mlock'ing the pages that it had
modified.  That way, even if there is an I/O error and the fsync
causes the pages to be marked clean, the pages wouldn't go away.
However, this is really a hack, and it would probably be easier for
the process to use Direct I/O instead.  :-)


Finally, if the kernel knows that an error might be one that could be
resolved by the simple expedient of waiting (for example, if a fibre
channel cable is temporarily unplugged so it can be rerouted, but the
user might plug it back in a minute or two later, or a dm-thin device
is full, but the system administrator might do something to fix it),
in the ideal world, the kernel should deal with it without requiring
any magic from userspace applications.  There might be a helper system
daemon that enacts policy (we've paged the sysadmin, so it's OK to
keep the page dirty and retry the writebacks to the dm-thin volume
after the helper daemon gives the all-clear), but we shouldn't require
all user space applications to have magic, Linux-specific retry code.

Cheers,

					- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
