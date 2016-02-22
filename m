Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f176.google.com (mail-io0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id 3C4E682F69
	for <linux-mm@kvack.org>; Mon, 22 Feb 2016 16:51:00 -0500 (EST)
Received: by mail-io0-f176.google.com with SMTP id l127so192442012iof.3
        for <linux-mm@kvack.org>; Mon, 22 Feb 2016 13:51:00 -0800 (PST)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id q6si35237560igr.96.2016.02.22.13.50.58
        for <linux-mm@kvack.org>;
        Mon, 22 Feb 2016 13:50:59 -0800 (PST)
Date: Tue, 23 Feb 2016 08:50:55 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC 0/2] New MAP_PMEM_AWARE mmap flag
Message-ID: <20160222215055.GJ25832@dastard>
References: <56C9EDCF.8010007@plexistor.com>
 <CAPcyv4iqAXryz0-WAtvnYf6_Q=ha8F5b-fCUt7DDhYasX=YRUA@mail.gmail.com>
 <56CA1CE7.6050309@plexistor.com>
 <CAPcyv4hpxab=c1g83ARJvrnk_5HFkqS-t3sXpwaRBiXzehFwWQ@mail.gmail.com>
 <56CA2AC9.7030905@plexistor.com>
 <CAPcyv4gQV9Oh9OpHTGuGfTJ_s1C_L7J-VGyto3JMdAcgqyVeAw@mail.gmail.com>
 <20160221223157.GC25832@dastard>
 <x49fuwk7o8a.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <x49fuwk7o8a.fsf@segfault.boston.devel.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Arnd Bergmann <arnd@arndb.de>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Mon, Feb 22, 2016 at 10:34:45AM -0500, Jeff Moyer wrote:
> Hi, Dave,
> 
> Dave Chinner <david@fromorbit.com> writes:
> 
> >> Another potential issue is that MAP_PMEM_AWARE is not enough on its
> >> own.  If the filesystem or inode does not support DAX the application
> >> needs to assume page cache semantics.  At a minimum MAP_PMEM_AWARE
> >> requests would need to fail if DAX is not available.
> >
> > They will always still need to call msync()/fsync() to guarantee
> > data integrity, because the filesystem metadata that indexes the
> > data still needs to be committed before data integrity can be
> > guaranteed. i.e. MAP_PMEM_AWARE by itself it not sufficient for data
> > integrity, and so the app will have to be written like any other app
> > that uses page cache based mmap().
> >
> > Indeed, the application cannot even assume that a fully allocated
> > file does not require msync/fsync because the filesystem may be
> > doing things like dedupe, defrag, copy on write, etc behind the back
> > of the application and so file metadata changes may still be in
> > volatile RAM even though the application has flushed it's data.
> 
> Once you hand out a persistent memory mapping, you sure as heck can't
> switch blocks around behind the back of the application.

Yes we can. All we need to do is lock out page faults, invalidate
the mappings, and change the underlying blocks.  The app using mmap
will refault on it's next access, and get the new block mapped into
it's address space.

I'll point to hole punching as an example of how we do these
invalidate/modify operations right now, and we expect them to work
and not result in data corruption. We even have tests (e.g. fsx in
xfstests has all these operations enabled) to make sure it works.

> That aside, let me see if I understand you correctly.
> 
> An application creates a file and writes to every single block in the
> thing, sync's it, closes it.  It then opens it back up, calls mmap with
> this new MAP_DAX flag or on a file system mounted with -o dax, and
> proceeds to access the file using loads and stores.  It persists its
> data by using non-temporal stores, flushing and fencing cpu
> instructions.

The moment the app does a write to the file data, we can no longer
assume the filesystem metadata references to the file data are
durable.

> If I understand you correctly, you're saying that that application is
> not written correctly, because it needs to call fsync to persist
> metadata (that it presumably did not modify).  Is that right?

Yes, though fdatasync() would be sufficient because the app only
modified data.

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
