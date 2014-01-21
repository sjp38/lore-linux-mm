Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f48.google.com (mail-yh0-f48.google.com [209.85.213.48])
	by kanga.kvack.org (Postfix) with ESMTP id 630836B00AA
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 18:03:44 -0500 (EST)
Received: by mail-yh0-f48.google.com with SMTP id f11so2981553yha.7
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 15:03:44 -0800 (PST)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [2001:44b8:8060:ff02:300:1:6:4])
        by mx.google.com with ESMTP id q66si7928981yhm.4.2014.01.21.15.03.38
        for <linux-mm@kvack.org>;
        Tue, 21 Jan 2014 15:03:41 -0800 (PST)
Date: Wed, 22 Jan 2014 10:03:33 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] [ATTEND] Persistent memory
Message-ID: <20140121230333.GH13997@dastard>
References: <CALCETrUaotUuzn60-bSt1oUb8+94do2QgiCq_TXhqEHj79DePQ@mail.gmail.com>
 <52D8AEBF.3090803@symas.com>
 <52D982EB.6010507@amacapital.net>
 <52DE23E8.9010608@symas.com>
 <20140121111727.GB13997@dastard>
 <CALCETrUWhWDSJNHT5OEmNSyBuGx4-AxqeS3YBcKL0nejZ6kQ4w@mail.gmail.com>
 <20140121203620.GD13997@dastard>
 <CALCETrV3jL-m74apTyEN+vb0vFQqoCnCrtJVW3_MWk57WS0kqw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrV3jL-m74apTyEN+vb0vFQqoCnCrtJVW3_MWk57WS0kqw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Howard Chu <hyc@symas.com>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, lsf-pc@lists.linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Jan 21, 2014 at 12:59:42PM -0800, Andy Lutomirski wrote:
> On Tue, Jan 21, 2014 at 12:36 PM, Dave Chinner <david@fromorbit.com> wrote:
> > On Tue, Jan 21, 2014 at 08:48:06AM -0800, Andy Lutomirski wrote:
> >> On Tue, Jan 21, 2014 at 3:17 AM, Dave Chinner <david@fromorbit.com> wrote:
> >> > On Mon, Jan 20, 2014 at 11:38:16PM -0800, Howard Chu wrote:
> >> >> Andy Lutomirski wrote:
> >> >> >On 01/16/2014 08:17 PM, Howard Chu wrote:
> >> >> >>Andy Lutomirski wrote:
> >> >> >>>I'm interested in a persistent memory track.  There seems to be plenty
> >> >> >>>of other emails about this, but here's my take:
> >> >> >>
> >> >> >>I'm also interested in this track. I'm not up on FS development these
> >> >> >>days, the last time I wrote filesystem code was nearly 20 years ago. But
> >> >> >>persistent memory is a topic near and dear to my heart, and of great
> >> >> >>relevance to my current pet project, the LMDB memory-mapped database.
> >> >> >>
> >> >> >>In a previous era I also developed block device drivers for
> >> >> >>battery-backed external DRAM disks. (My ideal would have been systems
> >> >> >>where all of RAM was persistent. I suppose we can just about get there
> >> >> >>with mobile phones and tablets these days.)
> >> >> >>
> >> >> >>In the context of database engines, I'm interested in leveraging
> >> >> >>persistent memory for write-back caching and how user level code can be
> >> >> >>made aware of it. (If all your cache is persistent and guaranteed to
> >> >> >>eventually reach stable store then you never need to fsync() a
> >> >> >>transaction.)
> >> >
> >> > I don't think that is true -  your still going to need fsync to get
> >> > the CPU to flush it's caches and filesystem metadata into the
> >> > persistent domain....
> >>
> >> I think that this depends on the technology in question.
> >>
> >> I suspect (I don't know for sure) that, if the mapping is WT or UC,
> >> that it would be possible to get the data fully flushed to persistent
> >> storage by doing something like a UC read from any appropriate type of
> >> I/O space (someone from Intel would have to confirm).
> >
> > And what of the filesystem metadata that is necessary to reference
> > that data? What flushes that? e.g. using mmap of sparse files to
> > dynamically allocate persistent memory space requires fdatasync() at
> > minimum....
> 
> If we're using dm-crypt using an NV-DIMM "block" device as cache and a
> real disk as backing store, then ideally mmap would map the NV-DIMM
> directly if the data in question lives there.

dm-crypt does not use any block device as a cache. You're thinking
about dm-cache or bcache. And neither of them are operating at the
filesystem level or are aware of the difference between fileystem
metadata and user data. But talking about non-existent block layer
functionality doesn't answer my the question about keeping user data
and filesystem metadata needed to reference that user data
coherent in persistent memory...

> If that's happening,
> then, assuming that there are no metadata changes, you could just
> flush the relevant hw caches.  This assumes, of course, no dm-crypt,
> no btrfs-style checksumming, and, in general, nothing else that would
> require stable pages or similar things.

Well yes. Data IO path transformations are another reason why we'll
need the volatile page cache involved in the persistent memory IO
path. It follows immediately from this that applicaitons will still
require fsync() and other data integrity operations because they
have no idea where the persistence domain boundary lives in the IO
stack.

> > And then there's things like encrypted persistent memory when means
> > applications can't directly access it and so mmap() will be buffered
> > by the page cache just like a normal block device...
> >
> >> All of this suggests to me that a vsyscall "sync persistent memory"
> >> might be better than a real syscall.
> >
> > Perhaps, but that implies some method other than a filesystem to
> > manage access to persistent memory.
> 
> It should be at least as good as fdatasync if using XIP or something like pmfs.
> 
> For my intended application, I want to use pmfs or something similar
> directly.  This means that I want really fast synchronous flushes, and
> I suspect that the usual set of fs calls that handle fdatasync are
> already quite a bit slower than a vsyscall would be, assuming that no
> MSR write is needed.

What you are saying is that you want a fixed, allocated range of
persistent memory mapped into the applications address space that
you have direct control of. Yes, we can do that through the
filesystem XIP interface (zero the file via memset() rather than via
unwritten extents) and then fsync the file. The metadata on the file
will then never change, and you can do what you want via mmap from
then onwards. I'd suggest at this point that msync() is the
operation that should then be used to flush the data pages in the
mapped range into the persistence domain.


> >> For what it's worth, some of the NV-DIMM systems are supposed to be
> >> configured in such a way that, if power fails, an NMI, SMI, or even
> >> (not really sure) a hardwired thing in the memory controller will
> >> trigger the requisite flush.  I don't personally believe in this if
> >> L2/L3 cache are involved (they're too big), but for the little write
> >> buffers and memory controller things, this seems entirely plausible.
> >
> > Right - at the moment we have to assume the persistence domain
> > starts at the NVDIMM and doesn't cover the CPU's internal L* caches.
> > I have no idea if/when we'll be seeing CPUs that have persistent
> > caches, so we have to assume that data is still volatile and can be
> > lost unless it has been specifically synced to persistent memory.
> > i.e. persistent memory does not remove the need for fsync and
> > friends...
> 
> I have (NDAed and not entirely convincing) docs indicating a way (on
> hardware that I don't have access to) to make the caches be part of
> the persistence domain. 

Every platform will implement persistence domain
mangement differently. So we can't assume that what works on one
platform is going to work or be compatible with any other
platform....

> I also have non-NDA'd docs that suggest that
> it's really very fast to flush things through the memory controller.
> (I would need to time it, though.  I do have this hardware, and it
> more or less works.)

It still takes non-zero time, so there is still scope for data loss
on power failure, or even CPU failure.

Hmmm, now there's something I hadn't really thought about - how does
CPU failure, hotplug and/or power management affect persistence
domains if the CPU cache contains persistent data and it's no longer
accessible?

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
