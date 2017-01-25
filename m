Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7E0806B026A
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 13:35:52 -0500 (EST)
Received: by mail-yb0-f200.google.com with SMTP id o65so302424171yba.3
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 10:35:52 -0800 (PST)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id u74si6420073ybi.131.2017.01.25.10.35.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 10:35:51 -0800 (PST)
Date: Wed, 25 Jan 2017 13:35:42 -0500
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] I/O error handling and fsync()
Message-ID: <20170125183542.557drncuktc5wgzy@thunk.org>
References: <87mveufvbu.fsf@notabene.neil.brown.name>
 <1484568855.2719.3.camel@poochiereds.net>
 <87o9yyemud.fsf@notabene.neil.brown.name>
 <1485127917.5321.1.camel@poochiereds.net>
 <20170123002158.xe7r7us2buc37ybq@thunk.org>
 <20170123100941.GA5745@noname.redhat.com>
 <1485210957.2786.19.camel@poochiereds.net>
 <1485212994.3722.1.camel@primarydata.com>
 <878tq1ia6l.fsf@notabene.neil.brown.name>
 <1485228841.8987.1.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1485228841.8987.1.camel@primarydata.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "kwolf@redhat.com" <kwolf@redhat.com>, "jlayton@poochiereds.net" <jlayton@poochiereds.net>, "neilb@suse.com" <neilb@suse.com>, "hch@infradead.org" <hch@infradead.org>, "riel@redhat.com" <riel@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "rwheeler@redhat.com" <rwheeler@redhat.com>, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>

On Tue, Jan 24, 2017 at 03:34:04AM +0000, Trond Myklebust wrote:
> The reason why I'm thinking open() is because it has to be a contract
> between a specific application and the kernel. If the application
> doesn't open the file with the O_TIMEOUT flag, then it shouldn't see
> nasty non-POSIX timeout errors, even if there is another process that
> is using that flag on the same file.
> 
> The only place where that is difficult to manage is when the file is
> mmap()ed (no file descriptor), so you'd presumably have to disallow
> mixing mmap and O_TIMEOUT.

Well, technically there *is* a file descriptor when you do an mmap.
You can close the fd after you call mmap(), but the mmap bumps the
refcount on the struct file while the memory map is active.

I would argue though that at least for buffered writes, the timeout
has to be property of the underlying inode, and if there is an attempt
to set timeout on an inode that already has a timeout set to some
other non-zero value, the "set timeout" operation should fail with a
"timeout already set".  That's becuase we really don't want to have to
keep track, on a per-page basis, which struct file was responsible for
dirtying a page --- and what if it is dirtied by two different file
descriptors?

That being said, I suspect that for many applications, the timeout is
going to be *much* more interesting for O_DIRECT writes, and there we
can certainly have different timeouts on a per-fd basis.  This is
especially for cases where the timeout is implemented in storage
device, using multi-media extensions, and where the timout might be
measured in milliseconds (e.g., no point reading a video frame if its
been delayed too long).  That being said, it block layer would need to
know about this as well, since the timeout needs to be relative to
when the read(2) system call is issued, not to when it is finally
submitted to the storage device.

And if the process has suitable privileges, perhaps the I/O scheduler
should take the timeout into account, so that reads with a timeout
attached should be submitted, with the presumption that reads w/o a
timeout can afford to be queued.  If the process doesn't have suitable
privileges, or if cgroup has exceeded its I/O quota, perhaps the right
answer would be to fail the read right away.  In the case of a cluster
file system such, if a particular server knows its can't serve a
particular low latency read within the SLO, it might be worthwhile to
signal to the cluster file system client that it should start doing an
erasure code reconstruction right away (or read from one of the
mirrors if the file is stored with n=3 replication, etc.)

So depending on what the goals of userspace are, there are number of
different kernel policies that might be the best match for the
particular application in question.  In particular, if you are trying
to provide low latency reads to assure decent response time for web
applications, it may be *reads* that are much more interesting for
timeout purposes rather than *writes*.

(Especially in a distributed system, you're going to be using some
kind of encoding with redundancy, so as long as enough of the writes
have completed, it doesn't matter if the other writes take a long time
--- although if you eventually decide that the write's never going to
make it, it's ideal if you can reshard the chunk more aggressively,
instead of waiting for the scurbbing pass to notice that some of the
redundant copies of the chunk had gotten corrupted or were never
written out.)

Cheers,

					- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
