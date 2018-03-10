Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 670816B0005
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 20:36:50 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id y20so2496364pfm.1
        for <linux-mm@kvack.org>; Fri, 09 Mar 2018 17:36:50 -0800 (PST)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id r63-v6si1830907plb.356.2018.03.09.17.36.48
        for <linux-mm@kvack.org>;
        Fri, 09 Mar 2018 17:36:49 -0800 (PST)
Date: Sat, 10 Mar 2018 12:36:46 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: fallocate on XFS for swap
Message-ID: <20180310013646.GX18129@dastard>
References: <8C28C1CB-47F1-48D1-85C9-5373D29EA13E@amazon.com>
 <20180309234422.GA4860@magnolia>
 <20180310005850.GW18129@dastard>
 <20180310011707.GA4875@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180310011707.GA4875@magnolia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: "Besogonov, Aleksei" <cyberax@amazon.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, xfs <linux-xfs@vger.kernel.org>

On Fri, Mar 09, 2018 at 05:17:07PM -0800, Darrick J. Wong wrote:
> On Sat, Mar 10, 2018 at 11:58:50AM +1100, Dave Chinner wrote:
> > On Fri, Mar 09, 2018 at 03:44:22PM -0800, Darrick J. Wong wrote:
> > > [you really ought to cc the xfs list]
> > > 
> > > On Fri, Mar 09, 2018 at 10:05:24PM +0000, Besogonov, Aleksei wrote:
> > > > Hi!
> > > > 
> > > > Wea??re working at Amazon on making XFS our default root filesystem for
> > > > the upcoming Amazon Linux 2 (now in prod preview). One of the problems
> > > > that wea??ve encountered is inability to use fallocated files for swap
> > > > on XFS. This is really important for us, since wea??re shipping our
> > > > current Amazon Linux with hibernation support .
> > > 
> > > <shudder>
> > > 
> > > > Ia??ve traced the problem to bmap(), used in generic_swapfile_activate
> > > > call, which returns 0 for blocks inside holes created by fallocate and
> > > > Dave Chinner confirmed it in a private email. Ia??m thinking about ways
> > > > to fix it, so far I see the following possibilities:
> > > > 
> > > > 1. Change bmap() to not return zeroes for blocks inside holes. But
> > > > this is an ABI change and it likely will break some obscure userspace
> > > > utility somewhere.
> > > 
> > > bmap is a horrible interface, let's leave it to wither and eventually go
> > > away.
> > > 
> > > > 2. Change generic_swap_activate to use a more modern interface, by
> > > > adding fiemap-like operation to address_space_operations with fallback
> > > > on bmap().
> > > 
> > > Probably the best idea, but see fs/iomap.c since we're basically leasing
> > > a chunk of file space to the kernel.  Leasing space to a user that wants
> > > direct access is becoming rather common (rdma, map_sync, etc.)
> > 
> > thing is, we don't want in-kernel users of fiemap. We've got other
> > block mapping interfaces that can be used, such as iomap...
> 
> Well yes, I was clumsily trying to suggest reimplementing
> generic_swap_activate with an iomap backend replacing/augmenting the old
> get_blocks thing... :)
> 
> > > > 3. Add an XFS-specific implementation of swapfile_activate.
> > > 
> > > Ugh no.
> > 
> > What we want is an iomap-based re-implementation of
> > generic_swap_activate(). One of the ways to plumb that in is to
> > use ->swapfile_activate() like so:
> 
> Is this distinct from the ->swap_activate function pointer in
> address_operations or a new one?  I think it'd be best to have it be a
> separate callback like you suggest:

No, we don't need to create a new one - the existing one is used by
a single caller and we can easily move all the functionality it
requires inside the NFS specific implementation - it's just mapping
the entire range as a single extent, but the callout is needed to
mark the sockets backing the file as in the memalloc path...

> > iomap_swapfile_activate()
> > {
> > 	return iomap_apply(... iomap_swapfile_add_extent, ...)
> > }
> > 
> > xfs_vm_swapfile_activate()
> > {
> > 	return iomap_swapfile_activate(xfs_iomap_ops);
> > }
> > 
> > 	.swapfile_activate = xfs_vm_swapfile_activate()
> > 
> > And massage the swapfile_activate callout be friendly to fragmented
> > files. i.e. change the nfs caller to run a
> > "add_single_swap_extent()" caller rather than have to do it in the
> > generic code on return....
> 
> But ugh, the names are confusing.  ->swapfile_activate, ->swap_activate,
> and generic_swapfile_activate.  Not sure what's needed to clean up the
> other filesystems to use a single mapping interface, though.

If they don't implement the callout, they use the
generic_swapfile_activate code that currently exists. Maybe with a
name change, but this way we don't have to touch them....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
