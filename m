Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 953CF6B0253
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 12:12:01 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id fl4so113458317pad.0
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 09:12:01 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id o90si48450690pfi.192.2016.02.23.09.12.00
        for <linux-mm@kvack.org>;
        Tue, 23 Feb 2016 09:12:00 -0800 (PST)
Date: Tue, 23 Feb 2016 10:10:59 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [RFC 0/2] New MAP_PMEM_AWARE mmap flag
Message-ID: <20160223171059.GB15877@linux.intel.com>
References: <CAPcyv4hpxab=c1g83ARJvrnk_5HFkqS-t3sXpwaRBiXzehFwWQ@mail.gmail.com>
 <56CA2AC9.7030905@plexistor.com>
 <CAPcyv4gQV9Oh9OpHTGuGfTJ_s1C_L7J-VGyto3JMdAcgqyVeAw@mail.gmail.com>
 <20160221223157.GC25832@dastard>
 <x49fuwk7o8a.fsf@segfault.boston.devel.redhat.com>
 <20160222174426.GA30110@infradead.org>
 <257B23E37BCB93459F4D566B5EBAEAC550098A32@FMSMSX106.amr.corp.intel.com>
 <20160223095225.GB32294@infradead.org>
 <7168B635-938B-44A0-BECD-C0774207B36D@intel.com>
 <20160223120644.GL25832@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160223120644.GL25832@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: "Rudoff, Andy" <andy.rudoff@intel.com>, Arnd Bergmann <arnd@arndb.de>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Oleg Nesterov <oleg@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Feb 23, 2016 at 11:06:44PM +1100, Dave Chinner wrote:
> On Tue, Feb 23, 2016 at 10:07:07AM +0000, Rudoff, Andy wrote:
> > 
> > > [Hi Andy - care to properly line break after ~75 character, that makes
> > > ready the message a lot easier, thanks!]
> > 
> > My bad. 
> > 
> > >> The instructions give you very fine-grain flushing control, but the
> > >> downside is that the app must track what it changes at that fine
> > >> granularity.  Both models work, but there's a trade-off.
> > > 
> > > No, the cache flush model simply does not work without a lot of hard
> > > work to enable it first.
> > 
> > It's working well enough to pass tests that simulate crashes and
> > various workload tests for the apps involved. And I agree there
> > has been a lot of hard work behind it. I guess I'm not sure why you're
> > saying it is impossible or not working.
> > 
> > Let's take an example: an app uses fallocate() to create a DAX file,
> > mmap() to map it, msync() to flush changes. The app follows POSIX
> > meaning it doesn't expect file metadata to be flushed magically, etc.
> > The app is tested carefully and it works correctly.  Now the msync()
> > call used to flush stores is replaced by flushing instructions.
> > What's broken?
> 
> You haven't told the filesytem to flush any dirty metadata required
> to access the user data to persistent storage.  If the zeroing and
> unwritten extent conversion that is run by the filesytem during
> write faults into preallocated blocks isn't persistent, then after a
> crash the file will read back as unwritten extents, returning zeros
> rather than the data that was written.
> 
> msync() calls fsync() on file back pages, which makes file metadata
> changes persistent.  Indeed, if you read the fdatasync man page, you
> might have noticed that it makes explicit reference that it requires
> the filesystem to flush the metadata needed to access the data that
> is being synced. IOWs, the filesystem knows about this dirty
> metadata that needs to be flushed to ensure data integrity,
> userspace doesn't.
> 
> Not to mention that the filesystem will convert and zero much more
> than just a single cacheline (whole pages at minimum, could be 2MB
> extents for large pages, etc) so the filesystem may require CPU
> cache flushes over a much wider range of cachelines that the
> application realises are dirty and require flushing for data
> integrity purposes. The filesytem knows about these dirty cache
> lines, userspace doesn't.

With the current code at least dax_zero_page_range() doesn't rely on
fsync/msync from userspace to make the zeroes that it writes persistent.  It
does all the necessary flushing and wmb_pmem() calls itself.  I agree that
this does not address your concern about metadata being in sync, though.

> IOWs, your userspace library may have made sure the data it modifies
> is in the physical location via your userspace CPU cache flushes,
> but there can be a lot of stuff it doesn't know about internal to
> the filesytem that also needs to be flushed to ensure data integrity
> is maintained.
> 
> Cheers,
> 
> Dave.
> -- 
> Dave Chinner
> david@fromorbit.com
> _______________________________________________
> Linux-nvdimm mailing list
> Linux-nvdimm@lists.01.org
> https://lists.01.org/mailman/listinfo/linux-nvdimm

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
