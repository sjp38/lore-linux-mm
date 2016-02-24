Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 26B8C6B0009
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 23:10:02 -0500 (EST)
Received: by mail-pf0-f173.google.com with SMTP id c10so5210671pfc.2
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 20:10:02 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id tw5si1843591pac.131.2016.02.23.20.10.01
        for <linux-mm@kvack.org>;
        Tue, 23 Feb 2016 20:10:01 -0800 (PST)
Date: Tue, 23 Feb 2016 21:09:47 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [RFC 0/2] New MAP_PMEM_AWARE mmap flag
Message-ID: <20160224040947.GA10313@linux.intel.com>
References: <257B23E37BCB93459F4D566B5EBAEAC550098A32@FMSMSX106.amr.corp.intel.com>
 <20160223095225.GB32294@infradead.org>
 <56CC686A.9040909@plexistor.com>
 <CAPcyv4gTaikkXCG1fPBVT-0DE8Wst3icriUH5cbQH3thuEe-ow@mail.gmail.com>
 <56CCD54C.3010600@plexistor.com>
 <CAPcyv4iqO=Pzu_r8tV6K2G953c5HqJRdqCE1pymfDmURy8_ODw@mail.gmail.com>
 <x49egc3c8gf.fsf@segfault.boston.devel.redhat.com>
 <CAPcyv4jUkMikW_x1EOTHXH4GC5DkPieL=sGd0-ajZqmG6C7DEg@mail.gmail.com>
 <x49a8mrc7rn.fsf@segfault.boston.devel.redhat.com>
 <CAPcyv4hMJ_+o2hYU7xnKEWUcKpcPVd66e2KChwL96Qxxk2R8iQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4hMJ_+o2hYU7xnKEWUcKpcPVd66e2KChwL96Qxxk2R8iQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jeff Moyer <jmoyer@redhat.com>, Arnd Bergmann <arnd@arndb.de>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Dave Chinner <david@fromorbit.com>, Oleg Nesterov <oleg@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Feb 23, 2016 at 03:56:17PM -0800, Dan Williams wrote:
> On Tue, Feb 23, 2016 at 3:43 PM, Jeff Moyer <jmoyer@redhat.com> wrote:
> > Dan Williams <dan.j.williams@intel.com> writes:
> >
> >> On Tue, Feb 23, 2016 at 3:28 PM, Jeff Moyer <jmoyer@redhat.com> wrote:
> >>>> The crux of the problem, in my opinion, is that we're asking for an "I
> >>>> know what I'm doing" flag, and I expect that's an impossible statement
> >>>> for a filesystem to trust generically.
> >>>
> >>> The file system already trusts that.  If an application doesn't use
> >>> fsync properly, guess what, it will break.  This line of reasoning
> >>> doesn't make any sense to me.
> >>
> >> No, I'm worried about the case where an app specifies MAP_PMEM_AWARE
> >> uses fsync correctly, and fails to flush cpu cache.
> >
> > I don't think the kernel needs to put training wheels on applications.
> >
> >>>> If you can get MAP_PMEM_AWARE in, great, but I'm more and more of the
> >>>> opinion that the "I know what I'm doing" interface should be something
> >>>> separate from today's trusted filesystems.
> >>>
> >>> Just so I understand you, MAP_PMEM_AWARE isn't the "I know what I'm
> >>> doing" interface, right?
> >>
> >> It is the "I know what I'm doing" interface, MAP_PMEM_AWARE asserts "I
> >> know when to flush the cpu relative to an fsync()".
> >
> > I see.  So I think your argument is that new file systems (such as Nova)
> > can have whacky new semantics, but existing file systems should provide
> > the more conservative semantics that they have provided since the dawn
> > of time (even if we add a new mmap flag to control the behavior).
> >
> > I don't agree with that.  :)
> >
> 
> Fair enough.  Recall, I was pushing MAP_DAX not to long ago.  It just
> seems like a Sisyphean effort to push an mmap flag up the XFS hill and
> maybe that effort is better spent somewhere else.

Well, for what it's worth MAP_SYNC feels like the "right" solution to me.  I
understand that we are a ways from having it implemented, but it seems like
the correct way to have applications work with persistent memory in a perfect
world, and worth the effort.

MAP_PMEM_AWARE is interesting, but even in a perfect world it seems like a
partial solution - applications still need to call *sync to get the FS
metadata to be durable, and they have no reliable way of knowing which of
their actions will cause the metadata to be out of sync.

Dave, is your objection to the MAP_SYNC idea a practical one about complexity
and time to get it implemented, or do you think it's is the wrong solution?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
