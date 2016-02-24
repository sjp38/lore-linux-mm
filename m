Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f177.google.com (mail-io0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id 67A416B0009
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 19:08:28 -0500 (EST)
Received: by mail-io0-f177.google.com with SMTP id 9so9356246iom.1
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 16:08:28 -0800 (PST)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id p7si661586iop.141.2016.02.23.16.08.22
        for <linux-mm@kvack.org>;
        Tue, 23 Feb 2016 16:08:27 -0800 (PST)
Date: Wed, 24 Feb 2016 11:08:08 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC 0/2] New MAP_PMEM_AWARE mmap flag
Message-ID: <20160224000808.GJ14668@dastard>
References: <20160222174426.GA30110@infradead.org>
 <257B23E37BCB93459F4D566B5EBAEAC550098A32@FMSMSX106.amr.corp.intel.com>
 <20160223095225.GB32294@infradead.org>
 <56CC686A.9040909@plexistor.com>
 <CAPcyv4gTaikkXCG1fPBVT-0DE8Wst3icriUH5cbQH3thuEe-ow@mail.gmail.com>
 <56CCD54C.3010600@plexistor.com>
 <CAPcyv4iqO=Pzu_r8tV6K2G953c5HqJRdqCE1pymfDmURy8_ODw@mail.gmail.com>
 <56CCE647.70408@plexistor.com>
 <CAPcyv4gLoQm818BzQSqkCbNPztr0JVihmvuhb=d-kSgbrmYFzQ@mail.gmail.com>
 <56CCEE09.7070204@plexistor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56CCEE09.7070204@plexistor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Christoph Hellwig <hch@infradead.org>, "Rudoff, Andy" <andy.rudoff@intel.com>, Jeff Moyer <jmoyer@redhat.com>, Arnd Bergmann <arnd@arndb.de>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Wed, Feb 24, 2016 at 01:40:57AM +0200, Boaz Harrosh wrote:
> On 02/24/2016 01:23 AM, Dan Williams wrote:
> > On Tue, Feb 23, 2016 at 3:07 PM, Boaz Harrosh <boaz@plexistor.com> wrote:
> >> On 02/24/2016 12:33 AM, Dan Williams wrote:
> > 
> >>> The crux of the problem, in my opinion, is that we're asking for an "I
> >>> know what I'm doing" flag, and I expect that's an impossible statement
> >>> for a filesystem to trust generically.  If you can get MAP_PMEM_AWARE
> >>> in, great, but I'm more and more of the opinion that the "I know what
> >>> I'm doing" interface should be something separate from today's trusted
> >>> filesystems.
> >>>
> >>
> >> I disagree. I'm not saying any "trust me I know what I'm doing" flag.
> >> the FS reveals nothing and trusts nothing.
> >> All I'm saying is that the libc library I'm using as the new pmem_memecpy()
> >> and I'm using that instead of the old memecpy(). So the FS does not need to
> >> wipe my face after I eat. Failing to do so just means a bug in the application
> > 
> > "just means a bug in the application"
> > 
> > Who gets the bug report when an app gets its cache syncing wrong and
> > data corruption ensues, and why isn't the fix for that bug that the
> > filesystem simply stops trusting MAP_PMEM_AWARE and synching
> > cachelines on behalf of the app when it calls sync as it must for
> > metadata consistency.  Problem solved globally for all broken usages
> > of MAP_PMEM_AWARE and the flag loses all meaning as a result.
> > 
> 
> Because this will not fix the application's bugs. Because if the application
> is broken then you do not know that this will fix it. It is broken it failed
> to uphold the contract it had with the Kernel.

That's not the point Dan was making. Data corruption bugs are going
to get reported to the filesystem developers, not the application
developers, because usres think that data corruption is always the
fault of the filesystem. How is the filesystem developer going to
know that a) the app is using DAX, b) the app has set some special
"I know what I'm doing flag", and c) the app doesn't actually know
what it is doing.

We are simply going to assume c) - from long experience I don't
trust any application developer to understand how data integrity
works. Almost any app developer that says they understand how
filesystems provide data integrity are almost always competely
wrong.

Hell, this thread has made me understand that most pmem developers
don't understand how filesystems provide data integrity guarantees.
Why should we trust applicaiton developers to do better?

> It is like saying lets call fsync on file close because broken apps keep
> forgetting to call fsync(). And file close is called even if the app crashes.
> Will Dave do that?

/me points to XFS_ITRUNCATE and xfs_release().

Yes, we already flush data on close in situations where data loss is
common due to stupid application developers refusing to use fsync
because "it's too slow".

ext4 has similar flush on close behaviours for the same reasons.

> No if an app has a bug like this falling to call the proper pmem_xxx routine
> in the proper work flow, it might has just forgotten to call fsync, or maybe
> still modifying memory after fsync was called. And your babysitting the app
> will not help.

History tells us otherwise. users always blame the filesystem first,
and then app developers will refuse to fix their applications
because it would either make their app slow or they think it's a
filesystem problem to solve because they tested on some other
filesystem and it didn't display that behaviour. The result is we
end up working around such problems in the filesystem so that users
don't end up losing data due to shit applications.

The same will happen here - filesystems will end up ignoring this
special "I know what I'm doing" flag because the vast majority of
app developers don't know enough to even realise that they don't
know what they are doing.

I *really* don't care about speed and performance here. I care about
reliability, resilience and data integrity. Speed comes from the
storage hardware being fast, not from filesystems ignoring
reliability, resilience and data integrity.

> > This is the takeaway I've internalized from Dave's pushback of these
> > new mmap flags.
> > 
> 
> We are already used to tell the firefox guys, you did not call fsync and
> you lost data on a crash.
> 
> We will have a new mantra, "You did not use pmem_memcpy() but used MAP_PMEM_AWARE"
> We have contracts like that between Kernel and apps all the time. I fail to see why
> this one crossed the line for you?

So, you prefer to repeat past mistakes rather than learning from
them. I prefer that we don't make the same mistakes again and so
have to live with them for the next 20 years.

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
