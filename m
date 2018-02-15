Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5A1C16B0024
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 00:44:50 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id f4so12423588plr.14
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 21:44:50 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id a89si859721pfg.329.2018.02.14.21.44.48
        for <linux-mm@kvack.org>;
        Wed, 14 Feb 2018 21:44:49 -0800 (PST)
Date: Thu, 15 Feb 2018 16:44:36 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: freezing system for several second on high I/O [kernel 4.15]
Message-ID: <20180215054436.GN7000@dastard>
References: <20180206060840.kj2u6jjmkuk3vie6@destitution>
 <CABXGCsOgcYyj8Xukn7Pi_M2qz2aJ1MJZTaxaSgYno7f_BtZH6w@mail.gmail.com>
 <1517974845.4352.8.camel@gmail.com>
 <20180207065520.66f6gocvxlnxmkyv@destitution>
 <1518255240.31843.6.camel@gmail.com>
 <1518255352.31843.8.camel@gmail.com>
 <20180211225657.GA6778@dastard>
 <1518643669.6070.21.camel@gmail.com>
 <20180214215245.GI7000@dastard>
 <1518666178.6070.25.camel@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1518666178.6070.25.camel@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mikhail <mikhail.v.gavrilov@gmail.com>
Cc: "linux-xfs@vger.kernel.org" <linux-xfs@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Feb 15, 2018 at 08:42:58AM +0500, mikhail wrote:
> On Thu, 2018-02-15 at 08:52 +1100, Dave Chinner wrote:
> > On Thu, Feb 15, 2018 at 02:27:49AM +0500, mikhail wrote:
> > > On Mon, 2018-02-12 at 09:56 +1100, Dave Chinner wrote:
> > > > IOWs, this is not an XFS problem. It's exactly what I'd
> > > > expect to see when you try to run a very IO intensive
> > > > workload on a cheap SATA drive that can't keep up with what
> > > > is being asked of it....
> > > > 
> > > 
> > > I am understand that XFS is not culprit here. But I am worried
> > > about of interface freezing and various kernel messages with
> > > traces which leads to XFS. This is my only clue, and I do not
> > > know where to dig yet.
> > 
> > I've already told you the problem: sustained storage subsystem
> > overload. You can't "tune" you way around that. i.e. You need a
> > faster disk subsystem to maintian the load you are putting on
> > your system - either add more disks (e.g. RAID 0/5/6) or to move
> > to SSDs.
> 
> 
> I know that you are bored already, but: - But it not a reason send
> false positive messages in log, because next time when a real
> problems will occurs I would ignore all messages.

I've already explained that we can't annotate these memory
allocations to turn off the false positives because that will also
turning off all detection of real deadlock conditions.  Lockdep has
many, many limitations, and this happens to be one of them.

FWIW, is there any specific reason you running lockdep on your
desktop system?

> - I am not believe that for mouse pointer moving needed disk
> throughput. Very wildly that mouse pointer freeze I never seen
> this on Windows even I then I create such workload. So it look
> like on real blocking vital processes for GUI.

I think I've already explained that, too. The graphics subsystem -
which is responsible for updating the cursor - requires memory
allocation. The machine is running low on memory, so it runs memory
reclaim, which recurses back into the filesystem and blocks waiting
for IO to be completed (either writing dirty data pages or flushing
dirty metadata) so it can free memory.

IOWs, your problems all stem from long IO latencies caused by the
overloaded storage subsystem - they are propagate to all
aspects of the OS via direct memory reclaim blocking on IO....

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
