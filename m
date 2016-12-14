Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5E9A26B0253
	for <linux-mm@kvack.org>; Tue, 13 Dec 2016 23:24:22 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id q10so2909466pgq.7
        for <linux-mm@kvack.org>; Tue, 13 Dec 2016 20:24:22 -0800 (PST)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id m1si50870816pge.100.2016.12.13.20.24.19
        for <linux-mm@kvack.org>;
        Tue, 13 Dec 2016 20:24:21 -0800 (PST)
Date: Wed, 14 Dec 2016 15:23:13 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [LSF/MM TOPIC] Un-addressable device memory and block/fs
 implications
Message-ID: <20161214042313.GF4326@dastard>
References: <20161213181511.GB2305@redhat.com>
 <20161213201515.GB4326@dastard>
 <20161213203112.GE2305@redhat.com>
 <20161213211041.GC4326@dastard>
 <20161213212433.GF2305@redhat.com>
 <20161213221322.GD4326@dastard>
 <20161213225523.GG2305@redhat.com>
 <20161214001422.GE4326@dastard>
 <20161214010755.GA2182@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161214010755.GA2182@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org

On Tue, Dec 13, 2016 at 08:07:58PM -0500, Jerome Glisse wrote:
> On Wed, Dec 14, 2016 at 11:14:22AM +1100, Dave Chinner wrote:
> > On Tue, Dec 13, 2016 at 05:55:24PM -0500, Jerome Glisse wrote:
> > > On Wed, Dec 14, 2016 at 09:13:22AM +1100, Dave Chinner wrote:
> > > > On Tue, Dec 13, 2016 at 04:24:33PM -0500, Jerome Glisse wrote:
> > > > > On Wed, Dec 14, 2016 at 08:10:41AM +1100, Dave Chinner wrote:
> > > > > > > From kernel point of view such memory is almost like any other, it
> > > > > > > has a struct page and most of the mm code is non the wiser, nor need
> > > > > > > to be about it. CPU access trigger a migration back to regular CPU
> > > > > > > accessible page.
> > > > > > 
> > > > > > That sounds ... complex. Page migration on page cache access inside
> > > > > > the filesytem IO path locking during read()/write() sounds like
> > > > > > a great way to cause deadlocks....
> > > > > 
> > > > > There are few restriction on device page, no one can do GUP on them and
> > > > > thus no one can pin them. Hence they can always be migrated back. Yes
> > > > > each fs need modification, most of it (if not all) is isolated in common
> > > > > filemap helpers.
> > > > 
> > > > Sure, but you haven't answered my question: how do you propose we
> > > > address the issue of placing all the mm locks required for migration
> > > > under the filesystem IO path locks?
> > > 
> > > Two different plans (which are non exclusive of each other). First is to use
> > > workqueue and have read/write wait on the workqueue to be done migrating the
> > > page back.
> > 
> > Pushing something to a workqueue and then waiting on the workqueue
> > to complete the work doesn't change lock ordering problems - it
> > just hides them away and makes them harder to debug.
> 
> Migration doesn't need many lock below is a list and i don't see any lock issue
> in respect to ->read or ->write.
> 
>  lock_page(page);
>  spin_lock_irq(&mapping->tree_lock);
>  lock_buffer(bh); // if page has buffer_head
>  i_mmap_lock_read(mapping);
>  vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
>     // page table lock for each entry
>  }

We can't take the page or mapping tree locks that while we hold
various filesystem locks.

e.g. The IO path lock order is, in places:

inode->i_rwsem
  get page from page cache
  lock_page(page)
  inode->allocation lock
    zero page data

Filesystems are allowed to do this, because the IO path has
guaranteed them access to the page cache data on the page that is
locked. Your ZONE_DEVICE proposal breaks this guarantee - we might
have a locked page, but we don't have access to it's data.

Further, in various filesystems once the allocation lock is taken
(e.g. the i_lock in XFS) we're not allowed to lock pages or the
mapping tree as that leads to deadlocks with truncate, hole punch,
etc. Hence if the "zero page data" operation occurs on a ZONE_DEVICE page that
requires migration before the zeroing can occur, we can't perform
migration here.

Why are we even considering migration in situations where we already
hold the ZONE_DEVICE page locked, hold other filesystem locks inside
the page lock, and have an open dirty filesystem transaction as well?

Even if migration si possible and succeeds, the struct page in the
mapping tree for the file offset we are operating on is going to be
different after migration. That implies we need to completely
restart the operation. But given that we've already made changes,
backing out at this point is ...  complex and may not even be
possible.

i.e. we have an architectural assumption that page contents are
always accessable when we have a locked struct page, and your
proposal would appear to violate that assumption...

> > > Second solution is to use a bounce page during I/O so that there is no need
> > > for migration.
> > 
> > Which means the page in the device is left with out-of-date
> > contents, right?
> >
> > If so, how do you prevent data corruption/loss when the device
> > has modified the page out of sight of the CPU and the bounce page
> > doesn't contain those modifications? Or if the dirty device page is
> > written back directly without containing the changes made in the
> > bounce page?
> 
> There is no issue here, if bounce page is use then the page is mark as read
> only on the device until write is done and device copy is updated with what
> we have been ask to write. So no coherency issue between the 2 copy.

What if the page is already dirty on the device? You can't just
"mark it read only" because then you lose any data the device had
written that was not directly overwritten by the IO that needed
bouncing.

Partial page overwrites do occur...

> > > > And if zeroing the page during such a fault requires CPU access to
> > > > the data, how do you propose we handle page migration in the middle
> > > > of the page fault to allow the CPU to zero the page? Seems like more
> > > > lock order/inversion problems there, too...
> > > 
> > > File back page are never allocated on device, at least we have no incentive
> > > for usecase we care about today to do so. So a regular page is first use
> > > and initialize (to zero for hole) before being migrated to device.
> > > So i do not believe there should be any major concern on ->page_mkwrite.
> > 
> > Such deja vu - inodes are not static objects as modern filesystems
> > are highly dynamic. If you want to have safe, reliable non-coherent
> > mmap-based file data offload to devices, then I suspect that we're
> > going to need pretty much all of the same restrictions the pmem
> > programming model requires for userspace data flushing. i.e.:
> > 
> > https://lkml.org/lkml/2016/9/15/33
> 
> I don't see any of the issues in that email applying to my case. Like i said
> from fs/mm point of view my page are _exactly_ like regular page.

Except they aren't...

> Only thing
> is no CPU access.

... because filesystems need direct CPU access to the data the page
points at when migration does not appear to be possible.

FWIW, another nasty corner case I just realised: the file data
requires some kind of data transformation on writeback. e.g.
compression, encryption, parity calculations for RAID, etc. IOWs, it
could be the block device underneath the filesystem that requires
ZONE_DEVICE->ZONE_NORMAL migration to occur. And to make matters
worse, that can occur in code paths that operate in a "must
guarantee forwards progress" memory allocation context...

> > At which point I have to ask: why is mmap considered to be the right
> > model for transfering data in and out of devices that are not
> > directly CPU addressable? 
> 
> That is where the industry is going, OpenCL 2.0/3.0, C++ concurrency and
> parallelism, OpenACC, OpenMP, HSA, Cuda ... all those API require unified
> address space and transparent use of device memory.

Sure, but that doesn't mean you can just map random files into the
user address space and then hand it off to random hardware and
expect the filesystem to be perfectly happy with that. 

> > > migration for given fs.
> > 
> > How do you propose doing that?
> 
> As a mount flag option is my first idea but i have no strong opinion here.

No, absolutely not. Mount options are not for controlling random
special interest behaviours in filesystems. That makes it impossible
to mix "incompatible" technologies in the same filesystem.

> It might make sense for finer granularity but i don't believe so.

Then you're just not thinking about complex computation engines the
right way, are you?

e.g. you have a pmem filesystem as the central high-speed data store
for you computation engine. Some apps in the pipeline use DAX for
their data access because it's 10x faster than using traditional
buffered mmap access, so the filesystem is mounted "-o dax". But
then you want to add a hardware accelerator to speed up a different
stage of the pipeline by 10x, but it requires page based ZONE_DEVICE
management.

Unfortuantely the "-o zone_device" mount option is incompatible with
"-o dax" and because "it doesn't make sense for DAX to be a fine
grained option" you can't combine the two technologies into the one
pipeline....

That'd really suck, wouldn't it?

-Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
