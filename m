Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id 7E1B76B0005
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 07:07:01 -0500 (EST)
Received: by mail-ig0-f181.google.com with SMTP id hb3so97479957igb.0
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 04:07:01 -0800 (PST)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id c18si38501405igr.94.2016.02.23.04.06.59
        for <linux-mm@kvack.org>;
        Tue, 23 Feb 2016 04:07:00 -0800 (PST)
Date: Tue, 23 Feb 2016 23:06:44 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC 0/2] New MAP_PMEM_AWARE mmap flag
Message-ID: <20160223120644.GL25832@dastard>
References: <56CA1CE7.6050309@plexistor.com>
 <CAPcyv4hpxab=c1g83ARJvrnk_5HFkqS-t3sXpwaRBiXzehFwWQ@mail.gmail.com>
 <56CA2AC9.7030905@plexistor.com>
 <CAPcyv4gQV9Oh9OpHTGuGfTJ_s1C_L7J-VGyto3JMdAcgqyVeAw@mail.gmail.com>
 <20160221223157.GC25832@dastard>
 <x49fuwk7o8a.fsf@segfault.boston.devel.redhat.com>
 <20160222174426.GA30110@infradead.org>
 <257B23E37BCB93459F4D566B5EBAEAC550098A32@FMSMSX106.amr.corp.intel.com>
 <20160223095225.GB32294@infradead.org>
 <7168B635-938B-44A0-BECD-C0774207B36D@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7168B635-938B-44A0-BECD-C0774207B36D@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rudoff, Andy" <andy.rudoff@intel.com>
Cc: Christoph Hellwig <hch@infradead.org>, Jeff Moyer <jmoyer@redhat.com>, Arnd Bergmann <arnd@arndb.de>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Feb 23, 2016 at 10:07:07AM +0000, Rudoff, Andy wrote:
> 
> > [Hi Andy - care to properly line break after ~75 character, that makes
> > ready the message a lot easier, thanks!]
> 
> My bad. 
> 
> >> The instructions give you very fine-grain flushing control, but the
> >> downside is that the app must track what it changes at that fine
> >> granularity.  Both models work, but there's a trade-off.
> > 
> > No, the cache flush model simply does not work without a lot of hard
> > work to enable it first.
> 
> It's working well enough to pass tests that simulate crashes and
> various workload tests for the apps involved. And I agree there
> has been a lot of hard work behind it. I guess I'm not sure why you're
> saying it is impossible or not working.
> 
> Let's take an example: an app uses fallocate() to create a DAX file,
> mmap() to map it, msync() to flush changes. The app follows POSIX
> meaning it doesn't expect file metadata to be flushed magically, etc.
> The app is tested carefully and it works correctly.  Now the msync()
> call used to flush stores is replaced by flushing instructions.
> What's broken?

You haven't told the filesytem to flush any dirty metadata required
to access the user data to persistent storage.  If the zeroing and
unwritten extent conversion that is run by the filesytem during
write faults into preallocated blocks isn't persistent, then after a
crash the file will read back as unwritten extents, returning zeros
rather than the data that was written.

msync() calls fsync() on file back pages, which makes file metadata
changes persistent.  Indeed, if you read the fdatasync man page, you
might have noticed that it makes explicit reference that it requires
the filesystem to flush the metadata needed to access the data that
is being synced. IOWs, the filesystem knows about this dirty
metadata that needs to be flushed to ensure data integrity,
userspace doesn't.

Not to mention that the filesystem will convert and zero much more
than just a single cacheline (whole pages at minimum, could be 2MB
extents for large pages, etc) so the filesystem may require CPU
cache flushes over a much wider range of cachelines that the
application realises are dirty and require flushing for data
integrity purposes. The filesytem knows about these dirty cache
lines, userspace doesn't.

IOWs, your userspace library may have made sure the data it modifies
is in the physical location via your userspace CPU cache flushes,
but there can be a lot of stuff it doesn't know about internal to
the filesytem that also needs to be flushed to ensure data integrity
is maintained.

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
