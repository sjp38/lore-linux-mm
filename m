Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 26C466B0009
	for <linux-mm@kvack.org>; Sun, 21 Feb 2016 17:32:14 -0500 (EST)
Received: by mail-pf0-f180.google.com with SMTP id x65so81623912pfb.1
        for <linux-mm@kvack.org>; Sun, 21 Feb 2016 14:32:14 -0800 (PST)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id e90si34910143pfj.89.2016.02.21.14.32.11
        for <linux-mm@kvack.org>;
        Sun, 21 Feb 2016 14:32:12 -0800 (PST)
Date: Mon, 22 Feb 2016 09:31:57 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC 0/2] New MAP_PMEM_AWARE mmap flag
Message-ID: <20160221223157.GC25832@dastard>
References: <56C9EDCF.8010007@plexistor.com>
 <CAPcyv4iqAXryz0-WAtvnYf6_Q=ha8F5b-fCUt7DDhYasX=YRUA@mail.gmail.com>
 <56CA1CE7.6050309@plexistor.com>
 <CAPcyv4hpxab=c1g83ARJvrnk_5HFkqS-t3sXpwaRBiXzehFwWQ@mail.gmail.com>
 <56CA2AC9.7030905@plexistor.com>
 <CAPcyv4gQV9Oh9OpHTGuGfTJ_s1C_L7J-VGyto3JMdAcgqyVeAw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4gQV9Oh9OpHTGuGfTJ_s1C_L7J-VGyto3JMdAcgqyVeAw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Boaz Harrosh <boaz@plexistor.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, Arnd Bergmann <arnd@arndb.de>

On Sun, Feb 21, 2016 at 02:03:43PM -0800, Dan Williams wrote:
> On Sun, Feb 21, 2016 at 1:23 PM, Boaz Harrosh <boaz@plexistor.com> wrote:
> > On 02/21/2016 10:57 PM, Dan Williams wrote:
> >> On Sun, Feb 21, 2016 at 12:24 PM, Boaz Harrosh <boaz@plexistor.com> wrote:
> >>> On 02/21/2016 09:51 PM, Dan Williams wrote:
> > Sure. please have a look. What happens is that the legacy app
> > will add the page to the radix tree, come the fsync it will be
> > flushed. Even though a "new-type" app might fault on the same page
> > before or after, which did not add it to the radix tree.
> > So yes, all pages faulted by legacy apps will be flushed.
> >
> > I have manually tested all this and it seems to work. Can you see
> > a theoretical scenario where it would not?
> 
> I'm worried about the scenario where the pmem aware app assumes that
> none of the cachelines in its mapping are dirty when it goes to issue
> pcommit.  We'll have two applications with different perceptions of
> when writes are durable.  Maybe it's not a problem in practice, at
> least current generation x86 cpus flush existing dirty cachelines when
> performing non-temporal stores.  However, it bothers me that there are
> cpus where a pmem-unaware app could prevent a pmem-aware app from
> making writes durable.  It seems if one app has established a
> MAP_PMEM_AWARE mapping it needs guarantees that all apps participating
> in that shared mapping have the same awareness.

Which, in practice, cannot work. Think cp, rsync, or any other
program a user can run that can read the file the MAP_PMEM_AWARE
application is using.

> Another potential issue is that MAP_PMEM_AWARE is not enough on its
> own.  If the filesystem or inode does not support DAX the application
> needs to assume page cache semantics.  At a minimum MAP_PMEM_AWARE
> requests would need to fail if DAX is not available.

They will always still need to call msync()/fsync() to guarantee
data integrity, because the filesystem metadata that indexes the
data still needs to be committed before data integrity can be
guaranteed. i.e. MAP_PMEM_AWARE by itself it not sufficient for data
integrity, and so the app will have to be written like any other app
that uses page cache based mmap().

Indeed, the application cannot even assume that a fully allocated
file does not require msync/fsync because the filesystem may be
doing things like dedupe, defrag, copy on write, etc behind the back
of the application and so file metadata changes may still be in
volatile RAM even though the application has flushed it's data.
Applications have no idea what the underlying filesystem and storage
is doing and so they cannot assume that complete data integrity is
provided by userspace driven CPU cache flush instructions on their
file data.

This "pmem aware applications only need to commit their data"
thinking is what got us into this mess in the first place. It's
wrong, and we need to stop trying to make pmem work this way because
it's a fundamentally broken concept.

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
