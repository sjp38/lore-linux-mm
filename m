Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 131516B0279
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 21:00:13 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id u36so30277120pgn.5
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 18:00:13 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id 97si2463362plc.447.2017.06.22.18.00.10
        for <linux-mm@kvack.org>;
        Thu, 22 Jun 2017 18:00:11 -0700 (PDT)
Date: Fri, 23 Jun 2017 10:52:14 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC PATCH 2/2] mm, fs: daxfile, an interface for
 byte-addressable updates to pmem
Message-ID: <20170623005214.GO17542@dastard>
References: <20170619132107.GG11993@dastard>
 <CALCETrUe0igzK0RZTSSondkCY3ApYQti89tOh00f0j_APrf_dQ@mail.gmail.com>
 <20170620004653.GI17542@dastard>
 <CALCETrVuoPDRuuhc9X8eVCYiFUzWLSTRkcjbD6jas_2J2GixNQ@mail.gmail.com>
 <20170620101145.GJ17542@dastard>
 <CALCETrVCJkm5SCxAtNMW36eONHsFw1s0dkVnDAs4vAXvEKMsPw@mail.gmail.com>
 <20170621014032.GL17542@dastard>
 <CALCETrVYmbyNS-btvsN_M-QyWPZA_Y_4JXOM893g7nhZA+WviQ@mail.gmail.com>
 <20170622000235.GN17542@dastard>
 <CALCETrX0n0-JxJbisrVnM6QME3uToW_x26xN3Z-t0-1yDvWn4Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrX0n0-JxJbisrVnM6QME3uToW_x26xN3Z-t0-1yDvWn4Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Rudoff, Andy" <andy.rudoff@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux API <linux-api@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Christoph Hellwig <hch@lst.de>

On Wed, Jun 21, 2017 at 09:07:57PM -0700, Andy Lutomirski wrote:
> On Wed, Jun 21, 2017 at 5:02 PM, Dave Chinner <david@fromorbit.com> wrote:
> >
> > You seem to be calling the "fdatasync on every page fault" the
> 
> It's the opposite of fdatasync().  It needs to sync whatever metadata
> is needed to find the data.  The data doesn't need to be synced.

So much wrong with that statement.

Andy, what does fdatasync() do when you have a data-clean,
metadata-dirty file (e.g. you just punched a hole  or preallocated
more space via fallocate())?  Hint: it doesn't sync any data
because the mapping tree is clean, but it still syncs the dirty
metadata needed to access the data.

Now, what does a file where we do direct IO writes look like? Yup,
the mapping tree always remains clean and so it's only ever going to
appear to the kernel as a *data-clean, metadata-dirty* file. So,
after a direct IO write is done, what operation do we need to run to
ensure that we can always access the data?

Yup, it's fdatasync().

So, what does a DAX file that does userspace data flushes look like
to the kernel? Yup, again the mapping tree always remains clean and
so it's only ever going to be a *data-clean, metadata-dirty* file.

It should be clear now why I said "fdatasync on every page fault"
because that's exactly the mechanism we'd use to implement this
functionality....

It should also be clear that DAX is not introducing any new data
integrity problems to the filesystems that direct IO hasn't already
introduced. Both DAX with userspace data sync and Direct IO writes
are completely untracked by the kernel.  IOWs, direct IO is a form
of "kernel bypass", just like DAX+userspace data sync is.  All that
is different is the method by which data is written to the storage
media from userspace, which in the case of DAX is via mmap rather
than read/write.

> > "lightweight" option. That's the brute-force-with-big-hammer
> > solution - it's most definitely not lightweight as every page fault
> > has extra overhead to call ->fsync(). Sure, the API is simple, but
> > the runtime overhead is significant.
> 
> It's lightweight in terms of its impact on the filesystem.  It doesn't
> need any persistent setup -- you can just use it.

Well, no, that's wrong, because we have to co-ordinate multiple
concurrent accesses to the data in the kernel. What happens when
some other process writes to the file *at the same time* but does
not use userspace sync? We aren't tracking dirty regions on the
inode mapping because we've been told not to do that, so fsync()
from that other process *won't sync the data it wrote*. IOws, the
kernel has failed to provide the guarantee that userspace wants it
to provide.

The single mapping tree is central to the problem here - we can't
mix modes of dirty tracking across different processes. Either
everything uses userspace sync, or everything uses kernel controlled
dirty tracking so fsync() works correctly in all cases. Put simply -
dirty tracking is a per-inode function, not a per-file or per-vma
function.

As the direct IO kernel-bypass model demonstrates, as soon as you
start considering multi-process data coherency and durability with
mixed kernel+kernel bypass methods in play, lots of potential
problems and issues crop up that can't easily be solved by the
kernel or filesystems. We try to minimise the problems, but we don't
guarantee mixed mode coherency (and hence integrity) as we've
delegated data coherency and integrity responsibility to the app
bypassing the kernel data coherency and integrity mechanisms.

What I'd like to avoid is creating another kernel bypass mechanism
where we allow coherency and/or integrity to be fucked up in a way that
we can't fix without giving up all the performance that the kernel
bypass provides userspace apps. Constrain the cases where kernel
bypass is allowed, and we avoid all the crappy corner cases where
our only answer to users with corrupt data is "the man page advises
application developers not to do that".

If in future we work out how to implement everything without
needing immutable extents in the inode, we can relax the
restrictions we've placed on userspace DAX data sync....

> > Even if you are considering the complexity of the APIs, it's hardly
> > a "heavyweight" when it only requires a single call to fallocate()
> > before mmap() to set up the immutable extents on the file...
> 
> So what would the exact semantics be?  In particular, how can it fail?
>  If I do the fallocate(), is it absolutely promised that the extent
> map won't get out of sync between what mmap sees and what's on disk?

That's precisely the guarantee I documented would be given by
immutable extents in my very first proposal.

> Do user programs need to worry about colliding with each other when
> one does fallocate() to DAXify a file and the other does fallocate()
> to unDAXify a file?

Yes, it can. This was one of the reasons for putting it under
privilege - so only the app has full control of the extent map
changes and nobody else can fuck with it.

> Does this particular fallocate() call still keep
> its effect after a reboot?

Yes, it does, because it has to be transparent and behave
consistently with all of userspace, not just the app that owns the
file, and not just while that app is running. (e.g. defrag could be
running on the file before the app starts, and then you're screwed
when defrag modifies the extent map after app startup...)

> Is there an actual concrete proposal that's reviewable?

Yes, the first posting where I proposed this functionality many
months ago spelled this all out in detail.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
