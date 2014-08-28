Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id A46D16B0038
	for <linux-mm@kvack.org>; Thu, 28 Aug 2014 03:17:16 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id fb1so1363655pad.41
        for <linux-mm@kvack.org>; Thu, 28 Aug 2014 00:17:16 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id gn1si4424927pbb.221.2014.08.28.00.17.12
        for <linux-mm@kvack.org>;
        Thu, 28 Aug 2014 00:17:13 -0700 (PDT)
Date: Thu, 28 Aug 2014 17:17:06 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v10 00/21] Support ext4 on NV-DIMMs
Message-ID: <20140828071706.GD26465@dastard>
References: <cover.1409110741.git.matthew.r.wilcox@intel.com>
 <20140827130613.c8f6790093d279a447196f17@linux-foundation.org>
 <alpine.DEB.2.11.1408271616070.17080@gentwo.org>
 <20140827143055.5210c5fb9696e460b456eb26@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140827143055.5210c5fb9696e460b456eb26@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, willy@linux.intel.com

On Wed, Aug 27, 2014 at 02:30:55PM -0700, Andrew Morton wrote:
> On Wed, 27 Aug 2014 16:22:20 -0500 (CDT) Christoph Lameter <cl@linux.com> wrote:
> 
> > > Some explanation of why one would use ext4 instead of, say,
> > > suitably-modified ramfs/tmpfs/rd/etc?
> > 
> > The NVDIMM contents survive reboot and therefore ramfs and friends wont
> > work with it.
> 
> See "suitably modified".  Presumably this type of memory would need to
> come from a particular page allocator zone.  ramfs would be unweildy
> due to its use to dentry/inode caches, but rd/etc should be feasible.

<sigh>

That's where we started about two years ago with that horrible
pramfs trainwreck.

To start with: brd is a block device, not a filesystem. We still
need the filesystem on top of a persistent ram disk to make it
useful to applications. We can do this with ext4/XFS right now, and
that is the fundamental basis on which DAX is built.

For sake of the discussion, however, let's walk through what is
required to make an "existing" ramfs persistent. Persistence means we
can't just wipe it and start again if it gets corrupted, and
rebooting is not a fix for problems.  Hence we need to be able to
identify it, check it, repair it, ensure metadata operations are
persistent across machine crashes, etc, so there is all sorts of
management tools required by a persistent ramfs.

But most important of all: the persistent storage format needs to be
forwards and backwards compatible across kernel versions.  Hence we
can't encode any structure the kernel uses internally into the
persistent storage because they aren't stable structures.  That
means we need to marshall objects between the persistence domain and
the volatile domain in an orderly fashion.

We can avoid using the dentry/inode *caches* by freeing those
volatile objects the moment reference counts dop to zero rather than
putting them on LRUs. However, we can't store them in persistent
storage and we can't avoid using them to interface with the VFS, so
it makes little sense to burn CPU continually marshalling such
structures in and out of volatile memory if we have free RAM to do
so. So even with a "persistent ramfs" caching the working set of
volatile VFS objects makes sense from a peformance point of view.

Then you've got crash recovery management: NVDIMMs are not
synchronous: they can still lose data while it is being written on
power loss. And we can't update persistent memory piecemeal as the
VFS code modifies metadata - there needs to be synchronisation
points, otherwise we will always have inconsistent metadata state in
persistent memory.

Persistent memory also can't do atomic writes across multiple,
disjoint CPU cachelines or NVDIMMs, and this is what is needed for
synchroniation points for multi-object metadata modification
operations to be consistent after a crash.  There is some work in
the nvme working groups to define this, but so far there hasn't been
any useful outcome, and then we willhave to wait for CPUs to
implement those interfaces.

Hence the metadata that indexes the persistent RAM needs to use COW
techniques, use a log structure or use WAL (journalling).  Hence
that "persistent ramfs" is now looking much more like a database or
traditional filesystem.

Further, it's going to need to scale to very large amounts of
storage.  We're talking about machines with *tens of TB* of NVDIMM
capacity in the immediate future and so free space manangement and
concurrency of allocation and freeing of used space is going to be
fundamental to the performance of the persistent NVRAM filesystem.
So, you end up with block/allocation groups to subdivide the space.
Looking a lot like ext4 or XFS at this point.

And now you have to scale to indexing tens of millions of
everything. At least tens of millions - hundreds of millions to
billions is more likely, because storing tens of terabytes of small
files is going to require indexing billions of files. And because
there is no performance penalty for doing this, people will use the
filesystem as a great big database. So now you have to have a
scalable posix compatible directory structures, scalable freespace
indexation, dynamic, scalable inode allocation, freeing, etc. Oh,
and it also needs to be highly concurrent to handle machines with
hundreds of CPU cores.

Funnily enough, we already have a couple of persistent storage
implementations that solve these problems to varying degrees. ext4
is one of them, if you ignore the scalability and concurrency
requirements. XFS is the other. And both will run unmodified on
a persistant ram block device, which we *already have*.

And so back to DAX. What users actually want from their high speed
persistant RAM storage is direct, cpu addressable access to that
persistent storage. They don't want to have to care about how to
find an object in the persistent storage - that's what filesystems
are for - they just want to be able to read and write to it
directly. That's what DAX does - it provides existing filesystems
a method for exposing direct access to the persistent RAM to
applications in a manner that application developers are already
familiar with. It's a win-win situation all round.

IOWs, ext4/XFS + DAX gets us to a place that is good enough for most
users and the hardware capabilities we expect to see in the next 5
years.  And hopefully that will be long enough to bring a purpose
built, next generation persistent memory filesystem to production
quality that can take full advantage of the technology...

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
