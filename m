Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 5F7946B0069
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 14:25:09 -0400 (EDT)
Date: Mon, 29 Oct 2012 14:24:56 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH 2/3] ext4: introduce ext4_error_remove_page
Message-ID: <20121029182455.GA7098@thunk.org>
References: <1351177969-893-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1351177969-893-3-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20121026061206.GA31139@thunk.org>
 <3908561D78D1C84285E8C5FCA982C28F19D5A13B@ORSMSX108.amr.corp.intel.com>
 <20121026184649.GA8614@thunk.org>
 <3908561D78D1C84285E8C5FCA982C28F19D5A388@ORSMSX108.amr.corp.intel.com>
 <20121027221626.GA9161@thunk.org>
 <20121029011632.GN29378@dastard>
 <20121029024024.GC9365@thunk.org>
 <m27gq9r2cu.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <m27gq9r2cu.fsf@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Dave Chinner <david@fromorbit.com>, "Luck, Tony" <tony.luck@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kleen, Andi" <andi.kleen@intel.com>, "Wu, Fengguang" <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, Akira Fujita <a-fujita@rs.jp.nec.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>

On Mon, Oct 29, 2012 at 03:37:05AM -0700, Andi Kleen wrote:
> > Agreed, if we're going to add an xattr, then we might as well store
> 
> I don't think an xattr makes sense for this. It's sufficient to keep
> this state in memory.
> 
> In general these error paths are hard to test and it's important
> to keep them as simple as possible. Doing IO and other complexities
> just doesn't make sense. Just have the simplest possible path
> that can do the job.

It's actually pretty easy to test this particular one, and certainly
one of the things I'd strongly encourage in this patch series is the
introduction of an interface via madvise and fadvise that allows us to
simulate an ECC hard error event.  So I don't think "it's hard to
test" is a reason not to do the right thing.  Let's make it easy to
test, and the include it in xfstests.  All of the core file systems
are regularly running regression tests via xfstests, so if we define a
standard way of testing this function (this is why I suggested
fadvise/madvise instead of an ioctl, but in a pinch we could do this
via an ioctl instead).

Note that the problem that we're dealing with is buffered writes; so
it's quite possible that the process which wrote the file, thus
dirtying the page cache, has already exited; so there's no way we can
guarantee we can inform the process which wrote the file via a signal
or a error code return.  It's also possible that part of the file has
been written out to the disk, so forcibly crashing the system and
rebooting isn't necessarily going to save the file from being
corrupted.

Also, if you're going to keep this state in memory, what happens if
the inode gets pushed out of memory?  Do we pin the inode?  Or do we
just say that it's stored into memory until some non-deterministic
time (as far as userspace programs are concerned, but if they are
running in a tight memory cgroup, it might be very short time later)
suddenly the state gets lost?

I think it's fair that if there are file systems that don't have a
single bit they can allocate in the inode, we can either accept
Jun'ichi's suggest to just forcibly crash the system, or we can allow
the state to be stored in memory.  But I suspect the core file systems
that might be used by enterprise-class workloads will want to provide
something better.

I'm not that convinced that we need to insert an xattr; after all, not
all file systems support xattrs at all, and I think a single bit
indicating that the file has corrupted data is sufficient.  But I
think it would be useful to at least optionally support a persistent
storage of this bit.

					- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
